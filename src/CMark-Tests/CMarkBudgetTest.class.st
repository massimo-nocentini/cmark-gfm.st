"
I test the budget loop of CMarkPrimitives with the plugin (each test calls requirePlugin): a refused answer (status 1, forced with the test hook #budget) makes the loop grow the object memory and call again, which the plugin answers from the result it kept, without parsing again; an exception inside the loop releases that result; a large document parses; and the C budget stops a CommonMark render that would blow up.
"
Class {
	#name : 'CMarkBudgetTest',
	#superclass : 'CMarkTestCase',
	#category : 'CMark-Tests-Tests',
	#package : 'CMark-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkBudgetTest >> largeSource: byteCount [
	"About byteCount characters of Markdown: chunks of a heading and the table, task and nesting fixtures"

	| chunk |
	chunk := '# Chunk' , String lf , String lf , CMarkFixtures table , String lf , CMarkFixtures tasks , String lf , CMarkFixtures nested , String lf.
	^ String new: byteCount // chunk size * chunk size streamContents: [ :s |
		  byteCount // chunk size timesRepeat: [ s nextPutAll: chunk ] ]
]

{ #category : 'running' }
CMarkBudgetTest >> setUp [
	super setUp.
	self requirePlugin
]

{ #category : 'tests' }
CMarkBudgetTest >> testCommonMarkBlowUp [
	"A deep quote with many lazy lines: its CommonMark render repeats the quote markers on every line; the C budget of 8 MiB stops it on every platform"

	| source e |
	source := String new: 200000 streamContents: [ :s |
		          s nextPutAll: (String new: 3000 withAll: $>); nextPutAll: ' x'; nextPut: Character lf.
		          20000 timesRepeat: [ s nextPutAll: 'ab'; nextPut: Character lf ] ].
	e := [ CMark render: source format: #commonmark options: (CMarkOptions gfm cBudget: 8 * 1024 * 1024; yourself) ]
		     on: CMarkMemoryLimit
		     do: [ :ex | ex ].
	self assert: e class identicalTo: CMarkMemoryLimit.
	self assert: e reason equals: #budget.
	self assert: e limit equals: 8 * 1024 * 1024.
	self assert: (CMark statistics at: #kept) equals: 0
]

{ #category : 'tests' }
CMarkBudgetTest >> testExceptionReleasesTheKeptResult [
	| e |
	CMarkPrimitives
		testHook: #budget value: 0;
		testHook: #grow value: [ :byteCount | Error signal: 'no growing ' , byteCount printString ].
	e := [ CMark parse: CMarkFixtures sample ]
		     on: Error
		     do: [ :ex | ex ].
	self assert: (e messageText beginsWith: 'no growing ').
	self assert: (CMark statistics at: #kept) equals: 0.
	e := [ CMark html: CMarkFixtures sample ]
		     on: Error
		     do: [ :ex | ex ].
	self assert: (e messageText beginsWith: 'no growing ').
	self assert: (CMark statistics at: #kept) equals: 0
]

{ #category : 'tests' }
CMarkBudgetTest >> testLargeDocument [
	"2 MB of Markdown (512 KB on WebAssembly): an answer of several MB, which may need the recovery of the loop"

	| source doc |
	source := self largeSource: (CMarkPrimitives platform = 'emscripten'
			           ifTrue: [ 512 * 1024 ]
			           ifFalse: [ 2 * 1024 * 1024 ]).
	doc := CMark parse: source.
	self assert: doc headings size equals: (source lines count: [ :each | each = '# Chunk' ]).
	self assert: doc headings size > 1000.
	self assert: (doc headings allSatisfy: [ :each | each plainText = 'Chunk' ]).
	self assert: doc sourceString identicalTo: source.
	self assert: doc children last sourceText notNil.
	self assert: (CMark statistics at: #kept) equals: 0
]

{ #category : 'tests' }
CMarkBudgetTest >> testOverBudgetParse [
	| expected before after doc |
	expected := (CMark parse: CMarkFixtures sample) treeString.
	CMarkPrimitives testHook: #budget value: 0.
	before := CMark statistics.
	doc := CMark parse: CMarkFixtures sample.
	after := CMark statistics.
	self assert: doc treeString equals: expected.
	self assert: (after at: #parses) equals: (before at: #parses) + 1.
	self assert: (after at: #overBudget) equals: (before at: #overBudget) + 1.
	self assert: (after at: #reused) equals: (before at: #reused) + 1.
	self assert: (after at: #kept) equals: 0
]

{ #category : 'tests' }
CMarkBudgetTest >> testOverBudgetRender [
	| expected before after |
	expected := CMark html: CMarkFixtures sample.
	CMarkPrimitives testHook: #budget value: 0.
	before := CMark statistics.
	self assert: (CMark html: CMarkFixtures sample) equals: expected.
	after := CMark statistics.
	self assert: (after at: #renders) equals: (before at: #renders) + 1.
	self assert: (after at: #overBudget) equals: (before at: #overBudget) + 1.
	self assert: (after at: #reused) equals: (before at: #reused) + 1.
	self assert: (after at: #kept) equals: 0
]

{ #category : 'tests' }
CMarkBudgetTest >> testRecoverAfterNoMemory [
	"The recovery of a no-memory failure: measure (budget 0, the result is kept), grow, call with no budget (answered from the kept result)"

	| failure before answer after |
	failure := CMarkFailure on: #'insufficient object memory'.
	before := CMark statistics.
	answer := CMarkPrimitives recover: failure with: [ :budget |
		          CMarkPrimitives
			          primParse: '# Hi'
			          options: 0
			          extensions: 31
			          maxDepth: 0
			          budget: budget
			          cBudget: -1 ].
	after := CMark statistics.
	self assert: answer first equals: 0.
	self assert: (answer at: 5) equals: 3.
	self assert: (after at: #parses) equals: (before at: #parses) + 1.
	self assert: (after at: #reused) equals: (before at: #reused) + 1.
	self assert: (after at: #kept) equals: 0
]
