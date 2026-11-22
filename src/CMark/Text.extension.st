Extension { #name : 'Text' }

{ #category : '*CMark' }
Text >> cmarkSource [
	"The source that the CMarkPlugin parses for me: my characters, without their attributes"

	^ self asString
]
