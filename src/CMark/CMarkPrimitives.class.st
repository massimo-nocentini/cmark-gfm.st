"
I am the binding of the CMarkPlugin of the VM, on my class side only (docs/CMark.md of massimo-nocentini/pharo-vm, section Primitive contract, is the contract).  The four primitives are primInfo, primParse:..., primRender:... and primRelease; without the plugin they answer nil, a CMarkFailure and 0.  The plugin is used only when it speaks my protocol (pluginInfo, asked once per session).

parse:options:extensions:maxDepth:cBudget: and render:format:options:extensions:width:cBudget: run the budget loop: where budgetChecked (on WebAssembly, or when old space has a maximum), a source of more than 65,536 units gets the free old space as its budget, and an answer that would not fit is refused with its exact need (status 1); then the object memory is grown and the call made again, which the plugin answers from the result it kept, without parsing again.  A primitive that fails because an allocation of its answer failed is recovered the same way (measured with budget 0, memory grown, called with no budget).  An exception inside the loop releases the kept result (primRelease) at once.  The answers keep their statuses: signalStatusOf:maxDepth:cBudget: turns a status 2, 3 or 4 into CMarkInputTooLarge, CMarkTooDeep or CMarkMemoryLimit; CMarkParser and CMarkFormatter call it.  Without the plugin, the loop signals CMarkUnavailable before anything else.

Test hooks (testHook:value:, nil removes one, clearTestHooks removes all; each forgets pluginInfo): #pluginMissing (true: behave as if the module were absent), #protocol (an Integer: pretend the plugin answered this protocol), #budget (the budget of the first call of every loop), #cBudget (the cBudget of every call), #grow (a block of the byte count, evaluated instead of growing the object memory).
"
Class {
	#name : 'CMarkPrimitives',
	#superclass : 'Object',
	#classVars : [
		'PluginInfo',
		'SessionToken',
		'TestHooks'
	],
	#category : 'CMark-Backends',
	#package : 'CMark',
	#tag : 'Backends'
}

{ #category : 'budget' }
CMarkPrimitives class >> budgetChecked [
	"Whether a large source is given the free old space as its budget, so that the plugin measures the answer before it allocates it: on WebAssembly, and on a VM whose old space has a maximum.  Elsewhere old space grows on demand: an allocation that fails makes the primitive fail, the VM collects garbage and calls it again on the result the plugin kept, and the loop recovers a failure that remains (recover:with:)"

	^ self platform = 'emscripten' or: [ ((Smalltalk vm parameterAt: 67) ifNil: [ 0 ]) > 0 ]
]

{ #category : 'budget' }
CMarkPrimitives class >> budgetFor: units [
	"The budget of the first call for a source of units characters (bytes of a ByteArray): the free old space for a large source where budgetChecked, else -1 (no check)"

	^ (self testHook: #budget) ifNil: [
		  (units > 65536 and: [ self budgetChecked ])
			  ifTrue: [ Smalltalk vm parameterAt: 54 ]
			  ifFalse: [ -1 ] ]
]

{ #category : 'budget' }
CMarkPrimitives class >> cBudgetArgument: anInteger [
	"The cBudget argument of a call: the test hook #cBudget, else anInteger (-1: the default of the plugin), as a SmallInteger (the plugin clamps a larger one to its default)"

	^ ((self testHook: #cBudget) ifNil: [ anInteger ]) min: SmallInteger maxVal
]

{ #category : 'testing' }
CMarkPrimitives class >> clearTestHooks [
	"Remove every test hook"

	TestHooks := nil.
	SessionToken := nil
]

{ #category : 'plugin' }
CMarkPrimitives class >> defaultMaxInputSize [
	"The default maxInputSize of CMarkOptions: 32 Mi characters (bytes of a ByteArray) natively, 16 Mi on WebAssembly, whose C heap never shrinks (docs/CMark.md, Memory and limits)"

	^ self platform = 'emscripten'
		  ifTrue: [ 16777216 ]
		  ifFalse: [ 33554432 ]
]

{ #category : 'budget' }
CMarkPrimitives class >> grow: byteCount [
	"Grow the object memory by at least byteCount bytes (the test hook #grow, a block, is evaluated instead)"

	(self testHook: #grow) ifNotNil: [ :hook | ^ hook value: byteCount ].
	Smalltalk growMemoryByAtLeast: byteCount
]

{ #category : 'plugin' }
CMarkPrimitives class >> isAvailable [
	"Whether the VM has a CMarkPlugin of my protocol"

	^ self pluginInfo notNil
]

{ #category : 'budget' }
CMarkPrimitives class >> loop: aBlock units: units [
	"The answer of the primitive that aBlock calls with a budget, for a source of units characters: the budget loop (docs/CMark.md, Primitive contract, Budgets).  Status 1 grows the object memory by the need plus 1 MiB and calls again with the free old space as the budget; a failure is recovered (recover:with:); a second status 1 signals OutOfMemory.  An exception inside releases the kept result"

	| answer |
	self pluginInfo ifNil: [ ^ self signalUnavailable ].
	^ [
	  answer := aBlock value: (self budgetFor: units).
	  answer cmarkFailed ifTrue: [ answer := self recover: answer with: aBlock ].
	  (answer at: 1) = 1 ifTrue: [
		  self grow: (answer at: 2) + 1048576.
		  answer := aBlock value: (Smalltalk vm parameterAt: 54).
		  answer cmarkFailed ifTrue: [ answer := self recover: answer with: aBlock ].
		  (answer at: 1) = 1 ifTrue: [ OutOfMemory signal ] ].
	  answer ] ifCurtailed: [ self primRelease ]
]

{ #category : 'budget' }
CMarkPrimitives class >> parse: source options: optionBits extensions: extensionBits maxDepth: maxDepth cBudget: cBudget [
	"The answer of primitiveParse for source (a ByteString, a WideString or a ByteArray of UTF-8), under the budget loop: { status. code. tape. strings. nodeCount. depth. recordWords. sourceChars. sanitised } with a status other than 1 (docs/CMark.md, Tree format); maxDepth 0 and cBudget -1 mean no limit and the default of the plugin"

	| depth c |
	depth := maxDepth min: SmallInteger maxVal.
	c := self cBudgetArgument: cBudget.
	^ self
		  loop: [ :budget |
			  self
				  primParse: source
				  options: optionBits
				  extensions: extensionBits
				  maxDepth: depth
				  budget: budget
				  cBudget: c ]
		  units: source size
]

{ #category : 'plugin' }
CMarkPrimitives class >> platform [
	"'native' or 'emscripten', or nil without the plugin"

	^ self pluginInfo ifNotNil: [ :info | info at: 4 ]
]

{ #category : 'plugin' }
CMarkPrimitives class >> pluginInfo [
	"The answer of primitiveInfo, { protocol. plugin version. cmark-gfm version. platform. extensions. limits. stats }, as it was when first asked in this session, or nil when the module is missing or speaks another protocol"

	^ self sessionMemo first
]

{ #category : 'plugin' }
CMarkPrimitives class >> pluginLimits [
	"The limits of the plugin as a Dictionary (#maxInputBytes #maxBlockBytes #defaultCBudget #recordWords #keepCap), or nil without the plugin"

	^ self pluginInfo ifNotNil: [ :info |
		  | limits |
		  limits := Dictionary new.
		  #( #maxInputBytes #maxBlockBytes #defaultCBudget #recordWords #keepCap ) withIndexDo: [ :each :i |
			  limits at: each put: ((info at: 6) at: i) ].
		  limits ]
]

{ #category : 'plugin' }
CMarkPrimitives class >> pluginStatistics [
	"The counters of the plugin now, as a Dictionary by the names of statisticsKeys, or nil without the plugin"

	self isAvailable ifFalse: [ ^ nil ].
	^ self primInfo ifNotNil: [ :info |
		  | statistics |
		  statistics := Dictionary new.
		  self statisticsKeys withIndexDo: [ :each :i | statistics at: each put: ((info at: 7) at: i) ].
		  statistics ]
]

{ #category : 'primitives' }
CMarkPrimitives class >> primInfo [
	"{ protocol. plugin version. cmark-gfm version. platform. extensions. limits. stats }, or nil without the plugin"

	<primitive: 'primitiveInfo' module: 'CMarkPlugin' error: ec>
	^ nil
]

{ #category : 'primitives' }
CMarkPrimitives class >> primParse: source options: optionBits extensions: extensionBits maxDepth: maxDepth budget: budget cBudget: cBudget [
	"{ status. code. tape. strings. nodeCount. depth. recordWords. sourceChars. sanitised }, or a CMarkFailure (docs/CMark.md, Primitive contract and Tree format)"

	<primitive: 'primitiveParse' module: 'CMarkPlugin' error: ec>
	^ CMarkFailure on: ec
]

{ #category : 'primitives' }
CMarkPrimitives class >> primRelease [
	"Free the result the plugin keeps, answering its bytes of C memory (0 without the plugin)"

	<primitive: 'primitiveRelease' module: 'CMarkPlugin' error: ec>
	^ 0
]

{ #category : 'primitives' }
CMarkPrimitives class >> primRender: source format: formatCode options: optionBits extensions: extensionBits width: width budget: budget cBudget: cBudget [
	"{ status. code. bytes. ascii. byteSize }, or a CMarkFailure (docs/CMark.md, Primitive contract, primitiveRender); formatCode is 1 html, 2 xml, 3 commonmark, 4 plaintext, 5 latex, 6 man"

	<primitive: 'primitiveRender' module: 'CMarkPlugin' error: ec>
	^ CMarkFailure on: ec
]

{ #category : 'plugin' }
CMarkPrimitives class >> protocol [
	"The protocol of the plugin I speak (slot 1 of primitiveInfo)"

	^ 1
]

{ #category : 'budget' }
CMarkPrimitives class >> recover: aFailure with: aBlock [
	"The answer after aFailure of the primitive that aBlock calls with a budget.  The VM already collected garbage and called it again on the result the plugin kept: a no-memory failure here means that no free chunk was large enough, so measure the need (budget 0, answered from the kept result), grow the object memory by all of it and call once more with no budget.  A missing module signals CMarkUnavailable, a missing extension a CMarkError"

	| measure answer |
	aFailure isUnavailable ifTrue: [
		self pluginInfo ifNil: [ ^ self signalUnavailable ].
		^ CMarkError signal: 'extension missing from the plugin' ].
	aFailure isNoMemory ifFalse: [ ^ self primitiveFailed ].
	measure := aBlock value: 0.
	measure cmarkFailed ifTrue: [ ^ OutOfMemory signal ].
	(measure at: 1) = 1 ifFalse: [ ^ measure ].
	self grow: (measure at: 2) + 1048576.
	answer := aBlock value: -1.
	answer cmarkFailed ifTrue: [ ^ OutOfMemory signal ].
	^ answer
]

{ #category : 'budget' }
CMarkPrimitives class >> render: source format: formatCode options: optionBits extensions: extensionBits width: width cBudget: cBudget [
	"The answer of primitiveRender for source, under the budget loop: { status. code. bytes. ascii. byteSize } with a status other than 1; formatCode is 1 html, 2 xml, 3 commonmark, 4 plaintext, 5 latex, 6 man"

	| c |
	c := self cBudgetArgument: cBudget.
	^ self
		  loop: [ :budget |
			  self
				  primRender: source
				  format: formatCode
				  options: optionBits
				  extensions: extensionBits
				  width: width
				  budget: budget
				  cBudget: c ]
		  units: source size
]

{ #category : 'plugin' }
CMarkPrimitives class >> sessionMemo [
	"{ pluginInfo or nil. the protocol the plugin answered, or nil without the module }, asked once per session; a new session or a test hook forgets it"

	SessionToken == Smalltalk session ifFalse: [
		| info protocol |
		info := (self testHook: #pluginMissing) == true
			        ifTrue: [ nil ]
			        ifFalse: [ self primInfo ].
		protocol := (info isArray and: [ info notEmpty ])
			            ifTrue: [ (self testHook: #protocol) ifNil: [ info first ] ]
			            ifFalse: [ nil ].
		PluginInfo := {
			              (protocol = self protocol
				               ifTrue: [ info ]
				               ifFalse: [ nil ]).
			              protocol }.
		SessionToken := Smalltalk session ].
	^ PluginInfo
]

{ #category : 'errors' }
CMarkPrimitives class >> signalStatusOf: anAnswer maxDepth: maxDepth cBudget: cBudget [
	"Signal the error of the status of anAnswer of primitiveParse or primitiveRender: 2 CMarkInputTooLarge, 3 CMarkTooDeep, 4 CMarkMemoryLimit; maxDepth and cBudget are the arguments of the call (cBudget -1: the default of the plugin)"

	| status code limits |
	status := anAnswer at: 1.
	code := anAnswer at: 2.
	limits := self pluginLimits ifNil: [ Dictionary new ].
	status = 2 ifTrue: [ ^ CMarkInputTooLarge signalLimit: (limits at: #maxInputBytes ifAbsent: [ nil ]) actual: code ].
	status = 3 ifTrue: [ ^ CMarkTooDeep signalLimit: maxDepth actual: code ].
	status = 4 ifTrue: [
		^ CMarkMemoryLimit signalCode: code limit: (code = 1
				   ifTrue: [
					   | default c |
					   default := limits at: #defaultCBudget ifAbsent: [ nil ].
					   c := self cBudgetArgument: cBudget.
					   (c < 0 or: [ default notNil and: [ c > default ] ])
						   ifTrue: [ default ]
						   ifFalse: [ c ] ]
				   ifFalse: [
					   code = 2
						   ifTrue: [ limits at: #maxBlockBytes ifAbsent: [ nil ] ]
						   ifFalse: [ nil ] ]) ].
	^ CMarkError signal: 'the CMarkPlugin answered the status ' , status printString
]

{ #category : 'errors' }
CMarkPrimitives class >> signalUnavailable [
	"Signal that the VM has no usable CMarkPlugin: none, or one of another protocol"

	| protocol |
	protocol := self sessionMemo at: 2.
	(protocol notNil and: [ protocol ~= self protocol ]) ifTrue: [
		^ CMarkUnavailable signalProtocol: protocol expected: self protocol ].
	^ CMarkUnavailable new signal
]

{ #category : 'plugin' }
CMarkPrimitives class >> statisticsKeys [
	"The names of the counters of the plugin, the last slot of primitiveInfo, in their order: the parses and the renders made, the calls answered from the kept result, the answers over budget, too large, too deep and over a C limit, and the bytes kept now"

	^ #( #parses #renders #reused #overBudget #tooLarge #tooDeep #cLimit #kept )
]

{ #category : 'testing' }
CMarkPrimitives class >> testHook: aSymbol [
	"The value of the test hook aSymbol, or nil"

	^ TestHooks ifNotNil: [ :hooks | hooks at: aSymbol ifAbsent: [ nil ] ]
]

{ #category : 'testing' }
CMarkPrimitives class >> testHook: aSymbol value: anObject [
	"Set the test hook aSymbol (nil removes it): #pluginMissing, #protocol, #budget, #cBudget or #grow (see my comment); pluginInfo is asked again"

	TestHooks ifNil: [ TestHooks := Dictionary new ].
	anObject
		ifNil: [ TestHooks removeKey: aSymbol ifAbsent: [ nil ] ]
		ifNotNil: [ TestHooks at: aSymbol put: anObject ].
	TestHooks isEmpty ifTrue: [ TestHooks := nil ].
	SessionToken := nil
]
