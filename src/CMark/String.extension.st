Extension { #name : 'String' }

{ #category : '*CMark' }
String >> cmarkSource [
	"The source that the CMarkPlugin parses for me: my characters as a ByteString or a WideString (a Symbol, or another subclass of String, is converted)"

	^ self asString
]
