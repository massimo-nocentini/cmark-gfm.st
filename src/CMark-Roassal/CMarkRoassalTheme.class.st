"
I am the theme of the Roassal rendering of Markdown (CMarkRoassalRenderer): fonts, sizes, colours, gaps, list and quote indents, code and table looks, the treatment of raw HTML and of long code lines, the budgets of the rendering (maxNesting, maxShapes, maxTableCells), what a click on a link does (linkAction) and how images are found (imageResolver).

CMarkRoassalTheme default is the light GitHub-like look; dark changes the colours; compact lowers the gaps.  Every parameter has an accessor and a setter, so a theme is built by sending setters to one of these:
	CMarkRoassalTheme default fontSize: 14; maxWidth: 480; yourself

The parameters: sansFamily; monoFamily; fontSize; headingScales; monoScale; textColor; mutedColor; linkColor; codeBackground; borderColor; quoteBarColor; tableHeaderBackground; tableZebra; background; maxWidth; padding; blockGap; tightGap; lineGap; listIndent; markerGap; quoteIndent; quoteBarWidth; codePadding; cornerRadius; cellPadding; ruleThickness; headingRuleThickness; bulletStyles; superscriptScale; superscriptRaise; htmlStyle; codeWrap; breakLongWords; maxNesting; maxShapes; maxTableCells; linkAction; imageResolver.
"
Class {
	#name : 'CMarkRoassalTheme',
	#superclass : 'Object',
	#instVars : [
		'sansFamily',
		'monoFamily',
		'fontSize',
		'headingScales',
		'monoScale',
		'textColor',
		'mutedColor',
		'linkColor',
		'codeBackground',
		'borderColor',
		'quoteBarColor',
		'tableHeaderBackground',
		'tableZebra',
		'background',
		'maxWidth',
		'padding',
		'blockGap',
		'tightGap',
		'lineGap',
		'listIndent',
		'markerGap',
		'quoteIndent',
		'quoteBarWidth',
		'codePadding',
		'cornerRadius',
		'cellPadding',
		'ruleThickness',
		'headingRuleThickness',
		'bulletStyles',
		'superscriptScale',
		'superscriptRaise',
		'htmlStyle',
		'codeWrap',
		'breakLongWords',
		'maxNesting',
		'maxShapes',
		'maxTableCells',
		'linkAction',
		'imageResolver'
	],
	#category : 'CMark-Roassal-Theme',
	#package : 'CMark-Roassal',
	#tag : 'Theme'
}

{ #category : 'instance creation' }
CMarkRoassalTheme class >> compact [
	"The default look with smaller gaps and paddings"

	^ self new
		  padding: 8;
		  blockGap: 6;
		  tightGap: 1;
		  lineGap: 1;
		  codePadding: 6;
		  cellPadding: 4 @ 2;
		  listIndent: 18;
		  quoteIndent: 12;
		  yourself
]

{ #category : 'instance creation' }
CMarkRoassalTheme class >> dark [
	"Light text on a dark background"

	^ self new
		  textColor: (Color gray: 0.9);
		  mutedColor: (Color gray: 0.62);
		  linkColor: (Color r: 0.35 g: 0.65 b: 1.0);
		  codeBackground: (Color gray: 0.17);
		  borderColor: (Color gray: 0.33);
		  quoteBarColor: (Color gray: 0.38);
		  tableHeaderBackground: (Color gray: 0.2);
		  tableZebra: (Color gray: 0.14);
		  background: (Color r: 0.05 g: 0.07 b: 0.09);
		  yourself
]

{ #category : 'instance creation' }
CMarkRoassalTheme class >> default [
	"The light look"

	^ self new
]

{ #category : 'images' }
CMarkRoassalTheme class >> formForUrl: aString baseDirectory: aFileReferenceOrNil [
	"A Form read from the local image file that aString names (an absolute path, a file: url, or a path relative to aFileReferenceOrNil), or nil: no other scheme, no network, only .png .jpg .jpeg .gif .bmp files that exist"

	| path file |
	path := aString trimBoth.
	(path beginsWith: 'file://') ifTrue: [ path := path allButFirst: 7 ].
	(path includesSubstring: '://') ifTrue: [ ^ nil ].
	(path isEmpty or: [ (self imageExtensions anySatisfy: [ :each | path asLowercase endsWith: each ]) not ]) ifTrue: [ ^ nil ].
	file := [
	        (path beginsWith: '/')
		        ifTrue: [ path asFileReference ]
		        ifFalse: [ aFileReferenceOrNil ifNotNil: [ :dir | dir asFileReference resolve: path ] ] ]
		        on: Error
		        do: [ :e | nil ].
	(file isNil or: [ file exists not or: [ file isFile not ] ]) ifTrue: [ ^ nil ].
	^ [ ImageReadWriter formFromFileNamed: file fullName ]
		  on: Error
		  do: [ :e | nil ]
]

{ #category : 'images' }
CMarkRoassalTheme class >> imageExtensions [
	^ #( '.png' '.jpg' '.jpeg' '.gif' '.bmp' )
]

{ #category : 'accessing' }
CMarkRoassalTheme >> background [
	"The background of a document, or nil for none (transparent)"

	^ background
]

{ #category : 'accessing' }
CMarkRoassalTheme >> background: anObject [
	background := anObject
]

{ #category : 'styles' }
CMarkRoassalTheme >> baseStyle [
	"The style of body text"

	^ CMarkInlineStyle family: sansFamily size: fontSize color: textColor
]

{ #category : 'accessing' }
CMarkRoassalTheme >> blockGap [
	"The space between blocks"

	^ blockGap
]

{ #category : 'accessing' }
CMarkRoassalTheme >> blockGap: anObject [
	blockGap := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> borderColor [
	"The colour of rules, table borders and placeholder borders"

	^ borderColor
]

{ #category : 'accessing' }
CMarkRoassalTheme >> borderColor: anObject [
	borderColor := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> breakLongWords [
	"Whether a word longer than its line breaks by characters (otherwise it overflows)"

	^ breakLongWords
]

{ #category : 'accessing' }
CMarkRoassalTheme >> breakLongWords: anObject [
	breakLongWords := anObject
]

{ #category : 'styles' }
CMarkRoassalTheme >> bulletStyleAt: aDepth [
	"The bullet of a bullet list at the bullet-list depth aDepth (1 for the outermost), cycling over bulletStyles"

	^ bulletStyles at: (aDepth - 1 max: 0) \\ bulletStyles size + 1
]

{ #category : 'accessing' }
CMarkRoassalTheme >> bulletStyles [
	"The bullets of bullet lists by bullet-list depth only (#disc, #circle, #square), cycling"

	^ bulletStyles
]

{ #category : 'accessing' }
CMarkRoassalTheme >> bulletStyles: anObject [
	bulletStyles := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> cellPadding [
	"The space between a table cell's border and its text, horizontally @ vertically"

	^ cellPadding
]

{ #category : 'accessing' }
CMarkRoassalTheme >> cellPadding: anObject [
	cellPadding := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> codeBackground [
	"The background of code blocks and code spans"

	^ codeBackground
]

{ #category : 'accessing' }
CMarkRoassalTheme >> codeBackground: anObject [
	codeBackground := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> codePadding [
	"The space between a code block's box and its text"

	^ codePadding
]

{ #category : 'accessing' }
CMarkRoassalTheme >> codePadding: anObject [
	codePadding := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> codeWrap [
	"What long code lines do: #none (they widen the box), #characters (they break by characters) or #clip (the box keeps the column width and clips them)"

	^ codeWrap
]

{ #category : 'accessing' }
CMarkRoassalTheme >> codeWrap: anObject [
	(#( #none #characters #clip ) includes: anObject) ifFalse: [ CMarkError signal: 'codeWrap must be one of ' , #( #none #characters #clip ) printString ].
	codeWrap := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> cornerRadius [
	"The corner radius of code blocks"

	^ cornerRadius
]

{ #category : 'accessing' }
CMarkRoassalTheme >> cornerRadius: anObject [
	cornerRadius := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> fontSize [
	"The size of the body text, in points"

	^ fontSize
]

{ #category : 'accessing' }
CMarkRoassalTheme >> fontSize: anObject [
	fontSize := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> headingRuleThickness [
	"The thickness of the rule under the headings of level 1 and 2"

	^ headingRuleThickness
]

{ #category : 'accessing' }
CMarkRoassalTheme >> headingRuleThickness: anObject [
	headingRuleThickness := anObject
]

{ #category : 'styles' }
CMarkRoassalTheme >> headingScaleAt: aLevel [
	"The size factor of a heading of level aLevel (clamped to 1..6)"

	^ headingScales at: ((aLevel max: 1) min: headingScales size)
]

{ #category : 'accessing' }
CMarkRoassalTheme >> headingScales [
	"The size of the headings of level 1 to 6, as factors of fontSize (headings are bold)"

	^ headingScales
]

{ #category : 'accessing' }
CMarkRoassalTheme >> headingScales: anObject [
	headingScales := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> htmlStyle [
	"How raw HTML shows: #basic (comments hidden, <br> a line break, <img src alt> an image or its placeholder, other tags stripped and their text kept), #literal (the raw HTML as muted mono text) or #hide.  HTML is never interpreted beyond that and never executed"

	^ htmlStyle
]

{ #category : 'accessing' }
CMarkRoassalTheme >> htmlStyle: anObject [
	(#( #basic #literal #hide ) includes: anObject) ifFalse: [ CMarkError signal: 'htmlStyle must be one of ' , #( #basic #literal #hide ) printString ].
	htmlStyle := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> imageResolver [
	"A block of two arguments, the url of an image and the base directory of the renderer (or nil), that answers a Form or nil (then a placeholder is shown).  The default reads local .png, .jpg, .jpeg, .gif and .bmp files only, never the network"

	^ imageResolver
]

{ #category : 'accessing' }
CMarkRoassalTheme >> imageResolver: anObject [
	imageResolver := anObject
]

{ #category : 'initialization' }
CMarkRoassalTheme >> initialize [
	super initialize.
	sansFamily := 'Source Sans Pro'.
	monoFamily := 'Source Code Pro'.
	fontSize := 12.
	headingScales := #( 2.0 1.6 1.3 1.1 1.0 0.9 ).
	monoScale := 0.9.
	textColor := Color black.
	mutedColor := Color gray: 0.45.
	linkColor := Color r: 0.03 g: 0.41 b: 0.85.
	codeBackground := Color gray: 0.96.
	borderColor := Color gray: 0.82.
	quoteBarColor := Color gray: 0.8.
	tableHeaderBackground := Color gray: 0.95.
	tableZebra := Color gray: 0.98.
	background := Color white.
	maxWidth := 640.
	padding := 16.
	blockGap := 10.
	tightGap := 3.
	lineGap := 3.
	listIndent := 22.
	markerGap := 6.
	quoteIndent := 16.
	quoteBarWidth := 4.
	codePadding := 10.
	cornerRadius := 6.
	cellPadding := 6 @ 4.
	ruleThickness := 3.
	headingRuleThickness := 1.
	bulletStyles := #( #disc #circle #square ).
	superscriptScale := 0.75.
	superscriptRaise := 0.35.
	htmlStyle := #basic.
	codeWrap := #none.
	breakLongWords := false.
	maxNesting := 64.
	maxShapes := 100000.
	maxTableCells := 10000.
	linkAction := [ :url | (Smalltalk globals at: #WebBrowser ifAbsent: [ nil ]) ifNotNil: [ :browser | browser openOn: url ] ].
	imageResolver := [ :url :baseDirectory | self class formForUrl: url baseDirectory: baseDirectory ]
]

{ #category : 'accessing' }
CMarkRoassalTheme >> lineGap [
	"The space between two lines of text"

	^ lineGap
]

{ #category : 'accessing' }
CMarkRoassalTheme >> lineGap: anObject [
	lineGap := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> linkAction [
	"A block of one argument, the url, evaluated by a click on a link that does not point inside the document"

	^ linkAction
]

{ #category : 'accessing' }
CMarkRoassalTheme >> linkAction: anObject [
	linkAction := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> linkColor [
	"The colour of links, footnote references and checked task boxes"

	^ linkColor
]

{ #category : 'accessing' }
CMarkRoassalTheme >> linkColor: anObject [
	linkColor := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> listIndent [
	"The minimum width of the marker column of a list (it widens for wide markers)"

	^ listIndent
]

{ #category : 'accessing' }
CMarkRoassalTheme >> listIndent: anObject [
	listIndent := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> markerGap [
	"The space between a list marker and the content of its item"

	^ markerGap
]

{ #category : 'accessing' }
CMarkRoassalTheme >> markerGap: anObject [
	markerGap := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> maxNesting [
	"The deepest nesting of blocks and of inlines that is rendered: deeper blocks are rendered flat (their plainText in a muted paragraph), deeper inlines stop changing the style"

	^ maxNesting
]

{ #category : 'accessing' }
CMarkRoassalTheme >> maxNesting: anObject [
	maxNesting := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> maxShapes [
	"When the renderer has made this many shapes, the rest of the document is one muted paragraph 'N more blocks not shown'"

	^ maxShapes
]

{ #category : 'accessing' }
CMarkRoassalTheme >> maxShapes: anObject [
	maxShapes := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> maxTableCells [
	"A table with more cells is a muted placeholder 'table of R x C cells not shown'"

	^ maxTableCells
]

{ #category : 'accessing' }
CMarkRoassalTheme >> maxTableCells: anObject [
	maxTableCells := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> maxWidth [
	"The width of the content of a document, in user units, without the padding"

	^ maxWidth
]

{ #category : 'accessing' }
CMarkRoassalTheme >> maxWidth: anObject [
	maxWidth := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> monoFamily [
	"The family of code, checked like sansFamily"

	^ monoFamily
]

{ #category : 'accessing' }
CMarkRoassalTheme >> monoFamily: anObject [
	monoFamily := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> monoScale [
	"The size of code, as a factor of the size of the text around it"

	^ monoScale
]

{ #category : 'accessing' }
CMarkRoassalTheme >> monoScale: anObject [
	monoScale := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> mutedColor [
	"The colour of block quotes, code block languages, raw HTML and placeholders"

	^ mutedColor
]

{ #category : 'accessing' }
CMarkRoassalTheme >> mutedColor: anObject [
	mutedColor := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> padding [
	"The space around the content of a document"

	^ padding
]

{ #category : 'accessing' }
CMarkRoassalTheme >> padding: anObject [
	padding := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> quoteBarColor [
	"The colour of the bar left of a block quote"

	^ quoteBarColor
]

{ #category : 'accessing' }
CMarkRoassalTheme >> quoteBarColor: anObject [
	quoteBarColor := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> quoteBarWidth [
	"The width of the bar left of a block quote"

	^ quoteBarWidth
]

{ #category : 'accessing' }
CMarkRoassalTheme >> quoteBarWidth: anObject [
	quoteBarWidth := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> quoteIndent [
	"The indentation of the content of a block quote"

	^ quoteIndent
]

{ #category : 'accessing' }
CMarkRoassalTheme >> quoteIndent: anObject [
	quoteIndent := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> ruleThickness [
	"The thickness of a thematic break"

	^ ruleThickness
]

{ #category : 'accessing' }
CMarkRoassalTheme >> ruleThickness: anObject [
	ruleThickness := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> sansFamily [
	"The family of the text, checked against the families of the image (CMarkRoassalFonts falls back to RSLabel familyFontName at the same size)"

	^ sansFamily
]

{ #category : 'accessing' }
CMarkRoassalTheme >> sansFamily: anObject [
	sansFamily := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> superscriptRaise [
	"How far a footnote reference is raised, as a factor of the ascent of the text around it"

	^ superscriptRaise
]

{ #category : 'accessing' }
CMarkRoassalTheme >> superscriptRaise: anObject [
	superscriptRaise := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> superscriptScale [
	"The size of a footnote reference, as a factor of the text around it"

	^ superscriptScale
]

{ #category : 'accessing' }
CMarkRoassalTheme >> superscriptScale: anObject [
	superscriptScale := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> tableHeaderBackground [
	"The background of the header row of a table"

	^ tableHeaderBackground
]

{ #category : 'accessing' }
CMarkRoassalTheme >> tableHeaderBackground: anObject [
	tableHeaderBackground := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> tableZebra [
	"The background of every second body row of a table"

	^ tableZebra
]

{ #category : 'accessing' }
CMarkRoassalTheme >> tableZebra: anObject [
	tableZebra := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> textColor [
	"The colour of the text"

	^ textColor
]

{ #category : 'accessing' }
CMarkRoassalTheme >> textColor: anObject [
	textColor := anObject
]

{ #category : 'accessing' }
CMarkRoassalTheme >> tightGap [
	"The space between the items of a tight list"

	^ tightGap
]

{ #category : 'accessing' }
CMarkRoassalTheme >> tightGap: anObject [
	tightGap := anObject
]
