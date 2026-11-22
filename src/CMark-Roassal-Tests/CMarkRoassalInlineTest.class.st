"
I test the inline layout (CMarkInlineFlow): baselines of mixed sizes, clusters at the wrap boundary, code spans that wrap at their spaces, U+00A0, hard breaks from the options of the document, narrowing, deep emphasis, raised footnote references, and the no-kerning guard the breaker relies on.
"
Class {
	#name : 'CMarkRoassalInlineTest',
	#superclass : 'CMarkRoassalTestCase',
	#category : 'CMark-Roassal-Tests-Tests',
	#package : 'CMark-Roassal-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkRoassalInlineTest >> baselineOf: aLabelAssociation [
	"The y of the baseline of a label (label -> rectangle of walk:do:)"

	^ aLabelAssociation value top + aLabelAssociation key textExtents y_bearing negated
]

{ #category : 'helpers' }
CMarkRoassalInlineTest >> lineStartsOf: aShape [
	"The labels that start a line: the leftmost label of each distinct top"

	| byTop |
	byTop := Dictionary new.
	(self labelsOf: aShape) do: [ :each |
		| key |
		key := (each value top * 100) rounded.
		((byTop at: key ifAbsent: [ nil ]) isNil or: [ each value left < (byTop at: key) value left ]) ifTrue: [
			byTop at: key put: each ] ].
	^ byTop values collect: [ :each | each key ]
]

{ #category : 'tests' }
CMarkRoassalInlineTest >> testClustersAtTheWrapBoundary [
	"[x](u). never starts a line with the period, **b**, keeps its comma, at any width"

	100 to: 260 by: 3 do: [ :width |
		| doc shape |
		doc := self document: { (self paragraph: {
					        (self text: (self words: 12)).
					        ((CMarkLink url: 'u' title: '') addAll: { (self text: 'x') }; yourself).
					        (self text: '. then ').
					        (CMarkStrong with: { (self text: 'b') }).
					        (self text: ', and ' , (self words: 9)) }) }.
		shape := self render: doc width: width.
		(self lineStartsOf: shape) do: [ :each |
			self deny: (each text beginsWith: '.') description: width printString.
			self deny: (each text beginsWith: ',') description: width printString ] ]
]

{ #category : 'tests' }
CMarkRoassalInlineTest >> testCodeSpanWithSpacesWraps [
	| doc shape boxes |
	doc := self document: { (self paragraph: { (self code: 'one two three four five six seven eight nine ten eleven twelve') }) }.
	shape := self render: doc width: 160.
	self assert: (self lineTopsOf: shape) size > 1.
	self assert: shape encompassingRectangle width <= (160 + (2 * renderer theme padding) + 0.01).
	"one chip box per line"
	boxes := OrderedCollection new.
	self walk: shape do: [ :each :rect :depth | (each class == RSBox and: [ each model isKindOf: CMarkCode ]) ifTrue: [ boxes add: each ] ].
	self assert: boxes size equals: (self lineTopsOf: shape) size
]

{ #category : 'tests' }
CMarkRoassalInlineTest >> testCodeSpanWithoutSpacesOverflows [
	| doc shape |
	doc := self document: { (self paragraph: { (self code: (String new: 80 withAll: $x)) }) }.
	shape := self render: doc width: 160.
	self assert: (self lineTopsOf: shape) size equals: 1.
	self assert: shape encompassingRectangle width > (160 + (2 * renderer theme padding))
]

{ #category : 'tests' }
CMarkRoassalInlineTest >> testDeepEmphasis [
	"2000 nested emphases render without recursion, unstyled beyond maxNesting"

	| inline doc shape |
	inline := self text: 'deep'.
	2000 timesRepeat: [ inline := CMarkEmph with: { inline } ].
	doc := self document: { (self paragraph: { inline }) }.
	shape := self render: doc.
	self assert: ((self labelsOf: shape) collect: [ :each | each key text ]) asArray equals: #( 'deep' )
]

{ #category : 'tests' }
CMarkRoassalInlineTest >> testFootnoteReferenceIsRaised [
	| definition reference doc shape labels text ref |
	definition := CMarkFootnoteDefinition label: 'n'.
	definition ordinal: 1.
	definition addChild: (self paragraph: { (self text: 'note') }).
	reference := CMarkFootnoteReference new ordinal: 1; yourself.
	definition addReference: reference.
	doc := self document: { (self paragraph: { (self text: 'see'). reference }). definition }.
	shape := self render: doc.
	labels := self labelsOf: shape.
	text := labels detect: [ :each | each key text = 'see' ].
	ref := labels detect: [ :each | each key text = '[1]' ].
	self assert: (self baselineOf: ref) < ((self baselineOf: text) - 1).
	self assert: ref key model identicalTo: reference
]

{ #category : 'tests' }
CMarkRoassalInlineTest >> testHardBreaksFromTheDocumentOptions [
	| doc shape options |
	doc := self document: { (self paragraph: { (self text: 'one'). CMarkSoftBreak new. (self text: 'two') }) }.
	shape := self render: doc.
	self assert: (self lineTopsOf: shape) size equals: 1.
	options := CMarkOptions new.
	options hardBreaks: true.
	doc cmarkDecodedSource: '' options: options nodeCount: 6 depth: 3 sanitised: nil.
	shape := self render: doc.
	self assert: (self lineTopsOf: shape) size equals: 2
]

{ #category : 'tests' }
CMarkRoassalInlineTest >> testLineBreak [
	| doc shape |
	doc := self document: { (self paragraph: { (self text: 'one'). CMarkLineBreak new. (self text: 'two') }) }.
	shape := self render: doc.
	self assert: (self lineTopsOf: shape) size equals: 2
]

{ #category : 'tests' }
CMarkRoassalInlineTest >> testMergedLabels [
	"Consecutive words of one run make one label; a link of two words is one underlined label"

	| doc shape texts |
	doc := self document: { (self paragraph: {
				        (self text: 'plain words here ').
				        ((CMarkLink url: 'https://x.y' title: '') addAll: { (self text: 'link text') }; yourself) }) }.
	shape := self render: doc.
	texts := (self labelsOf: shape) collect: [ :each | each key text ].
	self assert: texts asArray equals: #( 'plain words here' 'link text' ).
	self assert: (self labelsOf: shape) last key isUnderlined
]

{ #category : 'tests' }
CMarkRoassalInlineTest >> testMetricsDoNotKern [
	"The breaker sums the advances of characters: the metrics provider must not kern"

	| fonts style |
	fonts := CMarkRoassalFonts new.
	style := CMarkRoassalTheme default baseStyle.
	#( 'AVAWay To' 'Markdown' 'parsed by cmark-gfm' 'Typography, kerning: VA To' 'f' ) do: [ :each |
		| label |
		label := fonts labelFor: each style: style.
		self assert: ((fonts widthOf: each in: style) - label textExtents x_advance) abs < 0.01 description: each ]
]

{ #category : 'tests' }
CMarkRoassalInlineTest >> testMixedSizesShareTheBaseline [
	"A heading with bold text, a code span and a link: every label of the first line sits on one baseline"

	| doc shape labels baselines |
	doc := self document: { (CMarkHeading level: 1 with: {
				        (self text: 'Big ').
				        (CMarkStrong with: { (self text: 'bold') }).
				        (self text: ' and ').
				        (self code: 'mono').
				        (self text: ' gyp') }) }.
	shape := self render: doc.
	labels := self labelsOf: shape.
	self assert: labels size equals: 5.
	baselines := labels collect: [ :each | self baselineOf: each ].
	baselines do: [ :each | self assert: (each - baselines first) abs < 0.01 ]
]

{ #category : 'tests' }
CMarkRoassalInlineTest >> testNarrowingAddsLines [
	| doc wide narrow |
	doc := self document: { (self paragraph: { (self text: (self words: 60)) }) }.
	wide := (self lineTopsOf: (self render: doc width: 640)) size.
	narrow := (self lineTopsOf: (self render: doc width: 200)) size.
	self assert: narrow > wide
]

{ #category : 'tests' }
CMarkRoassalInlineTest >> testNoBreakSpaceNeverBreaks [
	| nbsp doc shape |
	nbsp := (Character value: 160) asString.
	doc := self document: { (self paragraph: { (self text: (String streamContents: [ :s | 20 timesRepeat: [ s nextPutAll: 'aaaa' , nbsp , 'bbbb ' ] ])) }) }.
	80 to: 200 by: 7 do: [ :width |
		shape := self render: doc width: width.
		(self labelsOf: shape) do: [ :each |
			self deny: (each key text endsWith: 'aaaa').
			self deny: (each key text beginsWith: 'bbbb') ] ]
]

{ #category : 'tests' }
CMarkRoassalInlineTest >> testSoftBreakIsASpace [
	| doc shape |
	doc := self document: { (self paragraph: { (self text: 'one'). CMarkSoftBreak new. (self text: 'two') }) }.
	shape := self render: doc.
	self assert: ((self labelsOf: shape) collect: [ :each | each key text ]) asArray equals: #( 'one' 'two' ).
	self assert: (self lineTopsOf: shape) size equals: 1
]

{ #category : 'tests' }
CMarkRoassalInlineTest >> testTextWithBlanks [
	"TAB, CR and LF are blanks: they collapse and never reach a label"

	| doc shape |
	doc := self document: { (self paragraph: { (self text: 'a' , String tab , 'b' , String crlf , 'c   d') }) }.
	shape := self render: doc.
	self assert: ((self labelsOf: shape) collect: [ :each | each key text ]) asArray equals: #( 'a b c d' )
]

{ #category : 'helpers' }
CMarkRoassalInlineTest >> words: anInteger [
	^ String streamContents: [ :stream |
		  1 to: anInteger do: [ :i |
			  stream nextPutAll: (#( 'alpha' 'beta' 'gamma' 'delta' 'epsilon' ) at: i \\ 5 + 1).
			  stream space ] ]
]
