"
I am the style of a piece of inline text in the Roassal rendering:

- the font `family` and `size`, `bold`, `italic`, `strike`, `underline`,
- the colour and the background,
- whether the text is code (`mono`),
- the node that a click follows (`link`: a `CMarkLink` or a `CMarkFootnoteReference`), and
- how far the text is raised above the baseline (`raise`, for footnote references).

I am immutable: the `with...:` messages answer modified copies, so a style can be shared by every run that uses it. `fontKey` identifies the font (family, size, bold, italic) in the font cache of the renderer (`CMarkRoassalFonts`).
"
Class {
	#name : 'CMarkInlineStyle',
	#superclass : 'Object',
	#instVars : [
		'family',
		'size',
		'bold',
		'italic',
		'strike',
		'underline',
		'color',
		'background',
		'mono',
		'link',
		'raise'
	],
	#category : 'CMark-Roassal-Theme',
	#package : 'CMark-Roassal',
	#tag : 'Theme'
}

{ #category : 'instance creation' }
CMarkInlineStyle class >> family: aString size: aNumber color: aColor [
	"A plain style: not bold, not italic, no decoration, no background, not mono, no link, not raised"

	^ self new
		  setFamily: aString size: aNumber color: aColor;
		  yourself
]

{ #category : 'accessing' }
CMarkInlineStyle >> background [
	"The colour behind the text, or nil"

	^ background
]

{ #category : 'accessing' }
CMarkInlineStyle >> bold [
	^ bold
]

{ #category : 'accessing' }
CMarkInlineStyle >> color [
	^ color
]

{ #category : 'accessing' }
CMarkInlineStyle >> emphasisCode [
	"The emphasis code of LogicalFont: 1 bold, 2 italic"

	^ (bold ifTrue: [ 1 ] ifFalse: [ 0 ]) + (italic ifTrue: [ 2 ] ifFalse: [ 0 ])
]

{ #category : 'accessing' }
CMarkInlineStyle >> family [
	^ family
]

{ #category : 'accessing' }
CMarkInlineStyle >> fontKey [
	"The key of my font in a font cache: family, point size, bold and italic"

	^ { family. self pointSize. bold. italic }
]

{ #category : 'initialization' }
CMarkInlineStyle >> initialize [
	super initialize.
	family := 'Source Sans Pro'.
	size := 12.
	bold := false.
	italic := false.
	strike := false.
	underline := false.
	color := Color black.
	background := nil.
	mono := false.
	link := nil.
	raise := 0
]

{ #category : 'testing' }
CMarkInlineStyle >> isLink [
	"Whether a click on my text follows a node"

	^ link notNil
]

{ #category : 'accessing' }
CMarkInlineStyle >> italic [
	^ italic
]

{ #category : 'accessing' }
CMarkInlineStyle >> link [
	"The CMarkLink or CMarkFootnoteReference that a click on my text follows, or nil"

	^ link
]

{ #category : 'accessing' }
CMarkInlineStyle >> mono [
	^ mono
]

{ #category : 'accessing' }
CMarkInlineStyle >> pointSize [
	"My size rounded to whole points: the image's fonts do not measure fractional sizes reliably (10.8 points measures as 10 or as 11 points, depending on the fonts made before)"

	^ size rounded max: 1
]

{ #category : 'printing' }
CMarkInlineStyle >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: family;
		space;
		print: size.
	bold ifTrue: [ aStream nextPutAll: ' bold' ].
	italic ifTrue: [ aStream nextPutAll: ' italic' ].
	strike ifTrue: [ aStream nextPutAll: ' strike' ].
	underline ifTrue: [ aStream nextPutAll: ' underline' ].
	mono ifTrue: [ aStream nextPutAll: ' mono' ].
	raise = 0 ifFalse: [ aStream nextPutAll: ' raise '; print: raise ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
CMarkInlineStyle >> raise [
	"How far my text sits above the baseline, in user units"

	^ raise
]

{ #category : 'private' }
CMarkInlineStyle >> setBackground: aColorOrNil [
	background := aColorOrNil
]

{ #category : 'private' }
CMarkInlineStyle >> setBold: aBoolean [
	bold := aBoolean
]

{ #category : 'private' }
CMarkInlineStyle >> setColor: aColor [
	color := aColor
]

{ #category : 'private' }
CMarkInlineStyle >> setFamily: aString [
	family := aString
]

{ #category : 'private' }
CMarkInlineStyle >> setFamily: aString size: aNumber color: aColor [
	family := aString.
	size := aNumber.
	color := aColor
]

{ #category : 'private' }
CMarkInlineStyle >> setItalic: aBoolean [
	italic := aBoolean
]

{ #category : 'private' }
CMarkInlineStyle >> setLink: aNodeOrNil [
	link := aNodeOrNil
]

{ #category : 'private' }
CMarkInlineStyle >> setMono: aBoolean [
	mono := aBoolean
]

{ #category : 'private' }
CMarkInlineStyle >> setRaise: aNumber [
	raise := aNumber
]

{ #category : 'private' }
CMarkInlineStyle >> setSize: aNumber [
	size := aNumber
]

{ #category : 'private' }
CMarkInlineStyle >> setStrike: aBoolean [
	strike := aBoolean
]

{ #category : 'private' }
CMarkInlineStyle >> setUnderline: aBoolean [
	underline := aBoolean
]

{ #category : 'accessing' }
CMarkInlineStyle >> size [
	"My font size in points"

	^ size
]

{ #category : 'accessing' }
CMarkInlineStyle >> strike [
	^ strike
]

{ #category : 'accessing' }
CMarkInlineStyle >> underline [
	^ underline
]

{ #category : 'copying' }
CMarkInlineStyle >> withBackground: aColorOrNil [
	^ self copy
		  setBackground: aColorOrNil;
		  yourself
]

{ #category : 'copying' }
CMarkInlineStyle >> withBold: aBoolean [
	^ self copy
		  setBold: aBoolean;
		  yourself
]

{ #category : 'copying' }
CMarkInlineStyle >> withColor: aColor [
	^ self copy
		  setColor: aColor;
		  yourself
]

{ #category : 'copying' }
CMarkInlineStyle >> withFamily: aString [
	^ self copy
		  setFamily: aString;
		  yourself
]

{ #category : 'copying' }
CMarkInlineStyle >> withItalic: aBoolean [
	^ self copy
		  setItalic: aBoolean;
		  yourself
]

{ #category : 'copying' }
CMarkInlineStyle >> withLink: aNodeOrNil [
	^ self copy
		  setLink: aNodeOrNil;
		  yourself
]

{ #category : 'copying' }
CMarkInlineStyle >> withMono: aBoolean [
	^ self copy
		  setMono: aBoolean;
		  yourself
]

{ #category : 'copying' }
CMarkInlineStyle >> withRaise: aNumber [
	^ self copy
		  setRaise: aNumber;
		  yourself
]

{ #category : 'copying' }
CMarkInlineStyle >> withSize: aNumber [
	^ self copy
		  setSize: aNumber;
		  yourself
]

{ #category : 'copying' }
CMarkInlineStyle >> withStrike: aBoolean [
	^ self copy
		  setStrike: aBoolean;
		  yourself
]

{ #category : 'copying' }
CMarkInlineStyle >> withUnderline: aBoolean [
	^ self copy
		  setUnderline: aBoolean;
		  yourself
]
