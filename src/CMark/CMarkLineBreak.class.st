"
I am a hard line break (two spaces or a backslash before a newline).  cmark gives me no position.
"
Class {
	#name : 'CMarkLineBreak',
	#superclass : 'CMarkInlineNode',
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CMarkLineBreak class >> typeCode [
	^ 16rC003
]

{ #category : 'accessing' }
CMarkLineBreak class >> typeName [
	^ 'linebreak'
]

{ #category : 'visiting' }
CMarkLineBreak >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitLineBreak: self
]

{ #category : 'plain text' }
CMarkLineBreak >> cmarkAppendPlainTextOn: aStream [
	aStream nextPut: Character lf
]
