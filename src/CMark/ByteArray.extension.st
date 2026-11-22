Extension { #name : 'ByteArray' }

{ #category : '*CMark' }
ByteArray >> cmarkSource [
	"The source that the CMarkPlugin parses for me: myself (I am UTF-8); the plugin reads this exact class only, so a subclass falls back to my superclass"

	self class == ByteArray ifFalse: [ ^ super cmarkSource ].
	^ self
]

{ #category : '*CMark' }
ByteArray >> cmarkUtf8Decoded [
	"My bytes decoded from UTF-8 like utf8Decoded, but keeping every U+FEFF (the byte-order mark EF BB BF): Zinc drops it wherever it is (and raises on one at the end), while cmark-gfm and the CMarkPlugin count it as a character.  Bytes that are not UTF-8 signal a ZnCharacterEncodingError, as utf8Decoded does (EF never continues a sequence, so splitting at the marks keeps every sequence whole)"

	| marks start |
	marks := OrderedCollection new.
	start := 1.
	[ (start := ByteString indexOfAscii: 16rEF inString: self startingAt: start) > 0 ] whileTrue: [
		(start + 2 <= self size and: [ (self at: start + 1) = 16rBB and: [ (self at: start + 2) = 16rBF ] ])
			ifTrue: [
				marks add: start.
				start := start + 3 ]
			ifFalse: [ start := start + 1 ] ].
	marks isEmpty ifTrue: [ ^ self utf8Decoded ].
	^ WideString new: self size streamContents: [ :stream |
		  start := 1.
		  marks do: [ :each |
			  stream
				  nextPutAll: (self copyFrom: start to: each - 1) utf8Decoded;
				  nextPut: (Character value: 16rFEFF).
			  start := each + 3 ].
		  stream nextPutAll: (self copyFrom: start to: self size) utf8Decoded ]
]
