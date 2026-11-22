"
I compare the structural dump of the renderings of the fixtures (CMarkRoassalTestCase>>dump:: one line per shape with its class, the typeName of its model, its bounds rounded to 0.5 and the text of a label) with the goldens of CMarkRoassalGoldens, which were generated once and reviewed.  A change of the layout then shows as a golden diff, without fragile pixels.  The hand-built document needs no plugin; the fixtures of CMarkFixtures are parsed with the GitHub options and footnotes.
"
Class {
	#name : 'CMarkRoassalGoldenTest',
	#superclass : 'CMarkRoassalTestCase',
	#category : 'CMark-Roassal-Tests-Tests',
	#package : 'CMark-Roassal-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkRoassalGoldenTest >> assertFixture: aSymbol [
	self assertGolden: aSymbol of: (self fixture: aSymbol)
]

{ #category : 'helpers' }
CMarkRoassalGoldenTest >> assertGolden: aSymbol of: aDocument [
	| actual expected |
	actual := (self dump: (self render: aDocument)) lines.
	expected := (CMarkRoassalGoldens perform: aSymbol) lines.
	1 to: (actual size min: expected size) do: [ :i |
		self assert: (actual at: i) = (expected at: i) description: aSymbol , ' line ' , i printString , ': ' , (actual at: i) , ' instead of ' , (expected at: i) ].
	self assert: actual size equals: expected size
]

{ #category : 'tests' }
CMarkRoassalGoldenTest >> testFootnotes [
	self assertFixture: #footnotes
]

{ #category : 'tests' }
CMarkRoassalGoldenTest >> testHandBuilt [
	self assertGolden: #handBuilt of: CMarkRoassalExamples handBuiltDocument
]

{ #category : 'tests' }
CMarkRoassalGoldenTest >> testNested [
	self assertFixture: #nested
]

{ #category : 'tests' }
CMarkRoassalGoldenTest >> testSample [
	self assertFixture: #sample
]

{ #category : 'tests' }
CMarkRoassalGoldenTest >> testTable [
	self assertFixture: #table
]

{ #category : 'tests' }
CMarkRoassalGoldenTest >> testTasks [
	self assertFixture: #tasks
]

{ #category : 'tests' }
CMarkRoassalGoldenTest >> testUnicode [
	self assertFixture: #unicode
]
