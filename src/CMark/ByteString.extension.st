Extension { #name : 'ByteString' }

{ #category : '*CMark' }
ByteString >> cmarkSource [
	"The source that the CMarkPlugin parses for me: myself (I am Latin-1, one byte per character); the plugin reads this exact class only, so a subclass falls back to my superclass"

	self class == ByteString ifFalse: [ ^ super cmarkSource ].
	^ self
]
