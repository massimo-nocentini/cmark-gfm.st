"
I am the root of a parse tree: my children are the blocks of the source.  I keep the source I was parsed from (a String or a ByteArray of UTF-8), the CMarkOptions, the node count and the depth of the deepest node (treeDepth) of the answer of the plugin.  sourceString is the source as a String, against which the startIndex and endIndex of every node count: the source itself when it is a String; for a ByteArray, decoded from the sanitised bytes of the plugin when the source was not valid UTF-8 (each bad byte is one U+FFFD there, and NUL is U+FFFD), else from the source.

	CMarkDocument source: '# Hi'

answers a hand-built document, with no children and no positions.  The footnote definitions that cmark resolved come last, in the order of their first reference.
"
Class {
	#name : 'CMarkDocument',
	#superclass : 'CMarkBlockNode',
	#instVars : [
		'source',
		'options',
		'nodeCount',
		'depth',
		'sourceString',
		'sanitised'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CMarkDocument class >> source: aStringOrByteArray [
	"A hand-built document of aStringOrByteArray, with no children"

	^ self new
		source: aStringOrByteArray;
		yourself
]

{ #category : 'accessing' }
CMarkDocument class >> typeCode [
	^ 16r8001
]

{ #category : 'accessing' }
CMarkDocument class >> typeName [
	^ 'document'
]

{ #category : 'visiting' }
CMarkDocument >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitDocument: self
]

{ #category : 'private' }
CMarkDocument >> cmarkDecodeSourceString [
	"The source as a String, decoded from UTF-8 for a ByteArray (from the sanitised bytes when the plugin answered them); bytes that are not UTF-8 in a hand-built document decode as Latin-1"

	source ifNil: [ ^ nil ].
	source isString ifTrue: [ ^ source ].
	^ [ (sanitised ifNil: [ source ]) utf8Decoded ]
		  on: ZnCharacterEncodingError
		  do: [ :e | source asString ]
]

{ #category : 'decoding' }
CMarkDocument >> cmarkDecodedSource: aSource options: anOptions nodeCount: anInteger depth: depthInteger sanitised: aByteArrayOrNil [
	source := aSource.
	options := anOptions.
	nodeCount := anInteger.
	depth := depthInteger.
	sanitised := aByteArrayOrNil.
	sourceString := nil
]

{ #category : 'printing' }
CMarkDocument >> cmarkPrintAttributesOn: aStream [
	nodeCount ifNil: [ ^ false ].
	aStream print: nodeCount; nextPutAll: ' nodes'.
	^ true
]

{ #category : 'accessing' }
CMarkDocument >> footnoteDefinitions [
	"My footnote definitions, in order (cmark moved the resolved ones to my end)"

	^ children select: [ :each | each isFootnoteDefinition ]
]

{ #category : 'accessing' }
CMarkDocument >> headingAnchors [
	"An IdentityDictionary of my headings to their anchors (CMarkHeading>>anchor): the slug of a heading, with -1, -2... for the second, third... heading of the same slug, in document order"

	| counts anchors |
	counts := Dictionary new.
	anchors := IdentityDictionary new.
	self headings do: [ :each |
		| slug n |
		slug := each slug.
		n := counts at: slug ifAbsent: [ 0 ].
		anchors at: each put: (n = 0
				 ifTrue: [ slug ]
				 ifFalse: [ slug , '-' , n printString ]).
		counts at: slug put: n + 1 ].
	^ anchors
]

{ #category : 'accessing' }
CMarkDocument >> headings [
	"My headings, in document order"

	^ self select: [ :each | each isHeading ]
]

{ #category : 'testing' }
CMarkDocument >> isDocument [
	^ true
]

{ #category : 'accessing' }
CMarkDocument >> links [
	"My links (not the images), in document order"

	^ self select: [ :each | each isLink ]
]

{ #category : 'accessing' }
CMarkDocument >> nodeCount [
	"The number of nodes of the answer of the plugin, or nil for a hand-built document"

	^ nodeCount
]

{ #category : 'accessing' }
CMarkDocument >> options [
	"The CMarkOptions I was parsed with, or nil"

	^ options
]

{ #category : 'accessing' }
CMarkDocument >> sanitised [
	"The bytes of the source as the plugin parsed them, when they differ from a ByteArray source (invalid UTF-8 or NUL), else nil"

	^ sanitised
]

{ #category : 'accessing' }
CMarkDocument >> source [
	"The source I was parsed from: a String or a ByteArray of UTF-8"

	^ source
]

{ #category : 'accessing' }
CMarkDocument >> source: aStringOrByteArray [
	source := aStringOrByteArray cmarkSource.
	sanitised := nil.
	sourceString := nil
]

{ #category : 'accessing' }
CMarkDocument >> sourceString [
	"The source as a String: the indices of the nodes count its characters; never raises"

	^ sourceString ifNil: [ sourceString := self cmarkDecodeSourceString ]
]

{ #category : 'accessing' }
CMarkDocument >> treeDepth [
	"The depth of the deepest node, from the answer of the plugin (the document has 1), or nil for a hand-built document"

	^ depth
]
