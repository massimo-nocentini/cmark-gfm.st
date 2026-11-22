"
I test the canvas of a rendering (requireCanvas): canvasFor: fits the width of the view and shows the top-left of the document, and a click on an anchor link or on a footnote reference moves the camera to its target.
"
Class {
	#name : 'CMarkRoassalCanvasTest',
	#superclass : 'CMarkRoassalTestCase',
	#category : 'CMark-Roassal-Tests-Tests',
	#package : 'CMark-Roassal-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkRoassalCanvasTest >> longDocumentWith: aFirstParagraph [
	"A document whose heading Target comes after many paragraphs"

	| blocks |
	blocks := OrderedCollection new.
	blocks add: aFirstParagraph.
	1 to: 60 do: [ :i | blocks add: (self paragraph: { (self text: 'filler paragraph number ' , i printString) }) ].
	blocks add: (CMarkHeading level: 2 with: { (self text: 'Target') }).
	blocks add: (self paragraph: { (self text: 'the end') }).
	^ self document: blocks
]

{ #category : 'tests' }
CMarkRoassalCanvasTest >> testAnchorClickMovesTheCamera [
	| link doc canvas label heading before after |
	self requireCanvas.
	link := (CMarkLink url: '#target' title: '') addAll: { (self text: 'go to the target') }; yourself.
	doc := self longDocumentWith: (self paragraph: { link }).
	renderer := CMarkRoassalRenderer new.
	canvas := renderer canvasFor: doc.
	canvas extent: 800 @ 400.
	label := canvas allChildren detect: [ :each | each isLabel and: [ each text = 'go to the target' ] ].
	heading := canvas allChildren detect: [ :each | each isLabel and: [ each text = 'Target' ] ].
	before := (canvas camera fromSpaceToPixel: heading globalEncompassingRectangle topLeft) y.
	self assert: before > 400.
	label announce: (RSMouseLeftClick new
			 shape: label;
			 canvas: canvas;
			 yourself).
	after := (canvas camera fromSpaceToPixel: heading globalEncompassingRectangle topLeft) y.
	self assert: after < 100.
	self assert: after >= 0
]

{ #category : 'tests' }
CMarkRoassalCanvasTest >> testCanvasFitsTheWidthAndShowsTheTop [
	| doc canvas shape topLeft topRight |
	self requireCanvas.
	doc := self longDocumentWith: (self paragraph: { (self text: 'first') }).
	renderer := CMarkRoassalRenderer new.
	canvas := renderer canvasFor: doc.
	canvas extent: 500 @ 300.
	shape := canvas shapes first.
	self assert: shape model identicalTo: doc.
	topLeft := canvas camera fromSpaceToPixel: shape encompassingRectangle topLeft.
	topRight := canvas camera fromSpaceToPixel: shape encompassingRectangle topRight.
	self assert: (topLeft x) abs < 1.
	self assert: (topLeft y) abs < 1.
	self assert: (topRight x - 500) abs < 1
]

{ #category : 'tests' }
CMarkRoassalCanvasTest >> testFootnoteClickMovesTheCamera [
	| definition reference doc canvas label target before after |
	self requireCanvas.
	definition := CMarkFootnoteDefinition label: 'n'.
	definition ordinal: 1.
	definition addChild: (self paragraph: { (self text: 'the footnote text') }).
	reference := CMarkFootnoteReference new ordinal: 1; yourself.
	definition addReference: reference.
	doc := self longDocumentWith: (self paragraph: { (self text: 'see'). reference }).
	doc addChild: definition.
	renderer := CMarkRoassalRenderer new.
	canvas := renderer canvasFor: doc.
	canvas extent: 800 @ 400.
	label := canvas allChildren detect: [ :each | each isLabel and: [ each text = '[1]' ] ].
	target := canvas allChildren detect: [ :each | each isLabel and: [ each text = 'the footnote text' ] ].
	before := (canvas camera fromSpaceToPixel: target globalEncompassingRectangle topLeft) y.
	self assert: before > 400.
	label announce: (RSMouseLeftClick new
			 shape: label;
			 canvas: canvas;
			 yourself).
	after := (canvas camera fromSpaceToPixel: target globalEncompassingRectangle topLeft) y.
	self assert: after < 100
]

{ #category : 'tests' }
CMarkRoassalCanvasTest >> testInspectorTab [
	| doc context |
	self requireCanvas.
	doc := CMarkRoassalExamples handBuiltDocument.
	self assert: (doc inspectionCMarkRendered isKindOf: SpPresenter).
	context := CMarkContextStub new.
	doc inspectionCMarkRenderedContext: context.
	self assert: context active
]
