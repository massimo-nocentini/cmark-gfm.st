"
I am a code block: literal is my content (each line ends with a line feed), info the info string of a fenced block ('' for an indented one), language its first word.  fenced says whether I am fenced; fenceLength, fenceCharacter ($` or $~, nil when indented) and fenceOffset describe the fence.

	CMarkCodeBlock literal: 'x := 1.' , String lf info: 'smalltalk'
"
Class {
	#name : 'CMarkCodeBlock',
	#superclass : 'CMarkBlockNode',
	#instVars : [
		'literal',
		'info',
		'fenced',
		'fenceLength',
		'fenceCharacter',
		'fenceOffset'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CMarkCodeBlock class >> literal: aString info: anInfoString [
	"A hand-built fenced code block (three backquotes)"

	^ self new
		literal: aString;
		info: anInfoString;
		fenced: true;
		fenceLength: 3;
		fenceCharacter: $`;
		yourself
]

{ #category : 'accessing' }
CMarkCodeBlock class >> typeCode [
	^ 16r8005
]

{ #category : 'accessing' }
CMarkCodeBlock class >> typeName [
	^ 'code_block'
]

{ #category : 'visiting' }
CMarkCodeBlock >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitCodeBlock: self
]

{ #category : 'printing' }
CMarkCodeBlock >> cmarkPrintAttributesOn: aStream [
	aStream nextPutAll: (fenced ifTrue: [ 'fenced' ] ifFalse: [ 'indented' ]).
	info isEmpty ifFalse: [ aStream space. self cmarkPrintShort: info on: aStream ].
	^ true
]

{ #category : 'printing' }
CMarkCodeBlock >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' fenced='; print: (fenced ifTrue: [ 1 ] ifFalse: [ 0 ]); nextPutAll: ' info='.
	self cmarkPrintLiteral: info on: aStream.
	aStream nextPutAll: ' literal='.
	self cmarkPrintLiteral: literal on: aStream
]

{ #category : 'decoding' }
CMarkCodeBlock >> cmarkRead: aDecoder record: base [
	| c |
	fenceLength := aDecoder int1At: base.
	c := aDecoder int2At: base.
	fenceCharacter := c = 0
						  ifTrue: [ nil ]
						  ifFalse: [ Character value: c ].
	fenceOffset := aDecoder int3At: base.
	literal := aDecoder string1At: base.
	info := aDecoder string2At: base.
	fenced := self cmarkHasFlag: CMarkTreeDecoder flagFenced
]

{ #category : 'accessing' }
CMarkCodeBlock >> fenceCharacter [
	"$` or $~, or nil for an indented block"

	^ fenceCharacter
]

{ #category : 'accessing' }
CMarkCodeBlock >> fenceCharacter: aCharacterOrNil [
	fenceCharacter := aCharacterOrNil
]

{ #category : 'accessing' }
CMarkCodeBlock >> fenceLength [
	^ fenceLength
]

{ #category : 'accessing' }
CMarkCodeBlock >> fenceLength: anInteger [
	fenceLength := anInteger
]

{ #category : 'accessing' }
CMarkCodeBlock >> fenceOffset [
	"The indentation of the fence"

	^ fenceOffset
]

{ #category : 'accessing' }
CMarkCodeBlock >> fenceOffset: anInteger [
	fenceOffset := anInteger
]

{ #category : 'accessing' }
CMarkCodeBlock >> fenced [
	^ fenced
]

{ #category : 'accessing' }
CMarkCodeBlock >> fenced: aBoolean [
	fenced := aBoolean
]

{ #category : 'accessing' }
CMarkCodeBlock >> info [
	"The info string, '' for an indented block"

	^ info
]

{ #category : 'accessing' }
CMarkCodeBlock >> info: aString [
	info := aString
]

{ #category : 'initialization' }
CMarkCodeBlock >> initialize [
	super initialize.
	literal := ''.
	info := ''.
	fenced := false.
	fenceLength := 0.
	fenceCharacter := nil.
	fenceOffset := 0
]

{ #category : 'testing' }
CMarkCodeBlock >> isFenced [
	^ fenced
]

{ #category : 'accessing' }
CMarkCodeBlock >> language [
	"The first word of the info string, or nil"

	| words |
	words := info substrings.
	^ words isEmpty
		  ifTrue: [ nil ]
		  ifFalse: [ words first ]
]

{ #category : 'accessing' }
CMarkCodeBlock >> lines [
	"The lines of my literal, without their terminators (LF, CR LF or CR); the empty line after the last terminator is dropped"

	| lines start i size c |
	lines := OrderedCollection new.
	start := 1.
	i := 1.
	size := literal size.
	[ i <= size ] whileTrue: [
		c := literal at: i.
		(c = Character lf or: [ c = Character cr ])
			ifTrue: [
				lines add: (literal copyFrom: start to: i - 1).
				(c = Character cr and: [ i < size and: [ (literal at: i + 1) = Character lf ] ]) ifTrue: [ i := i + 1 ].
				start := i + 1 ].
		i := i + 1 ].
	start <= size ifTrue: [ lines add: (literal copyFrom: start to: size) ].
	^ lines asArray
]

{ #category : 'accessing' }
CMarkCodeBlock >> literal [
	"The content of the block, each line ending with a line feed"

	^ literal
]

{ #category : 'accessing' }
CMarkCodeBlock >> literal: aString [
	literal := aString
]
