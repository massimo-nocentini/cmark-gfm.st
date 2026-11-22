"
I test CMarkTreeDecoder on tapes built by hand (CMarkTapeBuilder): every code of the tape, every flag and every field, the flag variants, unknown codes, ASCII and non-ASCII strings, the sanitised bytes, the footnote links, malformed tapes, and a chain of 200,000 nodes.  No plugin is needed.
"
Class {
	#name : 'CMarkDecoderTest',
	#superclass : 'CMarkTestCase',
	#category : 'CMark-Tests-Tests',
	#package : 'CMark-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkDecoderTest >> assertMalformed: aBuilderOrAnswer [
	| answer |
	answer := aBuilderOrAnswer isArray
		          ifTrue: [ aBuilderOrAnswer ]
		          ifFalse: [ aBuilderOrAnswer answer ].
	self
		should: [ CMarkTreeDecoder new decode: answer source: '' options: nil ]
		raise: CMarkMalformedTree
]

{ #category : 'helpers' }
CMarkDecoderTest >> builder [
	^ CMarkTapeBuilder new
]

{ #category : 'tests' }
CMarkDecoderTest >> testAnswerShape [
	| b answer |
	b := self builder.
	self assertMalformed: #( 1 2 3 ).
	answer := b answer.
	answer at: 7 put: 12.
	self assertMalformed: answer.
	answer := b answer.
	answer at: 5 put: 2.
	self assertMalformed: answer.
	answer := b answer.
	answer at: 5 put: 0.
	answer at: 3 put: (Bitmap new: 0).
	self assertMalformed: answer.
	answer := b answer.
	answer at: 3 put: nil.
	self assertMalformed: answer.
	answer := b answer.
	answer at: 4 put: nil.
	self assert: (CMarkTreeDecoder new decode: answer source: '' options: nil) children isEmpty
]

{ #category : 'tests' }
CMarkDecoderTest >> testBadParents [
	| b answer |
	"record 1 must be the document"
	b := self builder.
	b at: 1 word: 1 put: 16r8008.
	self assertMalformed: b.
	b := self builder.
	b at: 1 word: 2 put: 1.
	self assertMalformed: b.
	"a parent must come before its child"
	b := self builder.
	b add: 16r8008 parent: 2.
	self assertMalformed: b.
	b := self builder.
	b add: 16r8008 parent: 0.
	self assertMalformed: b.
	b := self builder.
	b add: 16r8008 parent: 1.
	b add: 16r8008 parent: 3.
	self assertMalformed: b.
	"a parent index too large in the raw tape"
	b := self builder.
	b add: 16r8008 parent: 1.
	answer := b answer.
	(answer at: 3) at: 16 + 2 put: 99.
	self assertMalformed: answer
]

{ #category : 'tests' }
CMarkDecoderTest >> testBlockFields [
	| b q h t hb cb tb doc |
	b := self builder.
	q := b add: 16r8002 parent: 1.
	h := b add: 16r8009 parent: q.
	b at: h int1: 3.
	t := b add: 16r800A parent: 1.
	hb := b add: 16r8006 parent: 1 str1: '<div>' , String lf.
	cb := b add: 16r8007 parent: 1 str1: '<x>'.
	b at: cb str2: '</x>'.
	tb := b add: 16r8008 parent: 1.
	doc := b decode.
	self assert: doc class identicalTo: CMarkDocument.
	self assert: doc children size equals: 5.
	self assert: doc firstChild class identicalTo: CMarkBlockQuote.
	self assert: doc firstChild firstChild class identicalTo: CMarkHeading.
	self assert: doc firstChild firstChild level equals: 3.
	self assert: (doc children at: 2) class identicalTo: CMarkThematicBreak.
	self assert: (doc children at: 3) literal equals: '<div>' , String lf.
	self assert: (doc children at: 4) onEnter equals: '<x>'.
	self assert: (doc children at: 4) onExit equals: '</x>'.
	self assert: (doc children at: 5) class identicalTo: CMarkParagraph.
	self assert: (doc children at: 5) children isEmpty
]

{ #category : 'tests' }
CMarkDecoderTest >> testBulletList [
	| b list doc |
	b := self builder.
	list := b add: 16r8003 parent: 1.
	b at: list int1: 1.
	b add: 16r8004 parent: list.
	doc := b decode.
	self assert: doc firstChild listType equals: #bullet.
	self assert: doc firstChild isBullet.
	self assert: doc firstChild delimiter isNil.
	self assert: doc firstChild start equals: 0.
	self deny: doc firstChild isTight.
	b := self builder.
	list := b add: 16r8003 parent: 1.
	b at: list int1: 2; at: list int2: 1; at: list int3: 1.
	self assert: b decode firstChild delimiter equals: #period
]

{ #category : 'tests' }
CMarkDecoderTest >> testClassMapHasOnlyOwners [
	| classes codes |
	classes := CMarkTreeDecoder new classes.
	codes := #( 16r8001 16r8002 16r8003 16r8004 16r8005 16r8006 16r8007 16r8008 16r8009 16r800A 16r800B 16r8100 16r8101 16r8102 16r80FF 16rC001 16rC002 16rC003 16rC004 16rC005 16rC006 16rC007 16rC008 16rC009 16rC00A 16rC00B 16rC100 16rC0FF ).
	self assert: classes keys asSet equals: codes asSet.
	self assert: classes size equals: codes size.
	classes keysAndValuesDo: [ :code :cls | self assert: cls typeCode equals: code ].
	self deny: (classes includes: CMarkTaskItem).
	self deny: (classes includes: CMarkTableHeaderRow).
	self assert: CMarkTaskItem typeCode isNil.
	self assert: CMarkTableHeaderRow typeCode isNil.
	self assert: CMarkTaskItem new typeCode equals: 16r8004.
	self assert: CMarkTableHeaderRow new typeCode equals: 16r8101.
	self assert: (CMarkItem cmarkClassForFlags: 0) identicalTo: CMarkItem.
	self assert: (CMarkItem cmarkClassForFlags: 64) identicalTo: CMarkTaskItem.
	self assert: (CMarkTaskItem cmarkClassForFlags: 0) identicalTo: CMarkItem.
	self assert: (CMarkTableRow cmarkClassForFlags: 32) identicalTo: CMarkTableHeaderRow.
	self assert: (CMarkTableHeaderRow cmarkClassForFlags: 0) identicalTo: CMarkTableRow.
	self assert: (CMarkHeading cmarkClassForFlags: 64 + 32) identicalTo: CMarkHeading
]

{ #category : 'tests' }
CMarkDecoderTest >> testCodeBlocks [
	| b f i doc fenced indented |
	b := self builder.
	f := b add: 16r8005 parent: 1 str1: 'a' , String lf , 'b' , String lf.
	b at: f str2: 'smalltalk extra'; at: f int1: 4; at: f int2: 126; at: f int3: 2; at: f flags: CMarkTreeDecoder flagFenced.
	i := b add: 16r8005 parent: 1 str1: 'x' , String lf.
	b at: i str2: ''.
	doc := b decode.
	fenced := doc firstChild.
	indented := doc lastChild.
	self assert: fenced isFenced.
	self assert: fenced fenced.
	self assert: fenced fenceLength equals: 4.
	self assert: fenced fenceCharacter equals: $~.
	self assert: fenced fenceOffset equals: 2.
	self assert: fenced info equals: 'smalltalk extra'.
	self assert: fenced language equals: 'smalltalk'.
	self assert: fenced lines equals: #( 'a' 'b' ).
	self deny: indented isFenced.
	self assert: indented fenceCharacter isNil.
	self assert: indented info equals: ''.
	self assert: indented language isNil.
	self assert: indented lines equals: #( 'x' )
]

{ #category : 'tests' }
CMarkDecoderTest >> testDeepChain [
	"A chain of 200,000 nested block quotes decodes, and the iterative walks go through it"

	| b n parent doc count deepest text |
	n := 200000.
	b := self builder.
	parent := 1.
	n - 2 timesRepeat: [ parent := b add: 16r8002 parent: parent ].
	parent := b add: 16r8008 parent: parent.
	b add: 16rC001 parent: parent str1: 'deep'.
	doc := b decode.
	self assert: doc nodeCount equals: n + 1.
	self assert: doc treeDepth equals: n + 1.
	count := 0.
	deepest := nil.
	doc do: [ :each |
		count := count + 1.
		deepest := each ].
	self assert: count equals: n + 1.
	self assert: deepest literal equals: 'deep'.
	self assert: deepest depth equals: n + 1.
	self assert: deepest document identicalTo: doc.
	self assert: doc plainText equals: 'deep'.
	self assert: doc allNodes size equals: n + 1.
	text := doc treeString.
	self assert: (text occurrencesOf: Character lf) equals: n + 1.
	self assert: (text endsWith: 'text 0:0-0:0 literal="deep"' , String lf)
]

{ #category : 'tests' }
CMarkDecoderTest >> testDocumentFields [
	| b options doc |
	options := CMarkOptions gfm.
	b := self builder.
	b source: 'x'.
	b options: options.
	b add: 16r8008 parent: 1.
	doc := b decode.
	self assert: doc nodeCount equals: 2.
	self assert: doc treeDepth equals: 2.
	self assert: doc depth equals: 1.
	self assert: doc options identicalTo: options.
	self assert: doc source equals: 'x'.
	self assert: doc sanitised isNil.
	self assert: doc document identicalTo: doc.
	self assert: doc parent isNil
]

{ #category : 'tests' }
CMarkDecoderTest >> testFlagsAndPositions [
	| b p t c doc para text code |
	b := self builder.
	b source: 'ab *cd*'.
	p := b add: 16r8008 parent: 1.
	b at: p line: 1 column: 1 toLine: 1 column: 7; at: p from: 1 to: 7.
	t := b add: 16rC001 parent: p str1: 'ab '.
	b at: t line: 1 column: 1 toLine: 1 column: 3; at: t from: 1 to: 3.
	c := b add: 16rC004 parent: p str1: 'cd'.
	b at: c line: 1 column: 4 toLine: 1 column: 99; at: c from: 4 to: 7; at: c flags: CMarkTreeDecoder flagClamped.
	b add: 16rC002 parent: p.
	doc := b decode.
	para := doc firstChild.
	text := para firstChild.
	code := para children at: 2.
	self assert: para hasSourcePosition.
	self assert: para startLine equals: 1.
	self assert: para startByteColumn equals: 1.
	self assert: para endLine equals: 1.
	self assert: para endByteColumn equals: 7.
	self assert: para startIndex equals: 1.
	self assert: para endIndex equals: 7.
	self assert: para sourceInterval equals: (1 to: 7).
	self assert: para sourceText equals: 'ab *cd*'.
	self assert: text sourceText equals: 'ab '.
	self deny: text isClamped.
	self assert: code isClamped.
	self assert: code sourceText equals: '*cd*'.
	self deny: para lastChild hasSourcePosition.
	self assert: para lastChild sourceInterval isNil.
	self assert: para lastChild sourceText isNil.
	self assert: para lastChild startLine equals: 0.
	self assert: para lastChild flags equals: 0
]

{ #category : 'tests' }
CMarkDecoderTest >> testFootnoteReferenceToNonDefinition [
	| b p r |
	b := self builder.
	p := b add: 16r8008 parent: 1.
	r := b add: 16rC00B parent: p.
	b at: r int2: p.
	self assertMalformed: b.
	b := self builder.
	p := b add: 16r8008 parent: 1.
	r := b add: 16rC00B parent: p.
	b at: r int2: 9.
	self assertMalformed: b
]

{ #category : 'tests' }
CMarkDecoderTest >> testFootnoteReferencesInSourceOrder [
	"A definition referenced twice: its references are sorted by startIndex, whatever the record order"

	| b p late early d doc refs |
	b := self builder.
	p := b add: 16r8008 parent: 1.
	late := b add: 16rC00B parent: p str1: '1'.
	b at: late int1: 1; at: late line: 1 column: 9 toLine: 1 column: 12; at: late from: 9 to: 12.
	early := b add: 16rC00B parent: p str1: '1'.
	b at: early int1: 1; at: early line: 1 column: 1 toLine: 1 column: 4; at: early from: 1 to: 4.
	d := b add: 16r800B parent: 1 str1: 'a'.
	b at: d int1: 1.
	b at: late int2: d; at: early int2: d.
	b add: 16rC00B parent: p.
	doc := b decode.
	refs := doc firstChild children.
	self assert: doc lastChild references equals: { refs at: 2. refs at: 1 }.
	self assert: (refs at: 2) referenceIndex equals: 1.
	self assert: (refs at: 1) referenceIndex equals: 2.
	self assert: (refs at: 3) definition isNil.
	self assert: (refs at: 3) referenceIndex equals: 0
]

{ #category : 'tests' }
CMarkDecoderTest >> testFootnotesInMovedOrder [
	"A[^y] and [^x], with the definitions x, z and y: cmark drops z and moves y then x to the end; the references point at their definitions by record"

	| b p r1 r2 dy dx doc refs y x |
	b := self builder.
	b source: 'A[^y] and [^x]'.
	p := b add: 16r8008 parent: 1.
	b add: 16rC001 parent: p str1: 'A'.
	r1 := b add: 16rC00B parent: p str1: '1'.
	b at: r1 int1: 1; at: r1 line: 1 column: 2 toLine: 1 column: 5; at: r1 from: 2 to: 5.
	b add: 16rC001 parent: p str1: ' and '.
	r2 := b add: 16rC00B parent: p str1: '2'.
	b at: r2 int1: 2; at: r2 line: 1 column: 11 toLine: 1 column: 14; at: r2 from: 11 to: 14.
	dy := b add: 16r800B parent: 1 str1: 'y'.
	b at: dy int1: 1.
	b add: 16rC001 parent: (b add: 16r8008 parent: dy) str1: 'Y'.
	dx := b add: 16r800B parent: 1 str1: 'x'.
	b at: dx int1: 2.
	b at: r1 int2: dy; at: r2 int2: dx.
	doc := b decode.
	refs := doc firstChild children select: [ :each | each class == CMarkFootnoteReference ].
	y := doc children at: 2.
	x := doc children at: 3.
	self assert: doc footnoteDefinitions equals: { y. x }.
	self assert: y label equals: 'y'.
	self assert: y ordinal equals: 1.
	self assert: x label equals: 'x'.
	self assert: x ordinal equals: 2.
	self assert: refs first definition identicalTo: y.
	self assert: refs last definition identicalTo: x.
	self assert: refs first ordinal equals: 1.
	self assert: y references equals: { refs first }.
	self assert: x references equals: { refs last }.
	self assert: refs first referenceIndex equals: 1.
	self assert: refs last referenceIndex equals: 1.
	self assert: y plainText equals: 'Y'
]

{ #category : 'tests' }
CMarkDecoderTest >> testInlineFields [
	| b p l e s st i k doc para kinds |
	b := self builder.
	p := b add: 16r8008 parent: 1.
	b add: 16rC001 parent: p str1: 'text'.
	b add: 16rC002 parent: p.
	b add: 16rC003 parent: p.
	b add: 16rC004 parent: p str1: 'code'.
	b add: 16rC005 parent: p str1: '<b>'.
	k := b add: 16rC006 parent: p str1: '{'.
	b at: k str2: '}'.
	e := b add: 16rC007 parent: p.
	b add: 16rC001 parent: e str1: 'em'.
	s := b add: 16rC008 parent: p.
	b add: 16rC001 parent: s str1: 'strong'.
	l := b add: 16rC009 parent: p str1: 'https://pharo.org'.
	b at: l str2: 'Pharo'.
	b add: 16rC001 parent: l str1: 'link'.
	i := b add: 16rC00A parent: p str1: 'logo.png'.
	b add: 16rC001 parent: i str1: 'alt'.
	st := b add: 16rC100 parent: p.
	b at: st flags: CMarkTreeDecoder flagExtension.
	b add: 16rC001 parent: st str1: 'gone'.
	doc := b decode.
	para := doc firstChild.
	kinds := para children collect: [ :each | each class ].
	self assert: kinds equals: {
			CMarkText.
			CMarkSoftBreak.
			CMarkLineBreak.
			CMarkCode.
			CMarkHtmlInline.
			CMarkCustomInline.
			CMarkEmph.
			CMarkStrong.
			CMarkLink.
			CMarkImage.
			CMarkStrikethrough }.
	self assert: (para children at: 4) literal equals: 'code'.
	self assert: (para children at: 5) literal equals: '<b>'.
	self assert: (para children at: 6) onEnter equals: '{'.
	self assert: (para children at: 6) onExit equals: '}'.
	self assert: (para children at: 9) url equals: 'https://pharo.org'.
	self assert: (para children at: 9) title equals: 'Pharo'.
	self assert: (para children at: 9) hasTitle.
	self assert: (para children at: 10) url equals: 'logo.png'.
	self assert: (para children at: 10) title equals: ''.
	self deny: (para children at: 10) hasTitle.
	self assert: (para children at: 10) altText equals: 'alt'.
	self assert: (para children at: 11) isExtension.
	self deny: (para children at: 10) isExtension.
	self assert: para plainText equals: 'text ' , String lf , 'code<b>emstronglinkaltgone'.
	self assert: (para children allSatisfy: [ :each | each isInline ]).
	self assert: para isBlock
]

{ #category : 'tests' }
CMarkDecoderTest >> testItemsAndTasks [
	| b list i1 i2 i3 doc l items |
	b := self builder.
	b source: '3. a' , String lf , '4. [ ] b' , String lf , '5. [x] c'.
	list := b add: 16r8003 parent: 1.
	b at: list int1: 2; at: list int2: 2; at: list int3: 3; at: list flags: CMarkTreeDecoder flagTight.
	i1 := b add: 16r8004 parent: list.
	b at: i1 int1: 3; at: i1 line: 1 column: 1 toLine: 1 column: 4; at: i1 from: 1 to: 4.
	i2 := b add: 16r8004 parent: list.
	b at: i2 int1: 4; at: i2 flags: CMarkTreeDecoder flagTask.
	i3 := b add: 16r8004 parent: list.
	b at: i3 int1: 5; at: i3 flags: CMarkTreeDecoder flagTask + CMarkTreeDecoder flagChecked + CMarkTreeDecoder flagExtension.
	doc := b decode.
	l := doc firstChild.
	items := l children.
	self assert: l listType equals: #ordered.
	self assert: l isOrdered.
	self deny: l isBullet.
	self assert: l delimiter equals: #paren.
	self assert: l start equals: 3.
	self assert: l isTight.
	self assert: items first class identicalTo: CMarkItem.
	self deny: items first isTask.
	self assert: items first markerNumber equals: 3.
	self assert: items first markerText equals: '3.'.
	self assert: (items at: 2) class identicalTo: CMarkTaskItem.
	self assert: (items at: 2) isTask.
	self deny: (items at: 2) isChecked.
	self assert: (items at: 2) markerNumber equals: 4.
	self assert: (items at: 2) markerText isNil.
	self assert: (items at: 3) isChecked.
	self assert: (items at: 3) typeName equals: 'tasklist'.
	self assert: items first typeName equals: 'item'
]

{ #category : 'tests' }
CMarkDecoderTest >> testSanitisedSource [
	"A ByteArray source with an invalid byte: the plugin answers the sanitised bytes, against which the indices count"

	| bad b p doc |
	bad := #[ 97 255 98 ].
	b := self builder.
	b source: bad.
	b sanitised: #[ 97 239 191 189 98 ].
	p := b add: 16r8008 parent: 1.
	b at: p line: 1 column: 1 toLine: 1 column: 5; at: p from: 1 to: 3.
	b at: (b add: 16rC001 parent: p str1: 'b') line: 1 column: 5 toLine: 1 column: 5.
	b at: 3 from: 3 to: 3.
	doc := b decode.
	self assert: doc source identicalTo: bad.
	self assert: doc sourceString equals: 'a' , (Character value: 16rFFFD) asString , 'b'.
	self assert: doc firstChild sourceText equals: doc sourceString.
	self assert: doc firstChild firstChild sourceText equals: 'b'.
	"valid UTF-8 and no sanitised bytes: decoded from the source"
	b := self builder.
	b source: (self stringOf: #( 233 )) utf8Encoded.
	self assert: b decode sourceString equals: (self stringOf: #( 233 )).
	"a String source is the sourceString itself"
	b := self builder.
	b source: 'abc'.
	doc := b decode.
	self assert: doc sourceString identicalTo: doc source
]

{ #category : 'tests' }
CMarkDecoderTest >> testStrings [
	| b p wide doc kids |
	wide := self stringOf: #( 220 110 239 99 246 100 233 32 16r2713 32 16r1F600 ).
	b := self builder.
	p := b add: 16r8008 parent: 1.
	b add: 16rC001 parent: p str1: 'ascii'.
	b add: 16rC001 parent: p str1: wide.
	b add: 16rC001 parent: p str1: ''.
	b add: 16rC001 parent: p str1: (self stringOf: #( 233 )).
	b add: 16rC001 parent: p str1: 'plain'.
	b at: 7 word: 3 put: 0.
	doc := b decode.
	kids := doc firstChild children.
	self assert: kids first literal equals: 'ascii'.
	self assert: kids first literal class identicalTo: ByteString.
	self assert: (kids at: 2) literal equals: wide.
	self assert: (kids at: 2) literal size equals: 11.
	self assert: (kids at: 3) literal equals: ''.
	self assert: (kids at: 4) literal equals: (self stringOf: #( 233 )).
	self assert: (kids at: 4) literal class identicalTo: ByteString.
	self assert: (kids at: 5) literal equals: 'plain'
]

{ #category : 'tests' }
CMarkDecoderTest >> testStringsOutOfRange [
	| b t answer |
	b := self builder.
	t := b add: 16r8008 parent: 1.
	b add: 16rC001 parent: t str1: 'abc'.
	answer := b answer.
	(answer at: 3) at: 32 + 14 put: 4.
	self assertMalformed: answer.
	answer := b answer.
	(answer at: 3) at: 32 + 13 put: 1.
	self assertMalformed: answer.
	answer := b answer.
	answer at: 4 put: #[ 97 98 ].
	self assertMalformed: answer.
	"bytes that are not UTF-8 in a non-ASCII string"
	answer := b answer.
	answer at: 4 put: #[ 97 255 99 ].
	(answer at: 3) at: 32 + 3 put: 0.
	self assertMalformed: answer
]

{ #category : 'tests' }
CMarkDecoderTest >> testTables [
	| b table head body cell short doc t rows |
	b := self builder.
	table := b add: 16r8100 parent: 1 str1: 'lcr-'.
	b at: table int1: 4; at: table flags: CMarkTreeDecoder flagExtension.
	head := b add: 16r8101 parent: table.
	b at: head flags: CMarkTreeDecoder flagHeader + CMarkTreeDecoder flagExtension.
	4 timesRepeat: [ b at: (b add: 16r8102 parent: head) line: 1 column: 1 toLine: 1 column: 2 ].
	body := b add: 16r8101 parent: table.
	cell := b add: 16r8102 parent: body.
	b at: cell int1: 1; at: cell line: 3 column: 2 toLine: 3 column: 4.
	b add: 16rC001 parent: cell str1: 'f'.
	short := b add: 16r8102 parent: body.
	b at: short int1: 2.
	doc := b decode.
	t := doc firstChild.
	rows := t children.
	self assert: t columnCount equals: 4.
	self assert: t alignments equals: #( #left #center #right nil ).
	self assert: t isExtension.
	self assert: rows first class identicalTo: CMarkTableHeaderRow.
	self assert: rows first isHeader.
	self assert: rows first typeName equals: 'table_header'.
	self assert: rows last class identicalTo: CMarkTableRow.
	self deny: rows last isHeader.
	self assert: t headerRow identicalTo: rows first.
	self assert: t bodyRows equals: { rows last }.
	self assert: rows last cells size equals: 2.
	self assert: rows last cells first column equals: 1.
	self assert: rows last cells first alignment equals: #left.
	self deny: rows last cells first isAutocompleted.
	self assert: rows last cells last column equals: 2.
	self assert: rows last cells last alignment equals: #center.
	self assert: rows last cells last isAutocompleted.
	self assert: rows last cells last table identicalTo: t.
	self assert: rows last cells last row identicalTo: rows last.
	self assert: (rows first cells collect: [ :each | each alignment ]) equals: #( #left #center #right nil ).
	self deny: (rows first cells anySatisfy: [ :each | each isAutocompleted ])
]

{ #category : 'tests' }
CMarkDecoderTest >> testUnknownCodes [
	| b ub ui p doc kids inl |
	b := self builder.
	ub := b add: 16r80FF parent: 1 str1: 'mystery'.
	b at: ub int1: 16r8042.
	b add: 16r8008 parent: ub.
	b add: 16r8077 parent: 1.
	p := b add: 16r8008 parent: 1.
	ui := b add: 16rC0FF parent: p str1: 'sparkle'.
	b at: ui int1: 16rC042.
	b add: 16rC077 parent: p.
	doc := b decode.
	kids := doc children.
	self assert: kids first class identicalTo: CMarkUnknownBlock.
	self assert: kids first rawType equals: 16r8042.
	self assert: kids first typeString equals: 'mystery'.
	self assert: kids first typeName equals: 'mystery'.
	self assert: kids first firstChild class identicalTo: CMarkParagraph.
	self assert: (kids at: 2) class identicalTo: CMarkUnknownBlock.
	self assert: (kids at: 2) rawType equals: 16r8077.
	self assert: (kids at: 2) typeName equals: 'unknown_block'.
	inl := (kids at: 3) children.
	self assert: inl first class identicalTo: CMarkUnknownInline.
	self assert: inl first rawType equals: 16rC042.
	self assert: inl first typeName equals: 'sparkle'.
	self assert: inl last class identicalTo: CMarkUnknownInline.
	self assert: inl last rawType equals: 16rC077.
	self assert: inl last typeName equals: 'unknown_inline'.
	self assert: inl last isInline
]
