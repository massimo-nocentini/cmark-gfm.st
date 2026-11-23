"
I am a custom block of cmark (made by programs, never by the parser): `onEnter` and `onExit` are the literal texts the renders put around my children.
"
Class {
	#name : 'CMarkCustomBlock',
	#superclass : 'CMarkBlockNode',
	#instVars : [
		'onEnter',
		'onExit'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CMarkCustomBlock class >> onEnter: aString onExit: anotherString [
	"A hand-built custom node"

	^ self new
		onEnter: aString;
		onExit: anotherString;
		yourself
]

{ #category : 'accessing' }
CMarkCustomBlock class >> typeCode [
	^ 16r8007
]

{ #category : 'accessing' }
CMarkCustomBlock class >> typeName [
	^ 'custom_block'
]

{ #category : 'visiting' }
CMarkCustomBlock >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitCustomBlock: self
]

{ #category : 'printing' }
CMarkCustomBlock >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' on_enter='.
	self cmarkPrintLiteral: onEnter on: aStream.
	aStream nextPutAll: ' on_exit='.
	self cmarkPrintLiteral: onExit on: aStream
]

{ #category : 'decoding' }
CMarkCustomBlock >> cmarkRead: aDecoder record: base [
	onEnter := aDecoder string1At: base.
	onExit := aDecoder string2At: base
]

{ #category : 'initialization' }
CMarkCustomBlock >> initialize [
	super initialize.
	onEnter := ''.
	onExit := ''
]

{ #category : 'accessing' }
CMarkCustomBlock >> onEnter [
	"The literal text before my children in the renders"

	^ onEnter
]

{ #category : 'accessing' }
CMarkCustomBlock >> onEnter: aString [
	onEnter := aString
]

{ #category : 'accessing' }
CMarkCustomBlock >> onExit [
	"The literal text after my children in the renders"

	^ onExit
]

{ #category : 'accessing' }
CMarkCustomBlock >> onExit: aString [
	onExit := aString
]
