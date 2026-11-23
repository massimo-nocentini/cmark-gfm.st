"
I test the exports of `CMarkRoassalExporter` (`requireSurface`): a PNG and an SVG of the hand-built document (and of the parsed sample with the plugin) are written, not empty, and the PNG is as large as the composite plus the margin, times the scale (within two pixels, rounded up: the PNG of a cairo surface of `1352@1274` has 1275 rows).
"
Class {
	#name : 'CMarkRoassalExportTest',
	#superclass : 'CMarkRoassalTestCase',
	#category : 'CMark-Roassal-Tests-Tests',
	#package : 'CMark-Roassal-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkRoassalExportTest >> assertExportsOf: aDocument [
	self requireSurface.
	self withTemporaryDirectory: [ :dir |
		| shape png svg form |
		shape := self render: aDocument.
		png := CMarkRoassalExporter exportPng: shape to: dir / 'doc.png' scale: 2.
		self assert: png exists.
		self assert: png size > 1000.
		form := PNGReadWriter formFromFileNamed: png fullName.
		"the extent of the composite plus the margin, times the scale, rounded up (cairo may add one row)"
		self assert: (form extent - ((shape extent + (2 * CMarkRoassalExporter margin)) * 2)) abs <= (2 @ 2).
		"the corners are the background of the document"
		self assert: (form colorAt: 6 @ 6) equals: (form colorAt: form width - 6 @ (form height - 6)).
		svg := CMarkRoassalExporter exportSvg: shape to: dir / 'doc.svg'.
		self assert: svg exists.
		self assert: (svg contents includesSubstring: '<svg') ]
]

{ #category : 'tests' }
CMarkRoassalExportTest >> testExportHandBuilt [
	self assertExportsOf: CMarkRoassalExamples handBuiltDocument
]

{ #category : 'tests' }
CMarkRoassalExportTest >> testExportKeepsAScrolledCamera [
	"Exporting a canvas of canvasFor: that was scrolled leaves its camera where it was (restoring the extent refits the camera, so the camera comes back last)"

	self requireSurface.
	self requireCanvas.
	self withTemporaryDirectory: [ :dir |
		| canvas scale position |
		canvas := CMarkRoassalRenderer new canvasFor: CMarkRoassalExamples handBuiltDocument.
		canvas extent: 400 @ 300.
		canvas camera translateBy: 0 @ 300.
		scale := canvas camera scale.
		position := canvas camera position copy.
		CMarkRoassalExporter exportPng: canvas to: dir / 'a.png' scale: 1.
		self assert: (dir / 'a.png') size > 1000.
		self assert: canvas camera scale equals: scale.
		self assert: canvas camera position equals: position.
		self assert: canvas extent equals: 400 @ 300 ]
]

{ #category : 'tests' }
CMarkRoassalExportTest >> testExportSample [
	self assertExportsOf: (self parse: CMarkFixtures sample)
]

{ #category : 'tests' }
CMarkRoassalExportTest >> testExportTwiceFromOneCanvas [
	"Exporting a shape in a canvas keeps the camera and the extent of the canvas"

	self requireSurface.
	self requireCanvas.
	self withTemporaryDirectory: [ :dir |
		| canvas scale position |
		canvas := CMarkRoassalRenderer new canvasFor: CMarkRoassalExamples handBuiltDocument.
		canvas extent: 400 @ 300.
		scale := canvas camera scale.
		position := canvas camera position.
		CMarkRoassalExporter exportPng: canvas to: dir / 'a.png' scale: 1.
		CMarkRoassalExporter exportPng: canvas shapes first to: dir / 'b.png' scale: 1.
		self assert: (dir / 'a.png') size > 1000.
		self assert: (dir / 'a.png') asFileReference binaryReadStream contents equals: (dir / 'b.png') asFileReference binaryReadStream contents.
		self assert: canvas camera scale equals: scale.
		self assert: canvas camera position equals: position.
		self assert: canvas extent equals: 400 @ 300 ]
]
