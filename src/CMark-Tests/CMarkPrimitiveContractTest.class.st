"
I test the contract of the primitives of the CMarkPlugin as CMarkPrimitives sees it (each test calls requirePlugin): primitiveInfo, the conversions of the sources, the bad arguments (a CMarkFailure with #'bad argument'), the need of a refused answer against the formula of the plugin, and primitiveRelease.
"
Class {
	#name : 'CMarkPrimitiveContractTest',
	#superclass : 'CMarkTestCase',
	#category : 'CMark-Tests-Tests',
	#package : 'CMark-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkPrimitiveContractTest >> assertBadArgument: aBlock [
	| answer |
	answer := aBlock value.
	self assert: answer cmarkFailed.
	self assert: answer ec equals: #'bad argument'.
	self deny: answer isUnavailable.
	self deny: answer isNoMemory
]

{ #category : 'helpers' }
CMarkPrimitiveContractTest >> parse: source options: o extensions: e maxDepth: d budget: b cBudget: c [
	^ CMarkPrimitives primParse: source options: o extensions: e maxDepth: d budget: b cBudget: c
]

{ #category : 'helpers' }
CMarkPrimitiveContractTest >> render: source format: f width: w [
	^ CMarkPrimitives primRender: source format: f options: 0 extensions: 31 width: w budget: -1 cBudget: -1
]

{ #category : 'running' }
CMarkPrimitiveContractTest >> setUp [
	super setUp.
	self requirePlugin
]

{ #category : 'helpers' }
CMarkPrimitiveContractTest >> spurBytes: byteCount [
	"The bytes of a byte object of byteCount bytes in Spur's 64-bit object memory: an 8-byte header, an overflow header from 255 slots, at least one slot"

	^ self spurSlots: (byteCount + 7) // 8
]

{ #category : 'helpers' }
CMarkPrimitiveContractTest >> spurSlots: slotCount [
	| slots |
	slots := slotCount max: 1.
	^ 8 + (slots >= 255 ifTrue: [ 8 ] ifFalse: [ 0 ]) + (slots * 8)
]

{ #category : 'tests' }
CMarkPrimitiveContractTest >> testBadArguments [
	self assertBadArgument: [ self parse: #'# Hi' options: 0 extensions: 0 maxDepth: 0 budget: -1 cBudget: -1 ].
	self assertBadArgument: [ self parse: #( 1 2 ) options: 0 extensions: 0 maxDepth: 0 budget: -1 cBudget: -1 ].
	self assertBadArgument: [ self parse: nil options: 0 extensions: 0 maxDepth: 0 budget: -1 cBudget: -1 ].
	self assertBadArgument: [ self parse: '# Hi' options: nil extensions: 0 maxDepth: 0 budget: -1 cBudget: -1 ].
	self assertBadArgument: [ self parse: '# Hi' options: 1 extensions: 0 maxDepth: 0 budget: -1 cBudget: -1 ].
	self assertBadArgument: [ self parse: '# Hi' options: 0 extensions: 32 maxDepth: 0 budget: -1 cBudget: -1 ].
	self assertBadArgument: [ self parse: '# Hi' options: 0 extensions: -1 maxDepth: 0 budget: -1 cBudget: -1 ].
	self assertBadArgument: [ self parse: '# Hi' options: 0 extensions: 0 maxDepth: -1 budget: -1 cBudget: -1 ].
	self assertBadArgument: [ self parse: '# Hi' options: 0 extensions: 0 maxDepth: 0 budget: -2 cBudget: -1 ].
	self assertBadArgument: [ self parse: '# Hi' options: 0 extensions: 0 maxDepth: 0 budget: -1 cBudget: -2 ].
	self assertBadArgument: [ self parse: '# Hi' options: 0 extensions: 0 maxDepth: 0 budget: -1 cBudget: SmallInteger maxVal + 1 ].
	self assertBadArgument: [ self render: '# Hi' format: 0 width: 0 ].
	self assertBadArgument: [ self render: '# Hi' format: 7 width: 0 ].
	self assertBadArgument: [ self render: '# Hi' format: 1 width: -1 ].
	self assertBadArgument: [ self render: '# Hi' format: 1 width: 10001 ].
	self assertBadArgument: [ self render: #'# Hi' format: 1 width: 0 ].
	"the same arguments, right, are answered"
	self assert: (self parse: '# Hi' options: 0 extensions: 31 maxDepth: 0 budget: -1 cBudget: -1) first equals: 0.
	self assert: (self render: '# Hi' format: 6 width: 10000) first equals: 0
]

{ #category : 'tests' }
CMarkPrimitiveContractTest >> testFacadeChecksBeforeAnyCall [
	| before |
	before := CMark statistics.
	self should: [ CMark parse: 42 ] raise: CMarkError.
	self should: [ CMark parse: #( 1 2 ) ] raise: CMarkError.
	self should: [ CMark html: Object new ] raise: CMarkError.
	self should: [ CMark parse: UUID new ] raise: CMarkError.
	self assert: CMark statistics equals: before.
	"the huge limits are passed as SmallIntegers"
	self assert: (CMark parse: '# Hi' options: (CMarkOptions gfm maxDepth: 1 << 70; cBudget: 1 << 70; yourself)) firstChild level equals: 1
]

{ #category : 'tests' }
CMarkPrimitiveContractTest >> testInfo [
	| info native limits |
	info := CMarkPrimitives pluginInfo.
	self assert: info size equals: 7.
	self assert: info first equals: CMarkPrimitives protocol.
	self assert: CMarkPrimitives protocol equals: 1.
	self assert: (info at: 2) equals: 'CMarkPlugin 1.0'.
	self assert: (info at: 3) equals: '0.29.0.gfm.14'.
	self assert: CMark version equals: '0.29.0.gfm.14'.
	self assert: (#( 'native' 'emscripten' ) includes: (info at: 4)).
	self assert: CMarkPrimitives platform equals: (info at: 4).
	self assert: (info at: 5) asArray equals: #( 'table' 'strikethrough' 'autolink' 'tagfilter' 'tasklist' ).
	self assert: (info at: 5) asArray equals: (CMarkOptions allExtensionNames collect: [ :each | each asString ]).
	native := (info at: 4) = 'native'.
	self assert: (info at: 6) asArray equals: (native
			 ifTrue: [ #( 268435456 268435456 4294967296 16 4294967296 ) ]
			 ifFalse: [ #( 268435456 268435456 134217728 16 8388608 ) ]).
	limits := CMarkPrimitives pluginLimits.
	self assert: (limits at: #recordWords) equals: CMarkTreeDecoder recordWords.
	self assert: (limits at: #defaultCBudget) equals: ((info at: 6) at: 3).
	self assert: (info at: 7) size equals: CMarkPrimitives statisticsKeys size.
	self assert: ((info at: 7) allSatisfy: [ :each | each isInteger and: [ each >= 0 ] ]).
	self assert: CMark statistics keys asSet equals: CMarkPrimitives statisticsKeys asSet.
	self assert: CMark isAvailable.
	self assert: CMarkPrimitives defaultMaxInputSize equals: (native
			 ifTrue: [ 32 * 1024 * 1024 ]
			 ifFalse: [ 16 * 1024 * 1024 ])
]

{ #category : 'tests' }
CMarkPrimitiveContractTest >> testNeed [
	"A refused answer says the exact bytes of object memory the full answer needs: an Array of 9, a Bitmap of 16 words per node and the strings"

	| answer |
	answer := self parse: '# Hi' options: 0 extensions: 31 maxDepth: 0 budget: 0 cBudget: -1.
	self assert: answer size equals: 9.
	self assert: (answer first: 2) equals: { 1. (self spurSlots: 9) + (self spurBytes: 3 * 16 * 4) + (self spurBytes: 2) }.
	self assert: (answer copyFrom: 3 to: 9) equals: #( nil nil 0 3 16 4 nil ).
	CMarkPrimitives primRelease.
	answer := self parse: '# Hi' options: 0 extensions: 31 maxDepth: 0 budget: (answer at: 2) cBudget: -1.
	self assert: answer first equals: 0.
	self assert: (answer at: 3) class identicalTo: Bitmap.
	self assert: (answer at: 4) equals: 'Hi' asByteArray.
	answer := CMarkPrimitives primRender: '# Hi' format: 1 options: 0 extensions: 31 width: 0 budget: 0 cBudget: -1.
	self assert: answer equals: { 1. (self spurSlots: 5) + (self spurBytes: 12). nil. true. 12 }.
	CMarkPrimitives primRelease
]

{ #category : 'tests' }
CMarkPrimitiveContractTest >> testRelease [
	| answer kept |
	CMarkPrimitives primRelease.
	self assert: CMarkPrimitives primRelease equals: 0.
	answer := self parse: CMarkFixtures sample options: 0 extensions: 31 maxDepth: 0 budget: 0 cBudget: -1.
	self assert: answer first equals: 1.
	kept := CMark statistics at: #kept.
	self assert: kept > 0.
	self assert: CMarkPrimitives primRelease equals: kept.
	self assert: CMarkPrimitives primRelease equals: 0.
	self assert: (CMark statistics at: #kept) equals: 0
]

{ #category : 'tests' }
CMarkPrimitiveContractTest >> testSources [
	| doc |
	doc := CMark parse: #'# Hi'.
	self assert: doc firstChild level equals: 1.
	self assert: doc source equals: '# Hi'.
	self assert: doc source class identicalTo: ByteString.
	doc := CMark parse: '# Hi' asText.
	self assert: doc firstChild plainText equals: 'Hi'.
	self assert: (CMark html: #'*a*') equals: '<p><em>a</em></p>' , String lf.
	"any object of 32-bit words is read as UTF-32 by the plugin"
	self assert: (self parse: (WordArray withAll: #( 35 32 72 105 )) options: 0 extensions: 0 maxDepth: 0 budget: -1 cBudget: -1) first equals: 0
]
