"
I am signalled when a source is too large: over the maxInputSize of the CMarkOptions (checked before any call on the size of the source, in characters or, for a ByteArray, in bytes), or over the cap of the plugin (CM_MAX_INPUT_BYTES, 256 MiB of sanitised UTF-8, status 2 of the plugin).
"
Class {
	#name : 'CMarkInputTooLarge',
	#superclass : 'CMarkLimitExceeded',
	#category : 'CMark-Errors',
	#package : 'CMark',
	#tag : 'Errors'
}

{ #category : 'accessing' }
CMarkInputTooLarge >> limitName [
	^ 'the input size'
]
