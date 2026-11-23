"
I render Markdown source text to text through the renderers of cmark-gfm in the `CMarkPlugin`: `#html`, `#xml`, `#commonmark`, `#plaintext`, `#latex` or `#man` (my `format`, `#html` by default), with my options (`CMarkOptions gfm` by default; `width` is the wrap width of the text formats, `sourcePos` puts the positions into the HTML and the XML, `unsafe` keeps raw HTML).

```smalltalk
CMarkFormatter html: '# Hi'.
	""'<h1>Hi</h1>', LF""
CMarkFormatter
	render: '# Hi'
	format: #man
	options: CMarkOptions commonMark.
CMarkFormatter
	renderBytes: aByteArray
	format: #html
	options: CMarkOptions gfm.
	""UTF-8 bytes""
```

I render source text, not trees (`CMarkRoassalRenderer` draws trees): there is no Smalltalk CommonMark writer, so a tree built or changed by hand cannot reach these renderers.

An unknown format is a `CMarkError` before any call; the sources, the size check and the errors are those of `CMarkParser`.
"
Class {
	#name : 'CMarkFormatter',
	#superclass : 'Object',
	#instVars : [
		'options',
		'format'
	],
	#category : 'CMark-Facade',
	#package : 'CMark',
	#tag : 'Facade'
}

{ #category : 'accessing' }
CMarkFormatter class >> formatCode: aSymbol [
	"The format argument of primitiveRender for aSymbol (1 html, 2 xml, 3 commonmark, 4 plaintext, 5 latex, 6 man), or a CMarkError"

	| code |
	code := self formats indexOf: aSymbol.
	code = 0 ifTrue: [ ^ CMarkError signal: 'unknown format: ' , aSymbol printString ].
	^ code
]

{ #category : 'accessing' }
CMarkFormatter class >> formats [
	"The formats of the renderers, in the order of their codes"

	^ #( #html #xml #commonmark #plaintext #latex #man )
]

{ #category : 'rendering' }
CMarkFormatter class >> html: aString [
	"The HTML of the Markdown aString, with CMarkOptions gfm"

	^ self render: aString format: #html
]

{ #category : 'rendering' }
CMarkFormatter class >> render: aString format: aSymbol [
	"aString rendered as aSymbol, with CMarkOptions gfm"

	^ self render: aString format: aSymbol options: CMarkOptions gfm
]

{ #category : 'rendering' }
CMarkFormatter class >> render: aString format: aSymbol options: aCMarkOptions [
	"aString rendered as aSymbol with aCMarkOptions, as a String"

	^ self new
		  options: aCMarkOptions;
		  format: aSymbol;
		  render: aString
]

{ #category : 'rendering' }
CMarkFormatter class >> renderBytes: aStringOrByteArray format: aSymbol options: aCMarkOptions [
	"aStringOrByteArray rendered as aSymbol with aCMarkOptions, as a ByteArray of UTF-8"

	^ self new
		  options: aCMarkOptions;
		  format: aSymbol;
		  renderBytes: aStringOrByteArray
]

{ #category : 'accessing' }
CMarkFormatter >> format [
	"The format I render (#html unless set)"

	^ format ifNil: [ #html ]
]

{ #category : 'accessing' }
CMarkFormatter >> format: aSymbol [
	"Render as aSymbol, one of the formats (CMarkError otherwise)"

	self class formatCode: aSymbol.
	format := aSymbol
]

{ #category : 'accessing' }
CMarkFormatter >> options [
	"The CMarkOptions I render with (CMarkOptions gfm unless set)"

	^ options ifNil: [ options := CMarkOptions gfm ]
]

{ #category : 'accessing' }
CMarkFormatter >> options: aCMarkOptions [
	options := aCMarkOptions
]

{ #category : 'rendering' }
CMarkFormatter >> render: aStringOrByteArray [
	"The Markdown aStringOrByteArray rendered, as a String: a ByteString copied from the bytes when the output is ASCII, else decoded from UTF-8, keeping every U+FEFF"

	| answer bytes |
	answer := self renderAnswer: aStringOrByteArray.
	bytes := (answer at: 3) ifNil: [ ByteArray new ].
	(answer at: 4) == true ifFalse: [ ^ bytes cmarkUtf8Decoded ].
	^ (ByteString new: bytes size)
		  replaceFrom: 1
		  to: bytes size
		  with: bytes
		  startingAt: 1
]

{ #category : 'private' }
CMarkFormatter >> renderAnswer: aStringOrByteArray [
	"The answer of primitiveRender for aStringOrByteArray, with status 0, or the error of its status"

	| code source o answer |
	code := self class formatCode: self format.
	source := aStringOrByteArray cmarkSource.
	o := self options.
	o checkInputSize: source.
	answer := CMarkPrimitives
		          render: source
		          format: code
		          options: o optionBits
		          extensions: o extensionBits
		          width: o width
		          cBudget: o cBudgetArgument.
	(answer at: 1) = 0 ifFalse: [
		^ CMarkPrimitives signalStatusOf: answer maxDepth: nil cBudget: o cBudgetArgument ].
	^ answer
]

{ #category : 'rendering' }
CMarkFormatter >> renderBytes: aStringOrByteArray [
	"The Markdown aStringOrByteArray rendered, as a ByteArray of UTF-8"

	^ ((self renderAnswer: aStringOrByteArray) at: 3) ifNil: [ ByteArray new ]
]
