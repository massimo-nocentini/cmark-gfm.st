"
I am a raw HTML tag, comment or declaration inside a paragraph: literal is the HTML as written.  Nothing interprets or runs it.

	CMarkHtmlInline literal: 'x'
"
Class {
	#name : 'CMarkHtmlInline',
	#superclass : 'CMarkInlineNode',
	#instVars : [
		'literal'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CMarkHtmlInline class >> literal: aString [
	"A hand-built node of aString"

	^ self new
		literal: aString;
		yourself
]

{ #category : 'accessing' }
CMarkHtmlInline class >> typeCode [
	^ 16rC005
]

{ #category : 'accessing' }
CMarkHtmlInline class >> typeName [
	^ 'html_inline'
]

{ #category : 'visiting' }
CMarkHtmlInline >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitHtmlInline: self
]

{ #category : 'plain text' }
CMarkHtmlInline >> cmarkAppendPlainTextOn: aStream [
	aStream nextPutAll: literal
]

{ #category : 'printing' }
CMarkHtmlInline >> cmarkPrintAttributesOn: aStream [
	self cmarkPrintShort: literal on: aStream.
	^ true
]

{ #category : 'printing' }
CMarkHtmlInline >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' literal='.
	self cmarkPrintLiteral: literal on: aStream
]

{ #category : 'decoding' }
CMarkHtmlInline >> cmarkRead: aDecoder record: base [
	literal := aDecoder string1At: base
]

{ #category : 'initialization' }
CMarkHtmlInline >> initialize [
	super initialize.
	literal := ''
]

{ #category : 'accessing' }
CMarkHtmlInline >> literal [
	"The raw HTML, as written"

	^ literal
]

{ #category : 'accessing' }
CMarkHtmlInline >> literal: aString [
	literal := aString
]
