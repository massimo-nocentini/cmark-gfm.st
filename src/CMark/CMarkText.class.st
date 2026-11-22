"
I am a run of text: literal is the text, entities and escapes resolved.

	CMarkText literal: 'x'
"
Class {
	#name : 'CMarkText',
	#superclass : 'CMarkInlineNode',
	#instVars : [
		'literal'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CMarkText class >> literal: aString [
	"A hand-built node of aString"

	^ self new
		literal: aString;
		yourself
]

{ #category : 'accessing' }
CMarkText class >> typeCode [
	^ 16rC001
]

{ #category : 'accessing' }
CMarkText class >> typeName [
	^ 'text'
]

{ #category : 'visiting' }
CMarkText >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitText: self
]

{ #category : 'plain text' }
CMarkText >> cmarkAppendPlainTextOn: aStream [
	aStream nextPutAll: literal
]

{ #category : 'printing' }
CMarkText >> cmarkPrintAttributesOn: aStream [
	self cmarkPrintShort: literal on: aStream.
	^ true
]

{ #category : 'printing' }
CMarkText >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' literal='.
	self cmarkPrintLiteral: literal on: aStream
]

{ #category : 'decoding' }
CMarkText >> cmarkRead: aDecoder record: base [
	literal := aDecoder string1At: base
]

{ #category : 'initialization' }
CMarkText >> initialize [
	super initialize.
	literal := ''
]

{ #category : 'accessing' }
CMarkText >> literal [
	"The text, entities and escapes resolved"

	^ literal
]

{ #category : 'accessing' }
CMarkText >> literal: aString [
	literal := aString
]
