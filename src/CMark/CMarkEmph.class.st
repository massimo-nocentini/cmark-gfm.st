"
I am emphasis (*x* or _x_): my children are inlines.
"
Class {
	#name : 'CMarkEmph',
	#superclass : 'CMarkInlineNode',
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CMarkEmph class >> typeCode [
	^ 16rC007
]

{ #category : 'accessing' }
CMarkEmph class >> typeName [
	^ 'emph'
]

{ #category : 'visiting' }
CMarkEmph >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitEmph: self
]
