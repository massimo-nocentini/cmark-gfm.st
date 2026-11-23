"
I test the errors of CMark: all under `CMarkError`, their accessors and messages, and the reasons of `CMarkMemoryLimit`.
"
Class {
	#name : 'CMarkErrorTest',
	#superclass : 'CMarkTestCase',
	#category : 'CMark-Tests-Tests',
	#package : 'CMark-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
CMarkErrorTest >> testHierarchy [
	{ CMarkUnavailable. CMarkLimitExceeded. CMarkInputTooLarge. CMarkTooDeep. CMarkMemoryLimit. CMarkMalformedTree } do: [ :each |
		self assert: (each inheritsFrom: CMarkError) ].
	self assert: (CMarkError inheritsFrom: Error).
	self assert: CMarkLimitExceeded isAbstract.
	self deny: CMarkTooDeep isAbstract.
	{ CMarkInputTooLarge. CMarkTooDeep. CMarkMemoryLimit } do: [ :each |
		self assert: (each inheritsFrom: CMarkLimitExceeded) ].
	self deny: (OutOfMemory inheritsFrom: CMarkError)
]

{ #category : 'tests' }
CMarkErrorTest >> testLimits [
	| e |
	e := [ CMarkTooDeep signalLimit: 100 actual: 101 ]
		     on: CMarkError
		     do: [ :ex | ex ].
	self assert: e class identicalTo: CMarkTooDeep.
	self assert: e limit equals: 100.
	self assert: e actual equals: 101.
	self assert: e messageText equals: 'the tree depth was exceeded: 101 (limit 100)'.
	e := [ CMarkInputTooLarge signalLimit: 10 actual: 11 ]
		     on: CMarkLimitExceeded
		     do: [ :ex | ex ].
	self assert: e messageText equals: 'the input size was exceeded: 11 (limit 10)'.
	e := [ CMarkInputTooLarge new signal: 'custom' ]
		     on: CMarkInputTooLarge
		     do: [ :ex | ex ].
	self assert: e messageText equals: 'custom'
]

{ #category : 'tests' }
CMarkErrorTest >> testMemoryLimit [
	| e |
	self assert: (CMarkMemoryLimit reasonForCode: 1) equals: #budget.
	self assert: (CMarkMemoryLimit reasonForCode: 2) equals: #block.
	self assert: (CMarkMemoryLimit reasonForCode: 3) equals: #malloc.
	self assert: (CMarkMemoryLimit reasonForCode: 4) isNil.
	e := [ CMarkMemoryLimit signalCode: 1 limit: 4096 ]
		     on: CMarkError
		     do: [ :ex | ex ].
	self assert: e reason equals: #budget.
	self assert: e limit equals: 4096.
	self assert: e actual isNil.
	self assert: e messageText equals: 'the C budget was exceeded (limit 4096)'.
	e := [ CMarkMemoryLimit signalCode: 2 limit: nil ]
		     on: CMarkError
		     do: [ :ex | ex ].
	self assert: e messageText equals: 'the C block size was exceeded'.
	e := [ CMarkMemoryLimit signalCode: 3 limit: nil ]
		     on: CMarkError
		     do: [ :ex | ex ].
	self assert: e reason equals: #malloc
]

{ #category : 'tests' }
CMarkErrorTest >> testUnavailable [
	| e |
	e := [ CMarkUnavailable new signal ]
		     on: CMarkError
		     do: [ :ex | ex ].
	self assert: e messageText equals: 'CMarkPlugin not available'.
	e := [ CMarkUnavailable signalProtocol: 2 expected: 1 ]
		     on: CMarkUnavailable
		     do: [ :ex | ex ].
	self assert: e messageText equals: 'CMarkPlugin speaks protocol 2, not 1'
]
