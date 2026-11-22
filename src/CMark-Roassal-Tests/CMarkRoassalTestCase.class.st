"
I am the abstract test of the Roassal rendering.  My tests build their trees by hand (no plugin needed) or parse them with requirePlugin.  requireCanvas skips when RSCanvas new raises (the stock image of the WebAssembly VM has no world surface) and requireSurface when no cairo surface can be made; the shape tests (composites, labels, metrics) need neither.

Helpers: render: (with the renderer kept in renderer), walk:do: (every shape of a rendering with its rectangle in the coordinates of the root, iteratively), labelsOf:, framesOf:, dump: (the golden structural dump: one line per shape, its class, the typeName of its model, its bounds rounded to 0.5 and the text of a label, non-ASCII characters escaped), and small builders of nodes (text:, paragraph:, document:).
"
Class {
	#name : 'CMarkRoassalTestCase',
	#superclass : 'CMarkTestCase',
	#instVars : [
		'renderer'
	],
	#category : 'CMark-Roassal-Tests-Support',
	#package : 'CMark-Roassal-Tests',
	#tag : 'Support'
}

{ #category : 'testing' }
CMarkRoassalTestCase class >> isAbstract [
	^ self == CMarkRoassalTestCase
]

{ #category : 'builders' }
CMarkRoassalTestCase >> code: aString [
	^ CMarkCode literal: aString
]

{ #category : 'builders' }
CMarkRoassalTestCase >> document: aCollection [
	"A hand-built document of the blocks of aCollection"

	^ (CMarkDocument source: '')
		  addAll: aCollection;
		  yourself
]

{ #category : 'dumping' }
CMarkRoassalTestCase >> dump: aShape [
	"The golden structural dump of aShape: one line per shape, indented by its depth, with its class, the typeName of its model, its bounds rounded to 0.5 and the text of a label"

	^ String streamContents: [ :stream |
		  self walk: aShape do: [ :shape :rect :depth |
			  stream
				  next: 2 * depth put: Character space;
				  nextPutAll: shape class name;
				  space;
				  nextPutAll: (shape model ifNil: [ '-' ] ifNotNil: [ :model | model typeName ]).
			  { rect left. rect top. rect right. rect bottom } do: [ :each |
				  stream
					  space;
					  nextPutAll: (self half: each) ].
			  shape isLabel ifTrue: [
				  stream
					  nextPutAll: ' "';
					  nextPutAll: (self escaped: shape text);
					  nextPut: $" ].
			  stream lf ] ]
]

{ #category : 'dumping' }
CMarkRoassalTestCase >> escaped: aString [
	"aString with its non-ASCII characters and its quotes and backslashes escaped, so that dumps stay ASCII"

	^ String streamContents: [ :stream |
		  aString do: [ :each |
			  (each = $" or: [ each = $\ ])
				  ifTrue: [ stream nextPut: $\; nextPut: each ]
				  ifFalse: [
					  each asInteger < 128
						  ifTrue: [ stream nextPut: each ]
						  ifFalse: [
							  stream nextPutAll: '\u{'.
							  each asInteger printOn: stream base: 16.
							  stream nextPut: $} ] ] ] ]
]

{ #category : 'rendering' }
CMarkRoassalTestCase >> fixture: aSymbol [
	"The fixture aSymbol of CMarkFixtures parsed by the plugin with the GitHub options and footnotes"

	self requireParser.
	^ CMark parse: (CMarkFixtures perform: aSymbol) options: (CMarkOptions gfm
			   footnotes: true;
			   yourself)
]

{ #category : 'helpers' }
CMarkRoassalTestCase >> framesOf: aShape [
	"The frame boxes of the blocks of aShape"

	| frames |
	frames := OrderedCollection new.
	self walk: aShape do: [ :shape :rect :depth | (shape propertyAt: #cmarkFrame ifAbsent: [ false ]) ifTrue: [ frames add: shape ] ].
	^ frames
]

{ #category : 'dumping' }
CMarkRoassalTestCase >> half: aNumber [
	"aNumber rounded to 0.5, printed with one decimal"

	^ ((aNumber * 2) rounded / 2) printShowingDecimalPlaces: 1
]

{ #category : 'helpers' }
CMarkRoassalTestCase >> labelsOf: aShape [
	"The RSLabels of aShape, with their rectangles: an OrderedCollection of label -> rectangle, in drawing order"

	| labels |
	labels := OrderedCollection new.
	self walk: aShape do: [ :shape :rect :depth | shape isLabel ifTrue: [ labels add: shape -> rect ] ].
	^ labels
]

{ #category : 'helpers' }
CMarkRoassalTestCase >> lineTopsOf: aShape [
	"The distinct tops of the labels of aShape, sorted: one per line of text"

	^ ((self labelsOf: aShape) collect: [ :each | (each value top * 100) rounded / 100 ]) asSet asSortedCollection asArray
]

{ #category : 'builders' }
CMarkRoassalTestCase >> paragraph: aCollection [
	^ CMarkParagraph with: aCollection
]

{ #category : 'rendering' }
CMarkRoassalTestCase >> parse: aString [
	"aString parsed by the CMarkPlugin (skips without it)"

	self requireParser.
	^ CMarkRoassalExamples parse: aString
]

{ #category : 'rendering' }
CMarkRoassalTestCase >> render: aNode [
	renderer := CMarkRoassalRenderer new.
	^ renderer render: aNode
]

{ #category : 'rendering' }
CMarkRoassalTestCase >> render: aNode theme: aTheme [
	renderer := CMarkRoassalRenderer theme: aTheme.
	^ renderer render: aNode
]

{ #category : 'rendering' }
CMarkRoassalTestCase >> render: aNode width: aNumber [
	renderer := CMarkRoassalRenderer new maxWidth: aNumber.
	^ renderer render: aNode
]

{ #category : 'helpers' }
CMarkRoassalTestCase >> requireCanvas [
	"Skip unless a canvas can be made (the stock image of the WebAssembly VM has no world surface)"

	[ RSCanvas new ]
		on: Error
		do: [ :e | self skip: 'no RSCanvas here: ' , e messageText asString ]
]

{ #category : 'helpers' }
CMarkRoassalTestCase >> requireParser [
	"Skip unless the CMarkPlugin parses (requirePlugin of CMark-Tests)"

	(self respondsTo: #requirePlugin) ifFalse: [ ^ self skip: 'CMark-Tests cannot check for the plugin' ].
	self perform: #requirePlugin
]

{ #category : 'helpers' }
CMarkRoassalTestCase >> requireSurface [
	"Skip unless a cairo surface can be made"

	[ AthensCairoSurface extent: 1 @ 1 ]
		on: Error
		do: [ :e | self skip: 'no cairo surface here: ' , e messageText asString ]
]

{ #category : 'builders' }
CMarkRoassalTestCase >> text: aString [
	^ CMarkText literal: aString
]

{ #category : 'helpers' }
CMarkRoassalTestCase >> walk: aShape do: aBlock [
	"Evaluate aBlock with each shape of aShape (pre-order, iteratively), its encompassing rectangle in the coordinates of aShape's parent, and its depth"

	| stack |
	stack := OrderedCollection with: { aShape. 0 @ 0. 0 }.
	[ stack isEmpty ] whileFalse: [
		| entry shape offset |
		entry := stack removeLast.
		shape := entry first.
		offset := entry second.
		aBlock value: shape value: (shape encompassingRectangle translateBy: offset) value: entry third.
		shape isComposite ifTrue: [
			shape children reverseDo: [ :each | stack addLast: { each. offset + shape position. entry third + 1 } ] ] ]
]

{ #category : 'helpers' }
CMarkRoassalTestCase >> withTemporaryDirectory: aBlock [
	"Evaluate aBlock with a new empty directory, deleted afterwards"

	| dir |
	dir := FileLocator temp / ('cmark-roassal-' , UUID new asString).
	dir ensureCreateDirectory.
	[ aBlock value: dir ] ensure: [ dir ensureDeleteAll ]
]
