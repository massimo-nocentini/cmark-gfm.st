"
I am strong emphasis (**x** or __x__): my children are inlines.
"
Class {
	#name : 'CMarkStrong',
	#superclass : 'CMarkInlineNode',
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CMarkStrong class >> typeCode [
	^ 16rC008
]

{ #category : 'accessing' }
CMarkStrong class >> typeName [
	^ 'strong'
]

{ #category : 'visiting' }
CMarkStrong >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitStrong: self
]
