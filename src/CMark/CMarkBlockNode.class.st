"
I am the abstract block node of a parse tree of cmark-gfm (the block bit of the tape codes: 16r8000).
"
Class {
	#name : 'CMarkBlockNode',
	#superclass : 'CMarkNode',
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'testing' }
CMarkBlockNode class >> isAbstract [
	^ self == CMarkBlockNode
]

{ #category : 'testing' }
CMarkBlockNode >> isBlock [
	^ true
]
