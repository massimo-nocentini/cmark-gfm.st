"
I am a code span: `literal` is the code, its outer spaces stripped as CommonMark says.

```smalltalk
CMarkCode literal: 'x'
```
"
Class {
	#name : 'CMarkCode',
	#superclass : 'CMarkInlineNode',
	#instVars : [
		'literal'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CMarkCode class >> literal: aString [
	"A hand-built node of aString"

	^ self new
		literal: aString;
		yourself
]

{ #category : 'accessing' }
CMarkCode class >> typeCode [
	^ 16rC004
]

{ #category : 'accessing' }
CMarkCode class >> typeName [
	^ 'code'
]

{ #category : 'visiting' }
CMarkCode >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitCode: self
]

{ #category : 'plain text' }
CMarkCode >> cmarkAppendPlainTextOn: aStream [
	aStream nextPutAll: literal
]

{ #category : 'printing' }
CMarkCode >> cmarkPrintAttributesOn: aStream [
	self cmarkPrintShort: literal on: aStream.
	^ true
]

{ #category : 'printing' }
CMarkCode >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' literal='.
	self cmarkPrintLiteral: literal on: aStream
]

{ #category : 'decoding' }
CMarkCode >> cmarkRead: aDecoder record: base [
	literal := aDecoder string1At: base
]

{ #category : 'initialization' }
CMarkCode >> initialize [
	super initialize.
	literal := ''
]

{ #category : 'accessing' }
CMarkCode >> literal [
	"The code"

	^ literal
]

{ #category : 'accessing' }
CMarkCode >> literal: aString [
	literal := aString
]
