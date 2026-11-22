"
I am the abstract inline node of a parse tree of cmark-gfm (the inline bit of the tape codes: 16rC000).
"
Class {
	#name : 'CMarkInlineNode',
	#superclass : 'CMarkNode',
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'testing' }
CMarkInlineNode class >> isAbstract [
	^ self == CMarkInlineNode
]

{ #category : 'testing' }
CMarkInlineNode >> isInline [
	^ true
]
