"
I test parsing through the `CMarkPlugin` (each test calls `requirePlugin`):

- the tree of the sample (classes, parents and positions against the golden tree of the C tests, the character indices against the byte columns, the attributes of each construct),
- the kinds of sources (ByteString, WideString, ByteArray, Latin-1, NUL, CR LF, invalid UTF-8),
- footnotes in the moved order,
- the options and the extensions per call, and
- the limits (`maxDepth`, `maxInputSize`, `cBudget`).
"
Class {
	#name : 'CMarkParseTest',
	#superclass : 'CMarkTestCase',
	#category : 'CMark-Tests-Tests',
	#package : 'CMark-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkParseTest >> assertIndicesOf: aDocument against: aString [
	"For an ASCII source: every node with a position that the plugin did not clamp starts at the offset of its start line plus its start byte column, and ends at the offset of its end line plus its end byte column (with an end column of 0, at the line terminator before the end line)"

	| starts |
	starts := self lineStartsOf: aString.
	aDocument do: [ :each |
		(each hasSourcePosition and: [ each isClamped not ]) ifTrue: [
			self assert: each startIndex equals: (starts at: each startLine) + each startByteColumn.
			self assert: each endIndex equals: (starts at: each endLine) + each endByteColumn ] ]
]

{ #category : 'helpers' }
CMarkParseTest >> footnotes [
	"The options gfm with footnotes"

	^ CMarkOptions gfm
		  footnotes: true;
		  yourself
]

{ #category : 'helpers' }
CMarkParseTest >> lineStartsOf: aString [
	"The 0-based offset of each line of aString, line 1 first, cut at CR LF, CR and LF as cmark cuts them, plus the offset after the end (the line after the last)"

	| starts i |
	starts := OrderedCollection with: 0.
	i := 1.
	[ i <= aString size ] whileTrue: [
		| c |
		c := aString at: i.
		(c = Character cr and: [ i < aString size and: [ (aString at: i + 1) = Character lf ] ]) ifTrue: [ i := i + 1 ].
		(c = Character cr or: [ c = Character lf ]) ifTrue: [ starts add: i ].
		i := i + 1 ].
	(starts last = aString size) ifFalse: [ starts add: aString size ].
	^ starts asArray
]

{ #category : 'helpers' }
CMarkParseTest >> nodesOf: aClass in: aNode [
	"The nodes of exactly aClass under aNode, in document order"

	^ aNode select: [ :each | each class == aClass ]
]

{ #category : 'helpers' }
CMarkParseTest >> sampleTree [
	"Each record of fixtures/sample.tree of the CMarkPlugin (the golden tree of the C tests, reviewed against cmark-gfm's own output), parsed with the options footnotes: { class. parent record. startLine. startByteColumn. endLine. endByteColumn. startIndex. endIndex }"

	^ #(
		#( #CMarkDocument 0 1 1 37 24 1 614 )
		#( #CMarkHeading 1 1 1 1 15 1 15 )
		#( #CMarkText 2 1 3 1 10 3 10 )
		#( #CMarkEmph 2 1 11 1 15 11 15 )
		#( #CMarkText 4 1 12 1 14 12 14 )
		#( #CMarkHeading 1 3 1 5 0 18 47 )
		#( #CMarkText 6 3 1 3 14 18 31 )
		#( #CMarkParagraph 1 6 1 9 40 49 271 )
		#( #CMarkText 8 6 1 6 5 49 53 )
		#( #CMarkEmph 8 6 6 6 15 54 63 )
		#( #CMarkText 10 6 7 6 14 55 62 )
		#( #CMarkText 8 6 16 6 17 64 65 )
		#( #CMarkStrong 8 6 18 6 27 66 75 )
		#( #CMarkText 13 6 20 6 25 68 73 )
		#( #CMarkText 8 6 28 6 29 76 77 )
		#( #CMarkStrikethrough 8 6 30 6 39 78 87 )
		#( #CMarkText 16 6 32 6 37 80 85 )
		#( #CMarkText 8 6 40 6 41 88 89 )
		#( #CMarkCode 8 6 43 6 46 91 94 )
		#( #CMarkText 8 6 48 6 51 96 99 )
		#( #CMarkLink 8 6 52 6 86 100 134 )
		#( #CMarkText 21 6 53 6 56 101 104 )
		#( #CMarkSoftBreak 8 0 0 0 0 0 0 )
		#( #CMarkText 8 7 1 7 7 136 142 )
		#( #CMarkImage 8 7 8 7 36 143 171 )
		#( #CMarkText 25 7 10 7 14 145 149 )
		#( #CMarkText 8 7 37 7 48 172 183 )
		#( #CMarkLink 8 7 48 7 61 183 196 )
		#( #CMarkText 28 7 48 7 61 183 196 )
		#( #CMarkText 8 7 62 7 66 197 201 )
		#( #CMarkLink 8 7 154 7 166 216 216 )
		#( #CMarkText 31 7 68 7 78 203 213 )
		#( #CMarkText 8 7 80 7 80 215 215 )
		#( #CMarkSoftBreak 8 0 0 0 0 0 0 )
		#( #CMarkText 8 8 1 8 14 217 230 )
		#( #CMarkLineBreak 8 0 0 0 0 0 0 )
		#( #CMarkText 8 9 1 9 8 232 239 )
		#( #CMarkHtmlInline 8 9 9 9 14 240 245 )
		#( #CMarkText 8 9 15 9 18 246 249 )
		#( #CMarkHtmlInline 8 9 19 9 25 250 256 )
		#( #CMarkText 8 9 26 9 35 257 266 )
		#( #CMarkFootnoteReference 8 9 37 9 38 268 269 )
		#( #CMarkText 8 9 40 9 40 271 271 )
		#( #CMarkBlockQuote 1 11 1 12 11 274 305 )
		#( #CMarkParagraph 44 11 3 12 11 276 305 )
		#( #CMarkText 45 11 3 11 20 276 293 )
		#( #CMarkSoftBreak 45 0 0 0 0 0 0 )
		#( #CMarkText 45 12 3 12 11 297 305 )
		#( #CMarkList 1 14 1 19 0 308 383 )
		#( #CMarkItem 49 14 1 14 8 308 315 )
		#( #CMarkParagraph 50 14 4 14 8 311 315 )
		#( #CMarkText 51 14 4 14 8 311 315 )
		#( #CMarkItem 49 15 1 19 0 317 383 )
		#( #CMarkParagraph 53 15 4 15 9 320 325 )
		#( #CMarkText 54 15 4 15 9 320 325 )
		#( #CMarkList 53 16 4 19 0 330 383 )
		#( #CMarkItem 56 16 4 16 18 330 344 )
		#( #CMarkParagraph 57 16 6 16 18 332 344 )
		#( #CMarkText 58 16 6 16 18 332 344 )
		#( #CMarkTaskItem 56 17 4 17 18 349 363 )
		#( #CMarkParagraph 60 17 10 17 18 355 363 )
		#( #CMarkText 61 17 10 17 18 355 363 )
		#( #CMarkTaskItem 56 18 4 19 0 368 383 )
		#( #CMarkParagraph 63 18 10 18 18 374 382 )
		#( #CMarkText 64 18 10 18 18 374 382 )
		#( #CMarkCodeBlock 1 20 1 22 3 385 428 )
		#( #CMarkCodeBlock 1 24 5 25 0 435 448 )
		#( #CMarkTable 1 26 1 29 8 450 558 )
		#( #CMarkTableHeaderRow 68 26 1 26 32 450 481 )
		#( #CMarkTableCell 69 26 2 26 7 451 456 )
		#( #CMarkText 70 26 3 26 6 452 455 )
		#( #CMarkTableCell 69 26 9 26 16 458 465 )
		#( #CMarkText 72 26 10 26 15 459 464 )
		#( #CMarkTableCell 69 26 18 26 24 467 473 )
		#( #CMarkText 74 26 19 26 23 468 472 )
		#( #CMarkTableCell 69 26 26 26 31 475 480 )
		#( #CMarkText 76 26 27 26 30 476 479 )
		#( #CMarkTableRow 68 28 1 28 34 516 549 )
		#( #CMarkTableCell 78 28 2 28 7 517 522 )
		#( #CMarkText 79 28 3 28 3 518 518 )
		#( #CMarkTableCell 78 28 9 28 16 524 531 )
		#( #CMarkStrong 81 28 10 28 14 525 529 )
		#( #CMarkText 82 28 12 28 12 527 527 )
		#( #CMarkTableCell 78 28 18 28 24 533 539 )
		#( #CMarkCode 84 28 20 28 20 535 535 )
		#( #CMarkTableCell 78 28 26 28 33 541 548 )
		#( #CMarkText 86 28 27 28 31 542 546 )
		#( #CMarkTableRow 68 29 1 29 8 551 558 )
		#( #CMarkTableCell 88 29 2 29 7 552 557 )
		#( #CMarkText 89 29 3 29 3 553 553 )
		#( #CMarkTableCell 88 0 0 0 0 0 0 )
		#( #CMarkTableCell 88 0 0 0 0 0 0 )
		#( #CMarkTableCell 88 0 0 0 0 0 0 )
		#( #CMarkHtmlBlock 1 31 1 33 6 561 583 )
		#( #CMarkThematicBreak 1 35 1 36 0 586 589 )
		#( #CMarkFootnoteDefinition 1 37 7 37 24 597 614 )
		#( #CMarkParagraph 96 37 7 37 24 597 614 )
		#( #CMarkText 97 37 7 37 24 597 614 )
	)
]

{ #category : 'running' }
CMarkParseTest >> setUp [
	super setUp.
	self requirePlugin
]

{ #category : 'tests' }
CMarkParseTest >> testByteArraySources [
	| text bytes fromWide fromBytes |
	text := CMarkFixtures unicode.
	bytes := text utf8Encoded.
	fromWide := CMark parse: text.
	fromBytes := CMark parse: bytes.
	self assert: fromBytes source identicalTo: bytes.
	self assert: fromBytes sanitised isNil.
	self assert: fromBytes sourceString equals: text.
	self assert: fromBytes treeString equals: fromWide treeString.
	self assert: (fromBytes allNodes collect: [ :each | each sourceText ]) equals: (fromWide allNodes collect: [ :each | each sourceText ]).
	"a byte-order mark, at the start (cmark counts it in the columns of line 1) and later (cmark keeps it in the text)"
	text := (self stringOf: #( 16rFEFF 35 32 72 105 10 10 120 16rFEFF 121 10 10 42 122 42 16rFEFF 10 )).
	bytes := text utf8Encoded.
	fromWide := CMark parse: text.
	fromBytes := CMark parse: bytes.
	self assert: fromBytes sanitised isNil.
	self assert: fromBytes sourceString equals: text.
	self assert: fromBytes firstChild sourceText equals: '# Hi'.
	self assert: (self nodesOf: CMarkText in: fromBytes) first sourceText equals: 'Hi'.
	self assert: (fromBytes children at: 2) sourceText equals: (self stringOf: #( 120 16rFEFF 121 )).
	self assert: (fromBytes children at: 2) firstChild literal equals: (self stringOf: #( 120 16rFEFF 121 )).
	self assert: (self nodesOf: CMarkEmph in: fromBytes) first sourceText equals: '*z*'.
	self assert: fromBytes treeString equals: fromWide treeString.
	self assert: (fromBytes allNodes collect: [ :each | each sourceText ]) equals: (fromWide allNodes collect: [ :each | each sourceText ]).
	"and after an invalid byte, in the sanitised bytes"
	fromBytes := CMark parse: #[ 16rEF 16rBB 16rBF 16rFF 35 32 72 105 10 ].
	self assert: fromBytes sanitised notNil.
	self assert: fromBytes sourceString equals: (self stringOf: #( 16rFEFF 16rFFFD 35 32 72 105 10 )).
	self assert: fromBytes firstChild sourceText equals: (self stringOf: #( 16rFFFD 35 32 72 105 ))
]

{ #category : 'tests' }
CMarkParseTest >> testCrLf [
	| crlf source doc paragraph line |
	crlf := String with: Character cr with: Character lf.
	source := '# A' , crlf , crlf , 'para *x*' , crlf , 'next' , (String with: Character cr) , 'line' , crlf.
	doc := CMark parse: source.
	self assert: doc firstChild sourceText equals: '# A'.
	paragraph := doc children second.
	self assert: paragraph startLine equals: 3.
	self assert: paragraph endLine equals: 5.
	self assert: (self nodesOf: CMarkEmph in: doc) first sourceText equals: '*x*'.
	self assert: (self nodesOf: CMarkSoftBreak in: doc) size equals: 2.
	line := (self nodesOf: CMarkText in: doc) last.
	self assert: line literal equals: 'line'.
	self assert: line startLine equals: 5.
	self assert: line sourceText equals: 'line'.
	self assertIndicesOf: doc against: source
]

{ #category : 'tests' }
CMarkParseTest >> testDocumentKeepsACopyOfTheOptions [
	| options doc |
	options := CMarkOptions gfm smart: true; yourself.
	doc := CMark parse: '"x"' options: options.
	self assert: doc options equals: options.
	self deny: doc options identicalTo: options.
	options smart: false.
	self assert: doc options smart
]

{ #category : 'tests' }
CMarkParseTest >> testEmptySource [
	| doc |
	doc := CMark parse: ''.
	self assert: doc children isEmpty.
	self assert: doc nodeCount equals: 1.
	self assert: doc treeDepth equals: 1.
	self assert: doc sourceString equals: ''.
	self assert: (doc sourceText ifNil: [ '' ]) equals: ''
]

{ #category : 'tests' }
CMarkParseTest >> testExtensionsPerCall [
	| plain with |
	plain := CMarkOptions commonMark.
	with := [ :name | CMarkOptions commonMark addExtension: name; yourself ].
	self assert: (self nodesOf: CMarkTable in: (CMark parse: CMarkFixtures table options: plain)) isEmpty.
	self assert: (self nodesOf: CMarkTable in: (CMark parse: CMarkFixtures table options: (with value: #table))) size equals: 1.
	self assert: (self nodesOf: CMarkStrikethrough in: (CMark parse: '~~x~~' options: plain)) isEmpty.
	self assert: (self nodesOf: CMarkStrikethrough in: (CMark parse: '~~x~~' options: (with value: #strikethrough))) size equals: 1.
	self assert: (CMark parse: 'see www.pharo.org' options: plain) links isEmpty.
	self assert: ((CMark parse: 'see www.pharo.org' options: (with value: #autolink)) links collect: [ :each | each url ]) asArray equals: #( 'http://www.pharo.org' ).
	self assert: (self nodesOf: CMarkTaskItem in: (CMark parse: '- [x] a' options: plain)) isEmpty.
	self assert: (self nodesOf: CMarkItem in: (CMark parse: '- [x] a' options: plain)) first plainText equals: '[x] a'.
	self assert: (self nodesOf: CMarkTaskItem in: (CMark parse: '- [x] a' options: (with value: #tasklist))) first isChecked.
	"the tag filter changes the renders, not the tree"
	self
		assert: (CMark parse: '<script>x</script>' options: (with value: #tagfilter)) treeString
		equals: (CMark parse: '<script>x</script>' options: plain) treeString
]

{ #category : 'tests' }
CMarkParseTest >> testFootnotesMovedOrder [
	| doc definitions references |
	doc := CMark parse: CMarkFixtures footnotes options: self footnotes.
	definitions := doc footnoteDefinitions.
	"cmark moves the referenced definitions to the end, in the order of their first reference, and drops z"
	self assert: (definitions collect: [ :each | each label ]) asArray equals: #( 'y' 'x' ).
	self assert: (definitions collect: [ :each | each ordinal ]) asArray equals: #( 1 2 ).
	self assert: (doc children last: 2) asArray equals: definitions asArray.
	references := self nodesOf: CMarkFootnoteReference in: doc.
	self assert: (references collect: [ :each | each ordinal ]) asArray equals: #( 1 2 1 ).
	self assert: (references collect: [ :each | each definition label ]) asArray equals: #( 'y' 'x' 'y' ).
	self assert: (references collect: [ :each | each referenceIndex ]) asArray equals: #( 1 1 2 ).
	self assert: definitions first references asArray equals: { references first. references third }.
	self assert: definitions second references asArray equals: { references second }.
	"the unresolved reference stays text"
	self assert: (doc firstChild plainText includesSubstring: '[^missing]').
	self assertIndicesOf: doc against: CMarkFixtures footnotes
]

{ #category : 'tests' }
CMarkParseTest >> testFootnoteReferencesInDroppedDefinitions [
	"cmark numbers every reference before it drops the unreferenced definition u: its HTML numbers y's reference 3, while referenceIndex ranks the references of the tree only (pinned, as documented in CMarkFootnoteReference>>referenceIndex)"

	| source doc references html |
	source := CMarkFixtures lines: #( 'x[^a]' '' '[^u]: unused[^a]' '' 'y[^a]' '' '[^a]: A' ).
	doc := CMark parse: source options: self footnotes.
	self assert: (doc footnoteDefinitions collect: [ :each | each label ]) asArray equals: #( 'a' ).
	references := self nodesOf: CMarkFootnoteReference in: doc.
	self assert: (references collect: [ :each | each referenceIndex ]) asArray equals: #( 1 2 ).
	self assert: doc footnoteDefinitions first references asArray equals: references asArray.
	html := CMark render: source format: #html options: self footnotes.
	self assert: (html includesSubstring: 'id="fnref-a-3"').
	self deny: (html includesSubstring: 'id="fnref-a-2"')
]

{ #category : 'tests' }
CMarkParseTest >> testFootnotesOff [
	| doc |
	doc := CMark parse: CMarkFixtures footnotes.
	self assert: (self nodesOf: CMarkFootnoteReference in: doc) isEmpty.
	self assert: doc footnoteDefinitions isEmpty
]

{ #category : 'tests' }
CMarkParseTest >> testInvalidUtf8 [
	| bytes doc emphs expected |
	"C3 alone, FF, ED A0 80 (a surrogate), and a truncated F0 9F 98 at the end: one U+FFFD per byte"
	bytes := #[ 16rC3 32 42 98 42 32 16rFF 16rED 16rA0 16r80 32 42 99 42 32 16rF0 16r9F 16r98 ].
	doc := CMark parse: bytes.
	self assert: doc sanitised notNil.
	expected := self stringOf: #( 16rFFFD 32 42 98 42 32 16rFFFD 16rFFFD 16rFFFD 16rFFFD 32 42 99 42 32 16rFFFD 16rFFFD 16rFFFD ).
	self assert: doc sourceString equals: expected.
	emphs := self nodesOf: CMarkEmph in: doc.
	self assert: (emphs collect: [ :each | each sourceText ]) asArray equals: #( '*b*' '*c*' ).
	self assert: (emphs collect: [ :each | each startIndex ]) asArray equals: #( 3 12 ).
	self assert: doc firstChild sourceText equals: expected.
	"NUL is U+FFFD too"
	doc := CMark parse: #[ 97 0 32 42 98 42 ].
	self assert: doc sourceString equals: (self stringOf: #( 97 16rFFFD 32 42 98 42 )).
	self assert: (self nodesOf: CMarkEmph in: doc) first sourceText equals: '*b*'
]

{ #category : 'tests' }
CMarkParseTest >> testKnownFootnoteLabelBug [
	"Known gfm.14 behaviour (an upstream regression, which the candidate patch 0001 of the CMarkPlugin would fix): a footnote label that holds an inline is cut short, and the dropped text disappears"

	| doc |
	doc := CMark parse: 'Hi[^a<b>c].' , String lf , String lf , '[^a<b>c]: d' , String lf options: self footnotes.
	self assert: doc children size equals: 1.
	self assert: doc firstChild plainText equals: 'Hi[^a].'
]

{ #category : 'tests' }
CMarkParseTest >> testKnownEscapedPipeBug [
	"Known gfm.14 behaviour (upstream's --sourcepos gives the same columns): the inlines of a table cell after an escaped pipe start and end one column early per escaped pipe before them, inside the line, so they are not clamped; the cell itself is right"

	| doc cell texts emph |
	doc := CMark parse: (CMarkFixtures lines: #( '| a | b |' '|---|---|' '| x \| y *e* | z |' )).
	cell := doc firstChild children last firstChild.
	self assert: cell sourceText equals: ' x \| y *e* '.
	texts := self nodesOf: CMarkText in: cell.
	self assert: texts first literal equals: 'x | y '.
	self assert: texts first sourceText equals: 'x \| y'.
	emph := (self nodesOf: CMarkEmph in: cell) first.
	self assert: emph startByteColumn equals: 9.
	self assert: emph endByteColumn equals: 11.
	self deny: emph isClamped.
	self assert: emph sourceText equals: ' *e'.
	self assert: emph firstChild sourceText equals: '*'.
	"the cell after it is right"
	self assert: (self nodesOf: CMarkText in: doc firstChild children last) last sourceText equals: 'z'
]

{ #category : 'tests' }
CMarkParseTest >> testLatin1 [
	| source doc emph |
	source := 'Caf' , (String with: (Character value: 233)) , ' *' , (String with: (Character value: 255)) , '* ' , (String with: (Character value: 128)).
	self assert: source class identicalTo: ByteString.
	doc := CMark parse: source.
	self assert: doc sourceString identicalTo: source.
	self assert: (self nodesOf: CMarkText in: doc) first literal equals: 'Caf' , (String with: (Character value: 233)) , ' '.
	emph := (self nodesOf: CMarkEmph in: doc) first.
	self assert: emph startIndex equals: 6.
	self assert: emph endIndex equals: 8.
	self assert: emph sourceText equals: '*' , (String with: (Character value: 255)) , '*'.
	self assert: doc firstChild plainText equals: (source copyWithout: $*)
]

{ #category : 'tests' }
CMarkParseTest >> testMaxDepth [
	| e deep doc |
	e := [ CMark parse: (String new: 10 withAll: $>) , ' x' options: (CMarkOptions gfm maxDepth: 5; yourself) ]
		     on: CMarkTooDeep
		     do: [ :ex | ex ].
	self assert: e class identicalTo: CMarkTooDeep.
	self assert: e limit equals: 5.
	self assert: e actual equals: 6.
	"the document is 1, the 10 quotes 2 to 11, the paragraph 12 and the text 13"
	self assert: (CMark parse: (String new: 10 withAll: $>) , ' x' options: (CMarkOptions gfm maxDepth: 13; yourself)) treeDepth equals: 13.
	deep := (String new: 5000 withAll: $>) , ' x'.
	self should: [ CMark parse: deep ] raise: CMarkTooDeep.
	doc := CMark parse: deep options: (CMarkOptions gfm maxDepth: nil; yourself).
	self assert: doc treeDepth equals: 5003.
	self assert: doc nodeCount equals: 5003.
	self assert: doc allNodes size equals: 5003.
	self assert: doc plainText equals: 'x'
]

{ #category : 'tests' }
CMarkParseTest >> testMaxInputSize [
	| before e options |
	options := CMarkOptions gfm maxInputSize: 10; yourself.
	before := CMark statistics.
	e := [ CMark parse: 'abcdefghijk' options: options ]
		     on: CMarkInputTooLarge
		     do: [ :ex | ex ].
	self assert: e class identicalTo: CMarkInputTooLarge.
	self assert: e limit equals: 10.
	self assert: e actual equals: 11.
	self should: [ CMark parse: 'abcdefghij' asByteArray , #[ 33 ] options: options ] raise: CMarkInputTooLarge.
	self should: [ CMark render: 'abcdefghijk' format: #html options: options ] raise: CMarkInputTooLarge.
	self assert: (CMark statistics at: #parses) equals: (before at: #parses).
	self assert: (CMark statistics at: #renders) equals: (before at: #renders).
	self assert: (CMark parse: 'abcdefghij' options: options) plainText equals: 'abcdefghij'
]

{ #category : 'tests' }
CMarkParseTest >> testMemoryLimit [
	| e |
	e := [ CMark parse: '# Hi' options: (CMarkOptions gfm cBudget: 512; yourself) ]
		     on: CMarkMemoryLimit
		     do: [ :ex | ex ].
	self assert: e class identicalTo: CMarkMemoryLimit.
	self assert: e reason equals: #budget.
	self assert: e limit equals: 512.
	"the plugin freed everything: the next parse is a fresh one"
	self assert: (CMark parse: '# Hi') firstChild level equals: 1
]

{ #category : 'tests' }
CMarkParseTest >> testNul [
	| source doc emph |
	source := 'a' , (String with: (Character value: 0)) , ' *b*'.
	doc := CMark parse: source.
	self assert: (self nodesOf: CMarkText in: doc) first literal equals: (self stringOf: #( 97 16rFFFD 32 )).
	emph := (self nodesOf: CMarkEmph in: doc) first.
	self assert: emph startIndex equals: 4.
	self assert: emph sourceText equals: '*b*'.
	self assert: doc sourceString identicalTo: source
]

{ #category : 'tests' }
CMarkParseTest >> testSampleConstructs [
	| doc nodes headings p links image code html list items tasks blocks table cells ref def |
	doc := CMark parse: CMarkFixtures sample options: self footnotes.
	nodes := doc allNodes.
	headings := doc headings.
	self assert: (headings collect: [ :each | each level ]) asArray equals: #( 1 2 ).
	self assert: headings first sourceText equals: '# Heading *one*'.
	self assert: headings first plainText equals: 'Heading one'.
	self assert: headings first anchor equals: 'heading-one'.
	self assert: headings second sourceText equals: 'Setext heading' , String lf , '--------------' , String lf.
	p := doc children third.
	self assert: p class identicalTo: CMarkParagraph.
	self assert: ((self nodesOf: CMarkStrikethrough in: p) collect: [ :each | each plainText ]) asArray equals: #( 'struck' ).
	self assert: (self nodesOf: CMarkStrikethrough in: p) first isExtension.
	self assert: ((self nodesOf: CMarkCode in: p) collect: [ :each | each literal ]) asArray equals: #( 'code' ).
	links := doc links.
	self assert: (links collect: [ :each | each url ]) asArray equals: #( 'https://example.org' 'http://www.pharo.org' 'https://x.y' ).
	self assert: (links collect: [ :each | each title ]) asArray equals: #( 'Title' '' '' ).
	self assert: links first hasTitle.
	self assert: links first sourceText equals: '[link](https://example.org "Title")'.
	"known gfm.14 behaviour: the angle autolink's columns are relative to the paragraph, clamped by the plugin"
	self assert: links third isClamped.
	self deny: links first isClamped.
	image := (self nodesOf: CMarkImage in: p) first.
	self assert: image url equals: 'img.png'.
	self assert: image title equals: 'Alt title'.
	self assert: image altText equals: 'image'.
	self assert: (self nodesOf: CMarkLineBreak in: p) size equals: 1.
	self assert: ((self nodesOf: CMarkHtmlInline in: p) collect: [ :each | each literal ]) asArray equals: #( '<span>' '</span>' ).
	self assert: (self nodesOf: CMarkSoftBreak in: p) size equals: 2.
	self assert: ((self nodesOf: CMarkSoftBreak in: p) allSatisfy: [ :each | each hasSourcePosition not ]).
	self assert: (self nodesOf: CMarkBlockQuote in: doc) first plainText equals: 'Block quote with a lazy line'.
	list := doc children fifth.
	self assert: list isOrdered.
	self assert: list start equals: 1.
	self assert: list delimiter equals: #period.
	self assert: list isTight.
	items := list children.
	self assert: (items collect: [ :each | each markerNumber ]) asArray equals: #( 1 2 ).
	self assert: items first markerText equals: '1.'.
	tasks := self nodesOf: CMarkTaskItem in: doc.
	self assert: (tasks collect: [ :each | each isChecked ]) asArray equals: #( false true ).
	self assert: (tasks collect: [ :each | each plainText ]) asArray equals: #( 'open task' 'done task' ).
	self assert: tasks first parent isBullet.
	self assert: ((self nodesOf: CMarkItem in: doc) collect: [ :each | each plainText ]) asArray equals: #( 'first' 'secondnested bulletopen taskdone task' 'nested bullet' ).
	blocks := self nodesOf: CMarkCodeBlock in: doc.
	code := blocks first.
	self assert: code isFenced.
	self assert: code info equals: 'smalltalk extra'.
	self assert: code language equals: 'smalltalk'.
	self assert: code literal equals: 'Transcript show: ''hi''' , String lf.
	self assert: code fenceLength equals: 3.
	self assert: code fenceCharacter equals: $`.
	self deny: blocks second isFenced.
	self assert: blocks second literal equals: 'indented code' , String lf.
	self assert: blocks second info equals: ''.
	table := (self nodesOf: CMarkTable in: doc) first.
	self assert: table columnCount equals: 4.
	self assert: table alignments asArray equals: #( #left #center #right nil ).
	self assert: table headerRow isHeader.
	self assert: (table headerRow cells collect: [ :each | each plainText ]) asArray equals: #( 'Left' 'Centre' 'Right' 'None' ).
	self assert: table bodyRows size equals: 2.
	self assert: (table bodyRows first cells collect: [ :each | each plainText ]) asArray equals: #( 'a' 'b' 'c' 'd | e' ).
	"the short row: cmark pads it with three cells that have no position"
	cells := table bodyRows second cells.
	self assert: (cells collect: [ :each | each isAutocompleted ]) asArray equals: #( false true true true ).
	self assert: (cells collect: [ :each | each hasSourcePosition ]) asArray equals: #( true false false false ).
	self assert: (cells collect: [ :each | each column ]) asArray equals: #( 1 2 3 4 ).
	self assert: (cells collect: [ :each | each alignment ]) asArray equals: #( #left #center #right nil ).
	self assert: ((cells allButFirst collect: [ :each | each sourceText ]) allSatisfy: [ :each | each isNil ]).
	html := (self nodesOf: CMarkHtmlBlock in: doc) first.
	self assert: html literal equals: '<div>' , String lf , 'html block' , String lf , '</div>' , String lf.
	self assert: (self nodesOf: CMarkThematicBreak in: doc) first sourceText equals: '***' , String lf.
	ref := (self nodesOf: CMarkFootnoteReference in: doc) first.
	def := doc footnoteDefinitions first.
	self assert: ref ordinal equals: 1.
	self assert: ref definition identicalTo: def.
	self assert: ref referenceIndex equals: 1.
	self assert: def label equals: '1'.
	self assert: def references asArray equals: { ref }.
	self assert: def plainText equals: 'The footnote text.'.
	self assert: doc children last identicalTo: def.
	self assert: nodes size equals: 98
]

{ #category : 'tests' }
CMarkParseTest >> testSampleIndices [
	"For the ASCII sample, every index computed by the plugin from cmark's line and byte column is the offset of the line plus the column"

	self assertIndicesOf: (CMark parse: CMarkFixtures sample options: self footnotes) against: CMarkFixtures sample
]

{ #category : 'tests' }
CMarkParseTest >> testSampleTree [
	| doc nodes expected index |
	doc := CMark parse: CMarkFixtures sample options: self footnotes.
	self assert: doc sourceString equals: CMarkFixtures sample.
	self assert: doc nodeCount equals: 98.
	self assert: doc treeDepth equals: 7.
	nodes := doc allNodes asArray.
	expected := self sampleTree.
	self assert: nodes size equals: expected size.
	index := IdentityDictionary new.
	nodes doWithIndex: [ :each :i | index at: each put: i ].
	nodes with: expected do: [ :node :record |
		self assert: node class name equals: record first.
		self assert: (node parent ifNil: [ 0 ] ifNotNil: [ :parent | index at: parent ]) equals: (record at: 2).
		self assert: { node startLine. node startByteColumn. node endLine. node endByteColumn. node startIndex. node endIndex } equals: (record copyFrom: 3 to: 8) ]
]

{ #category : 'tests' }
CMarkParseTest >> testSmartAndDoubleTilde [
	| text doc |
	text := (CMark parse: '"hi" -- it''s...' options: (CMarkOptions gfm smart: true; yourself)) plainText.
	self assert: text equals: (self stringOf: #( 16r201C 104 105 16r201D 32 16r2013 32 105 116 16r2019 115 16r2026 )).
	self assert: (CMark parse: '"hi" -- it''s...') plainText equals: '"hi" -- it''s...'.
	doc := CMark parse: '~x~ and ~~y~~' options: (CMarkOptions gfm strikethroughDoubleTilde: true; yourself).
	self assert: ((self nodesOf: CMarkStrikethrough in: doc) collect: [ :each | each plainText ]) asArray equals: #( 'y' ).
	doc := CMark parse: '~x~ and ~~y~~'.
	self assert: ((self nodesOf: CMarkStrikethrough in: doc) collect: [ :each | each plainText ]) asArray equals: #( 'x' 'y' )
]

{ #category : 'tests' }
CMarkParseTest >> testStringKinds [
	| wide doc heading emph emoji |
	"A heading of Latin-1 letters and a check mark (U+2713), and an emoji outside the BMP (U+1F600)"
	wide := (self stringOf: #( 35 32 220 110 239 99 246 100 233 32 16r2713 10 10 120 32 16r1F600 32 42 121 42 10 )).
	self assert: wide class identicalTo: WideString.
	doc := CMark parse: wide.
	self assert: doc sourceString identicalTo: wide.
	heading := doc firstChild.
	self assert: heading plainText equals: (self stringOf: #( 220 110 239 99 246 100 233 32 16r2713 )).
	self assert: heading sourceText equals: (wide copyFrom: 1 to: 11).
	self assert: heading endIndex equals: 11.
	emph := (self nodesOf: CMarkEmph in: doc) first.
	"x is 14, the emoji one character, 16"
	self assert: emph startIndex equals: 18.
	self assert: emph sourceText equals: '*y*'.
	emoji := (self nodesOf: CMarkText in: doc) second.
	self assert: emoji literal equals: (self stringOf: #( 120 32 16r1F600 32 )).
	self assert: (CMark parse: wide utf8Encoded) treeString equals: doc treeString
]

{ #category : 'tests' }
CMarkParseTest >> testUnicodeFixture [
	| text doc |
	text := CMarkFixtures unicode.
	doc := CMark parse: text.
	self assert: doc headings first plainText equals: (text copyFrom: 3 to: (text indexOf: Character lf) - 1).
	self assert: (self nodesOf: CMarkEmph in: doc) first plainText equals: (self stringOf: #( 16r3053 16r3093 16r306B 16r3061 16r306F )).
	self assert: (self nodesOf: CMarkCode in: doc) first literal equals: (self stringOf: #( 16r1F600 )).
	self assert: doc links first url equals: 'https://example.org/' , (String with: (Character value: 252)).
	self assert: (self nodesOf: CMarkTable in: doc) size equals: 1.
	doc do: [ :each |
		each hasSourcePosition ifTrue: [
			self assert: each sourceText equals: (text copyFrom: each startIndex to: each endIndex) ] ]
]
