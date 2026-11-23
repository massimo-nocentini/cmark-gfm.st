"
I am the font cache of one rendering (`CMarkRoassalRenderer>>render:`, which resets me at its end).

## Fonts

I answer the `LogicalFont` of a `CMarkInlineStyle` (`fontFor:`), cached by its `fontKey`, after checking its family against the families of the image (a missing family falls back to `RSLabel familyFontName` at the same size: Roassal would silently use its default font at 10 points).

The `LogicalFont`s themselves are made once for the image (class side, `sharedFontFamily:pointSize:emphasis:`) and kept, as the fonts of the user interface are. With new `LogicalFont`s in every rendering, the cairo fonts of Roassal (cached per `FreeTypeFont` in the weak `CairoBackendCache`) were made and dropped again and again, and after some renderings the labels of the 11-point footnote font measured about 1.25 times too wide: the golden tests failed on the batteries image and on Pharo 12, depending on the tests run before. With shared fonts this was not seen again.

## Measures

I measure text per (`fontKey`, Character): the advance of a string is the sum of the advances of its characters. That is exact because the cairo metrics provider of Roassal (`RSCairoMetricsProvider`, through `RSLabel>>textExtents`) sums glyph advances without kerning, and it keeps the cache small (a few hundred entries) where a cache per word would grow with every distinct word.

Each font has one probe `RSLabel` that does the measuring. The ascent and the height of a font are those of its probe's `textExtents` (the ascent is the same for every text of a font).

Pen positions always use these advances, never `RSLabel>>width`, which is ink-based.
"
Class {
	#name : 'CMarkRoassalFonts',
	#superclass : 'Object',
	#instVars : [
		'fonts',
		'advances',
		'probes',
		'metrics',
		'families'
	],
	#classVars : [
		'SharedFonts'
	],
	#category : 'CMark-Roassal-Rendering',
	#package : 'CMark-Roassal',
	#tag : 'Rendering'
}

{ #category : 'fonts' }
CMarkRoassalFonts class >> sharedFontFamily: aString pointSize: anInteger emphasis: aCode [
	"The LogicalFont of the family aString at anInteger points with the emphasis aCode, made once and kept for the image, as the fonts of its user interface are (see the class comment: fonts made anew in every rendering let labels measure at a wrong size)"

	^ (SharedFonts ifNil: [ SharedFonts := Dictionary new ])
		  at: { aString. anInteger. aCode }
		  ifAbsentPut: [ (LogicalFont familyName: aString pointSize: anInteger) emphasized: aCode ]
]

{ #category : 'measuring' }
CMarkRoassalFonts >> advanceOf: aCharacter in: aStyle [
	"The advance of aCharacter in the font of aStyle"

	^ (advances at: aStyle fontKey ifAbsentPut: [ Dictionary new ])
		  at: aCharacter
		  ifAbsentPut: [
			  | probe |
			  probe := self probeFor: aStyle.
			  probe text: (String with: aCharacter).
			  probe textExtents x_advance ]
]

{ #category : 'measuring' }
CMarkRoassalFonts >> ascentOf: aStyle [
	"The ascent of the font of aStyle (the distance from the top of a label to its baseline)"

	^ (self metricsOf: aStyle) first
]

{ #category : 'measuring' }
CMarkRoassalFonts >> descentOf: aStyle [
	^ (self metricsOf: aStyle) second - (self metricsOf: aStyle) first
]

{ #category : 'fonts' }
CMarkRoassalFonts >> familyFor: aString [
	"aString when the image has a font family of that name, else the default family of RSLabel"

	^ families at: aString ifAbsentPut: [
		  (LogicalFontManager current allFamilies anySatisfy: [ :each | each familyName asString = aString ])
			  ifTrue: [ aString ]
			  ifFalse: [ RSLabel familyFontName ] ]
]

{ #category : 'fonts' }
CMarkRoassalFonts >> fontFor: aStyle [
	"The LogicalFont of aStyle: its family (or the fallback family), its size, bold and italic"

	^ fonts at: aStyle fontKey ifAbsentPut: [
		  self class sharedFontFamily: (self familyFor: aStyle family) pointSize: aStyle pointSize emphasis: aStyle emphasisCode ]
]

{ #category : 'measuring' }
CMarkRoassalFonts >> heightOf: aStyle [
	"The height of a label of the font of aStyle"

	^ (self metricsOf: aStyle) second
]

{ #category : 'initialization' }
CMarkRoassalFonts >> initialize [
	super initialize.
	self reset
]

{ #category : 'labels' }
CMarkRoassalFonts >> labelFor: aString style: aStyle [
	"A new RSLabel of the non-empty aString (it has no TAB, CR or LF) in the font, colour and decorations of aStyle; its model is not set"

	| label |
	label := RSLabel new.
	label font: (self fontFor: aStyle).
	aStyle underline ifTrue: [ label underline ].
	aStyle strike ifTrue: [ label struckOut ].
	label text: aString.
	label color: aStyle color.
	^ label
]

{ #category : 'measuring' }
CMarkRoassalFonts >> metricsOf: aStyle [
	"{ ascent. height } of the font of aStyle"

	^ metrics at: aStyle fontKey ifAbsentPut: [
		  | probe extents |
		  probe := self probeFor: aStyle.
		  probe text: 'Hg'.
		  extents := probe textExtents.
		  { extents y_bearing negated. extents height } ]
]

{ #category : 'measuring' }
CMarkRoassalFonts >> probeFor: aStyle [
	"The RSLabel that measures the font of aStyle"

	^ probes at: aStyle fontKey ifAbsentPut: [
		  RSLabel new
			  font: (self fontFor: aStyle);
			  yourself ]
]

{ #category : 'initialization' }
CMarkRoassalFonts >> reset [
	"Forget every font, probe and measure"

	fonts := Dictionary new.
	advances := Dictionary new.
	probes := Dictionary new.
	metrics := Dictionary new.
	families := Dictionary new
]

{ #category : 'measuring' }
CMarkRoassalFonts >> widthOf: aString in: aStyle [
	"The advance of aString in the font of aStyle: the sum of the advances of its characters"

	| sum |
	sum := 0.
	aString do: [ :each | sum := sum + (self advanceOf: each in: aStyle) ].
	^ sum
]
