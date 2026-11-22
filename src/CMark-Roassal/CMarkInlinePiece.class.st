"
I am a piece of a line of CMarkInlineFlow: a word of text (#word), a segment of a code span (#chip) or an atom (#atom, an image or its placeholder), with its style, its node, its advance (width), and the part of it above (ascent) and below (descent) the baseline.  A chip knows whether it is the first and the last segment of its code span (its box is padded and rounded only at the outer ends) and how wide its padding is.
"
Class {
	#name : 'CMarkInlinePiece',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'text',
		'style',
		'node',
		'width',
		'ascent',
		'descent',
		'shape',
		'isFirst',
		'isLast',
		'pad'
	],
	#category : 'CMark-Roassal-Inline',
	#package : 'CMark-Roassal',
	#tag : 'Inline'
}

{ #category : 'instance creation' }
CMarkInlinePiece class >> kind: aSymbol text: aString style: aStyle node: aNode width: aNumber [
	^ self new
		  setKind: aSymbol text: aString style: aStyle node: aNode width: aNumber;
		  yourself
]

{ #category : 'accessing' }
CMarkInlinePiece >> ascent [
	^ ascent
]

{ #category : 'accessing' }
CMarkInlinePiece >> ascent: aNumber descent: anotherNumber [
	ascent := aNumber.
	descent := anotherNumber
]

{ #category : 'copying' }
CMarkInlinePiece >> copyWithText: aString width: aNumber [
	"A copy of me holding aString, aNumber wide"

	^ self copy
		  setText: aString width: aNumber;
		  yourself
]

{ #category : 'accessing' }
CMarkInlinePiece >> descent [
	^ descent
]

{ #category : 'testing' }
CMarkInlinePiece >> isAtom [
	^ kind = #atom
]

{ #category : 'testing' }
CMarkInlinePiece >> isChip [
	^ kind = #chip
]

{ #category : 'accessing' }
CMarkInlinePiece >> isFirst [
	"For a chip: whether I am the first segment of my code span"

	^ isFirst
]

{ #category : 'accessing' }
CMarkInlinePiece >> isFirst: aBoolean isLast: anotherBoolean pad: aNumber [
	isFirst := aBoolean.
	isLast := anotherBoolean.
	pad := aNumber
]

{ #category : 'accessing' }
CMarkInlinePiece >> isLast [
	"For a chip: whether I am the last segment of my code span"

	^ isLast
]

{ #category : 'accessing' }
CMarkInlinePiece >> kind [
	^ kind
]

{ #category : 'accessing' }
CMarkInlinePiece >> node [
	^ node
]

{ #category : 'accessing' }
CMarkInlinePiece >> pad [
	"For a chip: the horizontal padding of its box at an outer end"

	^ pad
]

{ #category : 'printing' }
CMarkInlinePiece >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: kind;
		space;
		print: text;
		space;
		print: width;
		nextPut: $)
]

{ #category : 'private' }
CMarkInlinePiece >> setKind: aSymbol text: aString style: aStyle node: aNode width: aNumber [
	kind := aSymbol.
	text := aString.
	style := aStyle.
	node := aNode.
	width := aNumber.
	ascent := 0.
	descent := 0.
	isFirst := true.
	isLast := true.
	pad := 0
]

{ #category : 'private' }
CMarkInlinePiece >> setText: aString width: aNumber [
	text := aString.
	width := aNumber
]

{ #category : 'accessing' }
CMarkInlinePiece >> shape [
	"For an atom: its shape"

	^ shape
]

{ #category : 'accessing' }
CMarkInlinePiece >> shape: aShape [
	shape := aShape
]

{ #category : 'accessing' }
CMarkInlinePiece >> style [
	^ style
]

{ #category : 'accessing' }
CMarkInlinePiece >> text [
	^ text
]

{ #category : 'accessing' }
CMarkInlinePiece >> width [
	"My advance"

	^ width
]
