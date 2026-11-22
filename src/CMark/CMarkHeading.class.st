"
I am a heading of level 1 to 6: my children are inlines.  Whether I was written as an ATX heading (# x) or a setext one (x underlined) is private to cmark and not in the tape.  anchor is my anchor as GitHub makes it (slug, then -1, -2... for the repeats in my document).

	CMarkHeading level: 2 with: { CMarkText literal: 'Usage' }
"
Class {
	#name : 'CMarkHeading',
	#superclass : 'CMarkBlockNode',
	#instVars : [
		'level'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CMarkHeading class >> level: anInteger [
	"A hand-built heading of level anInteger"

	^ self new
		level: anInteger;
		yourself
]

{ #category : 'instance creation' }
CMarkHeading class >> level: anInteger with: anArray [
	"A hand-built heading of level anInteger whose children are the inlines of anArray"

	^ (self withAll: anArray)
		level: anInteger;
		yourself
]

{ #category : 'accessing' }
CMarkHeading class >> typeCode [
	^ 16r8009
]

{ #category : 'accessing' }
CMarkHeading class >> typeName [
	^ 'heading'
]

{ #category : 'visiting' }
CMarkHeading >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitHeading: self
]

{ #category : 'accessing' }
CMarkHeading >> anchor [
	"My anchor as GitHub makes it: my slug, then -1, -2... when an earlier heading of my document has the same slug"

	| d |
	d := self document.
	d ifNil: [ ^ self slug ].
	^ d headingAnchors at: self ifAbsent: [ self slug ]
]

{ #category : 'printing' }
CMarkHeading >> cmarkPrintAttributesOn: aStream [
	aStream nextPutAll: 'level '; print: level.
	^ true
]

{ #category : 'printing' }
CMarkHeading >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' level='; print: level
]

{ #category : 'decoding' }
CMarkHeading >> cmarkRead: aDecoder record: base [
	level := aDecoder int1At: base
]

{ #category : 'initialization' }
CMarkHeading >> initialize [
	super initialize.
	level := 1
]

{ #category : 'testing' }
CMarkHeading >> isHeading [
	^ true
]

{ #category : 'accessing' }
CMarkHeading >> level [
	"1 to 6"

	^ level
]

{ #category : 'accessing' }
CMarkHeading >> level: anInteger [
	level := anInteger
]

{ #category : 'accessing' }
CMarkHeading >> slug [
	"My plainText as GitHub makes an anchor of it: lowercased, every character but letters, digits, -, _ and spaces removed, the spaces made -"

	^ String streamContents: [ :stream |
		  self plainText asLowercase do: [ :each |
			  (each isLetter or: [ each isDigit or: [ each = $- or: [ each = $_ ] ] ])
				  ifTrue: [ stream nextPut: each ]
				  ifFalse: [ each = Character space ifTrue: [ stream nextPut: $- ] ] ] ]
]
