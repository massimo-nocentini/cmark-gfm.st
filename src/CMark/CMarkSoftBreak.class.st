"
I am a soft line break (a newline inside a paragraph): the renders make me a space or a newline (`hardBreaks`, `noBreaks`). cmark gives me no position.
"
Class {
	#name : 'CMarkSoftBreak',
	#superclass : 'CMarkInlineNode',
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CMarkSoftBreak class >> typeCode [
	^ 16rC002
]

{ #category : 'accessing' }
CMarkSoftBreak class >> typeName [
	^ 'softbreak'
]

{ #category : 'visiting' }
CMarkSoftBreak >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitSoftBreak: self
]

{ #category : 'plain text' }
CMarkSoftBreak >> cmarkAppendPlainTextOn: aStream [
	aStream space
]
