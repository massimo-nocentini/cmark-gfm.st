Extension { #name : 'WideString' }

{ #category : '*CMark' }
WideString >> cmarkSource [
	"The source that the CMarkPlugin parses for me: myself (I am UTF-32, one word per character); the plugin reads this exact class only, so a subclass falls back to my superclass"

	self class == WideString ifFalse: [ ^ super cmarkSource ].
	^ self
]
