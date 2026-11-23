"
I am a thematic break (`***`, `---`, `___`): I have no children.
"
Class {
	#name : 'CMarkThematicBreak',
	#superclass : 'CMarkBlockNode',
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CMarkThematicBreak class >> typeCode [
	^ 16r800A
]

{ #category : 'accessing' }
CMarkThematicBreak class >> typeName [
	^ 'thematic_break'
]

{ #category : 'visiting' }
CMarkThematicBreak >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitThematicBreak: self
]
