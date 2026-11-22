Extension { #name : 'ByteArray' }

{ #category : '*CMark' }
ByteArray >> cmarkSource [
	"The source that the CMarkPlugin parses for me: myself (I am UTF-8); the plugin reads this exact class only, so a subclass falls back to my superclass"

	self class == ByteArray ifFalse: [ ^ super cmarkSource ].
	^ self
]
