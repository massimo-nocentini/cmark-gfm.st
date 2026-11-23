"
I am signalled when Markdown must be parsed or rendered and the VM has no usable `CMarkPlugin`: the module is missing, or it speaks another protocol than the one of `CMarkPrimitives`. Nothing has been touched when I am signalled. Hand-built trees, their walks and the visitor need no plugin.
"
Class {
	#name : 'CMarkUnavailable',
	#superclass : 'CMarkError',
	#category : 'CMark-Errors',
	#package : 'CMark',
	#tag : 'Errors'
}

{ #category : 'signalling' }
CMarkUnavailable class >> signalProtocol: anInteger expected: expectedInteger [
	"Signal that the plugin answers anInteger as its protocol, not expectedInteger"

	^ self new signal: 'CMarkPlugin speaks protocol ' , anInteger printString , ', not ' , expectedInteger printString
]

{ #category : 'accessing' }
CMarkUnavailable >> messageText [
	^ messageText ifNil: [ 'CMarkPlugin not available' ]
]
