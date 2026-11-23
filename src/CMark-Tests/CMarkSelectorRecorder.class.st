"
I record every message I do not understand: given to `acceptCMarkVisitor:`, I tell which visit method a node class sends.
"
Class {
	#name : 'CMarkSelectorRecorder',
	#superclass : 'Object',
	#instVars : [
		'selectors'
	],
	#category : 'CMark-Tests-Support',
	#package : 'CMark-Tests',
	#tag : 'Support'
}

{ #category : 'reflective operations' }
CMarkSelectorRecorder >> doesNotUnderstand: aMessage [
	selectors add: aMessage selector.
	^ aMessage arguments first
]

{ #category : 'initialization' }
CMarkSelectorRecorder >> initialize [
	super initialize.
	selectors := OrderedCollection new
]

{ #category : 'accessing' }
CMarkSelectorRecorder >> selectors [
	^ selectors
]
