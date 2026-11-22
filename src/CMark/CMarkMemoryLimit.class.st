"
I am signalled when the C memory of a parse or a render went over a limit of the plugin (status 4): reason is #budget (the C budget of the call, cBudget of the CMarkOptions or the default of the plugin), #block (one allocation of cmark over 256 MiB, which a line or a paragraph of about 170 MiB reaches) or #malloc (the C heap had no memory).  The plugin freed everything before answering.
"
Class {
	#name : 'CMarkMemoryLimit',
	#superclass : 'CMarkLimitExceeded',
	#instVars : [
		'reason'
	],
	#category : 'CMark-Errors',
	#package : 'CMark',
	#tag : 'Errors'
}

{ #category : 'accessing' }
CMarkMemoryLimit class >> reasonForCode: anInteger [
	"The reason of the code of status 4 of the plugin: 1 #budget, 2 #block, 3 #malloc, anything else nil"

	anInteger = 1 ifTrue: [ ^ #budget ].
	anInteger = 2 ifTrue: [ ^ #block ].
	anInteger = 3 ifTrue: [ ^ #malloc ].
	^ nil
]

{ #category : 'signalling' }
CMarkMemoryLimit class >> signalCode: anInteger limit: aLimit [
	"Signal the reason of the code of status 4 of the plugin"

	^ self new
		reason: (self reasonForCode: anInteger);
		limit: aLimit;
		signal
]

{ #category : 'accessing' }
CMarkMemoryLimit >> limitName [
	reason == #budget ifTrue: [ ^ 'the C budget' ].
	reason == #block ifTrue: [ ^ 'the C block size' ].
	reason == #malloc ifTrue: [ ^ 'the C heap' ].
	^ 'the C memory'
]

{ #category : 'accessing' }
CMarkMemoryLimit >> reason [
	"#budget, #block or #malloc"

	^ reason
]

{ #category : 'accessing' }
CMarkMemoryLimit >> reason: aSymbol [
	reason := aSymbol
]
