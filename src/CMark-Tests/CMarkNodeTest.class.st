"
I test the node API without the plugin: building by hand, navigation, the iterative walks, plainText, printing, treeString, the table cells, the anchors of the headings, the constructors, and the cmarkSource, cmarkFailed and cmarkUtf8Decoded extensions.
"
Class {
	#name : 'CMarkNodeTest',
	#superclass : 'CMarkTestCase',
	#category : 'CMark-Tests-Tests',
	#package : 'CMark-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkNodeTest >> heading: aString [
	^ CMarkHeading level: 1 with: { (CMarkText literal: aString) }
]

{ #category : 'tests' }
CMarkNodeTest >> testAbstractClasses [
	| concrete |
	self assert: CMarkNode isAbstract.
	self assert: CMarkBlockNode isAbstract.
	self assert: CMarkInlineNode isAbstract.
	concrete := CMarkNode allSubclasses reject: [ :each | each isAbstract ].
	self assert: concrete size equals: 30.
	self assert: (concrete collect: [ :each | each typeName ]) asSet size equals: 30.
	concrete do: [ :each |
		self assert: each new isBlock ~= each new isInline.
		self assert: each new typeName equals: each typeName ]
]

{ #category : 'tests' }
CMarkNodeTest >> testAddChild [
	| p q a e |
	p := CMarkParagraph new.
	self assert: p children isEmpty.
	self assert: p isLeaf.
	a := CMarkText literal: 'a'.
	self assert: (p addChild: a) identicalTo: a.
	self assert: a parent identicalTo: p.
	self assert: p children equals: { a }.
	"moving a child takes it from its parent"
	q := CMarkParagraph new.
	q addChild: a.
	self assert: p children isEmpty.
	self assert: q children equals: { a }.
	self assert: a parent identicalTo: q.
	"no cycles"
	e := CMarkEmph new.
	q addChild: e.
	self should: [ e addChild: q ] raise: CMarkError.
	self should: [ e addChild: e ] raise: CMarkError.
	self assert: e parent identicalTo: q.
	"removeChild:"
	self assert: (q removeChild: a) identicalTo: a.
	self assert: a parent isNil.
	self assert: q children equals: { e }
]

{ #category : 'tests' }
CMarkNodeTest >> testAnchors [
	| h1 h2 h3 h4 doc |
	h1 := self heading: 'Hello, World!'.
	h2 := self heading: 'Hello World'.
	h3 := self heading: (self stringOf: #( 220 110 239 99 246 100 233 32 16r2713 32 95 120 45 121 95 )).
	h4 := self heading: 'hello world'.
	doc := CMarkDocument withAll: {
			       h1.
			       (CMarkParagraph with: { (CMarkText literal: 'x') }).
			       h2.
			       h3.
			       (CMarkBlockQuote with: { h4 }) }.
	self assert: h1 anchor equals: 'hello-world'.
	self assert: h2 anchor equals: 'hello-world-1'.
	self assert: h4 anchor equals: 'hello-world-2'.
	self assert: h3 anchor equals: (self stringOf: #( 252 110 239 99 246 100 233 45 45 95 120 45 121 95 )).
	self assert: doc headings equals: { h1. h2. h3. h4 }.
	self assert: (doc headingAnchors at: h2) equals: 'hello-world-1'.
	self assert: (self heading: 'A B') anchor equals: 'a-b'.
	self assert: (CMarkHeading level: 2) anchor equals: ''
]

{ #category : 'tests' }
CMarkNodeTest >> testCmarkFailed [
	| failure |
	self deny: 42 cmarkFailed.
	self deny: nil cmarkFailed.
	self deny: #( 1 ) cmarkFailed.
	failure := CMarkFailure on: nil.
	self assert: failure cmarkFailed.
	self assert: failure isUnavailable.
	self deny: failure isNoMemory.
	self assert: (CMarkFailure on: #'not found') isUnavailable.
	self deny: (CMarkFailure on: #'bad argument') isUnavailable.
	self assert: (CMarkFailure on: #'insufficient object memory') isNoMemory.
	self assert: (CMarkFailure on: 9) isNoMemory.
	self assert: (CMarkFailure on: #'bad argument') printString equals: 'a CMarkFailure(#''bad argument'')'
]

{ #category : 'tests' }
CMarkNodeTest >> testCmarkSource [
	| byteString wide bytes |
	byteString := 'abc' copy.
	self assert: byteString cmarkSource identicalTo: byteString.
	wide := self stringOf: #( 97 16r2713 ).
	self assert: wide class identicalTo: WideString.
	self assert: wide cmarkSource identicalTo: wide.
	bytes := #[ 97 98 ] copy.
	self assert: bytes cmarkSource identicalTo: bytes.
	self assert: #abc cmarkSource equals: 'abc'.
	self assert: #abc cmarkSource class identicalTo: ByteString.
	self assert: wide asSymbol cmarkSource equals: wide.
	self assert: wide asSymbol cmarkSource class identicalTo: WideString.
	self assert: 'abc' asText cmarkSource equals: 'abc'.
	self assert: 'abc' asText cmarkSource class identicalTo: ByteString.
	self should: [ UUID new cmarkSource ] raise: CMarkError.
	self should: [ #( 1 2 ) cmarkSource ] raise: CMarkError.
	self should: [ 42 cmarkSource ] raise: CMarkError.
	self should: [ nil cmarkSource ] raise: CMarkError.
	self should: [ Object new cmarkSource ] raise: CMarkError.
	self should: [ (WordArray new: 2) cmarkSource ] raise: CMarkError
]

{ #category : 'tests' }
CMarkNodeTest >> testCmarkUtf8Decoded [
	"UTF-8 decoded like utf8Decoded, but every U+FEFF kept (Zinc drops them, and raises on one at the end)"

	| bom wide |
	bom := Character value: 16rFEFF.
	self assert: #[ 16rEF 16rBB 16rBF 66 ] cmarkUtf8Decoded equals: (String with: bom with: $B).
	self
		assert: #[ 16rEF 16rBB 16rBF 16rEF 16rBB 16rBF 65 16rEF 16rBB 16rBF 66 16rEF 16rBB 16rBF ] cmarkUtf8Decoded
		equals: (String with: bom with: bom with: $A with: bom) , (String with: $B with: bom).
	self assert: #[ 16rEF 16rBB 16rBF ] cmarkUtf8Decoded equals: (String with: bom).
	"no mark: utf8Decoded itself, a ByteString when it fits"
	self assert: #[ 97 98 ] cmarkUtf8Decoded equals: 'ab'.
	self assert: #[ 97 98 ] cmarkUtf8Decoded class identicalTo: ByteString.
	self assert: #[ 16rC3 16rA9 ] cmarkUtf8Decoded equals: (self stringOf: #( 233 )).
	self assert: #[ 16rC3 16rA9 ] cmarkUtf8Decoded class identicalTo: ByteString.
	self assert: #[  ] cmarkUtf8Decoded equals: ''.
	"EF that starts another character (U+FF46, U+FEFE, U+FFBF)"
	self assert: #[ 16rEF 16rBD 16r86 16rEF 16rBB 16rBE 16rEF 16rBE 16rBF 16rEF 16rBB 16rBF ] cmarkUtf8Decoded equals: (self stringOf: #( 16rFF46 16rFEFE 16rFFBF 16rFEFF )).
	"a round trip of every kind of character, with the marks anywhere"
	wide := self stringOf: #( 16rFEFF 97 16rFEFF 233 16r2713 16rFEFF 16rFEFF 16r1F600 10 16rFEFF ).
	self assert: wide utf8Encoded cmarkUtf8Decoded equals: wide.
	"bytes that are not UTF-8 still raise"
	self should: [ #[ 16rEF 16rBB ] cmarkUtf8Decoded ] raise: ZnCharacterEncodingError.
	self should: [ #[ 16rC3 16rEF 16rBB 16rBF ] cmarkUtf8Decoded ] raise: ZnCharacterEncodingError.
	self should: [ #[ 16rEF 16rBB 16rBF 16rFF ] cmarkUtf8Decoded ] raise: ZnCharacterEncodingError
]

{ #category : 'tests' }
CMarkNodeTest >> testCodeBlockLines [
	| cr lf |
	cr := String cr.
	lf := String lf.
	self assert: (CMarkCodeBlock literal: 'a' , cr , lf , 'b' , cr , 'c' , lf info: '') lines equals: #( 'a' 'b' 'c' ).
	self assert: (CMarkCodeBlock literal: 'x' info: '') lines equals: #( 'x' ).
	self assert: (CMarkCodeBlock literal: '' info: '') lines equals: #(  ).
	self assert: (CMarkCodeBlock literal: 'a' , lf , lf info: '') lines equals: #( 'a' '' ).
	self assert: (CMarkCodeBlock literal: lf info: '') lines equals: #( '' ).
	self assert: (CMarkCodeBlock literal: '' info: '  st  x') language equals: 'st'
]

{ #category : 'tests' }
CMarkNodeTest >> testConstructors [
	| list ordered task table link image code doc heading def ref html custom |
	list := CMarkList bullet.
	self assert: list isBullet.
	self assert: list isTight.
	self assert: list start equals: 0.
	self assert: list delimiter isNil.
	ordered := CMarkList ordered: 3.
	self assert: ordered isOrdered.
	self assert: ordered start equals: 3.
	self assert: ordered delimiter equals: #period.
	task := CMarkTaskItem checked: true.
	self assert: task isTask.
	self assert: task isChecked.
	self deny: (CMarkTaskItem checked: false) isChecked.
	self deny: CMarkItem new isTask.
	self assert: CMarkItem new markerNumber equals: 0.
	self assert: CMarkItem new markerText isNil.
	table := CMarkTable alignments: #( #left nil #right ).
	self assert: table columnCount equals: 3.
	self assert: table alignments equals: #( #left nil #right ).
	self assert: table headerRow isNil.
	link := CMarkLink url: '#usage' title: 'T'.
	self assert: link url equals: '#usage'.
	self assert: link title equals: 'T'.
	self assert: link hasTitle.
	self assert: link isAnchor.
	self deny: (CMarkLink url: 'https://pharo.org' title: '') isAnchor.
	self deny: (CMarkLink url: '' title: '') isAnchor.
	self deny: (CMarkLink url: '' title: '') hasTitle.
	image := CMarkImage url: 'logo.png' title: ''.
	image addChild: (CMarkText literal: 'the logo').
	self assert: image altText equals: 'the logo'.
	self deny: image hasTitle.
	code := CMarkCodeBlock literal: 'x := 1.' , String lf info: 'smalltalk'.
	self assert: code fenced.
	self assert: code fenceCharacter equals: $`.
	self assert: code fenceLength equals: 3.
	self assert: code language equals: 'smalltalk'.
	self assert: code lines equals: #( 'x := 1.' ).
	self deny: CMarkCodeBlock new isFenced.
	heading := CMarkHeading level: 2 with: { (CMarkText literal: 'Usage') }.
	self assert: heading level equals: 2.
	self assert: heading plainText equals: 'Usage'.
	self assert: CMarkHeading new level equals: 1.
	self assert: (CMarkText literal: 'x') literal equals: 'x'.
	self assert: (CMarkCode literal: 'y') literal equals: 'y'.
	self assert: CMarkText new literal equals: ''.
	html := CMarkHtmlBlock literal: '<hr>'.
	self assert: html literal equals: '<hr>'.
	custom := CMarkCustomInline onEnter: '[' onExit: ']'.
	self assert: custom onEnter equals: '['.
	self assert: custom onExit equals: ']'.
	self assert: (CMarkCustomBlock onEnter: '<' onExit: '>') onExit equals: '>'.
	def := CMarkFootnoteDefinition label: 'n'.
	ref := CMarkFootnoteReference new.
	self assert: (def addReference: ref) identicalTo: ref.
	self assert: ref definition identicalTo: def.
	self assert: ref referenceIndex equals: 1.
	self assert: (def addReference: CMarkFootnoteReference new) referenceIndex equals: 2.
	self assert: def references size equals: 2.
	self assert: def label equals: 'n'.
	doc := CMarkDocument source: '# Hi'.
	self assert: doc source equals: '# Hi'.
	self assert: doc sourceString equals: '# Hi'.
	self assert: doc children isEmpty.
	self assert: doc nodeCount isNil.
	self assert: doc treeDepth isNil.
	self assert: doc options isNil.
	self should: [ CMarkDocument source: 42 ] raise: CMarkError.
	self assert: (CMarkDocument source: #[ 97 255 ]) sourceString size equals: 2.
	self assert: (CMarkDocument source: #abc) source class identicalTo: ByteString.
	self assert: CMarkDocument new sourceString isNil.
	self assert: (CMarkParagraph with: { CMarkText new. CMarkText new }) children size equals: 2.
	self assert: (CMarkBlockQuote withAll: (OrderedCollection with: CMarkParagraph new)) children size equals: 1
]

{ #category : 'tests' }
CMarkNodeTest >> testDocumentQueries [
	| l1 img l2 d1 doc |
	l1 := CMarkLink url: 'a' title: ''.
	img := CMarkImage url: 'b' title: ''.
	l2 := CMarkLink url: 'c' title: ''.
	d1 := CMarkFootnoteDefinition label: '1'.
	doc := CMarkDocument withAll: {
			       (CMarkParagraph with: { l1. img }).
			       (CMarkBlockQuote with: { (CMarkParagraph with: { l2 }) }).
			       d1 }.
	self assert: doc links equals: { l1. l2 }.
	self assert: doc footnoteDefinitions equals: { d1 }.
	self assert: doc headings isEmpty.
	self assert: doc isDocument.
	self deny: d1 isDocument
]

{ #category : 'tests' }
CMarkNodeTest >> testEnclosingLink [
	| t1 t2 em link outside p |
	t1 := CMarkText literal: 'in'.
	em := CMarkEmph with: { t1 }.
	link := CMarkLink url: 'u' title: ''.
	link addAll: { em. (t2 := CMarkText literal: 'also') }.
	outside := CMarkText literal: 'out'.
	p := CMarkParagraph with: { link. outside }.
	self assert: t1 enclosingLink identicalTo: link.
	self assert: t2 enclosingLink identicalTo: link.
	self assert: em enclosingLink identicalTo: link.
	self assert: link enclosingLink isNil.
	self assert: outside enclosingLink isNil.
	self assert: p enclosingLink isNil
]

{ #category : 'tests' }
CMarkNodeTest >> testExtensionsArePrefixed [
	"Every extension method of CMark on a class that CMark does not define begins with cmark"

	| methods |
	methods := CMarkNode package extensionMethods.
	self assert: (methods collect: [ :each | each selector ]) asSet equals: #( #cmarkFailed #cmarkSource #cmarkUtf8Decoded ) asSet.
	self assert: (methods collect: [ :each | each methodClass name ]) asSet equals: #( #ProtoObject #String #ByteString #WideString #ByteArray #Text ) asSet
]

{ #category : 'tests' }
CMarkNodeTest >> testFixtures [
	#( #sample #table #tasks #footnotes #unicode #nested ) do: [ :each |
		| text |
		text := CMarkFixtures perform: each.
		self assert: text isString.
		self assert: text notEmpty.
		self assert: text last equals: Character lf.
		self deny: (text includes: Character cr) ].
	self assert: (CMarkFixtures sample includesSubstring: '| f    |').
	self assert: (CMarkFixtures sample includesSubstring: 'a hard break  ' , String lf).
	self assert: (CMarkFixtures unicode includes: (Character value: 16r1F600)).
	self assert: (CMarkFixtures unicode includes: (Character value: 16r2713))
]

{ #category : 'tests' }
CMarkNodeTest >> testInspector [
	| node stub b doc presenter |
	node := CMarkParagraph with: { (CMarkText literal: 'x') }.
	presenter := node inspectionCMarkTree.
	self assert: presenter notNil.
	self assert: presenter class name equals: #SpTreePresenter.
	self assert: presenter roots asArray equals: { node }.
	stub := CMarkContextStub new.
	node inspectionCMarkSourceContext: stub.
	self deny: stub active.
	self assert: node inspectionCMarkSource text asString equals: ''.
	b := CMarkTapeBuilder new source: 'hi'.
	b at: (b add: 16r8008 parent: 1) line: 1 column: 1 toLine: 1 column: 2.
	b at: 2 from: 1 to: 2.
	doc := b decode.
	doc firstChild inspectionCMarkSourceContext: stub.
	self assert: stub active.
	self assert: doc firstChild inspectionCMarkSource text asString equals: 'hi'
]

{ #category : 'tests' }
CMarkNodeTest >> testNavigation [
	| a b c e p doc |
	p := CMarkParagraph with: {
			     (a := CMarkText literal: 'a').
			     (e := CMarkEmph with: { (b := CMarkText literal: 'b') }).
			     (c := CMarkText literal: 'c') }.
	doc := CMarkDocument withAll: { p }.
	self assert: p firstChild identicalTo: a.
	self assert: p lastChild identicalTo: c.
	self assert: a firstChild isNil.
	self assert: a lastChild isNil.
	self assert: a nextSibling identicalTo: e.
	self assert: e nextSibling identicalTo: c.
	self assert: c nextSibling isNil.
	self assert: e previousSibling identicalTo: a.
	self assert: a previousSibling isNil.
	self assert: doc nextSibling isNil.
	self assert: doc previousSibling isNil.
	self assert: e indexInParent equals: 2.
	self assert: doc indexInParent isNil.
	self assert: b ancestors equals: { e. p. doc }.
	self assert: doc ancestors isEmpty.
	self assert: b depth equals: 4.
	self assert: doc depth equals: 1.
	self assert: b document identicalTo: doc.
	self assert: b root identicalTo: doc.
	self assert: b parent identicalTo: e.
	self assert: p isBlock.
	self deny: p isInline.
	self assert: b isInline.
	self assert: b isLeaf.
	self deny: e isLeaf.
	self assert: (CMarkText literal: 'x') document isNil.
	self assert: (CMarkParagraph with: { (CMarkText literal: 'x') }) firstChild document isNil
]

{ #category : 'tests' }
CMarkNodeTest >> testPlainText [
	| p wide |
	p := CMarkParagraph with: {
			     (CMarkText literal: 'a').
			     CMarkSoftBreak new.
			     (CMarkCode literal: 'c').
			     CMarkLineBreak new.
			     (CMarkHtmlInline literal: '<b>').
			     (CMarkEmph with: { (CMarkText literal: 'e') }).
			     (CMarkImage url: 'u' title: 't') }.
	self assert: p plainText equals: 'a c' , String lf , '<b>e'.
	wide := self stringOf: #( 16r2713 32 16r1F600 ).
	self assert: (CMarkParagraph with: { (CMarkText literal: 'x '). (CMarkText literal: wide) }) plainText equals: 'x ' , wide.
	self assert: CMarkParagraph new plainText equals: ''.
	self assert: (CMarkCodeBlock literal: 'not inline' info: '') plainText equals: ''
]

{ #category : 'tests' }
CMarkNodeTest >> testPrintOn [
	| b h t long doc |
	self assert: (CMarkHeading level: 2) printString equals: 'a CMarkHeading(level 2)'.
	self assert: CMarkParagraph new printString equals: 'a CMarkParagraph'.
	self assert: (CMarkText literal: 'hi') printString equals: 'a CMarkText(''hi'')'.
	long := String new: 50 withAll: $x.
	self assert: (CMarkText literal: long) printString equals: 'a CMarkText(''' , (String new: 40 withAll: $x) , '''...)'.
	self assert: (CMarkList ordered: 2) printString equals: 'a CMarkList(ordered start 2 tight)'.
	self assert: (CMarkTaskItem checked: true) printString equals: 'a CMarkTaskItem(checked)'.
	b := CMarkTapeBuilder new.
	h := b add: 16r8009 parent: 1.
	b at: h int1: 1; at: h line: 1 column: 1 toLine: 1 column: 15.
	t := b add: 16rC001 parent: h str1: 'Hi'.
	b at: t line: 1 column: 3 toLine: 1 column: 4.
	doc := b decode.
	self assert: doc firstChild printString equals: 'a CMarkHeading(level 1, 1:1-1:15)'.
	self assert: doc firstChild firstChild printString equals: 'a CMarkText(''Hi'', 1:3-1:4)'.
	self assert: doc printString equals: 'a CMarkDocument(3 nodes)'
]

{ #category : 'tests' }
CMarkNodeTest >> testTableCells [
	| table row c1 c2 c3 detached |
	table := CMarkTable alignments: #( #right #center ).
	row := CMarkTableRow with: {
			       (c1 := CMarkTableCell new).
			       (c2 := CMarkTableCell with: { (CMarkText literal: 'x') }).
			       (c3 := CMarkTableCell new) }.
	table addChild: (CMarkTableHeaderRow with: { CMarkTableCell new }).
	table addChild: row.
	self assert: c1 column equals: 1.
	self assert: c1 alignment equals: #right.
	self assert: c1 isAutocompleted.
	self assert: c2 column equals: 2.
	self assert: c2 alignment equals: #center.
	self deny: c2 isAutocompleted.
	self assert: c3 column equals: 3.
	self assert: c3 alignment isNil.
	self assert: c2 row identicalTo: row.
	self assert: c2 table identicalTo: table.
	self assert: row table identicalTo: table.
	self assert: row cells size equals: 3.
	self assert: table headerRow isHeader.
	self assert: table bodyRows equals: { row }.
	detached := CMarkTableCell new.
	self assert: detached column isNil.
	self assert: detached alignment isNil.
	self assert: detached table isNil
]

{ #category : 'tests' }
CMarkNodeTest >> testTreeString [
	| doc |
	doc := CMarkDocument withAll: {
			       (CMarkHeading level: 1 with: { (CMarkText literal: 'Hi') }).
			       (CMarkParagraph with: {
					        (CMarkText literal: 'a "q" \' , String lf).
					        CMarkSoftBreak new.
					        (CMarkLink url: 'u' title: '') }).
			       ((CMarkList ordered: 2) addChild: (CMarkTaskItem checked: true); yourself).
			       (CMarkCodeBlock literal: 'x' , String tab info: 'st').
			       ((CMarkTable alignments: #( #left nil )) addChild: (CMarkTableHeaderRow with: { CMarkTableCell new }); yourself) }.
	self assert: doc treeString equals: (String lf join: #(
			  'document 0:0-0:0'
			  '  heading 0:0-0:0 level=1'
			  '    text 0:0-0:0 literal="Hi"'
			  '  paragraph 0:0-0:0'
			  '    text 0:0-0:0 literal="a \"q\" \\\n"'
			  '    softbreak 0:0-0:0'
			  '    link 0:0-0:0 url="u" title=""'
			  '  list 0:0-0:0 list=ordered delim=period start=2 tight=1'
			  '    tasklist 0:0-0:0 marker=0 checked=1'
			  '  code_block 0:0-0:0 fenced=1 info="st" literal="x\t"'
			  '  table 0:0-0:0 columns=2 align=l-'
			  '    table_header 0:0-0:0'
			  '      table_cell 0:0-0:0'
			  '' ))
]

{ #category : 'tests' }
CMarkNodeTest >> testWalks [
	| doc names |
	doc := CMarkDocument withAll: {
			       (CMarkParagraph with: {
					        (CMarkText literal: 'a').
					        (CMarkEmph with: { (CMarkText literal: 'b') }) }).
			       (CMarkParagraph with: { (CMarkText literal: 'c') }) }.
	names := OrderedCollection new.
	doc do: [ :each | names add: each typeName ].
	self assert: names asArray equals: #( 'document' 'paragraph' 'text' 'emph' 'text' 'paragraph' 'text' ).
	self assert: (doc allNodes collect: [ :each | each typeName ]) equals: names asArray.
	self assert: ((doc select: [ :each | each isInline ]) collect: [ :each | each typeName ]) equals: #( 'text' 'emph' 'text' 'text' ).
	self assert: (doc detect: [ :each | each typeName = 'emph' ] ifNone: [ nil ]) firstChild literal equals: 'b'.
	self assert: (doc detect: [ :each | each typeName = 'image' ] ifNone: [ #none ]) equals: #none.
	self assert: doc firstChild allNodes size equals: 4
]
