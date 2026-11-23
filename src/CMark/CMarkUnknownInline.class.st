"
I am an inline of a type that the tape has no code for (a newer cmark, or an extension that CMark does not know): `rawType` is the type of cmark, `typeString` its name. My children are kept.
"
Class {
	#name : 'CMarkUnknownInline',
	#superclass : 'CMarkInlineNode',
	#instVars : [
		'rawType',
		'typeString'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CMarkUnknownInline class >> typeCode [
	^ 16rC0FF
]

{ #category : 'accessing' }
CMarkUnknownInline class >> typeName [
	^ 'unknown_inline'
]

{ #category : 'visiting' }
CMarkUnknownInline >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitUnknownInline: self
]

{ #category : 'printing' }
CMarkUnknownInline >> cmarkPrintAttributesOn: aStream [
	aStream print: typeString.
	^ true
]

{ #category : 'printing' }
CMarkUnknownInline >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' raw='; print: rawType; nextPutAll: ' type='.
	self cmarkPrintLiteral: typeString on: aStream
]

{ #category : 'decoding' }
CMarkUnknownInline >> cmarkRead: aDecoder record: base [
	"Integer 1 is the raw type of cmark; for a code that no class owns, the code itself"

	rawType := aDecoder int1At: base.
	rawType = 0 ifTrue: [ rawType := aDecoder codeAt: base ].
	typeString := aDecoder string1At: base
]

{ #category : 'initialization' }
CMarkUnknownInline >> initialize [
	super initialize.
	rawType := 0.
	typeString := ''
]

{ #category : 'accessing' }
CMarkUnknownInline >> rawType [
	"The type of cmark (a runtime value of cmark)"

	^ rawType
]

{ #category : 'accessing' }
CMarkUnknownInline >> rawType: anInteger [
	rawType := anInteger
]

{ #category : 'accessing' }
CMarkUnknownInline >> typeName [
	"The type string of cmark, or mine when cmark gave none"

	^ typeString isEmpty
		  ifTrue: [ self class typeName ]
		  ifFalse: [ typeString ]
]

{ #category : 'accessing' }
CMarkUnknownInline >> typeString [
	"The type string of cmark (cmark_node_get_type_string)"

	^ typeString
]

{ #category : 'accessing' }
CMarkUnknownInline >> typeString: aString [
	typeString := aString
]
