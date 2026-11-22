"
I test the block layout rules: code blocks (tabs, the final line feed, codeWrap), tables (alignment, automatic widths, overflow, the cell budget), lists (ordered markers, wide starts, task boxes), headings, quotes nested deeper than maxNesting, the shape budget, images (placeholders, files relative to the base directory, scaling), raw HTML by htmlStyle, the font fallback, and the overflow cases of the width.
"
Class {
	#name : 'CMarkRoassalBlockTest',
	#superclass : 'CMarkRoassalTestCase',
	#category : 'CMark-Roassal-Tests-Tests',
	#package : 'CMark-Roassal-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkRoassalBlockTest >> list: aList items: aCollection [
	aCollection do: [ :each | aList addChild: (CMarkItem with: { (self paragraph: { (self text: each) }) }) ].
	^ aList
]

{ #category : 'helpers' }
CMarkRoassalBlockTest >> pngNamed: aString extent: aPoint in: aDirectory [
	"Write a PNG of aPoint to aDirectory / aString; answer the file"

	| form file |
	form := Form extent: aPoint depth: 32.
	form fillColor: Color orange.
	file := aDirectory / aString.
	PNGReadWriter putForm: form onFileNamed: file fullName.
	^ file
]

{ #category : 'helpers' }
CMarkRoassalBlockTest >> shapesOf: aShape satisfying: aBlock [
	| result |
	result := OrderedCollection new.
	self walk: aShape do: [ :each :rect :depth | (aBlock value: each) ifTrue: [ result add: each -> rect ] ].
	^ result
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testCodeBlockTabsAndFinalLineFeed [
	| block shape lines texts lineHeight |
	block := CMarkCodeBlock literal: 'a' , String tab , 'b' , String lf , String tab , 'c' , String lf , String lf , 'ab' , String tab , 'x' , String lf info: ''.
	shape := self render: (self document: { block }).
	texts := self texts: shape.
	self assert: texts equals: #( 'a   b' '    c' 'ab  x' ).
	lines := (self labelsOf: shape) collect: [ :each | each value top ].
	lineHeight := lines second - lines first.
	"the empty line takes one line, the final line feed none"
	self assert: (lines third - lines second - (2 * lineHeight)) abs < 0.01.
	self
		assert: ((self shapesOf: shape satisfying: [ :each | each class == RSBox and: [ each model == block and: [ each hasBorder not and: [ each paint notNil ] ] ] ]) first value height
			- (4 * lineHeight) - (2 * renderer theme codePadding)) abs
		< 0.01
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testCodeWrapModes [
	| block long padding none characters clip |
	long := String new: 200 withAll: $x.
	block := CMarkCodeBlock literal: long , String lf , 'short' , String lf info: 'text'.
	padding := CMarkRoassalTheme default padding.
	none := self render: (self document: { block }) theme: (CMarkRoassalTheme default codeWrap: #none; yourself).
	self assert: none encompassingRectangle width > (renderer maxWidth + (2 * padding)).
	characters := self render: (self document: { block }) theme: (CMarkRoassalTheme default codeWrap: #characters; yourself).
	self assert: characters encompassingRectangle width <= (renderer maxWidth + (2 * padding) + 0.01).
	self assert: (self texts: characters) size > 3.
	clip := self render: (self document: { block }) theme: (CMarkRoassalTheme default codeWrap: #clip; yourself).
	self assert: clip encompassingRectangle width <= (renderer maxWidth + (2 * padding) + 0.01).
	self assert: (self texts: clip) first equals: long.
	self should: [ CMarkRoassalTheme default codeWrap: #wrap ] raise: CMarkError
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testDeepQuotesRenderFlat [
	"2000 nested quotes: no stack overflow; beyond maxNesting the text is one muted paragraph"

	| node doc shape labels |
	node := self paragraph: { (self text: 'deep text') }.
	2000 timesRepeat: [ node := CMarkBlockQuote with: { node } ].
	doc := self document: { node }.
	shape := self render: doc.
	labels := self labelsOf: shape.
	self assert: (labels collect: [ :each | each key text ]) asArray equals: #( 'deep text' ).
	self assert: labels first key color equals: renderer theme mutedColor
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testEmptyHeadingHasOneLine [
	| shape |
	shape := self render: (CMarkHeading level: 3 with: #(  )).
	self assert: (shape extent y - (renderer fonts heightOf: ((renderer theme baseStyle withSize: renderer theme fontSize * 1.3) withBold: true))) abs < 0.01.
	self assert: (self labelsOf: shape) isEmpty
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testFlatRenderingKeepsTheBlocksApart [
	"Beyond maxNesting a block is one muted paragraph of the text of its blocks, a space apart, code included"

	| quote shape |
	quote := CMarkBlockQuote with: {
			         (self paragraph: { (self text: 'one') }).
			         (self paragraph: { (self text: 'two') }).
			         (CMarkCodeBlock literal: 'x := 1.' , String lf , 'y := 2.' , String lf info: '') }.
	shape := self render: (self document: { quote }) theme: (CMarkRoassalTheme default maxNesting: 0; yourself).
	self assert: (self texts: shape) equals: #( 'one two x := 1. y := 2.' )
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testFontFallback [
	"A missing family falls back to the default family of RSLabel at the size of the theme"

	| shape label |
	shape := self render: (self document: { (self paragraph: { (self text: 'fallback') }) }) theme: (CMarkRoassalTheme default
			          sansFamily: 'No Such Family CMark';
			          fontSize: 15;
			          yourself).
	label := (self labelsOf: shape) first key.
	self assert: label font familyName equals: RSLabel familyFontName.
	self assert: label font pointSize equals: 15
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testFootnoteDefinitionsTakeLinearTime [
	"The marker column of the footnote definitions is measured once, not once per definition: a thousand of them take about the time of a list of a thousand items"

	| n notes list notesTime listTime |
	n := 1000.
	notes := self document: ((1 to: n) collect: [ :i |
			          (CMarkFootnoteDefinition label: i printString)
				          ordinal: i;
				          addChild: (self paragraph: { (self text: 'note') });
				          yourself ]).
	list := self document: { (self list: (CMarkList ordered: 1) items: ((1 to: n) collect: [ :i | 'note' ])) }.
	self render: list.
	listTime := Time millisecondsToRun: [ self render: list ].
	notesTime := Time millisecondsToRun: [ self render: notes ].
	self assert: (self texts: (self render: notes)) size equals: 2 * n.
	self assert: notesTime <= ((5 * listTime) + 250) description: n printString , ' definitions took ' , notesTime printString , ' ms, a list of as many items ' , listTime printString , ' ms'
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testHeadingRules [
	| shape rules |
	#( 1 2 3 ) do: [ :level |
		shape := self render: (CMarkHeading level: level with: { (self text: 'Title') }).
		rules := self shapesOf: shape satisfying: [ :each | each class == RSBox and: [ each paint = renderer theme borderColor ] ].
		self assert: rules size equals: (level <= 2
				 ifTrue: [ 1 ]
				 ifFalse: [ 0 ]) ]
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testHtmlBasic [
	| doc shape |
	doc := self document: {
			       (self paragraph: {
					        (self text: 'one').
					        (CMarkHtmlInline literal: '<br>').
					        (self text: 'two ').
					        (CMarkHtmlInline literal: '<!-- hidden -->').
					        (CMarkHtmlInline literal: '<b>').
					        (self text: 'bold').
					        (CMarkHtmlInline literal: '</b>') }).
			       (CMarkHtmlBlock literal: '<div align="center">' , String lf , '  <p>Block <i>text</i></p>' , String lf , '  <!-- a comment -->' , String lf , '</div>' , String lf) }.
	shape := self render: doc.
	self assert: (self texts: shape) equals: #( 'one' 'two' 'bold' 'Block text' ).
	self assert: (self lineTopsOf: shape) size equals: 3
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testHtmlCommentBlockIsEmpty [
	| doc shape |
	doc := self document: { (self paragraph: { (self text: 'a') }). (CMarkHtmlBlock literal: '<!-- nothing -->' , String lf). (self paragraph: { (self text: 'b') }) }.
	shape := self render: doc.
	self assert: (self texts: shape) equals: #( 'a' 'b' ).
	self assert: ((self labelsOf: shape) second value top - (self labelsOf: shape) first value bottom - renderer theme blockGap) abs < 0.01
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testHtmlHideAndLiteral [
	| doc shape |
	doc := self document: {
			       (self paragraph: { (self text: 'x '). (CMarkHtmlInline literal: '<b>') }).
			       (CMarkHtmlBlock literal: '<div>block</div>' , String lf) }.
	shape := self render: doc theme: (CMarkRoassalTheme default htmlStyle: #hide; yourself).
	self assert: (self texts: shape) equals: #( 'x' ).
	shape := self render: doc theme: (CMarkRoassalTheme default htmlStyle: #literal; yourself).
	self assert: (self texts: shape) equals: #( 'x' '<b>' '<div>block</div>' ).
	self should: [ CMarkRoassalTheme default htmlStyle: #full ] raise: CMarkError
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testHtmlImage [
	| doc shape |
	doc := self document: { (CMarkHtmlBlock literal: '<p align="center"><img src="nothing.png" alt="the logo" width="10"></p>' , String lf) }.
	shape := self render: doc.
	self assert: (self texts: shape) equals: #( '[image: the logo]' )
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testImageFromBaseDirectory [
	self withTemporaryDirectory: [ :dir |
		| image doc shape bitmaps wide |
		self pngNamed: 'pic.png' extent: 40 @ 20 in: dir.
		self pngNamed: 'wide.png' extent: 2000 @ 100 in: dir.
		image := (CMarkImage url: 'pic.png' title: '') addAll: { (self text: 'picture') }; yourself.
		wide := (CMarkImage url: 'wide.png' title: '') addAll: { (self text: 'wide') }; yourself.
		doc := self document: { (self paragraph: { (self text: 'see '). image. (self text: ' and '). wide }) }.
		shape := self render: doc.
		self assert: (self texts: shape) equals: #( 'see' '[image: picture]' 'and' '[image: wide]' ).
		renderer := CMarkRoassalRenderer new baseDirectory: dir.
		shape := renderer render: doc.
		bitmaps := self shapesOf: shape satisfying: [ :each | each class == RSBitmap ].
		self assert: bitmaps size equals: 2.
		self assert: bitmaps first value extent equals: 40 @ 20.
		self assert: (bitmaps second value width - renderer maxWidth) abs < 0.01.
		self assert: (bitmaps second value height - (100 * renderer maxWidth / 2000)) abs < 0.01.
		self assert: shape encompassingRectangle width <= (renderer maxWidth + (2 * renderer theme padding) + 0.01) ]
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testImagePlaceholder [
	| image doc shape placeholder |
	image := (CMarkImage url: 'https://example.org/remote.png' title: '') addAll: { (self text: 'remote') }; yourself.
	doc := self document: { (self paragraph: { image }) }.
	shape := self render: doc.
	self assert: (self texts: shape) equals: #( '[image: remote]' ).
	placeholder := self shapesOf: shape satisfying: [ :each | each class == RSBox and: [ each model == image ] ].
	self assert: placeholder size equals: 1.
	self assert: placeholder first key border dashArray notNil
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testListBullets [
	| outer inner innermost doc shape bullets |
	outer := self list: CMarkList bullet items: #( 'one' ).
	inner := self list: CMarkList bullet items: #( 'two' ).
	innermost := self list: CMarkList bullet items: #( 'three' ).
	inner children first addChild: innermost.
	outer children first addChild: inner.
	doc := self document: { outer }.
	shape := self render: doc.
	bullets := self shapesOf: shape satisfying: [ :each |
		           (each model isKindOf: CMarkItem) and: [ each isLabel not and: [ each isComposite not and: [ (each propertyAt: #cmarkFrame ifAbsent: [ false ]) not ] ] ] ].
	self assert: (bullets collect: [ :each | each key class ]) asArray equals: { RSEllipse. RSEllipse. RSBox }.
	self assert: bullets first key paint notNil.
	self assert: bullets second key paint isNil
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testMaxShapes [
	| doc shape texts |
	doc := self document: ((1 to: 100) collect: [ :i | self paragraph: { (self text: 'paragraph ' , i printString) } ]).
	shape := self render: doc theme: (CMarkRoassalTheme default maxShapes: 60; yourself).
	texts := self texts: shape.
	self assert: texts size < 30.
	self assert: (texts last endsWith: 'more blocks not shown').
	self assert: texts last first isDigit
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testMaxTableCells [
	| table doc shape |
	table := CMarkTable alignments: #( nil nil nil ).
	1 to: 3 do: [ :r |
		table addChild: (CMarkTableRow with: ((1 to: 3) collect: [ :c | CMarkTableCell with: { (self text: 'x') } ])) ].
	doc := self document: { table }.
	shape := self render: doc theme: (CMarkRoassalTheme default maxTableCells: 4; yourself).
	self assert: (self texts: shape) equals: #( 'table of 3 x 3 cells not shown' )
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testOrderedMarkers [
	| list doc shape texts labels column |
	list := self list: (CMarkList ordered: 3) items: #( 'three' 'four' ).
	shape := self render: (self document: { list }).
	self assert: (self texts: shape) equals: #( '3.' 'three' '4.' 'four' ).
	list := self list: (CMarkList ordered: 7) items: #( 'seven' ).
	list delimiter: #paren.
	self assert: (self texts: (self render: list)) equals: #( '7)' 'seven' ).
	list := self list: (CMarkList ordered: 123456789) items: #( 'a' 'b' ).
	doc := self document: { list }.
	shape := self render: doc.
	labels := self labelsOf: shape.
	texts := labels collect: [ :each | each key text ].
	self assert: texts asArray equals: #( '123456789.' 'a' '123456790.' 'b' ).
	"the markers stay right of the padding and left of their content"
	column := (labels detect: [ :each | each key text = 'a' ]) value left.
	labels do: [ :each |
		(each key text endsWith: '.') ifTrue: [
			self assert: each value left >= (renderer theme padding - 0.01).
			self assert: each value right <= column ] ]
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testTableOverflowsWhenTheMinimumDoesNotFit [
	| table shape |
	table := CMarkTable alignments: #( nil nil ).
	table addChild: (CMarkTableRow with: {
				 (CMarkTableCell with: { (self text: (String new: 60 withAll: $a)) }).
				 (CMarkTableCell with: { (self text: (String new: 60 withAll: $b)) }) }).
	shape := self render: (self document: { table }) width: 300.
	self assert: shape encompassingRectangle width > (300 + (2 * renderer theme padding))
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testTables [
	"Right-aligned cells end at the right edge of their column minus the padding, centred cells are centred, and a short column keeps its widest word when the table must shrink"

	| table doc shape cells pad labels right centre |
	table := CMarkTable alignments: #( #left #center #right ).
	table addChild: (CMarkTableHeaderRow with: {
				 (CMarkTableCell with: { (self text: 'Name') }).
				 (CMarkTableCell with: { (self text: 'Centred heading') }).
				 (CMarkTableCell with: { (self text: 'Amount') }) }).
	table addChild: (CMarkTableRow with: {
				 (CMarkTableCell with: { (self text: 'x') }).
				 (CMarkTableCell with: { (self text: 'c') }).
				 (CMarkTableCell with: { (self text: '12.50') }) }).
	doc := self document: { table }.
	shape := self render: doc.
	pad := renderer theme cellPadding x.
	cells := self shapesOf: shape satisfying: [ :each | (each model isKindOf: CMarkTableCell) and: [ each propertyAt: #cmarkFrame ifAbsent: [ false ] ] ].
	self assert: cells size equals: 6.
	labels := self labelsOf: shape.
	right := labels detect: [ :each | each key text = '12.50' ].
	self assert: ((right value left + (renderer fonts widthOf: '12.50' in: renderer theme baseStyle)) - (cells last value right - pad)) abs < 0.01.
	centre := labels detect: [ :each | each key text = 'c' ].
	self
		assert: (centre value left + ((renderer fonts widthOf: 'c' in: renderer theme baseStyle) / 2) - (cells fifth value left + (cells fifth value width / 2))) abs
		< 0.01.
	"shrinking: the short column keeps its widest word, the long one wraps"
	table := CMarkTable alignments: #( nil nil ).
	table addChild: (CMarkTableRow with: {
				 (CMarkTableCell with: { (self text: 'Supercalifragilistic') }).
				 (CMarkTableCell with: { (self text: 'a long cell of many words that has to wrap inside its column') }) }).
	shape := self render: (self document: { table }) width: 240.
	labels := self labelsOf: shape.
	self assert: (labels select: [ :each | each key text = 'Supercalifragilistic' ]) size equals: 1.
	self assert: (self lineTopsOf: shape) size > 1.
	self assert: shape encompassingRectangle width <= (240 + (2 * renderer theme padding) + 0.01)
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testTaskBoxes [
	| list shape ticks |
	list := CMarkList bullet.
	list addChild: ((CMarkTaskItem checked: true) addAll: { (self paragraph: { (self text: 'done') }) }; yourself).
	list addChild: ((CMarkTaskItem checked: false) addAll: { (self paragraph: { (self text: 'open') }) }; yourself).
	shape := self render: (self document: { list }).
	ticks := self shapesOf: shape satisfying: [ :each | each class == RSPolyline ].
	self assert: ticks size equals: 1.
	self assert: ticks first key model identicalTo: list children first.
	self assert: (self shapesOf: shape satisfying: [ :each | each class == RSPolyline and: [ each model == list children second ] ]) isEmpty
]

{ #category : 'tests' }
CMarkRoassalBlockTest >> testWordOverflowAndBreakLongWords [
	| doc long shape |
	long := String new: 120 withAll: $w.
	doc := self document: { (self paragraph: { (self text: 'short ' , long) }) }.
	shape := self render: doc.
	self assert: shape encompassingRectangle width > (renderer maxWidth + (2 * renderer theme padding)).
	shape := self render: doc theme: (CMarkRoassalTheme default breakLongWords: true; yourself).
	self assert: shape encompassingRectangle width <= (renderer maxWidth + (2 * renderer theme padding) + 0.01).
	self assert: (self lineTopsOf: shape) size > 2
]

{ #category : 'helpers' }
CMarkRoassalBlockTest >> texts: aShape [
	^ ((self labelsOf: aShape) collect: [ :each | each key text ]) asArray
]
