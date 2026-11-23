"
I export a rendering (an `RSComposite` of `CMarkRoassalRenderer`, any shape, or an `RSCanvas`) to PNG and SVG files through cairo, without `Roassal-Exporters` (it is not in the stock images):

```smalltalk
CMarkRoassalExporter
	exportPng: (CMark parse: text) asRoassalShape
	to: 'doc.png' asFileReference
	scale: 2.
CMarkRoassalExporter
	exportSvg: aCanvas
	to: 'doc.svg' asFileReference.
```

A shape that is in no canvas is put in a new one; a shape in a canvas exports its whole canvas. The picture is the encompassing rectangle of the canvas plus a margin, at the given scale: the camera is centred on it for the export; afterwards the extent of the canvas is restored, then its camera (a scrolled `canvasFor:` canvas stays where it was).

The SVG has the text as glyph outlines (cairo), images embedded, and is drawn without clearing the background (the clear of cairo would erase it).
"
Class {
	#name : 'CMarkRoassalExporter',
	#superclass : 'Object',
	#category : 'CMark-Roassal-Export',
	#package : 'CMark-Roassal',
	#tag : 'Export'
}

{ #category : 'private' }
CMarkRoassalExporter class >> canvasOf: aShapeOrCanvas [
	"The canvas of aShapeOrCanvas (an RSCanvas answers itself), or a new canvas holding it"

	^ aShapeOrCanvas canvas ifNil: [
		  RSCanvas new
			  add: aShapeOrCanvas;
			  yourself ]
]

{ #category : 'private' }
CMarkRoassalExporter class >> drawCanvas: aCanvas scale: aNumber with: aBlock [
	"Evaluate aBlock with the pixel extent and the morph of aCanvas, its camera centred on its shapes at the scale aNumber; restore the extent, then the camera"

	| rect extent morph savedCamera savedExtent savedMorphExtent |
	rect := aCanvas encompassingRectangle expandBy: self margin.
	extent := (rect extent * aNumber) ceiling.
	morph := aCanvas morph ifNil: [ aCanvas createMorph ].
	savedCamera := aCanvas camera copy.
	savedCamera matrix: aCanvas camera matrix copy.
	savedExtent := aCanvas extent.
	savedMorphExtent := morph extent.
	^ [
	  morph extent: extent.
	  aCanvas extent: extent.
	  aCanvas camera scale: aNumber.
	  aCanvas camera translateTo: (aCanvas camera positionFromSpace: rect floatCenter).
	  aCanvas invalidate.
	  aBlock value: extent value: morph ] ensure: [
		  "the extents first: a new extent may move the camera (canvasFor: fits the width again), which must come back as it was"
		  morph extent: savedMorphExtent.
		  savedExtent ifNotNil: [ aCanvas extent: savedExtent ].
		  aCanvas camera: savedCamera ]
]

{ #category : 'exporting' }
CMarkRoassalExporter class >> exportPng: aShapeOrCanvas to: aFileReference scale: aNumber [
	"Write a PNG of aShapeOrCanvas at the scale aNumber (2 for crisp text) to aFileReference; answer the file"

	| file canvas |
	file := aFileReference asFileReference.
	file ensureDelete.
	canvas := self canvasOf: aShapeOrCanvas.
	self drawCanvas: canvas scale: aNumber with: [ :extent :morph |
		| surface |
		surface := AthensCairoSurface extent: extent.
		surface drawDuring: [ :athensCanvas | morph fullDrawOnAthensCanvas: athensCanvas ].
		surface writeToPng: file fullName.
		surface flush ].
	^ file
]

{ #category : 'exporting' }
CMarkRoassalExporter class >> exportSvg: aShapeOrCanvas to: aFileReference [
	"Write an SVG of aShapeOrCanvas to aFileReference; answer the file"

	| file canvas |
	file := aFileReference asFileReference.
	file ensureDelete.
	canvas := self canvasOf: aShapeOrCanvas.
	self drawCanvas: canvas scale: 1 with: [ :extent :morph |
		| surface oldSurface clear |
		surface := AthensCairoSVGSurface extent: extent fileName: file fullName.
		oldSurface := morph surface.
		clear := canvas shouldClearBackground.
		[
		canvas shouldClearBackground: false.
		morph surface: surface.
		canvas invalidate.
		morph drawShapes.
		surface close ] ensure: [
			morph surface: oldSurface.
			canvas shouldClearBackground: clear ] ].
	^ file
]

{ #category : 'accessing' }
CMarkRoassalExporter class >> margin [
	"The space around the shapes in an export"

	^ 2
]
