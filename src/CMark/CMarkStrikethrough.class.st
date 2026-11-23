"
I am struck text of the strikethrough extension (`~~x~~`, or `~x~` unless `strikethroughDoubleTilde`): my children are inlines.
"
Class {
	#name : 'CMarkStrikethrough',
	#superclass : 'CMarkInlineNode',
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CMarkStrikethrough class >> typeCode [
	^ 16rC100
]

{ #category : 'accessing' }
CMarkStrikethrough class >> typeName [
	^ 'strikethrough'
]

{ #category : 'visiting' }
CMarkStrikethrough >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitStrikethrough: self
]
