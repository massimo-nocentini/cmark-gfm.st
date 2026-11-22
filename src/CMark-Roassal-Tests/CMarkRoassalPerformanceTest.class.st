"
I print the cost of rendering (no assertion beyond 60 s): for the hand-built document, the sample and a generated README-like text of about 1 MB (headings, paragraphs, lists, a 50 x 10 table, code; 256 KB on WebAssembly), the shape count, the build time and the time of one full draw into an off-screen cairo surface (skipped without a surface).
"
Class {
	#name : 'CMarkRoassalPerformanceTest',
	#superclass : 'CMarkRoassalTestCase',
	#category : 'CMark-Roassal-Tests-Tests',
	#package : 'CMark-Roassal-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkRoassalPerformanceTest >> drawTimeOf: aShape [
	"The milliseconds of one full draw of aShape into a cairo surface, or nil without a surface"

	| canvas morph surface |
	[ AthensCairoSurface extent: 1 @ 1 ]
		on: Error
		do: [ :e | ^ nil ].
	canvas := RSCanvas new.
	canvas add: aShape.
	morph := canvas createMorph.
	morph extent: 800 @ 600.
	canvas extent: 800 @ 600.
	canvas zoomToFit.
	^ Time millisecondsToRun: [
		  surface := AthensCairoSurface extent: 800 @ 600.
		  canvas invalidate.
		  surface drawDuring: [ :athensCanvas | morph fullDrawOnAthensCanvas: athensCanvas ] ]
]

{ #category : 'helpers' }
CMarkRoassalPerformanceTest >> readmeLikeText: aSize [
	"A generated Markdown text of about aSize characters"

	^ String streamContents: [ :stream |
		  | section |
		  section := 0.
		  [ stream position < aSize ] whileTrue: [
			  section := section + 1.
			  stream nextPutAll: '## Section ' , section printString; lf; lf.
			  3 timesRepeat: [
				  stream nextPutAll: 'Some *emphasis*, **strong** words, `code`, and a [link](https://example.org/' , section printString
					  , ') in a paragraph that is long enough to wrap over a few lines of the column, as a README has.'; lf; lf ].
			  1 to: 5 do: [ :i | stream nextPutAll: '- item ' , i printString , ' of the list'; lf ].
			  stream lf; nextPutAll: '```smalltalk'; lf; nextPutAll: 'Transcript show: ''section '; print: section; nextPutAll: ''''; lf; nextPutAll: '```'; lf; lf.
			  section \\ 20 = 1 ifTrue: [
				  stream nextPutAll: '| a | b | c | d | e | f | g | h | i | j |'; lf; nextPutAll: '|---|---|---|---|---|---|---|---|---|---|'; lf.
				  50 timesRepeat: [ stream nextPutAll: '| 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |'; lf ].
				  stream lf ] ] ]
]

{ #category : 'helpers' }
CMarkRoassalPerformanceTest >> report: aString document: aDocument [
	| shape ms draw |
	renderer := CMarkRoassalRenderer new.
	ms := Time millisecondsToRun: [ shape := renderer render: aDocument ].
	draw := self drawTimeOf: shape.
	Transcript
		show: 'CMark-Roassal ' , aString , ': ' , renderer shapeCount printString , ' shapes, build ' , ms printString , ' ms, draw '
			, (draw ifNil: [ 'n/a' ] ifNotNil: [ :d | d printString , ' ms' ]);
		cr;
		flush.
	^ ms
]

{ #category : 'tests' }
CMarkRoassalPerformanceTest >> testHandBuilt [
	self assert: (self report: 'hand-built' document: CMarkRoassalExamples handBuiltDocument) < 60000
]

{ #category : 'tests' }
CMarkRoassalPerformanceTest >> testReadmeLike [
	| size text |
	self requireParser.
	size := (CMarkPrimitives platform = 'emscripten')
		        ifTrue: [ 256 * 1024 ]
		        ifFalse: [ 1024 * 1024 ].
	text := self readmeLikeText: size.
	self assert: (self report: 'README-like ' , text size printString , ' characters' document: (self parse: text)) < 60000
]

{ #category : 'tests' }
CMarkRoassalPerformanceTest >> testSample [
	self assert: (self report: 'sample' document: (self fixture: #sample)) < 60000
]
