"
I render a tree of `CMarkNode`s as one `RSComposite` whose model is the node: a document gives the whole page (padding, background, footnote definitions last under a thin rule), any other node renders alone at `maxWidth`.

```smalltalk
(CMark parse: '# Hello *world*') asRoassalShape.
CMarkRoassalRenderer new
	theme: CMarkRoassalTheme dark;
	maxWidth: 480;
	render: aNode.
(CMarkRoassalRenderer new canvasFor: aDocument) open.
```

## Blocks

Every visit answers a `CMarkRoassalBlock`: an `RSComposite` whose top-left is its local `0@0` and whose first child is a transparent frame box (`0@0` to the available width @ the height, `noPaint`, model the node, property `#cmarkFrame`): it gives exact extents, backgrounds that span the column and a hit area.

Composites clip their children to their own rectangle, so a block composite never gets `extent:`, only `adjustToChildren`; the one clipping composite is a code block under the `codeWrap` `#clip` of the theme. My `visitNode:` (the default of every visit I do not override) answers the stacked blocks of the children, so no visit answers a node.

The context of a block (`CMarkRoassalContext`: available width, base style, list, bullet and quote depths, nesting) is passed down immutable and kept in my `context` only for one visit. Inline content is flattened by `CMarkInlineRunCollector` and laid out by `CMarkInlineFlow`. Measures are cached per rendering by `CMarkRoassalFonts` and dropped at the end of `render:`; the `LogicalFont`s are made once for the image.

## Budgets (`CMarkRoassalTheme`)

- Blocks deeper than `maxNesting` are rendered flat (their `cmarkRoassalFlatText` in a muted paragraph);
- when `maxShapes` shapes exist, no more blocks are made, nor lines of code, of raw HTML or of inline text, nor table rows (a block always gets its first line or row), and the page ends with one muted paragraph 'N more blocks not shown', where N counts the blocks left out, the footnote definitions among them, and one for each block cut short;
- a table of more than `maxTableCells` cells is a placeholder.

## Interactions

Every piece inside a link (labels, code chips, images) and every footnote reference shares one `RSPopup` and has a click subscription made with `when:do:for:` (never the deprecated `when:do:`, which rewrites the sender at run time).

A click on an anchor link (`#slug`) or on a footnote reference moves the camera of the canvas to the heading or the definition; other links go to the `linkAction` of the theme.

`canvasFor:` fits the width and shows the top of the document instead of zooming to fit.
"
Class {
	#name : 'CMarkRoassalRenderer',
	#superclass : 'CMarkVisitor',
	#instVars : [
		'theme',
		'maxWidth',
		'fonts',
		'context',
		'shapeCount',
		'footnotes',
		'popup',
		'baseDirectory',
		'targets',
		'skipped',
		'hardBreaks',
		'markerColumns',
		'footnoteColumns'
	],
	#category : 'CMark-Roassal-Rendering',
	#package : 'CMark-Roassal',
	#tag : 'Rendering'
}

{ #category : 'instance creation' }
CMarkRoassalRenderer class >> theme: aTheme [
	^ self new
		  theme: aTheme;
		  yourself
]

{ #category : 'interactions' }
CMarkRoassalRenderer >> attachInteractionsTo: aShape target: aNodeOrNil [
	"Give aShape the shared popup and, when aNodeOrNil is a link or a footnote reference, a click that follows it"

	| shapesByNode |
	aShape @ popup.
	aNodeOrNil ifNil: [ ^ self ].
	shapesByNode := targets.
	aShape
		when: RSMouseLeftClick
		do: [ :event | aNodeOrNil cmarkRoassalFollowIn: self targets: shapesByNode canvas: event canvas ]
		for: self
]

{ #category : 'accessing' }
CMarkRoassalRenderer >> baseDirectory [
	"The directory against which relative image urls are resolved, or nil"

	^ baseDirectory
]

{ #category : 'accessing' }
CMarkRoassalRenderer >> baseDirectory: aFileReferenceOrNil [
	baseDirectory := aFileReferenceOrNil
]

{ #category : 'rendering' }
CMarkRoassalRenderer >> beginRendering: aNode [
	| document |
	fonts := CMarkRoassalFonts new.
	shapeCount := 0.
	skipped := 0.
	targets := IdentityDictionary new.
	markerColumns := IdentityDictionary new.
	footnoteColumns := IdentityDictionary new.
	footnotes := IdentityDictionary new.
	popup := RSPopup text: [ :model | model cmarkRoassalPopupText ].
	document := aNode root.
	hardBreaks := [ document options hardBreaks ]
		              on: Error
		              do: [ :e | false ]
]

{ #category : 'blocks' }
CMarkRoassalRenderer >> block: aNode shapes: aCollection width: aWidth height: aHeight baseline: aBaseline natural: aNaturalWidth min: aMinWidth [
	"The block of aNode: a composite of a frame (0@0 to aWidth @ aHeight) and the shapes of aCollection, placed in local coordinates"

	^ CMarkRoassalBlock
		  shape: (self composite: aCollection frame: aWidth @ aHeight node: aNode)
		  firstBaseline: aBaseline
		  naturalWidth: aNaturalWidth
		  minWidth: aMinWidth
		  height: aHeight
]

{ #category : 'blocks' }
CMarkRoassalRenderer >> blockFor: aNode in: aContext [
	"Visit aNode in aContext (flat beyond maxNesting); answer its CMarkRoassalBlock"

	| saved |
	aContext nesting > theme maxNesting ifTrue: [ ^ self flatBlockFor: aNode in: aContext ].
	saved := context.
	context := aContext.
	^ [ aNode acceptCMarkVisitor: self ] ensure: [ context := saved ]
]

{ #category : 'shapes' }
CMarkRoassalRenderer >> boxFrom: aPoint to: anotherPoint color: aColor node: aNode [
	"A box of aColor from aPoint to anotherPoint"

	self noteShapes: 1.
	^ RSBox new
		  fromRectangle: (aPoint corner: anotherPoint);
		  color: aColor;
		  model: aNode;
		  yourself
]

{ #category : 'budgets' }
CMarkRoassalRenderer >> budgetedLines: aCollection [
	"The first lines of aCollection that the shape budget still allows, one label each but for the empty ones, and always the first; a block cut short counts as one block not shown"

	| left |
	left := theme maxShapes - shapeCount max: 1.
	aCollection doWithIndex: [ :each :i |
		each isEmpty ifFalse: [
			left = 0 ifTrue: [
				self skipBlocks: 1.
				^ aCollection first: i - 1 ].
			left := left - 1 ] ].
	^ aCollection
]

{ #category : 'list markers' }
CMarkRoassalRenderer >> bulletCircle: aSize color: aColor [
	^ RSEllipse new
		  size: aSize;
		  noPaint;
		  border: (RSBorder new
				   color: aColor;
				   width: 1;
				   yourself);
		  yourself
]

{ #category : 'list markers' }
CMarkRoassalRenderer >> bulletDisc: aSize color: aColor [
	^ RSEllipse new
		  size: aSize;
		  color: aColor;
		  yourself
]

{ #category : 'list markers' }
CMarkRoassalRenderer >> bulletMarkerFor: anItem baseline: aBaseline column: aColumn [
	"A drawn bullet (#disc, #circle or #square by the bullet-list depth) about a third of the ascent above aBaseline"

	| size shape |
	size := self bulletSize.
	shape := self
		         perform: ('bullet' , (theme bulletStyleAt: (context bulletDepth max: 1)) capitalized , ':color:') asSymbol
		         with: size
		         with: context baseStyle color.
	shape model: anItem.
	self noteShapes: 1.
	shape translateTo: aColumn - theme markerGap - (size / 2) @ (aBaseline - ((fonts ascentOf: context baseStyle) * 0.33)).
	^ { shape }
]

{ #category : 'list markers' }
CMarkRoassalRenderer >> bulletSize [
	"The diameter of a bullet"

	^ (fonts ascentOf: context baseStyle) * 0.34
]

{ #category : 'list markers' }
CMarkRoassalRenderer >> bulletSquare: aSize color: aColor [
	^ RSBox new
		  size: aSize * 0.9;
		  color: aColor;
		  yourself
]

{ #category : 'rendering' }
CMarkRoassalRenderer >> canvasFor: aNode [
	"An RSCanvas showing the rendering of aNode, with a canvas controller; the camera fits the width and shows the top (not zoomToFit, which makes tall documents unreadable)"

	| canvas |
	canvas := RSCanvas new.
	self show: aNode on: canvas.
	^ canvas
]

{ #category : 'tables' }
CMarkRoassalRenderer >> cellBlock: aCell flow: aFlow width: aWidth height: aHeight color: aColorOrNil [
	"The block of aCell: its bordered box, aWidth @ aHeight, and its content (aFlow, laid out already)"

	| pad shapes box |
	pad := theme cellPadding.
	shapes := OrderedCollection new.
	box := RSBox new
		       fromRectangle: (0 @ 0 corner: aWidth @ aHeight);
		       border: (RSBorder new
				        color: theme borderColor;
				        width: 1;
				        yourself);
		       model: aCell;
		       yourself.
	aColorOrNil
		ifNil: [ box noPaint ]
		ifNotNil: [ :color | box color: color ].
	self noteShapes: 1.
	shapes add: box.
	self translate: aFlow shapes by: pad into: shapes.
	^ self
		  block: aCell
		  shapes: shapes
		  width: aWidth
		  height: aHeight
		  baseline: pad y + aFlow firstBaseline
		  natural: aFlow naturalWidth + (2 * pad x)
		  min: aFlow minWidth + (2 * pad x)
]

{ #category : 'blocks' }
CMarkRoassalRenderer >> childBlocksOf: aCollection in: aContext [
	"The blocks of the nodes of aCollection in aContext, in order; when the shape budget is spent, the rest is counted as skipped"

	| blocks |
	blocks := OrderedCollection new.
	aCollection doWithIndex: [ :each :i |
		self isOverBudget ifTrue: [
			self skipBlocks: aCollection size - i + 1.
			^ blocks ].
		blocks add: (self blockFor: each in: aContext) ].
	^ blocks
]

{ #category : 'shapes' }
CMarkRoassalRenderer >> chipBox: anExtent first: isFirst last: isLast node: aNode [
	"The background box of the code chip of aNode, rounded at the outer ends of its code span only"

	| radius box |
	radius := anExtent y / 4.
	self noteShapes: 1.
	box := RSBox new
		       extent: anExtent;
		       color: theme codeBackground;
		       model: aNode;
		       yourself.
	(isFirst and: [ isLast ]) ifTrue: [ ^ box cornerRadius: radius ].
	isFirst ifTrue: [
		^ box cornerRadius: (RSCornerRadius new
				   left: radius;
				   yourself) ].
	isLast ifTrue: [
		^ box cornerRadius: (RSCornerRadius new
				   right: radius;
				   yourself) ].
	^ box
]

{ #category : 'shapes' }
CMarkRoassalRenderer >> chipPadding [
	"The padding of a code chip, horizontally @ vertically"

	^ (theme fontSize * 0.3) @ 1
]

{ #category : 'shapes' }
CMarkRoassalRenderer >> clippedComposite: aCollection extent: anExtent node: aNode [
	"A composite of the shapes of aCollection (in local coordinates) that clips them to 0@0 corner: anExtent (the only composite given an extent)"

	| composite center |
	composite := self compositeOf: aCollection node: aNode.
	center := composite position.
	composite extent: anExtent.
	composite children do: [ :each | each translateBy: center - (anExtent / 2) ].
	composite translateTo: anExtent / 2.
	^ composite
]

{ #category : 'code' }
CMarkRoassalRenderer >> codeLines: aCollection style: aStyle width: aWidth [
	"The lines of aCollection broken by characters to fit aWidth in aStyle (codeWrap #characters)"

	| result |
	result := OrderedCollection new.
	aCollection do: [ :line |
		| start x |
		line isEmpty ifTrue: [ result add: line ].
		start := 1.
		x := 0.
		line doWithIndex: [ :each :i |
			| w |
			w := fonts advanceOf: each in: aStyle.
			(x + w > aWidth and: [ i > start ]) ifTrue: [
				result add: (line copyFrom: start to: i - 1).
				start := i.
				x := 0 ].
			x := x + w ].
		line isEmpty ifFalse: [ result add: (line copyFrom: start to: line size) ] ].
	^ result
]

{ #category : 'shapes' }
CMarkRoassalRenderer >> composite: aCollection frame: anExtent node: aNode [
	"An RSComposite whose model is aNode: a transparent frame box from 0@0 to anExtent, then the shapes of aCollection (in local coordinates); adjusted to its children, so that its top-left is 0@0 of its parent until it is moved"

	| frame |
	frame := RSBox new
		         fromRectangle: (0 @ 0 corner: anExtent);
		         noPaint;
		         model: aNode;
		         yourself.
	frame propertyAt: #cmarkFrame put: true.
	self noteShapes: 1.
	^ self compositeOf: (Array with: frame) , aCollection asArray node: aNode
]

{ #category : 'shapes' }
CMarkRoassalRenderer >> compositeOf: aCollection node: aNode [
	"An RSComposite of the shapes of aCollection (in local coordinates) whose model is aNode, adjusted once to its children"

	| composite |
	composite := RSComposite new.
	composite addAll: aCollection.
	composite model: aNode.
	composite adjustToChildren.
	"adjustToChildren moves the points of lines (the tick of a task) without dropping their cached rectangle"
	composite children do: [ :each | each resetEncompassingRectangle ].
	self noteShapes: 1.
	^ composite
]

{ #category : 'accessing' }
CMarkRoassalRenderer >> context [
	"The context of the block being visited"

	^ context
]

{ #category : 'blocks' }
CMarkRoassalRenderer >> emptyBlock: aNode [
	"A block that takes no vertical space"

	^ self
		  block: aNode
		  shapes: #(  )
		  width: context availableWidth
		  height: 0
		  baseline: 0
		  natural: 0
		  min: 0
]

{ #category : 'rendering' }
CMarkRoassalRenderer >> endRendering [
	fonts reset
]

{ #category : 'code' }
CMarkRoassalRenderer >> expandTabs: aString [
	"aString with each TAB replaced by the spaces up to the next multiple of 4 columns"

	| column |
	(aString includes: Character tab) ifFalse: [ ^ aString ].
	column := 0.
	^ String streamContents: [ :stream |
		  aString do: [ :each |
			  each = Character tab
				  ifTrue: [
					  stream next: 4 - (column \\ 4) put: Character space.
					  column := column + 4 - (column \\ 4) ]
				  ifFalse: [
					  stream nextPut: each.
					  column := column + 1 ] ] ]
]

{ #category : 'camera' }
CMarkRoassalRenderer >> fitWidthAndTop: aShape in: aCanvas [
	"Set the camera of aCanvas so that aShape fills the width of the view and its top is at the top of the view"

	| rect extent scale camera |
	extent := aCanvas extent.
	(extent isNil or: [ extent x <= 0 or: [ extent y <= 0 ] ]) ifTrue: [ ^ self ].
	rect := aShape encompassingRectangle.
	rect width <= 0 ifTrue: [ ^ self ].
	scale := extent x / rect width.
	camera := aCanvas camera.
	camera scale: scale.
	camera translateTo: (camera positionFromSpace: rect center x @ (rect top + (extent y / 2 / scale))).
	aCanvas signalUpdate
]

{ #category : 'blocks' }
CMarkRoassalRenderer >> flatBlockFor: aNode in: aContext [
	"aNode, nested too deep, as its text in a muted paragraph (cmarkRoassalFlatText: its blocks a space apart)"

	| saved |
	saved := context.
	context := aContext.
	^ [
	  self
		  flowBlockForRuns: { (CMarkInlineRun
				   kind: #text
				   string: aNode cmarkRoassalFlatText
				   style: (aContext baseStyle withColor: theme mutedColor)
				   node: aNode) }
		  style: aContext baseStyle
		  node: aNode ] ensure: [ context := saved ]
]

{ #category : 'inline' }
CMarkRoassalRenderer >> flowBlockFor: aCollection style: aStyle node: aNode [
	"The block of the inline nodes of aCollection at the available width"

	^ self flowBlockForRuns: (self runsOf: aCollection style: aStyle) style: aStyle node: aNode
]

{ #category : 'inline' }
CMarkRoassalRenderer >> flowBlockForRuns: aCollection style: aStyle node: aNode [
	| flow width |
	width := context availableWidth.
	flow := CMarkInlineFlow renderer: self runs: aCollection baseStyle: aStyle.
	flow layoutWidth: width alignment: #left.
	^ self
		  block: aNode
		  shapes: flow shapes
		  width: width
		  height: flow height
		  baseline: flow firstBaseline
		  natural: flow naturalWidth
		  min: flow minWidth
]

{ #category : 'inline' }
CMarkRoassalRenderer >> flowFor: aCollection style: aStyle [
	"A CMarkInlineFlow of the inline nodes of aCollection, not laid out yet"

	^ CMarkInlineFlow renderer: self runs: (self runsOf: aCollection style: aStyle) baseStyle: aStyle
]

{ #category : 'interactions' }
CMarkRoassalRenderer >> followAnchor: aString targets: aDictionary canvas: aCanvas [
	"Move the camera of aCanvas to the heading whose anchor is aString, among the rendered nodes of aDictionary"

	aDictionary keysAndValuesDo: [ :node :shape |
		(node isHeading and: [ node anchor = aString ]) ifTrue: [ ^ self moveTo: shape in: aCanvas ] ]
]

{ #category : 'interactions' }
CMarkRoassalRenderer >> followUrl: aString [
	"A click on a link that does not point inside the document"

	theme linkAction value: aString
]

{ #category : 'accessing' }
CMarkRoassalRenderer >> fonts [
	"The CMarkRoassalFonts of the current rendering"

	^ fonts
]

{ #category : 'list markers' }
CMarkRoassalRenderer >> footnoteColumnOf: aFootnoteDefinition [
	"The marker column of aFootnoteDefinition and of the definitions beside it: listIndent, or more for wide ordinals; measured once per parent in a rendering"

	| parent |
	parent := aFootnoteDefinition parent.
	parent ifNil: [ ^ self footnoteColumnOfAll: { aFootnoteDefinition } ].
	^ footnoteColumns at: parent ifAbsentPut: [ self footnoteColumnOfAll: (parent children select: [ :each | each isFootnoteDefinition ]) ]
]

{ #category : 'list markers' }
CMarkRoassalRenderer >> footnoteColumnOfAll: aCollection [
	"The marker column of the footnote definitions of aCollection: listIndent, or the widest 'ordinal.' plus markerGap"

	^ theme listIndent max: theme markerGap
		  + (aCollection inject: 0 into: [ :max :each | max max: (fonts widthOf: each ordinal printString , '.' in: context baseStyle) ])
]

{ #category : 'inline' }
CMarkRoassalRenderer >> footnoteReferenceRun: aFootnoteReference style: aStyle [
	"A raised label [n] that follows aFootnoteReference to its definition"

	| style |
	style := (((aStyle withSize: aStyle size * theme superscriptScale) withRaise:
		           (fonts ascentOf: aStyle) * theme superscriptRaise) withColor: theme linkColor) withLink:
		         aFootnoteReference.
	^ CMarkInlineRun
		  kind: #text
		  string: '[' , aFootnoteReference ordinal printString , ']'
		  style: style
		  node: aFootnoteReference
]

{ #category : 'accessing' }
CMarkRoassalRenderer >> hardBreaks [
	"Whether the document of the current rendering was parsed with hardBreaks: its soft breaks are line breaks"

	^ hardBreaks ifNil: [ false ]
]

{ #category : 'html' }
CMarkRoassalRenderer >> htmlBlockBasic: aHtmlBlock [
	"The text of the raw HTML as muted lines: comments gone, <br> and block tags break the line, <img> an image"

	| tokens collector runs style |
	tokens := self tokensOfHtmlBlock: aHtmlBlock literal.
	tokens isEmpty ifTrue: [ ^ self emptyBlock: aHtmlBlock ].
	style := context baseStyle withColor: theme mutedColor.
	collector := CMarkInlineRunCollector renderer: self.
	runs := collector beginWithStyle: style width: context availableWidth.
	tokens do: [ :each | collector perform: each first with: each with: aHtmlBlock ].
	^ self flowBlockForRuns: runs style: context baseStyle node: aHtmlBlock
]

{ #category : 'html' }
CMarkRoassalRenderer >> htmlBlockHide: aHtmlBlock [
	^ self emptyBlock: aHtmlBlock
]

{ #category : 'html' }
CMarkRoassalRenderer >> htmlBlockLiteral: aHtmlBlock [
	"The raw HTML as muted mono lines, broken by characters at the available width (unlike code, raw HTML never overflows)"

	| style lines |
	style := self monoStyleFrom: (context baseStyle withColor: theme mutedColor).
	lines := aHtmlBlock literal lines collect: [ :each | self singleLine: (self expandTabs: each) trimRight ].
	^ self
		  linesBlock: (self codeLines: lines style: style width: context availableWidth)
		  style: style
		  node: aHtmlBlock
]

{ #category : 'inline' }
CMarkRoassalRenderer >> imageRunForUrl: aUrl alt: anAlt style: aStyle node: aNode width: aWidth [
	"An atom showing the image of aUrl (scaled down to aWidth), or a dashed placeholder [image: anAlt]"

	| form shape ascent |
	form := [ theme imageResolver value: aUrl value: baseDirectory ]
		        on: Error
		        do: [ :e | nil ].
	form
		ifNil: [
			| label box text pad |
			text := self singleLine: '[image: ' , anAlt , ']'.
			label := self labelFor: text style: (((aStyle withColor: theme mutedColor) withUnderline: false) withStrike: false) node: aNode.
			pad := 4 @ 2.
			box := RSBox new
				       extent: label width + (2 * pad x) @ (label height + (2 * pad y));
				       noPaint;
				       border: (RSBorder new
						        color: theme borderColor;
						        width: 1;
						        dashArray: #( 4 2 );
						        yourself);
				       model: aNode;
				       yourself.
			self noteShapes: 1.
			shape := self compositeOf: { box. label } node: aNode.
			ascent := pad y + (fonts ascentOf: aStyle) ]
		ifNotNil: [
			shape := RSBitmap new
				         form: form;
				         model: aNode;
				         yourself.
			form width > aWidth ifTrue: [ shape extent: aWidth @ (form height * aWidth / form width) ].
			self noteShapes: 1.
			ascent := shape height ].
	self attachInteractionsTo: shape target: aStyle link.
	^ CMarkInlineRun atom: shape ascent: ascent style: aStyle node: aNode
]

{ #category : 'initialization' }
CMarkRoassalRenderer >> initialize [
	super initialize.
	theme := CMarkRoassalTheme default.
	fonts := CMarkRoassalFonts new.
	shapeCount := 0.
	skipped := 0.
	targets := IdentityDictionary new.
	markerColumns := IdentityDictionary new.
	footnoteColumns := IdentityDictionary new.
	hardBreaks := false
]

{ #category : 'inline' }
CMarkRoassalRenderer >> inlineBlock: anInlineNode [
	"An inline node rendered alone: a paragraph of it"

	^ self flowBlockFor: { anInlineNode } style: context baseStyle node: anInlineNode
]

{ #category : 'budgets' }
CMarkRoassalRenderer >> isOverBudget [
	"Whether the shapes made so far reached maxShapes: the blocks, lines and table rows that follow are not shown"

	^ shapeCount >= theme maxShapes
]

{ #category : 'lists' }
CMarkRoassalRenderer >> itemBlock: anItem [
	"The block of anItem: the marker column, then its children; the marker sits on the first baseline"

	| list column tight blocks shapes result baseline height markerShapes |
	list := (markerColumns includesKey: anItem parent) ifTrue: [ anItem parent ].
	column := list
		          ifNil: [ self markerColumnFor: nil items: { anItem } ]
		          ifNotNil: [ markerColumns at: list ].
	tight := list isNil or: [ list isTight ].
	blocks := self childBlocksOf: anItem children in: (context withAvailableWidth: (self width: context availableWidth less: column)) nested.
	shapes := OrderedCollection new.
	result := self
		          stack: blocks
		          gap: (tight
				           ifTrue: [ theme tightGap ]
				           ifFalse: [ theme blockGap ])
		          into: shapes
		          at: column.
	baseline := result second ifNil: [ fonts ascentOf: context baseStyle ].
	markerShapes := self markerShapesFor: anItem list: list baseline: baseline column: column.
	shapes addAllFirst: markerShapes.
	height := result first max: (fonts heightOf: context baseStyle).
	^ self
		  block: anItem
		  shapes: shapes
		  width: context availableWidth
		  height: height
		  baseline: baseline
		  natural: column + (blocks inject: 0 into: [ :max :each | max max: each naturalWidth ])
		  min: column + (blocks inject: 0 into: [ :max :each | max max: each minWidth ])
]

{ #category : 'shapes' }
CMarkRoassalRenderer >> labelFor: aString style: aStyle node: aNode [
	"An RSLabel of the non-empty aString in aStyle whose model is aNode (set after the text: a label without text would take the model's printString)"

	| label |
	self noteShapes: 1.
	label := fonts labelFor: aString style: aStyle.
	label model: aNode.
	^ label
]

{ #category : 'code' }
CMarkRoassalRenderer >> lines: aCollection left: aLeft top: aTop lineHeight: aLineHeight reach: aRight above: aBottom [
	"Whether a line of the widths of aCollection, placed at aLeft from aTop and aLineHeight apart, that starts above aBottom ends right of aRight"

	aCollection doWithIndex: [ :each :i |
		aTop + (i - 1 * aLineHeight) < aBottom ifFalse: [ ^ false ].
		aLeft + each > aRight ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'code' }
CMarkRoassalRenderer >> linesBlock: aCollection style: aStyle node: aNode [
	"The lines of aCollection, one label each (none for an empty line), without a box, as many as the shape budget allows"

	| lines shapes lineHeight y |
	lines := self budgetedLines: aCollection.
	shapes := OrderedCollection new.
	lineHeight := fonts heightOf: aStyle.
	y := 0.
	lines do: [ :each |
		each isEmpty ifFalse: [
			| label |
			label := self labelFor: each style: aStyle node: aNode.
			label translateTo: label width / 2 @ (y + (label height / 2)).
			shapes add: label ].
		y := y + lineHeight ].
	^ self
		  block: aNode
		  shapes: shapes
		  width: context availableWidth
		  height: y
		  baseline: (fonts ascentOf: aStyle)
		  natural: (lines inject: 0 into: [ :max :each | max max: (fonts widthOf: each in: aStyle) ])
		  min: 0
]

{ #category : 'inline' }
CMarkRoassalRenderer >> linkStyleFrom: aStyle link: aLink [
	"The style of the text of aLink"

	^ ((aStyle withColor: theme linkColor) withUnderline: true) withLink: aLink
]

{ #category : 'list markers' }
CMarkRoassalRenderer >> markerColumnFor: aListOrNil items: aCollection [
	"The width of the marker column of a list: listIndent, or more for wide markers"

	| widest style |
	style := context baseStyle.
	widest := (aListOrNil notNil and: [ aListOrNil isOrdered ])
		          ifTrue: [ fonts widthOf: (self markerTextFor: aListOrNil index: aCollection size) in: style ]
		          ifFalse: [ self bulletSize ].
	(aCollection anySatisfy: [ :each | each isTask ]) ifTrue: [ widest := widest max: self taskBoxSize ].
	^ theme listIndent max: widest + theme markerGap
]

{ #category : 'list markers' }
CMarkRoassalRenderer >> markerShapesFor: anItem list: aListOrNil baseline: aBaseline column: aColumn [
	"The shapes of the marker of anItem: a checkbox for a task, a number for an ordered list, else a bullet"

	anItem isTask ifTrue: [ ^ self taskMarkerFor: anItem baseline: aBaseline column: aColumn ].
	(aListOrNil notNil and: [ aListOrNil isOrdered ]) ifTrue: [
		^ self textMarker: (self markerTextFor: aListOrNil index: anItem indexInParent) for: anItem baseline: aBaseline column: aColumn ].
	^ self bulletMarkerFor: anItem baseline: aBaseline column: aColumn
]

{ #category : 'list markers' }
CMarkRoassalRenderer >> markerTextFor: aList index: anInteger [
	"The marker of the item anInteger of the ordered aList: its number and its delimiter"

	^ (aList start + anInteger - 1) printString , (aList delimiter = #paren
		   ifTrue: [ ')' ]
		   ifFalse: [ '.' ])
]

{ #category : 'accessing' }
CMarkRoassalRenderer >> maxWidth [
	"The width of the content of a document (the theme's unless set)"

	^ maxWidth ifNil: [ theme maxWidth ]
]

{ #category : 'accessing' }
CMarkRoassalRenderer >> maxWidth: aNumber [
	maxWidth := aNumber
]

{ #category : 'inline' }
CMarkRoassalRenderer >> monoStyleFrom: aStyle [
	"The style of code inside text of aStyle"

	^ ((aStyle withFamily: theme monoFamily) withSize: aStyle size * theme monoScale) withMono: true
]

{ #category : 'camera' }
CMarkRoassalRenderer >> moveTo: aShapeOrNil in: aCanvas [
	"Move the camera of aCanvas, keeping its scale, so that the top of aShapeOrNil is near the top of the view"

	| rect camera scale extent |
	(aShapeOrNil isNil or: [ aCanvas isNil ]) ifTrue: [ ^ self ].
	rect := aShapeOrNil globalEncompassingRectangle.
	camera := aCanvas camera.
	scale := camera scale.
	extent := aCanvas extent.
	camera translateTo: (camera positionFromSpace:
			 (camera fromPixelToSpace: extent / 2) x @ (rect top - (theme blockGap / scale) + (extent y / 2 / scale))).
	aCanvas signalUpdate
]

{ #category : 'rendering' }
CMarkRoassalRenderer >> mutedParagraph: aString node: aNode [
	"The shapes (no frame) of aString in a muted paragraph, in local coordinates, and the flow"

	| flow |
	flow := CMarkInlineFlow
		        renderer: self
		        runs: { (CMarkInlineRun
				         kind: #text
				         string: aString
				         style: (context baseStyle withColor: theme mutedColor)
				         node: aNode) }
		        baseStyle: context baseStyle.
	flow budgeted: false.
	flow layoutWidth: context availableWidth alignment: #left.
	^ flow
]

{ #category : 'shapes' }
CMarkRoassalRenderer >> noteShapes: anInteger [
	shapeCount := shapeCount + anInteger
]

{ #category : 'accessing' }
CMarkRoassalRenderer >> popup [
	"The RSPopup shared by every interactive piece of the current rendering"

	^ popup
]

{ #category : 'rendering' }
CMarkRoassalRenderer >> render: aNode [
	"An RSComposite showing aNode, whose model is aNode: a whole page for a document, else aNode alone at maxWidth"

	| block |
	self beginRendering: aNode.
	^ [
	  block := self blockFor: aNode in: (CMarkRoassalContext width: self maxWidth style: theme baseStyle).
	  block shape ] ensure: [ self endRendering ]
]

{ #category : 'inline' }
CMarkRoassalRenderer >> runsOf: aCollection style: aStyle [
	^ (CMarkInlineRunCollector renderer: self) collect: aCollection style: aStyle width: context availableWidth
]

{ #category : 'accessing' }
CMarkRoassalRenderer >> shapeCount [
	"The number of shapes made by the current (or last) rendering"

	^ shapeCount
]

{ #category : 'rendering' }
CMarkRoassalRenderer >> show: aNode on: aCanvas [
	"Add the rendering of aNode to aCanvas (an empty canvas, such as the one of an SpRoassalPresenter), in the background of the theme and with a canvas controller (zoom and pan); the camera fits the width and shows the top now and whenever the extent of aCanvas changes (not zoomToFit, which makes tall documents unreadable).  Answer the RSComposite of aNode"

	| shape controller |
	shape := self render: aNode.
	theme background ifNotNil: [ :color | aCanvas color: color ].
	aCanvas add: shape.
	controller := RSCanvasController new.
	(controller interactions at: RSZoomToFitCanvasInteraction ifAbsent: [ nil ]) ifNotNil: [ :zoom | zoom noZoomToFitOnStart ].
	aCanvas @ controller.
	aCanvas when: RSExtentChangedEvent do: [ :event | self fitWidthAndTop: shape in: aCanvas ] for: self.
	self fitWidthAndTop: shape in: aCanvas.
	^ shape
]

{ #category : 'shapes' }
CMarkRoassalRenderer >> singleLine: aString [
	"aString with its blanks (TAB, CR, LF) made spaces, for a label"

	^ aString collect: [ :each |
		  (each = Character tab or: [ each = Character cr or: [ each = Character lf ] ])
			  ifTrue: [ Character space ]
			  ifFalse: [ each ] ]
]

{ #category : 'budgets' }
CMarkRoassalRenderer >> skipBlocks: anInteger [
	"Count anInteger more blocks (or rests of blocks cut short) as not shown"

	skipped := skipped + anInteger
]

{ #category : 'blocks' }
CMarkRoassalRenderer >> stack: aCollection gap: aGap into: shapes at: x [
	"Place the blocks of aCollection one under the other at x, aGap apart (no gap around an empty block); add their shapes to shapes; answer { height. first baseline or nil }"

	| y baseline placed |
	y := 0.
	baseline := nil.
	placed := false.
	aCollection do: [ :each |
		(placed and: [ each isEmpty not ]) ifTrue: [ y := y + aGap ].
		each shape translateBy: x @ y.
		shapes add: each shape.
		(baseline isNil and: [ each isEmpty not ]) ifTrue: [ baseline := y + each firstBaseline ].
		y := y + each height.
		each isEmpty ifFalse: [ placed := true ] ].
	^ { y. baseline }
]

{ #category : 'blocks' }
CMarkRoassalRenderer >> stackedBlock: aNode children: aCollection context: aContext gap: aGap [
	"The block of aNode made of the blocks of aCollection stacked at the left"

	| blocks shapes result |
	blocks := self childBlocksOf: aCollection in: aContext.
	shapes := OrderedCollection new.
	result := self stack: blocks gap: aGap into: shapes at: 0.
	^ self
		  block: aNode
		  shapes: shapes
		  width: context availableWidth
		  height: result first
		  baseline: (result second ifNil: [ fonts ascentOf: context baseStyle ])
		  natural: (blocks inject: 0 into: [ :max :each | max max: each naturalWidth ])
		  min: (blocks inject: 0 into: [ :max :each | max max: each minWidth ])
]

{ #category : 'tables' }
CMarkRoassalRenderer >> tableBlock: aNode rowBlocks: aCollection widths: widths min: minWidths max: maxWidths [
	"The block of aNode made of the blocks of its rows: a row rendered alone answers its own block, a table (even of one row) wraps them in its own"

	| shapes y |
	(aCollection size = 1 and: [ aCollection first shape model == aNode ]) ifTrue: [ ^ aCollection first ].
	shapes := OrderedCollection new.
	y := 0.
	aCollection do: [ :each |
		each shape translateBy: 0 @ y.
		shapes add: each shape.
		y := y + each height ].
	^ self
		  block: aNode
		  shapes: shapes
		  width: (widths inject: 0 into: [ :sum :each | sum + each ])
		  height: y
		  baseline: (aCollection ifEmpty: [ fonts ascentOf: context baseStyle ] ifNotEmpty: [ aCollection first firstBaseline ])
		  natural: (maxWidths inject: 0 into: [ :sum :each | sum + each ])
		  min: (minWidths inject: 0 into: [ :sum :each | sum + each ])
]

{ #category : 'tables' }
CMarkRoassalRenderer >> tableBlock: aNode rows: aCollection alignments: anArray [
	"The block of aNode, a table (or a row alone), of the rows of aCollection: an automatic layout of the columns"

	| columns cellCount flows minWidths maxWidths widths rowBlocks bodyIndex |
	columns := aCollection inject: anArray size into: [ :max :each | max max: each children size ].
	cellCount := aCollection inject: 0 into: [ :sum :each | sum + each children size ].
	cellCount > theme maxTableCells ifTrue: [
		| flow |
		flow := self
			        mutedParagraph: 'table of ' , aCollection size printString , ' x ' , columns printString , ' cells not shown'
			        node: aNode.
		^ self
			  block: aNode
			  shapes: flow shapes
			  width: context availableWidth
			  height: flow height
			  baseline: flow firstBaseline
			  natural: flow naturalWidth
			  min: flow minWidth ].
	flows := aCollection collect: [ :row |
		         | style |
		         style := row isHeader
			                  ifTrue: [ context baseStyle withBold: true ]
			                  ifFalse: [ context baseStyle ].
		         row children collect: [ :cell | self flowFor: cell children style: style ] ].
	minWidths := Array new: columns withAll: 0.
	maxWidths := Array new: columns withAll: 0.
	flows do: [ :row |
		row doWithIndex: [ :flow :i |
			minWidths at: i put: ((minWidths at: i) max: flow minWidth).
			maxWidths at: i put: ((maxWidths at: i) max: flow naturalWidth) ] ].
	minWidths := minWidths collect: [ :each | each + (2 * theme cellPadding x) ].
	maxWidths := maxWidths collect: [ :each | each + (2 * theme cellPadding x) ].
	widths := self tableWidthsMin: minWidths max: maxWidths width: context availableWidth.
	bodyIndex := 0.
	rowBlocks := OrderedCollection new.
	aCollection doWithIndex: [ :row :r |
		| color |
		(r > 1 and: [ self isOverBudget ]) ifTrue: [
			self skipBlocks: 1.
			^ self tableBlock: aNode rowBlocks: rowBlocks widths: widths min: minWidths max: maxWidths ].
		color := row isHeader
			         ifTrue: [ theme tableHeaderBackground ]
			         ifFalse: [
				         bodyIndex := bodyIndex + 1.
				         bodyIndex even
					         ifTrue: [ theme tableZebra ]
					         ifFalse: [ theme background ] ].
		rowBlocks add: (self
				 tableRowBlock: row
				 flows: (flows at: r)
				 widths: widths
				 color: color
				 alignments: anArray) ].
	^ self tableBlock: aNode rowBlocks: rowBlocks widths: widths min: minWidths max: maxWidths
]

{ #category : 'tables' }
CMarkRoassalRenderer >> tableRowBlock: aRow flows: aCollection widths: anArray color: aColorOrNil alignments: anAlignmentArray [
	"The block of aRow: its cells side by side, as tall as the tallest"

	| height cellBlocks shapes x pad |
	pad := theme cellPadding.
	height := fonts heightOf: context baseStyle.
	aCollection doWithIndex: [ :flow :i |
		flow layoutWidth: (anArray at: i) - (2 * pad x) alignment: (anAlignmentArray at: i ifAbsent: [ nil ]).
		height := height max: flow height ].
	height := height + (2 * pad y).
	cellBlocks := aRow children withIndexCollect: [ :cell :i |
		              self
			              cellBlock: cell
			              flow: (aCollection at: i)
			              width: (anArray at: i)
			              height: height
			              color: aColorOrNil ].
	shapes := OrderedCollection new.
	x := 0.
	cellBlocks doWithIndex: [ :each :i |
		each shape translateBy: x @ 0.
		shapes add: each shape.
		x := x + (anArray at: i) ].
	^ self
		  block: aRow
		  shapes: shapes
		  width: (anArray inject: 0 into: [ :sum :each | sum + each ])
		  height: height
		  baseline: (cellBlocks
				   ifEmpty: [ pad y + (fonts ascentOf: context baseStyle) ]
				   ifNotEmpty: [ cellBlocks first firstBaseline ])
		  natural: 0
		  min: 0
]

{ #category : 'tables' }
CMarkRoassalRenderer >> tableWidthsMin: minWidths max: maxWidths width: aWidth [
	"The widths of the columns: their natural widths when they fit, else their minimum widths plus a share of the rest proportional to max - min, else their minimum widths (the table overflows)"

	| sumMin sumMax extra spread |
	sumMax := maxWidths inject: 0 into: [ :sum :each | sum + each ].
	sumMax <= aWidth ifTrue: [ ^ maxWidths copy ].
	sumMin := minWidths inject: 0 into: [ :sum :each | sum + each ].
	sumMin >= aWidth ifTrue: [ ^ minWidths copy ].
	extra := aWidth - sumMin.
	spread := sumMax - sumMin.
	^ minWidths withIndexCollect: [ :each :i | each + (extra * ((maxWidths at: i) - each) / spread) ]
]

{ #category : 'list markers' }
CMarkRoassalRenderer >> taskBoxSize [
	"The side of a task checkbox"

	^ (fonts ascentOf: context baseStyle) * 0.8
]

{ #category : 'list markers' }
CMarkRoassalRenderer >> taskMarkerFor: aTaskItem baseline: aBaseline column: aColumn [
	"A rounded checkbox, filled with a white tick when checked"

	| size center box shapes |
	size := self taskBoxSize.
	center := aColumn - theme markerGap - (size / 2) @ (aBaseline - ((fonts ascentOf: context baseStyle) * 0.35)).
	box := RSBox new
		       extent: size @ size;
		       cornerRadius: size * 0.2;
		       model: aTaskItem;
		       yourself.
	box translateTo: center.
	shapes := OrderedCollection with: box.
	aTaskItem isChecked
		ifTrue: [
			box color: theme linkColor.
			shapes add: (RSPolyline new
					 controlPoints: {
							 (center + ((size * -0.27) @ (size * 0.02))).
							 (center + ((size * -0.07) @ (size * 0.22))).
							 (center + ((size * 0.28) @ (size * -0.2))) };
					 color: Color white;
					 width: size * 0.14;
					 model: aTaskItem;
					 yourself) ]
		ifFalse: [
			box noPaint.
			box border: (RSBorder new
					 color: theme mutedColor;
					 width: 1;
					 yourself) ].
	self noteShapes: shapes size.
	^ shapes
]

{ #category : 'list markers' }
CMarkRoassalRenderer >> textMarker: aString for: aNode baseline: aBaseline column: aColumn [
	"A label of aString ending markerGap left of aColumn, on aBaseline"

	| label style |
	style := context baseStyle.
	label := self labelFor: aString style: style node: aNode.
	label translateTo: aColumn - theme markerGap - (fonts widthOf: aString in: style) + (label width / 2)
		@ (aBaseline - (fonts ascentOf: style) + (label height / 2)).
	^ { label }
]

{ #category : 'accessing' }
CMarkRoassalRenderer >> theme [
	^ theme
]

{ #category : 'accessing' }
CMarkRoassalRenderer >> theme: aTheme [
	theme := aTheme
]

{ #category : 'html' }
CMarkRoassalRenderer >> tokensOfHtmlBlock: aString [
	"The tokens of CMarkHtmlLite of a raw HTML block, with the blank texts next to breaks removed, the breaks collapsed and none at the ends"

	| tokens result |
	tokens := (CMarkHtmlLite tokensOf: aString) reject: [ :each |
		          each first = #htmlText:node: and: [ each second allSatisfy: [ :c | c isSeparator ] ] ].
	result := OrderedCollection new.
	tokens do: [ :each |
		(each first = #htmlBreak:node: and: [ result isEmpty or: [ result last first = #htmlBreak:node: ] ]) ifFalse: [
			result add: each ] ].
	[ result notEmpty and: [ result last first = #htmlBreak:node: ] ] whileTrue: [ result removeLast ].
	^ result
]

{ #category : 'shapes' }
CMarkRoassalRenderer >> translate: aCollection by: aPoint into: shapes [
	aCollection do: [ :each |
		each translateBy: aPoint.
		shapes add: each ]
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitBlockQuote: aBlockQuote [
	| inner quoteContext blocks shapes result height bar |
	inner := self width: context availableWidth less: theme quoteIndent.
	quoteContext := ((((context withAvailableWidth: inner) withBaseStyle:
		                   (context baseStyle withColor: theme mutedColor)) withQuoteDepth:
		                  context quoteDepth + 1) nested).
	blocks := self childBlocksOf: aBlockQuote children in: quoteContext.
	shapes := OrderedCollection new.
	result := self stack: blocks gap: theme blockGap into: shapes at: theme quoteIndent.
	height := result first max: (fonts heightOf: context baseStyle).
	bar := self boxFrom: 0 @ 0 to: theme quoteBarWidth @ height color: theme quoteBarColor node: aBlockQuote.
	bar cornerRadius: theme quoteBarWidth / 2.
	shapes addFirst: bar.
	^ self
		  block: aBlockQuote
		  shapes: shapes
		  width: context availableWidth
		  height: height
		  baseline: (result second ifNil: [ fonts ascentOf: context baseStyle ])
		  natural: theme quoteIndent + (blocks inject: 0 into: [ :max :each | max max: each naturalWidth ])
		  min: theme quoteIndent + (blocks inject: 0 into: [ :max :each | max max: each minWidth ])
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitCode: aCode [
	^ self inlineBlock: aCode
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitCodeBlock: aCodeBlock [
	"The lines on the box, and the info's first word small and muted at its top right; when a line beside that word would reach it, the code starts under it"

	| style lines widths pad lineHeight shapes top y textWidth boxWidth height box language label width |
	width := context availableWidth.
	style := self monoStyleFrom: context baseStyle.
	pad := theme codePadding.
	lines := aCodeBlock lines collect: [ :each | self singleLine: (self expandTabs: each) trimRight ].
	theme codeWrap = #characters ifTrue: [ lines := self codeLines: lines style: style width: width - (2 * pad) ].
	lines := self budgetedLines: lines.
	widths := lines collect: [ :each |
		          each isEmpty
			          ifTrue: [ 0 ]
			          ifFalse: [ fonts widthOf: each in: style ] ].
	textWidth := widths inject: 0 into: [ :max :each | max max: each ].
	lineHeight := fonts heightOf: style.
	boxWidth := theme codeWrap = #none
		            ifTrue: [ width max: textWidth + (2 * pad) ]
		            ifFalse: [ width ].
	shapes := OrderedCollection new.
	top := pad.
	language := aCodeBlock language.
	language ifNotNil: [
		label := self
			         labelFor: (self singleLine: language)
			         style: ((context baseStyle withSize: theme fontSize * 0.75) withColor: theme mutedColor)
			         node: aCodeBlock.
		label translateTo: boxWidth - (pad / 2) - (label width / 2) @ (2 + (label height / 2)).
		(self
			 lines: widths
			 left: pad
			 top: pad
			 lineHeight: lineHeight
			 reach: boxWidth - pad - label width
			 above: 2 + label height) ifTrue: [ top := pad max: 2 + label height + (pad / 2) ] ].
	y := top.
	lines do: [ :each |
		each isEmpty ifFalse: [
			| line |
			line := self labelFor: each style: style node: aCodeBlock.
			line translateTo: pad + (line width / 2) @ (y + (line height / 2)).
			shapes add: line ].
		y := y + lineHeight ].
	height := top + ((lines size max: 1) * lineHeight) + pad.
	box := self boxFrom: 0 @ 0 to: boxWidth @ height color: theme codeBackground node: aCodeBlock.
	box cornerRadius: theme cornerRadius.
	shapes addFirst: box.
	label ifNotNil: [ shapes add: label ].
	theme codeWrap = #clip ifTrue: [ shapes := { (self clippedComposite: shapes extent: boxWidth @ height node: aCodeBlock) } ].
	^ self
		  block: aCodeBlock
		  shapes: shapes
		  width: width
		  height: height
		  baseline: top + (fonts ascentOf: style)
		  natural: textWidth + (2 * pad)
		  min: textWidth + (2 * pad)
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitCustomInline: aCustomInline [
	^ self inlineBlock: aCustomInline
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitDocument: aDocument [
	"The page: the blocks stacked, the footnote definitions last under a thin rule, the padding and the background"

	| pad width definitions body blocks content result y baseline shapes height |
	pad := theme padding.
	width := context availableWidth.
	definitions := aDocument children select: [ :each | each isFootnoteDefinition ].
	body := aDocument children reject: [ :each | each isFootnoteDefinition ].
	blocks := self childBlocksOf: body in: context nested.
	content := OrderedCollection new.
	result := self stack: blocks gap: theme blockGap into: content at: 0.
	y := result first.
	baseline := result second.
	"the definitions follow the whole body only: when the budget cut it, they count as not shown"
	(definitions notEmpty and: [ skipped > 0 ]) ifTrue: [ self skipBlocks: definitions size ].
	(definitions notEmpty and: [ skipped = 0 ]) ifTrue: [
		| definitionBlocks definitionShapes |
		definitionBlocks := self
			                    childBlocksOf: definitions
			                    in: (context nested withBaseStyle: (context baseStyle withSize: theme fontSize * 0.9)).
		y > 0 ifTrue: [ y := y + theme blockGap ].
		content add: (self boxFrom: 0 @ y to: width @ (y + 1) color: theme borderColor node: aDocument).
		y := y + 1 + theme blockGap.
		definitionShapes := OrderedCollection new.
		result := self stack: definitionBlocks gap: theme tightGap into: definitionShapes at: 0.
		self translate: definitionShapes by: 0 @ y into: content.
		y := y + result first ].
	skipped > 0 ifTrue: [
		| flow |
		flow := self mutedParagraph: skipped printString , ' more blocks not shown' node: aDocument.
		y > 0 ifTrue: [ y := y + theme blockGap ].
		self translate: flow shapes by: 0 @ y into: content.
		y := y + flow height ].
	height := y + (2 * pad).
	shapes := OrderedCollection new.
	theme background ifNotNil: [ :color |
		shapes add: (self boxFrom: 0 @ 0 to: (width + (2 * pad)) @ height color: color node: aDocument) ].
	self translate: content by: pad @ pad into: shapes.
	^ self
		  block: aDocument
		  shapes: shapes
		  width: width + (2 * pad)
		  height: height
		  baseline: pad + (baseline ifNil: [ fonts ascentOf: context baseStyle ])
		  natural: (blocks inject: 0 into: [ :max :each | max max: each naturalWidth ]) + (2 * pad)
		  min: (blocks inject: 0 into: [ :max :each | max max: each minWidth ]) + (2 * pad)
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitEmph: anEmph [
	^ self inlineBlock: anEmph
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitFootnoteDefinition: aFootnoteDefinition [
	"A footnote definition as a list item whose marker is its ordinal"

	| column blocks shapes result baseline height block marker |
	column := self footnoteColumnOf: aFootnoteDefinition.
	blocks := self childBlocksOf: aFootnoteDefinition children in: (context withAvailableWidth: (self width: context availableWidth less: column)) nested.
	shapes := OrderedCollection new.
	result := self stack: blocks gap: theme tightGap into: shapes at: column.
	baseline := result second ifNil: [ fonts ascentOf: context baseStyle ].
	marker := self
		          textMarker: aFootnoteDefinition ordinal printString , '.'
		          for: aFootnoteDefinition
		          baseline: baseline
		          column: column.
	shapes addAllFirst: marker.
	height := result first max: (fonts heightOf: context baseStyle).
	block := self
		         block: aFootnoteDefinition
		         shapes: shapes
		         width: context availableWidth
		         height: height
		         baseline: baseline
		         natural: column + (blocks inject: 0 into: [ :max :each | max max: each naturalWidth ])
		         min: column + (blocks inject: 0 into: [ :max :each | max max: each minWidth ]).
	targets at: aFootnoteDefinition put: block shape.
	^ block
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitFootnoteReference: aFootnoteReference [
	^ self inlineBlock: aFootnoteReference
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitHeading: aHeading [
	| style flow shapes height width gap |
	width := context availableWidth.
	style := (context baseStyle withSize: theme fontSize * (theme headingScaleAt: aHeading level)) withBold: true.
	flow := self flowFor: aHeading children style: style.
	flow layoutWidth: width alignment: #left.
	shapes := OrderedCollection withAll: flow shapes.
	height := flow height.
	aHeading level <= 2 ifTrue: [
		gap := theme lineGap * 2.
		shapes add: (self
				 boxFrom: 0 @ (height + gap)
				 to: width @ (height + gap + theme headingRuleThickness)
				 color: theme borderColor
				 node: aHeading).
		height := height + gap + theme headingRuleThickness ].
	^ (self
		   block: aHeading
		   shapes: shapes
		   width: width
		   height: height
		   baseline: flow firstBaseline
		   natural: flow naturalWidth
		   min: flow minWidth) in: [ :block |
		  targets at: aHeading put: block shape.
		  block ]
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitHtmlBlock: aHtmlBlock [
	^ self perform: ('htmlBlock' , theme htmlStyle capitalized , ':') asSymbol with: aHtmlBlock
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitHtmlInline: aHtmlInline [
	^ self inlineBlock: aHtmlInline
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitImage: anImage [
	^ self inlineBlock: anImage
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitItem: anItem [
	^ self itemBlock: anItem
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitLineBreak: aLineBreak [
	^ self inlineBlock: aLineBreak
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitLink: aLink [
	^ self inlineBlock: aLink
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitList: aList [
	| listContext |
	listContext := (context withListDepth: context listDepth + 1) nested.
	aList isBullet ifTrue: [ listContext := listContext withBulletDepth: context bulletDepth + 1 ].
	markerColumns at: aList put: (self markerColumnFor: aList items: aList children).
	^ self
		  stackedBlock: aList
		  children: aList children
		  context: listContext
		  gap: (aList isTight
				   ifTrue: [ theme tightGap ]
				   ifFalse: [ theme blockGap ])
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitNode: aNode [
	"Any other node (custom and unknown blocks): its children stacked"

	^ self
		  stackedBlock: aNode
		  children: aNode children
		  context: context nested
		  gap: theme blockGap
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitParagraph: aParagraph [
	^ self flowBlockFor: aParagraph children style: context baseStyle node: aParagraph
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitSoftBreak: aSoftBreak [
	^ self inlineBlock: aSoftBreak
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitStrikethrough: aStrikethrough [
	^ self inlineBlock: aStrikethrough
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitStrong: aStrong [
	^ self inlineBlock: aStrong
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitTable: aTable [
	^ self tableBlock: aTable rows: aTable children alignments: aTable alignments
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitTableCell: aTableCell [
	"A cell alone: its content in its box at the available width"

	| flow pad |
	pad := theme cellPadding.
	flow := self flowFor: aTableCell children style: context baseStyle.
	flow layoutWidth: context availableWidth - (2 * pad x) alignment: aTableCell alignment.
	^ self
		  cellBlock: aTableCell
		  flow: flow
		  width: context availableWidth
		  height: flow height + (2 * pad y)
		  color: theme background
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitTableRow: aTableRow [
	"A row alone: laid out as a table of one row"

	^ self
		  tableBlock: aTableRow
		  rows: { aTableRow }
		  alignments: (aTableRow table
				   ifNil: [ #(  ) ]
				   ifNotNil: [ :table | table alignments ])
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitText: aText [
	^ self inlineBlock: aText
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitThematicBreak: aThematicBreak [
	| width |
	width := context availableWidth.
	^ self
		  block: aThematicBreak
		  shapes: { (self boxFrom: 0 @ 0 to: width @ theme ruleThickness color: theme borderColor node: aThematicBreak) }
		  width: width
		  height: theme ruleThickness
		  baseline: 0
		  natural: 0
		  min: 0
]

{ #category : 'visiting' }
CMarkRoassalRenderer >> visitUnknownInline: anUnknownInline [
	^ self inlineBlock: anUnknownInline
]

{ #category : 'blocks' }
CMarkRoassalRenderer >> width: aWidth less: anIndent [
	"The width left inside an indent: never less than twelve ems, so that deep nesting overflows to the right instead of breaking every word"

	^ aWidth - anIndent max: theme fontSize * 12
]
