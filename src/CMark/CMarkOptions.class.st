"
I say how to parse and render Markdown: the extensions (a Set of the names of allExtensionNames), the options of cmark as booleans, the wrap width of the text renders, and the limits (maxDepth, cBudget, maxInputSize; docs/CMark.md, Memory and limits).  optionBits and extensionBits are the exact bits that the primitives take.

I am a mutable builder: the setters answer me, so they cascade (CMarkOptions gfm smart: true; footnotes: true).  commonMark and gfm answer a fresh instance every time; copy one before changing it for another use.  = and hash compare every setting: do not change an instance that is a key of a Dictionary.

Defaults of new: no extension, every boolean false, width 0 (no wrapping), maxDepth 1000 (nil: no limit), cBudget nil (the default of the plugin), maxInputSize defaultMaxInputSize (nil: only the cap of the plugin).
"
Class {
	#name : 'CMarkOptions',
	#superclass : 'Object',
	#instVars : [
		'extensions',
		'sourcePos',
		'hardBreaks',
		'noBreaks',
		'smart',
		'githubPreLang',
		'liberalHtmlTag',
		'footnotes',
		'strikethroughDoubleTilde',
		'tablePreferStyleAttributes',
		'fullInfoString',
		'unsafe',
		'width',
		'maxDepth',
		'cBudget',
		'maxInputSize'
	],
	#category : 'CMark-Options',
	#package : 'CMark',
	#tag : 'Options'
}

{ #category : 'accessing' }
CMarkOptions class >> allExtensionNames [
	"The GFM extensions of the plugin, in the order of their bits (1 table, 2 strikethrough, 4 autolink, 8 tagfilter, 16 tasklist)"

	^ #( #table #strikethrough #autolink #tagfilter #tasklist )
]

{ #category : 'instance creation' }
CMarkOptions class >> commonMark [
	"Fresh options for plain CommonMark: no extension"

	^ self new
]

{ #category : 'accessing' }
CMarkOptions class >> defaultMaxInputSize [
	"The default maxInputSize: 32 Mi characters (bytes of a ByteArray) natively, 16 Mi on WebAssembly (CMarkPrimitives defaultMaxInputSize)"

	^ CMarkPrimitives defaultMaxInputSize
]

{ #category : 'accessing' }
CMarkOptions class >> footnotesBit [
	^ 8192
]

{ #category : 'accessing' }
CMarkOptions class >> fullInfoStringBit [
	^ 65536
]

{ #category : 'instance creation' }
CMarkOptions class >> gfm [
	"Fresh options for GitHub Flavored Markdown: the five extensions; footnotes stay off (docs/CMark.md, Limitations)"

	^ self new
		extensions: self allExtensionNames;
		yourself
]

{ #category : 'accessing' }
CMarkOptions class >> githubPreLangBit [
	^ 2048
]

{ #category : 'accessing' }
CMarkOptions class >> hardBreaksBit [
	^ 4
]

{ #category : 'accessing' }
CMarkOptions class >> liberalHtmlTagBit [
	^ 4096
]

{ #category : 'accessing' }
CMarkOptions class >> noBreaksBit [
	^ 16
]

{ #category : 'accessing' }
CMarkOptions class >> smartBit [
	^ 1024
]

{ #category : 'accessing' }
CMarkOptions class >> sourcePosBit [
	^ 2
]

{ #category : 'accessing' }
CMarkOptions class >> strikethroughDoubleTildeBit [
	^ 16384
]

{ #category : 'accessing' }
CMarkOptions class >> tablePreferStyleAttributesBit [
	^ 32768
]

{ #category : 'accessing' }
CMarkOptions class >> unsafeBit [
	^ 131072
]

{ #category : 'comparing' }
CMarkOptions >> = anObject [
	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ self settings = anObject settings
]

{ #category : 'extensions' }
CMarkOptions >> addExtension: aSymbol [
	"Add the extension named aSymbol (one of allExtensionNames)"

	extensions add: (self checkedExtension: aSymbol)
]

{ #category : 'accessing' }
CMarkOptions >> cBudget [
	"The bytes of C memory that a call may hold at once, or nil for the default of the plugin"

	^ cBudget
]

{ #category : 'accessing' }
CMarkOptions >> cBudget: anIntegerOrNil [
	(anIntegerOrNil isNil or: [ anIntegerOrNil isInteger and: [ anIntegerOrNil >= 0 ] ]) ifFalse: [
		CMarkError signal: 'cBudget must be nil or an Integer >= 0' ].
	cBudget := anIntegerOrNil
]

{ #category : 'accessing' }
CMarkOptions >> cBudgetArgument [
	"The cBudget argument of the primitives: -1 for the default of the plugin"

	^ cBudget ifNil: [ -1 ]
]

{ #category : 'checking' }
CMarkOptions >> checkInputSize: aSource [
	"Signal CMarkInputTooLarge when aSource (a String, or a ByteArray of UTF-8) is larger than maxInputSize, in characters or bytes"

	maxInputSize ifNil: [ ^ self ].
	aSource size > maxInputSize ifTrue: [
		CMarkInputTooLarge signalLimit: maxInputSize actual: aSource size ]
]

{ #category : 'private' }
CMarkOptions >> checkedExtension: aSymbol [
	"aSymbol as a Symbol, or a CMarkError when it is not the name of an extension"

	^ self class allExtensionNames
		detect: [ :each | each = aSymbol ]
		ifNone: [ CMarkError signal: 'unknown extension: ' , aSymbol printString ]
]

{ #category : 'extensions' }
CMarkOptions >> extensionBits [
	"The extensions as the bit mask of the primitives"

	| bits |
	bits := 0.
	self class allExtensionNames withIndexDo: [ :each :i |
		(extensions includes: each) ifTrue: [ bits := bits bitOr: (1 bitShift: i - 1) ] ].
	^ bits
]

{ #category : 'extensions' }
CMarkOptions >> extensions [
	"The names of the extensions, in the order of allExtensionNames"

	^ self class allExtensionNames select: [ :each | extensions includes: each ]
]

{ #category : 'extensions' }
CMarkOptions >> extensions: aCollection [
	"Exactly the extensions named in aCollection"

	| names |
	names := aCollection collect: [ :each | self checkedExtension: each ].
	extensions := names asSet
]

{ #category : 'options' }
CMarkOptions >> footnotes [
	"Whether footnotes are parsed (off by default: gfm.14 truncates a footnote label that holds an inline, docs/CMark.md, Limitations)"

	^ footnotes
]

{ #category : 'options' }
CMarkOptions >> footnotes: aBoolean [
	footnotes := aBoolean == true
]

{ #category : 'options' }
CMarkOptions >> fullInfoString [
	"Whether the HTML render keeps the whole info string of a code block (data-meta)"

	^ fullInfoString
]

{ #category : 'options' }
CMarkOptions >> fullInfoString: aBoolean [
	fullInfoString := aBoolean == true
]

{ #category : 'options' }
CMarkOptions >> githubPreLang [
	"Whether the HTML render of a fenced code block puts its language on pre (lang) as GitHub does, not on code"

	^ githubPreLang
]

{ #category : 'options' }
CMarkOptions >> githubPreLang: aBoolean [
	githubPreLang := aBoolean == true
]

{ #category : 'options' }
CMarkOptions >> hardBreaks [
	"Whether a soft break (a newline inside a paragraph) is a hard break"

	^ hardBreaks
]

{ #category : 'options' }
CMarkOptions >> hardBreaks: aBoolean [
	hardBreaks := aBoolean == true
]

{ #category : 'extensions' }
CMarkOptions >> hasExtension: aSymbol [
	^ extensions includes: aSymbol
]

{ #category : 'comparing' }
CMarkOptions >> hash [
	^ self settings hash
]

{ #category : 'initialization' }
CMarkOptions >> initialize [
	super initialize.
	extensions := Set new.
	sourcePos := false.
	hardBreaks := false.
	noBreaks := false.
	smart := false.
	githubPreLang := false.
	liberalHtmlTag := false.
	footnotes := false.
	strikethroughDoubleTilde := false.
	tablePreferStyleAttributes := false.
	fullInfoString := false.
	unsafe := false.
	width := 0.
	maxDepth := 1000.
	cBudget := nil.
	maxInputSize := self class defaultMaxInputSize
]

{ #category : 'options' }
CMarkOptions >> liberalHtmlTag [
	"Whether raw HTML tags are recognised more liberally"

	^ liberalHtmlTag
]

{ #category : 'options' }
CMarkOptions >> liberalHtmlTag: aBoolean [
	liberalHtmlTag := aBoolean == true
]

{ #category : 'accessing' }
CMarkOptions >> maxDepth [
	"The deepest node a parse accepts (the document has depth 1), or nil for no limit"

	^ maxDepth
]

{ #category : 'accessing' }
CMarkOptions >> maxDepth: anIntegerOrNil [
	(anIntegerOrNil isNil or: [ anIntegerOrNil isInteger and: [ anIntegerOrNil >= 0 ] ]) ifFalse: [
		CMarkError signal: 'maxDepth must be nil or an Integer >= 0' ].
	maxDepth := anIntegerOrNil
]

{ #category : 'accessing' }
CMarkOptions >> maxDepthArgument [
	"The maxDepth argument of the primitives: 0 for no limit"

	^ maxDepth ifNil: [ 0 ]
]

{ #category : 'accessing' }
CMarkOptions >> maxInputSize [
	"The largest source accepted before any call, in characters (bytes of a ByteArray), or nil for only the cap of the plugin"

	^ maxInputSize
]

{ #category : 'accessing' }
CMarkOptions >> maxInputSize: anIntegerOrNil [
	(anIntegerOrNil isNil or: [ anIntegerOrNil isInteger and: [ anIntegerOrNil >= 0 ] ]) ifFalse: [
		CMarkError signal: 'maxInputSize must be nil or an Integer >= 0' ].
	maxInputSize := anIntegerOrNil
]

{ #category : 'options' }
CMarkOptions >> noBreaks [
	"Whether a soft break is a space in the renders"

	^ noBreaks
]

{ #category : 'options' }
CMarkOptions >> noBreaks: aBoolean [
	noBreaks := aBoolean == true
]

{ #category : 'options' }
CMarkOptions >> optionBits [
	"The booleans as the option bits of cmark that the primitives take (docs/CMark.md, Primitive contract)"

	| bits |
	bits := 0.
	sourcePos ifTrue: [ bits := bits bitOr: self class sourcePosBit ].
	hardBreaks ifTrue: [ bits := bits bitOr: self class hardBreaksBit ].
	noBreaks ifTrue: [ bits := bits bitOr: self class noBreaksBit ].
	smart ifTrue: [ bits := bits bitOr: self class smartBit ].
	githubPreLang ifTrue: [ bits := bits bitOr: self class githubPreLangBit ].
	liberalHtmlTag ifTrue: [ bits := bits bitOr: self class liberalHtmlTagBit ].
	footnotes ifTrue: [ bits := bits bitOr: self class footnotesBit ].
	strikethroughDoubleTilde ifTrue: [ bits := bits bitOr: self class strikethroughDoubleTildeBit ].
	tablePreferStyleAttributes ifTrue: [ bits := bits bitOr: self class tablePreferStyleAttributesBit ].
	fullInfoString ifTrue: [ bits := bits bitOr: self class fullInfoStringBit ].
	unsafe ifTrue: [ bits := bits bitOr: self class unsafeBit ].
	^ bits
]

{ #category : 'copying' }
CMarkOptions >> postCopy [
	super postCopy.
	extensions := extensions copy
]

{ #category : 'printing' }
CMarkOptions >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	self extensions do: [ :each | aStream nextPutAll: each ] separatedBy: [ aStream space ].
	aStream nextPutAll: '; options '; print: self optionBits.
	aStream nextPut: $)
]

{ #category : 'extensions' }
CMarkOptions >> removeExtension: aSymbol [
	"Remove the extension named aSymbol (one of allExtensionNames), if present"

	extensions remove: (self checkedExtension: aSymbol) ifAbsent: [ nil ]
]

{ #category : 'comparing' }
CMarkOptions >> settings [
	"Every setting, for = and hash"

	^ {
		  self extensions.
		  self optionBits.
		  width.
		  maxDepth.
		  cBudget.
		  maxInputSize }
]

{ #category : 'options' }
CMarkOptions >> smart [
	"Whether straight quotes become curly, -- an en dash, --- an em dash, ... an ellipsis"

	^ smart
]

{ #category : 'options' }
CMarkOptions >> smart: aBoolean [
	smart := aBoolean == true
]

{ #category : 'options' }
CMarkOptions >> sourcePos [
	"Whether the HTML and XML renders carry the source positions of the nodes (data-sourcepos, sourcepos); a parse always computes positions, so this changes only the renders"

	^ sourcePos
]

{ #category : 'options' }
CMarkOptions >> sourcePos: aBoolean [
	sourcePos := aBoolean == true
]

{ #category : 'options' }
CMarkOptions >> strikethroughDoubleTilde [
	"Whether only ~~double tildes~~ strike through, ~single~ ones stay text"

	^ strikethroughDoubleTilde
]

{ #category : 'options' }
CMarkOptions >> strikethroughDoubleTilde: aBoolean [
	strikethroughDoubleTilde := aBoolean == true
]

{ #category : 'options' }
CMarkOptions >> tablePreferStyleAttributes [
	"Whether the HTML render aligns table cells with style attributes, not align"

	^ tablePreferStyleAttributes
]

{ #category : 'options' }
CMarkOptions >> tablePreferStyleAttributes: aBoolean [
	tablePreferStyleAttributes := aBoolean == true
]

{ #category : 'options' }
CMarkOptions >> unsafe [
	"Whether the renders keep raw HTML and dangerous URLs (javascript:...) instead of omitting them; the tree always has them"

	^ unsafe
]

{ #category : 'options' }
CMarkOptions >> unsafe: aBoolean [
	unsafe := aBoolean == true
]

{ #category : 'accessing' }
CMarkOptions >> width [
	"The wrap width of the commonmark, plaintext, latex and man renders; 0 for no wrapping"

	^ width
]

{ #category : 'accessing' }
CMarkOptions >> width: anInteger [
	(anInteger isInteger and: [ anInteger between: 0 and: 10000 ]) ifFalse: [
		CMarkError signal: 'width must be an Integer between 0 and 10000' ].
	width := anInteger
]
