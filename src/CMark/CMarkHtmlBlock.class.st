"
I am a block of raw HTML: literal is the HTML as written, line terminators included.  The kind of HTML block (cmark's 7 kinds) is private to cmark and not in the tape.  Nothing interprets or runs it.

	CMarkHtmlBlock literal: 'x'
"
Class {
	#name : 'CMarkHtmlBlock',
	#superclass : 'CMarkBlockNode',
	#instVars : [
		'literal'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CMarkHtmlBlock class >> literal: aString [
	"A hand-built node of aString"

	^ self new
		literal: aString;
		yourself
]

{ #category : 'accessing' }
CMarkHtmlBlock class >> typeCode [
	^ 16r8006
]

{ #category : 'accessing' }
CMarkHtmlBlock class >> typeName [
	^ 'html_block'
]

{ #category : 'visiting' }
CMarkHtmlBlock >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitHtmlBlock: self
]

{ #category : 'printing' }
CMarkHtmlBlock >> cmarkPrintAttributesOn: aStream [
	self cmarkPrintShort: literal on: aStream.
	^ true
]

{ #category : 'printing' }
CMarkHtmlBlock >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' literal='.
	self cmarkPrintLiteral: literal on: aStream
]

{ #category : 'decoding' }
CMarkHtmlBlock >> cmarkRead: aDecoder record: base [
	literal := aDecoder string1At: base
]

{ #category : 'initialization' }
CMarkHtmlBlock >> initialize [
	super initialize.
	literal := ''
]

{ #category : 'accessing' }
CMarkHtmlBlock >> literal [
	"The raw HTML, as written"

	^ literal
]

{ #category : 'accessing' }
CMarkHtmlBlock >> literal: aString [
	literal := aString
]
