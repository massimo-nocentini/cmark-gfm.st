"
I am the examples of the Roassal rendering of Markdown. Each example method opens a canvas (with `open`) and answers it; the `canvas...` methods build the same canvases without opening them.

- `exampleHandBuilt`: a document built by hand with the node API (no plugin needed);
- `exampleSample`, `exampleDark`, `exampleNarrow` (320 units wide), `exampleTable`, `exampleTasks`: parsed by the `CMarkPlugin`;
- `exampleReadme`: the `README.md` of the `cmark-gfm.st` checkout, found through the Iceberg repository named `cmark-gfm.st`, else through the `CMARK_PLUGIN_DIR` environment variable (`<dir>/cmark-gfm.st/README.md`), else the sample (a `tonel://` load registers no Iceberg repository).
"
Class {
	#name : 'CMarkRoassalExamples',
	#superclass : 'Object',
	#category : 'CMark-Roassal-Examples',
	#package : 'CMark-Roassal',
	#tag : 'Examples'
}

{ #category : 'canvases' }
CMarkRoassalExamples class >> canvasFor: aNode theme: aTheme width: aNumberOrNil baseDirectory: aFileReferenceOrNil [
	"A canvas of aNode rendered in aTheme, aNumberOrNil wide (nil: the theme's width)"

	^ (CMarkRoassalRenderer theme: aTheme)
		  maxWidth: aNumberOrNil;
		  baseDirectory: aFileReferenceOrNil;
		  canvasFor: aNode
]

{ #category : 'examples' }
CMarkRoassalExamples class >> exampleDark [
	^ (self canvasFor: (self parse: self sampleMarkdown) theme: CMarkRoassalTheme dark width: nil baseDirectory: nil)
		  open;
		  yourself
]

{ #category : 'examples' }
CMarkRoassalExamples class >> exampleHandBuilt [
	^ (self canvasFor: self handBuiltDocument theme: CMarkRoassalTheme default width: nil baseDirectory: nil)
		  open;
		  yourself
]

{ #category : 'examples' }
CMarkRoassalExamples class >> exampleNarrow [
	^ (self canvasFor: (self parse: self sampleMarkdown) theme: CMarkRoassalTheme default width: 320 baseDirectory: nil)
		  open;
		  yourself
]

{ #category : 'examples' }
CMarkRoassalExamples class >> exampleReadme [
	| file |
	file := self readmeFile.
	^ (self
		   canvasFor: (self parse: (file
					     ifNil: [ self sampleMarkdown ]
					     ifNotNil: [ file contents ]))
		   theme: CMarkRoassalTheme default
		   width: nil
		   baseDirectory: (file ifNotNil: [ file parent ]))
		  open;
		  yourself
]

{ #category : 'examples' }
CMarkRoassalExamples class >> exampleSample [
	^ (self canvasFor: (self parse: self sampleMarkdown) theme: CMarkRoassalTheme default width: nil baseDirectory: nil)
		  open;
		  yourself
]

{ #category : 'examples' }
CMarkRoassalExamples class >> exampleTable [
	^ (self canvasFor: (self parse: self tableMarkdown) theme: CMarkRoassalTheme default width: nil baseDirectory: nil)
		  open;
		  yourself
]

{ #category : 'examples' }
CMarkRoassalExamples class >> exampleTasks [
	^ (self canvasFor: (self parse: self tasksMarkdown) theme: CMarkRoassalTheme default width: nil baseDirectory: nil)
		  open;
		  yourself
]

{ #category : 'documents' }
CMarkRoassalExamples class >> handBuiltDocument [
	"A document of every kind of block and inline, built with the node API (no plugin needed)"

	| doc list nested table quote definition reference |
	doc := CMarkDocument source: ''.
	doc addChild: (CMarkHeading level: 1 with: { (CMarkText literal: 'Hand-built Markdown') }).
	doc addChild: (CMarkParagraph with: {
				 (CMarkText literal: 'A paragraph with ').
				 (CMarkEmph with: { (CMarkText literal: 'emphasis') }).
				 (CMarkText literal: ', ').
				 (CMarkStrong with: { (CMarkText literal: 'strong text') }).
				 (CMarkText literal: ', ').
				 (CMarkStrikethrough with: { (CMarkText literal: 'struck') }).
				 (CMarkText literal: ', ').
				 (CMarkCode literal: 'inline code').
				 (CMarkText literal: ' and a ').
				 ((CMarkLink url: 'https://github.com/github/cmark-gfm' title: '') addAll: { (CMarkText literal: 'link to cmark-gfm') }; yourself).
				 (CMarkText literal: '. It wraps at the width of the column, and an image without a file shows its placeholder: ').
				 ((CMarkImage url: 'missing.png' title: '') addAll: { (CMarkText literal: 'a missing picture') }; yourself).
				 (CMarkText literal: '.') }).
	doc addChild: (CMarkHeading level: 2 with: { (CMarkText literal: 'Lists') }).
	list := doc addChild: CMarkList bullet.
	list addChild: (CMarkItem with: { (CMarkParagraph with: { (CMarkText literal: 'a bullet') }) }).
	nested := CMarkList ordered: 3.
	nested addChild: (CMarkItem with: { (CMarkParagraph with: { (CMarkText literal: 'third') }) }).
	nested addChild: (CMarkItem with: { (CMarkParagraph with: { (CMarkText literal: 'fourth') }) }).
	list addChild: (CMarkItem with: {
				 (CMarkParagraph with: { (CMarkText literal: 'a bullet with a nested ordered list') }).
				 nested }).
	list addChild: ((CMarkTaskItem checked: true) addAll: { (CMarkParagraph with: { (CMarkText literal: 'a done task') }) }; yourself).
	list addChild: ((CMarkTaskItem checked: false) addAll: { (CMarkParagraph with: { (CMarkText literal: 'an open task') }) }; yourself).
	quote := doc addChild: CMarkBlockQuote new.
	quote addChild: (CMarkParagraph with: { (CMarkText literal: 'A block quote is muted and indented, with a bar on its left.') }).
	doc addChild: (CMarkCodeBlock literal: 'Transcript show: ''hello'';' , String lf , '	cr.' , String lf info: 'smalltalk').
	table := doc addChild: (CMarkTable alignments: #( #left #center #right )).
	table addChild: (CMarkTableHeaderRow with: {
				 (CMarkTableCell with: { (CMarkText literal: 'Left') }).
				 (CMarkTableCell with: { (CMarkText literal: 'Centre') }).
				 (CMarkTableCell with: { (CMarkText literal: 'Right') }) }).
	table addChild: (CMarkTableRow with: {
				 (CMarkTableCell with: { (CMarkText literal: 'a') }).
				 (CMarkTableCell with: { (CMarkEmph with: { (CMarkText literal: 'b') }) }).
				 (CMarkTableCell with: { (CMarkText literal: '1.50') }) }).
	table addChild: (CMarkTableRow with: {
				 (CMarkTableCell with: { (CMarkText literal: 'a longer cell') }).
				 (CMarkTableCell with: { (CMarkCode literal: 'x') }).
				 (CMarkTableCell with: { (CMarkText literal: '1234.00') }) }).
	doc addChild: CMarkThematicBreak new.
	definition := CMarkFootnoteDefinition label: 'note'.
	definition ordinal: 1.
	definition addChild: (CMarkParagraph with: { (CMarkText literal: 'The text of the footnote.') }).
	reference := CMarkFootnoteReference new.
	reference ordinal: 1.
	definition addReference: reference.
	doc addChild: (CMarkParagraph with: {
				 (CMarkText literal: 'A footnote reference').
				 reference.
				 (CMarkText literal: ' points at the end of the page.') }).
	doc addChild: definition.
	^ doc
]

{ #category : 'parsing' }
CMarkRoassalExamples class >> parse: aString [
	"The document of aString, parsed by the CMarkPlugin with the GitHub options"

	^ CMark parse: aString
]

{ #category : 'documents' }
CMarkRoassalExamples class >> readmeFile [
	"The README.md of the cmark-gfm.st checkout, or nil"

	| file |
	(Smalltalk globals at: #IceRepository ifAbsent: [ nil ]) ifNotNil: [ :class |
		[
		class registry
			detect: [ :each | each name = 'cmark-gfm.st' ]
			ifFound: [ :repository |
				file := repository location ifNotNil: [ :location | location / 'README.md' ].
				(file notNil and: [ file exists ]) ifTrue: [ ^ file ] ] ]
			on: Error
			do: [ :e | nil ] ].
	(OSEnvironment current at: 'CMARK_PLUGIN_DIR' ifAbsent: [ nil ]) ifNotNil: [ :dir |
		file := dir asFileReference / 'cmark-gfm.st' / 'README.md'.
		file exists ifTrue: [ ^ file ] ].
	^ nil
]

{ #category : 'documents' }
CMarkRoassalExamples class >> sampleMarkdown [
	"A short document of the common constructs"

	^ String lf join: #(
		'# CMark in Roassal'
		''
		'Markdown parsed by **cmark-gfm** in the VM, walked as a tree of nodes and drawn as *one* composite shape: headings, `code`, ~~struck~~ text and [links](https://github.com/github/cmark-gfm "cmark-gfm").'
		''
		'## Lists'
		''
		'1. parse with `CMark parse: aString`'
		'2. render with `asRoassalShape`'
		'   - nested bullets'
		'   - [x] done'
		'   - [ ] to do'
		''
		'> A quote, muted and indented.'
		''
		'```smalltalk'
		'(CMark parse: ''# Hi'') asRoassalCanvas open'
		'```'
		''
		'| Left | Centre | Right |'
		'|:-----|:------:|------:|'
		'| a | *b* | 1.50 |'
		'| longer text | `x` | 1234.00 |'
		''
		'---'
		'' )
]

{ #category : 'documents' }
CMarkRoassalExamples class >> tableMarkdown [
	"A document of tables"

	^ String lf join: #(
		'# Tables'
		''
		'| Package | Purpose | Loaded by |'
		'|:--------|:--------|:---------:|'
		'| `CMark` | the parse tree, the visitor, the decoder of the tape, the facade | Core |'
		'| `CMark-Roassal` | the renderer of trees as one composite shape | Roassal |'
		'| `CMark-Tests` | the tests that need no plugin and those that need it | Tests |'
		''
		'| n | n squared | n factorial |'
		'|--:|----------:|------------:|'
		'| 1 | 1 | 1 |'
		'| 5 | 25 | 120 |'
		'| 10 | 100 | 3628800 |'
		'' )
]

{ #category : 'documents' }
CMarkRoassalExamples class >> tasksMarkdown [
	"A document of task lists"

	^ String lf join: #(
		'# Tasks'
		''
		'- [x] parse Markdown in the VM'
		'- [x] decode the tape'
		'- [ ] render with Pango'
		'  - [ ] glyph fallback'
		'  - [x] links and images'
		'- a plain item' )
]
