"
I test what CMark does without the plugin: with the test hook #pluginMissing (or on a VM that has no CMarkPlugin), parsing and rendering signal CMarkUnavailable and the rest works; with the test hook #protocol, a plugin of another protocol is refused.  I need no plugin.
"
Class {
	#name : 'CMarkUnavailableTest',
	#superclass : 'CMarkTestCase',
	#category : 'CMark-Tests-Tests',
	#package : 'CMark-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkUnavailableTest >> assertUnavailable: aBlock message: aString [
	| e |
	e := aBlock
		     on: CMarkUnavailable
		     do: [ :ex | ex ].
	self assert: e class identicalTo: CMarkUnavailable.
	self assert: e messageText equals: aString
]

{ #category : 'tests' }
CMarkUnavailableTest >> testArgumentsAreCheckedFirst [
	"The arguments are checked before the plugin is looked for"

	CMarkPrimitives testHook: #pluginMissing value: true.
	self should: [ CMark parse: 42 ] raise: CMarkError.
	self deny: ([ CMark parse: 42 ] on: CMarkError do: [ :ex | ex ]) class equals: CMarkUnavailable.
	self should: [ CMark render: 'x' format: #pdf ] raise: CMarkError.
	self deny: ([ CMark render: 'x' format: #pdf ] on: CMarkError do: [ :ex | ex ]) class equals: CMarkUnavailable.
	self should: [ CMark parse: 'abc' options: (CMarkOptions gfm maxInputSize: 2; yourself) ] raise: CMarkInputTooLarge
]

{ #category : 'tests' }
CMarkUnavailableTest >> testHooksAreCleared [
	| available |
	available := CMarkPrimitives isAvailable.
	CMarkPrimitives testHook: #pluginMissing value: true.
	self deny: CMarkPrimitives isAvailable.
	CMarkPrimitives testHook: #pluginMissing value: nil.
	self assert: CMarkPrimitives isAvailable equals: available.
	CMarkPrimitives testHook: #pluginMissing value: true; testHook: #budget value: 0.
	CMarkPrimitives clearTestHooks.
	self assert: (CMarkPrimitives testHook: #pluginMissing) isNil.
	self assert: (CMarkPrimitives testHook: #budget) isNil.
	self assert: CMarkPrimitives isAvailable equals: available
]

{ #category : 'tests' }
CMarkUnavailableTest >> testPluginMissing [
	| before doc |
	before := CMark statistics.
	CMarkPrimitives testHook: #pluginMissing value: true.
	self deny: CMark isAvailable.
	self assert: CMarkPrimitives pluginInfo isNil.
	self assert: CMarkPrimitives platform isNil.
	self assert: CMarkPrimitives pluginLimits isNil.
	self assert: CMark version isNil.
	self assert: CMark statistics isNil.
	self assert: CMarkPrimitives defaultMaxInputSize equals: 32 * 1024 * 1024.
	self assertUnavailable: [ CMark parse: '# Hi' ] message: 'CMarkPlugin not available'.
	self assertUnavailable: [ CMark parse: '# Hi' asByteArray options: CMarkOptions commonMark ] message: 'CMarkPlugin not available'.
	self assertUnavailable: [ CMarkParser new parse: '# Hi' ] message: 'CMarkPlugin not available'.
	self assertUnavailable: [ CMark html: '# Hi' ] message: 'CMarkPlugin not available'.
	self assertUnavailable: [ CMark render: '# Hi' format: #man ] message: 'CMarkPlugin not available'.
	self assertUnavailable: [ CMarkFormatter renderBytes: '# Hi' format: #xml options: CMarkOptions gfm ] message: 'CMarkPlugin not available'.
	"everything else works"
	doc := CMarkDocument withAll: { CMarkParagraph with: { CMarkText literal: 'hand-built' } }.
	self assert: doc plainText equals: 'hand-built'.
	CMarkPrimitives testHook: #pluginMissing value: nil.
	"no call reached the plugin"
	self assert: CMark statistics equals: before
]

{ #category : 'tests' }
CMarkUnavailableTest >> testProtocol [
	| available |
	available := CMarkPrimitives isAvailable.
	CMarkPrimitives testHook: #protocol value: 2.
	self deny: CMarkPrimitives isAvailable.
	self assert: CMarkPrimitives pluginInfo isNil.
	self
		assertUnavailable: [ CMark parse: '# Hi' ]
		message: (available
				 ifTrue: [ 'CMarkPlugin speaks protocol 2, not 1' ]
				 ifFalse: [ 'CMarkPlugin not available' ]).
	CMarkPrimitives testHook: #protocol value: 1.
	self assert: CMarkPrimitives isAvailable equals: available
]

{ #category : 'tests' }
CMarkUnavailableTest >> testWithoutThePlugin [
	"On a VM without the CMarkPlugin: what CMark answers (on a VM with it, the same through the hook)"

	CMarkPrimitives primInfo
		ifNil: [
			"no module: the primitives answer their fallbacks"
			self assert: CMarkPrimitives primRelease equals: 0.
			self assert: (CMarkPrimitives primParse: '# Hi' options: 0 extensions: 0 maxDepth: 0 budget: -1 cBudget: -1) isUnavailable.
			self assert: (CMarkPrimitives primRender: '# Hi' format: 1 options: 0 extensions: 0 width: 0 budget: -1 cBudget: -1) isUnavailable ]
		ifNotNil: [ CMarkPrimitives testHook: #pluginMissing value: true ].
	self deny: CMark isAvailable.
	self assertUnavailable: [ CMark parse: CMarkFixtures sample ] message: 'CMarkPlugin not available'.
	self assert: (CMarkOptions new maxInputSize) equals: CMarkPrimitives defaultMaxInputSize.
	self assert: (CMarkTreeDecoder new classForCode: 16r8001) identicalTo: CMarkDocument
]
