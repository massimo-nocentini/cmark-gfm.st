"
I flatten the inline children of a block into `CMarkInlineRun`s for `CMarkInlineFlow`.

I walk the inlines with an explicit stack, never recursively, so 2000 nested emphases cost no Smalltalk stack. Each visit answers the style for the children of its node, or nil when the node has no children to walk: `visitEmph:`, `visitStrong:`, `visitStrikethrough:` and `visitLink:` derive a style (italic, bold, strike, the link look) and the children are walked with it, so the style is popped when they are done. Beyond the `maxNesting` of the theme the style stops changing.

The leaves add runs:

- texts,
- soft and line breaks (a soft break is a line break when the document was parsed with `hardBreaks`),
- code spans,
- raw HTML (by the `htmlStyle` of the theme, through `CMarkHtmlLite`),
- images and footnote references (atoms and raised labels made by the renderer).
"
Class {
	#name : 'CMarkInlineRunCollector',
	#superclass : 'CMarkVisitor',
	#instVars : [
		'renderer',
		'runs',
		'style',
		'depth',
		'hardBreaks',
		'width'
	],
	#category : 'CMark-Roassal-Inline',
	#package : 'CMark-Roassal',
	#tag : 'Inline'
}

{ #category : 'instance creation' }
CMarkInlineRunCollector class >> renderer: aRenderer [
	^ self new
		  setRenderer: aRenderer;
		  yourself
]

{ #category : 'adding' }
CMarkInlineRunCollector >> add: aSymbol string: aString node: aNode [
	runs add: (CMarkInlineRun kind: aSymbol string: aString style: style node: aNode)
]

{ #category : 'adding' }
CMarkInlineRunCollector >> addRun: aRun [
	runs add: aRun
]

{ #category : 'collecting' }
CMarkInlineRunCollector >> beginWithStyle: aStyle width: aNumber [
	"Start an empty collection of runs in aStyle, for a line of aNumber units; answer it (the html* messages add to it)"

	runs := OrderedCollection new.
	style := aStyle.
	width := aNumber.
	depth := 1.
	^ runs
]

{ #category : 'collecting' }
CMarkInlineRunCollector >> collect: aCollection style: aStyle width: aNumber [
	"The runs of the inline nodes of aCollection, in order, in the style aStyle, for a line of aNumber units"

	| stack entry derived |
	self beginWithStyle: aStyle width: aNumber.
	stack := OrderedCollection new.
	aCollection reverseDo: [ :each | stack addLast: { each. aStyle. 1 } ].
	[ stack isEmpty ] whileFalse: [
		entry := stack removeLast.
		style := entry second.
		depth := entry third.
		derived := entry first acceptCMarkVisitor: self.
		derived ifNotNil: [ entry first children reverseDo: [ :each | stack addLast: { each. derived. depth + 1 } ] ] ].
	^ runs
]

{ #category : 'private' }
CMarkInlineRunCollector >> derive: aBlock [
	"The style of my current node's children: aBlock applied to the current style, unless the nesting is too deep"

	^ depth > renderer theme maxNesting
		  ifTrue: [ style ]
		  ifFalse: [ aBlock value: style ]
]

{ #category : 'html' }
CMarkInlineRunCollector >> htmlBasic: aNode [
	"Comments vanish, <br> breaks the line, <img> is an image, other tags are stripped and the text between them is kept"

	(CMarkHtmlLite tokensOf: aNode literal) do: [ :each | self perform: each first with: each with: aNode ]
]

{ #category : 'html' }
CMarkInlineRunCollector >> htmlBreak: aToken node: aNode [
	self add: #break string: '' node: aNode
]

{ #category : 'html' }
CMarkInlineRunCollector >> htmlHide: aNode [
	"Raw HTML is not shown"
]

{ #category : 'html' }
CMarkInlineRunCollector >> htmlImage: aToken node: aNode [
	runs add: (renderer imageRunForUrl: aToken second alt: aToken third style: style node: aNode width: width)
]

{ #category : 'html' }
CMarkInlineRunCollector >> htmlLiteral: aNode [
	"Raw HTML as muted mono text"

	runs add: (CMarkInlineRun
			 kind: #text
			 string: aNode literal
			 style: (renderer monoStyleFrom: (style withColor: renderer theme mutedColor))
			 node: aNode)
]

{ #category : 'html' }
CMarkInlineRunCollector >> htmlText: aToken node: aNode [
	self add: #text string: aToken second node: aNode
]

{ #category : 'private' }
CMarkInlineRunCollector >> setRenderer: aRenderer [
	renderer := aRenderer.
	hardBreaks := aRenderer hardBreaks
]

{ #category : 'visiting' }
CMarkInlineRunCollector >> visitCode: aCode [
	self add: #code string: aCode literal node: aCode.
	^ nil
]

{ #category : 'visiting' }
CMarkInlineRunCollector >> visitEmph: anEmph [
	^ self derive: [ :s | s withItalic: true ]
]

{ #category : 'visiting' }
CMarkInlineRunCollector >> visitFootnoteReference: aFootnoteReference [
	runs add: (renderer footnoteReferenceRun: aFootnoteReference style: style).
	^ nil
]

{ #category : 'visiting' }
CMarkInlineRunCollector >> visitHtmlInline: aHtmlInline [
	self perform: ('html' , renderer theme htmlStyle capitalized , ':') asSymbol with: aHtmlInline.
	^ nil
]

{ #category : 'visiting' }
CMarkInlineRunCollector >> visitImage: anImage [
	runs add: (renderer imageRunForUrl: anImage url alt: anImage altText style: style node: anImage width: width).
	^ nil
]

{ #category : 'visiting' }
CMarkInlineRunCollector >> visitLineBreak: aLineBreak [
	self add: #break string: '' node: aLineBreak.
	^ nil
]

{ #category : 'visiting' }
CMarkInlineRunCollector >> visitLink: aLink [
	^ self derive: [ :s | renderer linkStyleFrom: s link: aLink ]
]

{ #category : 'visiting' }
CMarkInlineRunCollector >> visitNode: aNode [
	"Any other node: its children, in the same style"

	^ style
]

{ #category : 'visiting' }
CMarkInlineRunCollector >> visitSoftBreak: aSoftBreak [
	self add: (hardBreaks ifTrue: [ #break ] ifFalse: [ #space ]) string: ' ' node: aSoftBreak.
	^ nil
]

{ #category : 'visiting' }
CMarkInlineRunCollector >> visitStrikethrough: aStrikethrough [
	^ self derive: [ :s | s withStrike: true ]
]

{ #category : 'visiting' }
CMarkInlineRunCollector >> visitStrong: aStrong [
	^ self derive: [ :s | s withBold: true ]
]

{ #category : 'visiting' }
CMarkInlineRunCollector >> visitText: aText [
	self add: #text string: aText literal node: aText.
	^ nil
]
