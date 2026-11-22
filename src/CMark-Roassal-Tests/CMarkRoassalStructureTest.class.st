"
I check the invariants of a rendering on the hand-built document of CMarkRoassalExamples (and on the parsed sample when the plugin is there): the models, one frame per block node, the labels, the composites that contain their children and were never given an extent, the width, every node class rendered alone, and determinism.
"
Class {
	#name : 'CMarkRoassalStructureTest',
	#superclass : 'CMarkRoassalTestCase',
	#category : 'CMark-Roassal-Tests-Tests',
	#package : 'CMark-Roassal-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkRoassalStructureTest >> assertInvariantsOf: aDocument [
	| shape frames |
	shape := self render: aDocument.
	self assert: shape model identicalTo: aDocument.
	self assert: shape class identicalTo: RSComposite.
	"every shape has a node as its model"
	self walk: shape do: [ :each :rect :depth | self assert: (each model isKindOf: CMarkNode) description: each printString ].
	"every block node has exactly one frame"
	frames := self framesOf: shape.
	aDocument allNodes do: [ :node |
		node isBlock ifTrue: [ self assert: (frames count: [ :each | each model == node ]) = 1 description: node printString ] ].
	frames do: [ :each | self assert: each model isBlock ].
	"labels: never empty, never the model's printString, never a TAB, CR or LF"
	(self labelsOf: shape) do: [ :each |
		| text |
		text := each key text.
		self assert: text notEmpty.
		self deny: text equals: each key model printString.
		self deny: (text includesAny: { Character tab. Character cr. Character lf }) ].
	"composites contain their children and are adjusted to them (none was given an extent)"
	self walk: shape do: [ :each :rect :depth |
		each isComposite ifTrue: [
			| children |
			children := each children encompassingRectangle.
			self assert: (each extent - children extent) abs < (0.01 @ 0.01) description: each model printString.
			each children do: [ :child |
				self assert: ((each encompassingRectangle expandBy: 0.01) containsRect: (child encompassingRectangle translateBy: each position)) ] ] ].
	"the width"
	self assert: shape encompassingRectangle width <= (renderer maxWidth + (2 * renderer theme padding) + 0.01).
	^ shape
]

{ #category : 'tests' }
CMarkRoassalStructureTest >> testDeterminism [
	| a b ra rb |
	a := self render: CMarkRoassalExamples handBuiltDocument.
	ra := renderer shapeCount.
	b := self render: CMarkRoassalExamples handBuiltDocument.
	rb := renderer shapeCount.
	self assert: a extent equals: b extent.
	self assert: ra equals: rb.
	self assert: (self dump: a) equals: (self dump: b)
]

{ #category : 'tests' }
CMarkRoassalStructureTest >> testEmptyDocument [
	| shape |
	shape := self render: (self document: #(  )).
	self assert: shape extent equals: (renderer maxWidth + (2 * renderer theme padding)) @ (2 * renderer theme padding).
	self assert: (self labelsOf: shape) isEmpty
]

{ #category : 'tests' }
CMarkRoassalStructureTest >> testEveryNodeClassAlone [
	"Every concrete node class, rendered alone (hand-built), answers a composite whose model is the node and whose first child is its frame"

	| classes |
	classes := CMarkNode allSubclasses reject: [ :each | each isAbstract ].
	self assert: classes size equals: 30.
	classes do: [ :each |
		| node shape block |
		node := each new.
		shape := self render: node.
		self assert: shape class == RSComposite description: each name.
		self assert: shape model identicalTo: node.
		self assert: (shape children first propertyAt: #cmarkFrame ifAbsent: [ false ]) description: each name.
		block := CMarkRoassalRenderer new in: [ :r |
			         r beginRendering: node.
			         r blockFor: node in: (CMarkRoassalContext width: 200 style: r theme baseStyle) ].
		self assert: block class == CMarkRoassalBlock description: each name ]
]

{ #category : 'tests' }
CMarkRoassalStructureTest >> testFixtureInvariants [
	#( #sample #table #tasks #footnotes #unicode #nested ) do: [ :each | self assertInvariantsOf: (self fixture: each) ]
]

{ #category : 'tests' }
CMarkRoassalStructureTest >> testHandBuiltInvariants [
	self assertInvariantsOf: CMarkRoassalExamples handBuiltDocument
]

{ #category : 'tests' }
CMarkRoassalStructureTest >> testHeaderOnlyTable [
	"A table of its header row alone (valid GFM) still has its own composite and frame; its row rendered alone is the row's block"

	| table shape |
	table := CMarkTable alignments: #( nil #right ).
	table addChild: (CMarkTableHeaderRow with: {
				 (CMarkTableCell with: { (self text: 'Name') }).
				 (CMarkTableCell with: { (self text: 'Value') }) }).
	self assertInvariantsOf: (self document: { table }).
	shape := self render: table.
	self assert: shape model identicalTo: table.
	self assert: ((self framesOf: shape) count: [ :each | each model == table ]) equals: 1.
	shape := self render: table children first.
	self assert: shape model identicalTo: table children first.
	self assert: ((self framesOf: shape) count: [ :each | each model == table ]) equals: 0
]

{ #category : 'tests' }
CMarkRoassalStructureTest >> testNodesWithContentAlone [
	"Non-empty nodes rendered alone keep the invariants of a block"

	| link table row |
	link := (CMarkLink url: 'https://x.y' title: '') addAll: { (self text: 'link') }; yourself.
	table := CMarkTable alignments: #( #left #right ).
	row := table addChild: (CMarkTableHeaderRow with: { (CMarkTableCell with: { (self text: 'a') }). (CMarkTableCell with: { (self text: 'b') }) }).
	{ (self text: 'text'). link. row. row children first. (CMarkItem with: { (self paragraph: { (self text: 'item') }) }). (CMarkHeading level: 3 with: { (self text: 'heading') }) } do: [ :node |
		| shape |
		shape := self render: node.
		self assert: shape model identicalTo: node.
		self assert: (self labelsOf: shape) notEmpty ]
]

{ #category : 'tests' }
CMarkRoassalStructureTest >> testReadmeLikeInvariants [
	self assertInvariantsOf: (self parse: CMarkRoassalExamples sampleMarkdown , CMarkRoassalExamples tableMarkdown , CMarkRoassalExamples tasksMarkdown)
]

{ #category : 'tests' }
CMarkRoassalStructureTest >> testShapeCount [
	| shape count |
	shape := self render: CMarkRoassalExamples handBuiltDocument.
	count := 0.
	self walk: shape do: [ :each :rect :depth | count := count + 1 ].
	self assert: renderer shapeCount equals: count
]
