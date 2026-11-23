"
I compare the structural dump of the renderings of the fixtures (`CMarkRoassalTestCase>>dump:`: one line per shape with its class, the `typeName` of its model, its bounds rounded to 0.5 and the text of a label) with the goldens of `CMarkRoassalGoldens`, which were generated once and reviewed. A change of the layout then shows as a golden diff, without fragile pixels. The hand-built document needs no plugin; the fixtures of `CMarkFixtures` are parsed with the GitHub options and footnotes.

The structure of a dump (the indentation, the class, the model and the text of a label of each line, and the number of lines) is compared under any cairo.

Its bounds hold cairo's text metrics, which differ between versions of cairo (cairo 1.17.4, which the VMs of files.pharo.org bundle, makes some labels narrower, by up to 25 pixels for a word of code): they are compared only under the major and minor version of the cairo that the goldens were made with (`CMarkRoassalGoldens class>>cairoVersion`), and a golden test skips after its structure matched under another cairo, or when the image cannot ask cairo for its version (`cairoVersion`). `cairoVersion:` sets the version for the tests of the comparison.
"
Class {
	#name : 'CMarkRoassalGoldenTest',
	#superclass : 'CMarkRoassalTestCase',
	#instVars : [
		'cairoVersion'
	],
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
	"The dump of the rendering of aDocument must have the structure of the golden aSymbol, and its bounds too under the cairo of the goldens (comparesBounds): under another cairo the test skips once the structure matched"

	| actual golden problems |
	actual := self dump: (self render: aDocument).
	golden := CMarkRoassalGoldens perform: aSymbol.
	problems := self goldenProblemsOf: actual against: golden bounds: false.
	self assert: problems isEmpty description: (problems ifEmpty: [ '' ] ifNotEmpty: [ aSymbol , ' ' , problems first ]).
	self comparesBounds ifFalse: [
		^ self skip: aSymbol , ': the structure matches; the bounds are not compared under cairo '
			  , (self cairoVersion ifNil: [ '(unknown)' ]) , ', the goldens hold those of cairo ' , CMarkRoassalGoldens cairoVersion ].
	problems := self goldenProblemsOf: actual against: golden bounds: true.
	self assert: problems isEmpty description: (problems ifEmpty: [ '' ] ifNotEmpty: [ aSymbol , ' ' , problems first ])
]

{ #category : 'accessing' }
CMarkRoassalGoldenTest >> cairoVersion [
	"The version of the cairo that measures the labels, such as '1.18.6' (cairo_version_string), or nil when the image cannot ask cairo"

	cairoVersion ifNil: [
		cairoVersion := [ (Smalltalk globals at: #CairoLibrary) uniqueInstance versionString asString ]
			                on: Error
			                do: [ :error | '' ] ].
	^ cairoVersion ifEmpty: [ nil ]
]

{ #category : 'accessing' }
CMarkRoassalGoldenTest >> cairoVersion: aString [
	"Take aString for the version of cairo (the empty String for a cairo whose version is unknown)"

	cairoVersion := aString
]

{ #category : 'comparing' }
CMarkRoassalGoldenTest >> comparesBounds [
	"Whether the bounds of the dumps are compared with those of the goldens: only under the major and minor version of the cairo that the goldens were made with"

	^ self cairoVersion
		  ifNil: [ false ]
		  ifNotNil: [ :version | (self majorMinorOf: version) = (self majorMinorOf: CMarkRoassalGoldens cairoVersion) ]
]

{ #category : 'comparing' }
CMarkRoassalGoldenTest >> goldenProblemsOf: actualString against: goldenString bounds: aBoolean [
	"The differences of the dump actualString from the golden goldenString, at most one per line and one for the number of lines: each line must have the structure of its golden line (structureOf:), and be equal to it when aBoolean"

	| actual expected problems |
	actual := actualString lines.
	expected := goldenString lines.
	problems := OrderedCollection new.
	1 to: (actual size min: expected size) do: [ :i |
		| line golden |
		line := actual at: i.
		golden := expected at: i.
		(aBoolean
			 ifTrue: [ line = golden ]
			 ifFalse: [ (self structureOf: line) = (self structureOf: golden) ]) ifFalse: [
			problems add: 'line ' , i printString , ': ' , line , ' instead of ' , golden ] ].
	actual size = expected size ifFalse: [
		problems add: actual size printString , ' lines instead of ' , expected size printString ].
	^ problems
]

{ #category : 'comparing' }
CMarkRoassalGoldenTest >> majorMinorOf: aVersionString [
	"The major and minor numbers of a version such as '1.18.6', as an Array of Strings"

	| numbers |
	numbers := aVersionString substrings: '.'.
	^ (numbers first: (numbers size min: 2)) asArray
]

{ #category : 'comparing' }
CMarkRoassalGoldenTest >> structureOf: aLine [
	"aLine of a dump without its bounds: its indentation, its class, its model and the quoted text of a label"

	| quote head text numeral |
	quote := aLine indexOf: $".
	head := quote = 0
		        ifTrue: [ aLine ]
		        ifFalse: [ aLine copyFrom: 1 to: quote - 1 ].
	text := quote = 0
		        ifTrue: [ '' ]
		        ifFalse: [ aLine copyFrom: quote to: aLine size ].
	numeral := [ :token | (token anySatisfy: [ :each | each isDigit ]) and: [ token allSatisfy: [ :each | each isDigit or: [ '.-' includes: each ] ] ] ].
	^ String streamContents: [ :stream |
		  stream next: (head findFirst: [ :each | each ~= Character space ]) - 1 put: Character space.
		  (head substrings reject: numeral) do: [ :each | stream nextPutAll: each ] separatedBy: [ stream space ].
		  text ifNotEmpty: [
			  stream
				  space;
				  nextPutAll: text ] ]
]

{ #category : 'tests - comparison' }
CMarkRoassalGoldenTest >> testBoundsAreComparedUnderTheCairoOfTheGoldens [
	"A label one and a half pixels narrower, as cairo 1.17.4 measures the first heading of the hand-built document, fails under cairo 1.18"

	| golden narrower problems |
	golden := CMarkRoassalGoldens handBuilt.
	narrower := golden copyReplaceAll: ' 16.0 16.0 307.5 56.0 "Hand-built Markdown"' with: ' 16.0 16.0 306.0 56.0 "Hand-built Markdown"'.
	self deny: narrower equals: golden.
	#( '1.18.6' '1.18.0' '1.18' ) do: [ :version |
		self cairoVersion: version.
		self assert: self comparesBounds.
		problems := self goldenProblemsOf: narrower against: golden bounds: true.
		self assert: problems size equals: 1.
		self assert: (problems first beginsWith: 'line 6: ') ].
	self assert: (self goldenProblemsOf: golden against: golden bounds: true) isEmpty
]

{ #category : 'tests - comparison' }
CMarkRoassalGoldenTest >> testBoundsAreNotComparedUnderAnotherCairo [
	"The dump of the hand-built document under cairo 1.17.4 (narrower labels, the CI batteries job's VM of files.pharo.org) has the structure of the golden, and its bounds are not compared under that cairo, nor under a later one or an unknown one"

	| golden narrower |
	golden := CMarkRoassalGoldens handBuilt.
	narrower := (golden copyReplaceAll: ' 16.0 16.0 307.5 56.0 "Hand-built Markdown"' with: ' 16.0 16.0 306.0 56.0 "Hand-built Markdown"')
		            copyReplaceAll: ' 16.0 155.5 64.5 186.5 "Lists"'
		            with: ' 16.0 155.5 63.5 186.5 "Lists"'.
	self deny: narrower equals: golden.
	self assert: (self goldenProblemsOf: narrower against: golden bounds: false) isEmpty.
	#( '1.17.4' '1.16.0' '1.20.0' '2.18.6' '' ) do: [ :version |
		self cairoVersion: version.
		self deny: self comparesBounds ]
]

{ #category : 'tests - comparison' }
CMarkRoassalGoldenTest >> testCairoVersionOfTheImage [
	"The image answers the version of its cairo (dotted numbers), or nil when it cannot ask"

	self cairoVersion ifNotNil: [ :version |
		self assert: (version allSatisfy: [ :each | each isDigit or: [ each = $. ] ]).
		self assert: (self majorMinorOf: version) size equals: 2 ]
]

{ #category : 'tests - comparison' }
CMarkRoassalGoldenTest >> testStructureIsComparedUnderAnyCairo [
	"A change of the text of a label, of a class, of a model, of a depth or of the number of lines fails, bounds or not"

	| golden |
	golden := CMarkRoassalGoldens handBuilt.
	{
		golden copyReplaceAll: ' "Lists"' with: ' "List"'.
		golden copyReplaceAll: 'RSEllipse item' with: 'RSBox item'.
		golden copyReplaceAll: 'RSComposite heading 16.0 155.5' with: 'RSComposite paragraph 16.0 155.5'.
		golden copyReplaceAll: '    RSLabel text 16.0 155.5' with: '      RSLabel text 16.0 155.5'.
		golden copyReplaceAll: ' "Lists"' with: ' "Lists"
    RSLabel text 16.0 155.5 64.5 186.5 "Lists"' } do: [ :changed |
		self deny: changed equals: golden.
		self deny: (self goldenProblemsOf: changed against: golden bounds: false) isEmpty.
		self deny: (self goldenProblemsOf: changed against: golden bounds: true) isEmpty ].
	self assert: (self structureOf: '    RSLabel text 16.0 155.5 64.5 186.5 "Lists 1.5 -2"') equals: '    RSLabel text "Lists 1.5 -2"'.
	self assert: (self structureOf: '  RSBox - 0.0 -1.5 672.0 633.0') equals: '  RSBox -'
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
