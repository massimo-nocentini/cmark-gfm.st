"
I build an answer of `primitiveParse` by hand, for the tests that need no plugin: records of 16 words in a Bitmap and their strings in UTF-8 (`docs/CMark.md`, Tree format).

```smalltalk
b := CMarkTapeBuilder new source: '# Hi'.
h := b add: 16r8009 parent: 1.
b
	at: h int1: 1;
	at: h line: 1 column: 1 toLine: 1 column: 4;
	at: h from: 1 to: 4.
t := b add: 16rC001 parent: h.
b at: t str1: 'Hi'.
b decode
```

Record 1, the document, exists from the start. The ASCII flags of the strings and `HAS_POS` are set as the plugin sets them; the other flags with `at:flags:`. `answer` is the 9-slot Array; a test may break it before decoding it.
"
Class {
	#name : 'CMarkTapeBuilder',
	#superclass : 'Object',
	#instVars : [
		'records',
		'strings',
		'source',
		'sanitised',
		'options'
	],
	#category : 'CMark-Tests-Support',
	#package : 'CMark-Tests',
	#tag : 'Support'
}

{ #category : 'building' }
CMarkTapeBuilder >> add: aCode parent: aParentIndex [
	"Add a record of aCode under the record aParentIndex; answer its index"

	| record |
	record := Array new: 16 withAll: 0.
	record at: 1 put: aCode.
	record at: 2 put: aParentIndex.
	records add: record.
	^ records size
]

{ #category : 'building' }
CMarkTapeBuilder >> add: aCode parent: aParentIndex str1: aString [
	"Add a record of aCode with string 1 aString; answer its index"

	| i |
	i := self add: aCode parent: aParentIndex.
	self at: i str1: aString.
	^ i
]

{ #category : 'accessing' }
CMarkTapeBuilder >> answer [
	"The answer of primitiveParse: { status. code. tape. strings. nodeCount. depth. recordWords. sourceChars. sanitised } (a record whose parent does not come before it counts as depth 1)"

	| tape depths depth |
	tape := Bitmap new: records size * 16.
	records doWithIndex: [ :record :i |
		record doWithIndex: [ :word :k | tape at: i - 1 * 16 + k put: word ] ].
	depths := Array new: records size.
	depth := 0.
	records doWithIndex: [ :record :i |
		depths at: i put: (((record at: 2) between: 1 and: i - 1)
				 ifTrue: [ (depths at: (record at: 2)) + 1 ]
				 ifFalse: [ 1 ]).
		depth := depth max: (depths at: i) ].
	^ {
		  0.
		  0.
		  tape.
		  strings contents.
		  records size.
		  depth.
		  16.
		  source size.
		  sanitised }
]

{ #category : 'building' }
CMarkTapeBuilder >> at: anIndex flags: anInteger [
	"Set the flags anInteger (or-ed) on the record anIndex"

	self at: anIndex word: 3 put: ((self wordAt: anIndex word: 3) bitOr: anInteger)
]

{ #category : 'building' }
CMarkTapeBuilder >> at: anIndex from: startIndex to: endIndex [
	"Set the character indices of the record anIndex"

	self at: anIndex word: 8 put: startIndex.
	self at: anIndex word: 9 put: endIndex
]

{ #category : 'building' }
CMarkTapeBuilder >> at: anIndex int1: anInteger [
	self at: anIndex word: 10 put: anInteger
]

{ #category : 'building' }
CMarkTapeBuilder >> at: anIndex int2: anInteger [
	self at: anIndex word: 11 put: anInteger
]

{ #category : 'building' }
CMarkTapeBuilder >> at: anIndex int3: anInteger [
	self at: anIndex word: 12 put: anInteger
]

{ #category : 'building' }
CMarkTapeBuilder >> at: anIndex line: sl column: sc toLine: el column: ec [
	"Set the position of cmark of the record anIndex, and HAS_POS as the plugin does (sl >= 1 and sc >= 1)"

	self at: anIndex word: 4 put: sl.
	self at: anIndex word: 5 put: sc.
	self at: anIndex word: 6 put: el.
	self at: anIndex word: 7 put: ec.
	(sl >= 1 and: [ sc >= 1 ]) ifTrue: [ self at: anIndex flags: CMarkTreeDecoder flagHasPosition ]
]

{ #category : 'building' }
CMarkTapeBuilder >> at: anIndex str1: aString [
	"Set string 1 of the record anIndex, and its ASCII flag"

	self at: anIndex string: aString offsetWord: 13 flag: CMarkTreeDecoder flagStr1Ascii
]

{ #category : 'building' }
CMarkTapeBuilder >> at: anIndex str2: aString [
	"Set string 2 of the record anIndex, and its ASCII flag"

	self at: anIndex string: aString offsetWord: 15 flag: CMarkTreeDecoder flagStr2Ascii
]

{ #category : 'private' }
CMarkTapeBuilder >> at: anIndex string: aString offsetWord: k flag: aFlag [
	| bytes |
	bytes := aString utf8Encoded.
	self at: anIndex word: k put: strings position.
	self at: anIndex word: k + 1 put: bytes size.
	strings nextPutAll: bytes.
	(bytes allSatisfy: [ :each | each < 128 ]) ifTrue: [ self at: anIndex flags: aFlag ]
]

{ #category : 'building' }
CMarkTapeBuilder >> at: anIndex word: k put: anInteger [
	"Set the word k (1-based) of the record anIndex"

	(records at: anIndex) at: k put: anInteger
]

{ #category : 'decoding' }
CMarkTapeBuilder >> decode [
	"The CMarkDocument of my answer"

	^ CMarkTreeDecoder new decode: self answer source: source options: options
]

{ #category : 'initialization' }
CMarkTapeBuilder >> initialize [
	super initialize.
	records := OrderedCollection new.
	strings := WriteStream on: (ByteArray new: 256).
	source := ''.
	self add: CMarkDocument typeCode parent: 0
]

{ #category : 'accessing' }
CMarkTapeBuilder >> options: aCMarkOptions [
	options := aCMarkOptions
]

{ #category : 'accessing' }
CMarkTapeBuilder >> sanitised: aByteArray [
	sanitised := aByteArray
]

{ #category : 'accessing' }
CMarkTapeBuilder >> source [
	^ source
]

{ #category : 'accessing' }
CMarkTapeBuilder >> source: aStringOrByteArray [
	source := aStringOrByteArray
]

{ #category : 'accessing' }
CMarkTapeBuilder >> wordAt: anIndex word: k [
	^ (records at: anIndex) at: k
]
