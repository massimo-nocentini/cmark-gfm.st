"
I am the context of a block in the Roassal rendering: the width available to it, the base style of its text (muted in block quotes, bold in header rows, smaller in footnote definitions), the depth of lists, of bullet lists and of quotes around it, and its nesting (the number of blocks around it).

I am immutable: the with...: messages answer modified copies.  The renderer passes me down its recursion and keeps the current one only for the duration of one visit (restored in an ensure:), so a non-local return or an error never leaves a wrong context behind.
"
Class {
	#name : 'CMarkRoassalContext',
	#superclass : 'Object',
	#instVars : [
		'availableWidth',
		'baseStyle',
		'listDepth',
		'bulletDepth',
		'quoteDepth',
		'nesting'
	],
	#category : 'CMark-Roassal-Rendering',
	#package : 'CMark-Roassal',
	#tag : 'Rendering'
}

{ #category : 'instance creation' }
CMarkRoassalContext class >> width: aNumber style: aStyle [
	"The context of a block at the top: nothing around it"

	^ self new
		  setWidth: aNumber style: aStyle;
		  yourself
]

{ #category : 'accessing' }
CMarkRoassalContext >> availableWidth [
	^ availableWidth
]

{ #category : 'accessing' }
CMarkRoassalContext >> baseStyle [
	^ baseStyle
]

{ #category : 'accessing' }
CMarkRoassalContext >> bulletDepth [
	"The number of bullet lists around me"

	^ bulletDepth
]

{ #category : 'accessing' }
CMarkRoassalContext >> listDepth [
	"The number of lists around me"

	^ listDepth
]

{ #category : 'copying' }
CMarkRoassalContext >> nested [
	"A copy one level deeper"

	^ self withNesting: nesting + 1
]

{ #category : 'accessing' }
CMarkRoassalContext >> nesting [
	"The number of blocks around me"

	^ nesting
]

{ #category : 'printing' }
CMarkRoassalContext >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: '(width ';
		print: availableWidth;
		nextPutAll: ' nesting ';
		print: nesting;
		nextPut: $)
]

{ #category : 'accessing' }
CMarkRoassalContext >> quoteDepth [
	"The number of block quotes around me"

	^ quoteDepth
]

{ #category : 'private' }
CMarkRoassalContext >> setAvailableWidth: aNumber [
	availableWidth := aNumber
]

{ #category : 'private' }
CMarkRoassalContext >> setBaseStyle: aStyle [
	baseStyle := aStyle
]

{ #category : 'private' }
CMarkRoassalContext >> setBulletDepth: anInteger [
	bulletDepth := anInteger
]

{ #category : 'private' }
CMarkRoassalContext >> setListDepth: anInteger [
	listDepth := anInteger
]

{ #category : 'private' }
CMarkRoassalContext >> setNesting: anInteger [
	nesting := anInteger
]

{ #category : 'private' }
CMarkRoassalContext >> setQuoteDepth: anInteger [
	quoteDepth := anInteger
]

{ #category : 'private' }
CMarkRoassalContext >> setWidth: aNumber style: aStyle [
	availableWidth := aNumber.
	baseStyle := aStyle.
	listDepth := 0.
	bulletDepth := 0.
	quoteDepth := 0.
	nesting := 0
]

{ #category : 'copying' }
CMarkRoassalContext >> withAvailableWidth: aNumber [
	^ self copy
		  setAvailableWidth: aNumber;
		  yourself
]

{ #category : 'copying' }
CMarkRoassalContext >> withBaseStyle: aStyle [
	^ self copy
		  setBaseStyle: aStyle;
		  yourself
]

{ #category : 'copying' }
CMarkRoassalContext >> withBulletDepth: anInteger [
	^ self copy
		  setBulletDepth: anInteger;
		  yourself
]

{ #category : 'copying' }
CMarkRoassalContext >> withListDepth: anInteger [
	^ self copy
		  setListDepth: anInteger;
		  yourself
]

{ #category : 'copying' }
CMarkRoassalContext >> withNesting: anInteger [
	^ self copy
		  setNesting: anInteger;
		  yourself
]

{ #category : 'copying' }
CMarkRoassalContext >> withQuoteDepth: anInteger [
	^ self copy
		  setQuoteDepth: anInteger;
		  yourself
]
