"
I am a custom inline of cmark (made by programs, never by the parser): `onEnter` and `onExit` are the literal texts the renders put around my children.
"
Class {
	#name : 'CMarkCustomInline',
	#superclass : 'CMarkInlineNode',
	#instVars : [
		'onEnter',
		'onExit'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CMarkCustomInline class >> onEnter: aString onExit: anotherString [
	"A hand-built custom node"

	^ self new
		onEnter: aString;
		onExit: anotherString;
		yourself
]

{ #category : 'accessing' }
CMarkCustomInline class >> typeCode [
	^ 16rC006
]

{ #category : 'accessing' }
CMarkCustomInline class >> typeName [
	^ 'custom_inline'
]

{ #category : 'visiting' }
CMarkCustomInline >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitCustomInline: self
]

{ #category : 'printing' }
CMarkCustomInline >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' on_enter='.
	self cmarkPrintLiteral: onEnter on: aStream.
	aStream nextPutAll: ' on_exit='.
	self cmarkPrintLiteral: onExit on: aStream
]

{ #category : 'decoding' }
CMarkCustomInline >> cmarkRead: aDecoder record: base [
	onEnter := aDecoder string1At: base.
	onExit := aDecoder string2At: base
]

{ #category : 'initialization' }
CMarkCustomInline >> initialize [
	super initialize.
	onEnter := ''.
	onExit := ''
]

{ #category : 'accessing' }
CMarkCustomInline >> onEnter [
	"The literal text before my children in the renders"

	^ onEnter
]

{ #category : 'accessing' }
CMarkCustomInline >> onEnter: aString [
	onEnter := aString
]

{ #category : 'accessing' }
CMarkCustomInline >> onExit [
	"The literal text after my children in the renders"

	^ onExit
]

{ #category : 'accessing' }
CMarkCustomInline >> onExit: aString [
	onExit := aString
]
