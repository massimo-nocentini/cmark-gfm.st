"
I stand for the inspector's StInspectionContext: I record what active: was given.
"
Class {
	#name : 'CMarkContextStub',
	#superclass : 'Object',
	#instVars : [
		'active'
	],
	#category : 'CMark-Tests-Support',
	#package : 'CMark-Tests',
	#tag : 'Support'
}

{ #category : 'accessing' }
CMarkContextStub >> active [
	^ active
]

{ #category : 'accessing' }
CMarkContextStub >> active: aBoolean [
	active := aBoolean
]
