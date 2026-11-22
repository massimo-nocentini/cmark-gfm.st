Extension { #name : 'ProtoObject' }

{ #category : '*CMark' }
ProtoObject >> cmarkFailed [
	"Whether I am the answer of a failed primitive of the CMarkPlugin: no"

	^ false
]

{ #category : '*CMark' }
ProtoObject >> cmarkSource [
	"The source that the CMarkPlugin parses for me: I am neither a String nor a ByteArray"

	^ CMarkError signal: 'not a String or ByteArray'
]
