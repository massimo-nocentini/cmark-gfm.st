"
I turn the answer of primitiveParse into a tree of CMarkNodes, in pure Smalltalk and without recursion (docs/CMark.md, Tree format).  The answer is { status. code. tape. strings. nodeCount. depth. recordWords. sourceChars. sanitised }: the tape is a Bitmap of 16 words per node in pre-order (code, parent, flags, the positions of cmark, the character indices in the source, three integers and two strings per type), and strings a ByteArray of every string of the tree in UTF-8.

	CMarkTreeDecoder new decode: anAnswer source: aSource options: aCMarkOptions

Pass 1 checks the parents (each one comes before its child; record 1 is the document) and counts the children; pass 2 makes each node, by the class that owns its code (classForCode:, then cmarkClassForFlags: for the task items and the header rows), reads its fields (cmarkRead:record:) and puts it in its parent.  The footnote references are then linked to their definitions.  Any broken invariant signals CMarkMalformedTree.  The tests build tapes by hand, so I need no plugin.
"
Class {
	#name : 'CMarkTreeDecoder',
	#superclass : 'Object',
	#instVars : [
		'tape',
		'strings',
		'nodes',
		'classes',
		'references'
	],
	#category : 'CMark-Backends',
	#package : 'CMark',
	#tag : 'Backends'
}

{ #category : 'flags' }
CMarkTreeDecoder class >> flagChecked [
	"A task item: checked"

	^ 128
]

{ #category : 'flags' }
CMarkTreeDecoder class >> flagClamped [
	"A position pointed outside the source and was clamped by the plugin"

	^ 512
]

{ #category : 'flags' }
CMarkTreeDecoder class >> flagExtension [
	"The node belongs to an extension of cmark"

	^ 256
]

{ #category : 'flags' }
CMarkTreeDecoder class >> flagFenced [
	"A code block: fenced"

	^ 16
]

{ #category : 'flags' }
CMarkTreeDecoder class >> flagHasPosition [
	"The node has a position: words 4 to 9 are meaningful"

	^ 4
]

{ #category : 'flags' }
CMarkTreeDecoder class >> flagHeader [
	"A table row: the header row"

	^ 32
]

{ #category : 'flags' }
CMarkTreeDecoder class >> flagStr1Ascii [
	"String 1 has only bytes below 128"

	^ 1
]

{ #category : 'flags' }
CMarkTreeDecoder class >> flagStr2Ascii [
	"String 2 has only bytes below 128"

	^ 2
]

{ #category : 'flags' }
CMarkTreeDecoder class >> flagTask [
	"An item: a task list item"

	^ 64
]

{ #category : 'flags' }
CMarkTreeDecoder class >> flagTight [
	"A list: tight"

	^ 8
]

{ #category : 'accessing' }
CMarkTreeDecoder class >> recordWords [
	"The words of one record of the tape"

	^ 16
]

{ #category : 'decoding' }
CMarkTreeDecoder >> classForCode: anInteger [
	"The class that owns the node code anInteger, or CMarkUnknownBlock or CMarkUnknownInline (by the inline bit 16r4000) for a code that no class owns"

	^ self classes at: anInteger ifAbsent: [
		  (anInteger bitAnd: 16r4000) = 0
			  ifTrue: [ CMarkUnknownBlock ]
			  ifFalse: [ CMarkUnknownInline ] ]
]

{ #category : 'decoding' }
CMarkTreeDecoder >> classes [
	"The node classes by their codes: only the classes that own a code (typeCode not nil); two owners of one code are an error"

	classes ifNotNil: [ ^ classes ].
	classes := Dictionary new.
	CMarkNode allSubclasses do: [ :each |
		each typeCode ifNotNil: [ :code |
			(classes includesKey: code) ifTrue: [
				CMarkError signal:
					(classes at: code) name , ' and ' , each name , ' both answer the code ' , code printString ].
			classes at: code put: each ] ].
	^ classes
]

{ #category : 'decoding' }
CMarkTreeDecoder >> codeAt: base [
	"The node code of the record that starts after the word base"

	^ tape at: base + 1
]

{ #category : 'decoding' }
CMarkTreeDecoder >> decode: anAnswer source: aSource options: anOptions [
	"The CMarkDocument of anAnswer of primitiveParse (status 0) for aSource parsed with anOptions"

	| count counts fill base code parentIndex flags node parentNode k document |
	self readAnswer: anAnswer.
	count := anAnswer at: 5.
	counts := Array new: count withAll: 0.
	1 to: count do: [ :i |
		base := i - 1 * 16.
		code := tape at: base + 1.
		parentIndex := tape at: base + 2.
		i = 1
			ifTrue: [
				(parentIndex = 0 and: [ code = CMarkDocument typeCode ]) ifFalse: [
					self malformed: 'record 1 is not the document' ] ]
			ifFalse: [
				(parentIndex >= 1 and: [ parentIndex < i ]) ifFalse: [
					self malformed: 'record ' , i printString , ' has the parent ' , parentIndex printString ].
				counts at: parentIndex put: (counts at: parentIndex) + 1 ] ].
	nodes := Array new: count.
	fill := Array new: count withAll: 0.
	references := OrderedCollection new.
	1 to: count do: [ :i |
		base := i - 1 * 16.
		code := tape at: base + 1.
		flags := tape at: base + 3.
		node := ((self classForCode: code) cmarkClassForFlags: flags) basicNew initializeDecoded.
		node
			cmarkDecodedFlags: flags
			startLine: (tape at: base + 4)
			startByteColumn: (tape at: base + 5)
			endLine: (tape at: base + 6)
			endByteColumn: (tape at: base + 7)
			startIndex: (tape at: base + 8)
			endIndex: (tape at: base + 9).
		(counts at: i) > 0 ifTrue: [ node cmarkChildren: (Array new: (counts at: i)) ].
		nodes at: i put: node.
		i > 1 ifTrue: [
			parentIndex := tape at: base + 2.
			parentNode := nodes at: parentIndex.
			k := (fill at: parentIndex) + 1.
			fill at: parentIndex put: k.
			parentNode children at: k put: node.
			node cmarkParent: parentNode ].
		node cmarkRead: self record: base ].
	self linkFootnotes.
	document := nodes first.
	document
		cmarkDecodedSource: aSource
		options: anOptions
		nodeCount: count
		depth: (anAnswer at: 6)
		sanitised: (anAnswer at: 9).
	^ document
]

{ #category : 'decoding' }
CMarkTreeDecoder >> int1At: base [
	"Integer 1 of the record that starts after the word base"

	^ tape at: base + 10
]

{ #category : 'decoding' }
CMarkTreeDecoder >> int2At: base [
	"Integer 2 of the record that starts after the word base"

	^ tape at: base + 11
]

{ #category : 'decoding' }
CMarkTreeDecoder >> int3At: base [
	"Integer 3 of the record that starts after the word base"

	^ tape at: base + 12
]

{ #category : 'private' }
CMarkTreeDecoder >> linkFootnotes [
	"Link each footnote reference to its definition; then each definition's references are in source order, and their referenceIndex their rank there (cmark numbers the references in document order before it moves the definitions to the end)"

	| definitions |
	definitions := IdentitySet new.
	references do: [ :each |
		| definition |
		definition := nodes at: each value.
		definition cmarkAddDecodedReference: each key.
		definitions add: definition ].
	definitions do: [ :each | each cmarkSortReferences ]
]

{ #category : 'private' }
CMarkTreeDecoder >> malformed: aString [
	^ CMarkMalformedTree signal: aString
]

{ #category : 'decoding' }
CMarkTreeDecoder >> noteFootnoteReference: aReference definitionRecord: anInteger [
	"aReference points at the definition of record anInteger (0: none); they are linked when every node exists"

	anInteger = 0 ifTrue: [ ^ self ].
	(anInteger between: 1 and: nodes size) ifFalse: [
		self malformed: 'a footnote reference points at the record ' , anInteger printString ].
	references add: aReference -> anInteger
]

{ #category : 'private' }
CMarkTreeDecoder >> readAnswer: anAnswer [
	"Check the shape of anAnswer and keep its tape and strings"

	| count |
	(anAnswer isArray and: [ anAnswer size = 9 ]) ifFalse: [
		self malformed: 'the answer is not an Array of 9' ].
	(anAnswer at: 7) = self class recordWords ifFalse: [
		self malformed: 'the records have ' , (anAnswer at: 7) printString , ' words, not 16' ].
	count := anAnswer at: 5.
	(count isInteger and: [ count >= 1 ]) ifFalse: [
		self malformed: 'the node count is ' , count printString ].
	tape := anAnswer at: 3.
	(tape notNil and: [ tape size = (count * self class recordWords) ]) ifFalse: [
		self malformed: 'the tape does not hold ' , count printString , ' records' ].
	strings := anAnswer at: 4.
	strings ifNil: [ strings := #[  ] ]
]

{ #category : 'decoding' }
CMarkTreeDecoder >> string1At: base [
	"String 1 of the record that starts after the word base"

	^ self
		  stringAt: (tape at: base + 13)
		  length: (tape at: base + 14)
		  ascii: ((tape at: base + 3) bitAnd: self class flagStr1Ascii) ~= 0
]

{ #category : 'decoding' }
CMarkTreeDecoder >> string2At: base [
	"String 2 of the record that starts after the word base"

	^ self
		  stringAt: (tape at: base + 15)
		  length: (tape at: base + 16)
		  ascii: ((tape at: base + 3) bitAnd: self class flagStr2Ascii) ~= 0
]

{ #category : 'decoding' }
CMarkTreeDecoder >> stringAt: offset length: length ascii: aBoolean [
	"The String of the length bytes of the strings after the 0-based offset: a ByteString copied by a primitive when aBoolean (only bytes below 128), else decoded from UTF-8"

	length = 0 ifTrue: [ ^ String new ].
	offset + length <= strings size ifFalse: [
		self malformed:
			'a string of ' , length printString , ' bytes at ' , offset printString , ' is outside the strings' ].
	aBoolean ifTrue: [
		^ (ByteString new: length)
			  replaceFrom: 1
			  to: length
			  with: strings
			  startingAt: offset + 1 ].
	^ [ (strings copyFrom: offset + 1 to: offset + length) utf8Decoded ]
		  on: ZnCharacterEncodingError
		  do: [ :e | self malformed: 'a string is not UTF-8' ]
]
