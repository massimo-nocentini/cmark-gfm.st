"
I am an item of a CMarkList: my children are blocks.  markerNumber is the number of my marker as written in the source (1. 1. 1. gives 1, 1, 1; bullets give 0; only the renders of cmark renumber); markerText is the marker as written (- * + or 3.), from the source.  A task list item is a CMarkTaskItem.
"
Class {
	#name : 'CMarkItem',
	#superclass : 'CMarkBlockNode',
	#instVars : [
		'markerNumber'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'decoding' }
CMarkItem class >> cmarkClassForFlags: anInteger [
	"CMarkTaskItem for a task list item, else CMarkItem"

	^ (anInteger bitAnd: CMarkTreeDecoder flagTask) ~= 0
		  ifTrue: [ CMarkTaskItem ]
		  ifFalse: [ CMarkItem ]
]

{ #category : 'accessing' }
CMarkItem class >> typeCode [
	^ 16r8004
]

{ #category : 'accessing' }
CMarkItem class >> typeName [
	^ 'item'
]

{ #category : 'visiting' }
CMarkItem >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitItem: self
]

{ #category : 'printing' }
CMarkItem >> cmarkPrintAttributesOn: aStream [
	markerNumber = 0 ifTrue: [ ^ false ].
	aStream nextPutAll: 'marker '; print: markerNumber.
	^ true
]

{ #category : 'printing' }
CMarkItem >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' marker='; print: markerNumber
]

{ #category : 'decoding' }
CMarkItem >> cmarkRead: aDecoder record: base [
	markerNumber := aDecoder int1At: base
]

{ #category : 'initialization' }
CMarkItem >> initialize [
	super initialize.
	markerNumber := 0
]

{ #category : 'testing' }
CMarkItem >> isTask [
	"Whether I am a task list item"

	^ false
]

{ #category : 'accessing' }
CMarkItem >> markerNumber [
	"The number of my marker as written in the source, 0 for a bullet"

	^ markerNumber
]

{ #category : 'accessing' }
CMarkItem >> markerNumber: anInteger [
	markerNumber := anInteger
]

{ #category : 'accessing' }
CMarkItem >> markerText [
	"My marker as written in the source (the text from my start up to the first blank), or nil without a position"

	| source i j |
	self hasSourcePosition ifFalse: [ ^ nil ].
	source := self document ifNotNil: [ :d | d sourceString ].
	source ifNil: [ ^ nil ].
	i := startIndex.
	(i between: 1 and: source size) ifFalse: [ ^ nil ].
	j := i.
	[ j <= source size and: [ (#( 32 9 10 13 ) includes: (source at: j) asInteger) not ] ]
		whileTrue: [ j := j + 1 ].
	^ source copyFrom: i to: j - 1
]
