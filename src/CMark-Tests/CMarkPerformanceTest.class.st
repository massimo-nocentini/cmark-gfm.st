"
I measure a parse and the decoding of its tape (with `requirePlugin`): 10 MB of fixture text (512 KB on WebAssembly), with the times, the node count and the bytes of object memory per node on the Transcript. My only assertion is the time limit of 60 s.
"
Class {
	#name : 'CMarkPerformanceTest',
	#superclass : 'CMarkTestCase',
	#category : 'CMark-Tests-Tests',
	#package : 'CMark-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
CMarkPerformanceTest >> setUp [
	super setUp.
	self requirePlugin
]

{ #category : 'tests' }
CMarkPerformanceTest >> testParseAndDecode [
	| target chunk source answer t0 tParse tDecode doc o bytes nodes |
	target := CMarkPrimitives platform = 'emscripten'
		          ifTrue: [ 512 * 1024 ]
		          ifFalse: [ 10 * 1024 * 1024 ].
	chunk := CMarkFixtures sample copyReplaceAll: '[^1]' with: ''.
	source := String new: target streamContents: [ :s |
		          target // chunk size timesRepeat: [ s nextPutAll: chunk; nextPut: Character lf ] ].
	o := CMarkOptions gfm.
	t0 := Time millisecondClockValue.
	answer := CMarkPrimitives
		          parse: source
		          options: o optionBits
		          extensions: o extensionBits
		          maxDepth: o maxDepthArgument
		          cBudget: o cBudgetArgument.
	tParse := Time millisecondClockValue - t0.
	self assert: answer first equals: 0.
	t0 := Time millisecondClockValue.
	doc := CMarkTreeDecoder new decode: answer source: source options: o.
	tDecode := Time millisecondClockValue - t0.
	nodes := doc nodeCount.
	bytes := 0.
	doc do: [ :each | bytes := bytes + each sizeInMemory + each children sizeInMemory ].
	Transcript show: 'CMarkPerformanceTest: ' , source size printString , ' characters, ' , nodes printString , ' nodes; parse '
		, tParse printString , ' ms, decode ' , tDecode printString , ' ms; tape ' , (answer at: 3) sizeInMemory printString
		, ' bytes, strings ' , (answer at: 4) size printString , ' bytes; nodes about ' , (bytes // nodes) printString
		, ' bytes each (without their strings)'; cr; flush.
	self assert: tParse + tDecode < 60000
]
