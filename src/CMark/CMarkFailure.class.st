"
I am the error code of a failed primitive of the `CMarkPlugin` (`ec`: a Symbol such as `#'bad argument'` or `#'insufficient object memory'`, or nil when the module is missing).

A primitive fails only on a bug of the caller or when an object allocation fails; limits are statuses of the answer, not failures (`docs/CMark.md`, Primitive contract). A missing extension of the plugin (`PrimErrNotFound`) also reads `#'not found'`: `pluginInfo` tells it apart from a missing module.
"
Class {
	#name : 'CMarkFailure',
	#superclass : 'Object',
	#instVars : [
		'ec'
	],
	#category : 'CMark-Backends',
	#package : 'CMark',
	#tag : 'Backends'
}

{ #category : 'instance creation' }
CMarkFailure class >> on: errorCode [
	"The error code of a failed primitive of the plugin (nil when the module is missing)"

	^ self new
		ec: errorCode;
		yourself
]

{ #category : 'testing' }
CMarkFailure >> cmarkFailed [
	"Whether a primitive call failed: I am a failure"

	^ true
]

{ #category : 'accessing' }
CMarkFailure >> ec [
	^ ec
]

{ #category : 'accessing' }
CMarkFailure >> ec: errorCode [
	ec := errorCode
]

{ #category : 'testing' }
CMarkFailure >> isNoMemory [
	"Whether an object allocation of the primitive failed (PrimErrNoMemory, 9)"

	^ ec = #'insufficient object memory' or: [ ec = 9 ]
]

{ #category : 'testing' }
CMarkFailure >> isUnavailable [
	"Whether the module could not be loaded, or it has no such primitive"

	^ ec isNil or: [ ec = #'not found' ]
]

{ #category : 'printing' }
CMarkFailure >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(; print: ec; nextPut: $)
]
