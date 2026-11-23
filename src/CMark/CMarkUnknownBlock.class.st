"
I am a block of a type that the tape has no code for (a newer cmark, or an extension that CMark does not know): `rawType` is the type of cmark, `typeString` its name. My children are kept.
"
Class {
	#name : 'CMarkUnknownBlock',
	#superclass : 'CMarkBlockNode',
	#instVars : [
		'rawType',
		'typeString'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CMarkUnknownBlock class >> typeCode [
	^ 16r80FF
]

{ #category : 'accessing' }
CMarkUnknownBlock class >> typeName [
	^ 'unknown_block'
]

{ #category : 'visiting' }
CMarkUnknownBlock >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitUnknownBlock: self
]

{ #category : 'printing' }
CMarkUnknownBlock >> cmarkPrintAttributesOn: aStream [
	aStream print: typeString.
	^ true
]

{ #category : 'printing' }
CMarkUnknownBlock >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' raw='; print: rawType; nextPutAll: ' type='.
	self cmarkPrintLiteral: typeString on: aStream
]

{ #category : 'decoding' }
CMarkUnknownBlock >> cmarkRead: aDecoder record: base [
	"Integer 1 is the raw type of cmark; for a code that no class owns, the code itself"

	rawType := aDecoder int1At: base.
	rawType = 0 ifTrue: [ rawType := aDecoder codeAt: base ].
	typeString := aDecoder string1At: base
]

{ #category : 'initialization' }
CMarkUnknownBlock >> initialize [
	super initialize.
	rawType := 0.
	typeString := ''
]

{ #category : 'accessing' }
CMarkUnknownBlock >> rawType [
	"The type of cmark (a runtime value of cmark)"

	^ rawType
]

{ #category : 'accessing' }
CMarkUnknownBlock >> rawType: anInteger [
	rawType := anInteger
]

{ #category : 'accessing' }
CMarkUnknownBlock >> typeName [
	"The type string of cmark, or mine when cmark gave none"

	^ typeString isEmpty
		  ifTrue: [ self class typeName ]
		  ifFalse: [ typeString ]
]

{ #category : 'accessing' }
CMarkUnknownBlock >> typeString [
	"The type string of cmark (cmark_node_get_type_string)"

	^ typeString
]

{ #category : 'accessing' }
CMarkUnknownBlock >> typeString: aString [
	typeString := aString
]
