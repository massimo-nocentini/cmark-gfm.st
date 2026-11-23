"
I check the code of CMark-Calypso and CMark-Calypso-Tests: no method uses an undeclared variable, the scratch classes leave nothing in Undeclared, and every selector that a method sends is implemented somewhere in the image.
"
Class {
	#name : 'CMarkCalypsoPackageTest',
	#superclass : 'CMarkCalypsoTestCase',
	#category : 'CMark-Calypso-Tests-Tests',
	#package : 'CMark-Calypso-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkCalypsoPackageTest >> methods [
	"The methods of CMark-Calypso and CMark-Calypso-Tests"

	^ #( 'CMark-Calypso' 'CMark-Calypso-Tests' ) flatCollect: [ :each | each asPackage methods ]
]

{ #category : 'tests' }
CMarkCalypsoPackageTest >> testEverySentSelectorIsImplemented [
	| missing |
	missing := OrderedCollection new.
	self methods do: [ :method |
		method messages do: [ :selector |
			(SystemNavigation default allImplementorsOf: selector) ifEmpty: [ missing add: method printString -> selector ] ] ].
	self assert: missing asArray equals: #(  )
]

{ #category : 'tests' }
CMarkCalypsoPackageTest >> testNoUndeclaredVariable [
	self assert: (self methods select: [ :each | each usesUndeclareds ]) asArray equals: #(  ).
	"the scratch classes of the tests leave no binding in Undeclared (tearDown)"
	self assert: (Undeclared keys select: [ :each | each beginsWith: 'CMarkCalypso' ]) asArray equals: #(  )
]
