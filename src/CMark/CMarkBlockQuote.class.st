"
I am a block quote: my children are blocks.  GitHub alerts (> [!NOTE]) are plain block quotes to cmark.
"
Class {
	#name : 'CMarkBlockQuote',
	#superclass : 'CMarkBlockNode',
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CMarkBlockQuote class >> typeCode [
	^ 16r8002
]

{ #category : 'accessing' }
CMarkBlockQuote class >> typeName [
	^ 'block_quote'
]

{ #category : 'visiting' }
CMarkBlockQuote >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitBlockQuote: self
]
