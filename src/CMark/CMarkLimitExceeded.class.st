"
I am the abstract error of a limit that a parse or a render went over: limit is the limit (nil when it is not known), actual the size or depth reached (nil when it is not known).  My subclasses say which limit.
"
Class {
	#name : 'CMarkLimitExceeded',
	#superclass : 'CMarkError',
	#instVars : [
		'limit',
		'actual'
	],
	#category : 'CMark-Errors',
	#package : 'CMark',
	#tag : 'Errors'
}

{ #category : 'testing' }
CMarkLimitExceeded class >> isAbstract [
	^ self == CMarkLimitExceeded
]

{ #category : 'signalling' }
CMarkLimitExceeded class >> signalLimit: aLimit actual: anActual [
	"Signal that anActual went over aLimit"

	^ self new
		limit: aLimit;
		actual: anActual;
		signal
]

{ #category : 'accessing' }
CMarkLimitExceeded >> actual [
	"The size or depth reached, or nil when it is not known"

	^ actual
]

{ #category : 'accessing' }
CMarkLimitExceeded >> actual: anInteger [
	actual := anInteger
]

{ #category : 'accessing' }
CMarkLimitExceeded >> limit [
	"The limit that was exceeded, or nil when it is not known"

	^ limit
]

{ #category : 'accessing' }
CMarkLimitExceeded >> limit: anInteger [
	limit := anInteger
]

{ #category : 'accessing' }
CMarkLimitExceeded >> limitName [
	"What the limit is about, for the message"

	^ 'a limit'
]

{ #category : 'accessing' }
CMarkLimitExceeded >> messageText [
	^ messageText ifNil: [
		  String streamContents: [ :s |
			  s nextPutAll: self limitName; nextPutAll: ' was exceeded'.
			  actual ifNotNil: [ s nextPutAll: ': '; print: actual ].
			  limit ifNotNil: [ s nextPutAll: ' (limit '; print: limit; nextPut: $) ] ] ]
]
