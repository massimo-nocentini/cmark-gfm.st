"
I hold the Markdown fixtures of the tests, on my class side, as Strings with LF line ends. They are our own text: no CommonMark or GFM spec text is copied (CC-BY-SA). `sample` is the text of `tests/fixtures/sample.md` of the `CMarkPlugin` (pharo-vm): keep the two equal.
"
Class {
	#name : 'CMarkFixtures',
	#superclass : 'Object',
	#category : 'CMark-Tests-Support',
	#package : 'CMark-Tests',
	#tag : 'Support'
}

{ #category : 'fixtures' }
CMarkFixtures class >> footnotes [
	"Footnotes (with the option footnotes): a definition referenced twice, references in another order than the definitions, an unreferenced definition, an unresolved reference"

	^ self lines: #(
			'A[^y] and [^x], then [^y] again and [^missing].'
			''
			'[^x]: The x note.'
			'[^z]: Never used.'
			'[^y]: The y note.' )
]

{ #category : 'private' }
CMarkFixtures class >> lines: anArray [
	"The lines of anArray, each ended by a line feed"

	^ String streamContents: [ :s |
		  anArray do: [ :each | s nextPutAll: each; nextPut: Character lf ] ]
]

{ #category : 'fixtures' }
CMarkFixtures class >> nested [
	"Nesting: quotes in a list in a quote, emphasis in strong in a link, a list four levels deep"

	^ self lines: #(
			'> 1. one'
			'>    > quoted *in **a [link](#one)** here*'
			'>    - a'
			'>      - b'
			'>        - c'
			'>          - d' )
]

{ #category : 'fixtures' }
CMarkFixtures class >> sample [
	"Every construct: ATX and setext headings, emphasis, strong, strikethrough, code, a link with a title, an image, autolinks, a hard break, inline HTML, a footnote, a block quote with a lazy line, an ordered list with a nested bullet list and two task items, fenced and indented code, a table with the four alignments, an escaped pipe and a short row, an HTML block, a thematic break, a footnote definition (the text of tests/fixtures/sample.md of the CMarkPlugin)"

	^ self lines: #(
			'# Heading *one*'
			''
			'Setext heading'
			'--------------'
			''
			'Some *emphasis*, **strong**, ~~struck~~, `code`, a [link](https://example.org "Title")'
			'and an ![image](img.png "Alt title"), autolinks www.pharo.org and <https://x.y>,'
			'a hard break  '
			'and raw <span>html</span>. Footnote[^1].'
			''
			'> Block quote with a'
			'> lazy line'
			''
			'1. first'
			'2. second'
			'   - nested bullet'
			'   - [ ] open task'
			'   - [x] done task'
			''
			'```smalltalk extra'
			'Transcript show: ''hi'''
			'```'
			''
			'    indented code'
			''
			'| Left | Centre | Right | None |'
			'|:-----|:------:|------:|------|'
			'| a    | **b**  | `c`   | d \| e |'
			'| f    |'
			''
			'<div>'
			'html block'
			'</div>'
			''
			'***'
			''
			'[^1]: The footnote text.' )
]

{ #category : 'fixtures' }
CMarkFixtures class >> table [
	"A table of three columns, aligned left, center and right, with inlines in the cells and a short row"

	^ self lines: #(
			'| Name | Kind | Size |'
			'|:-----|:----:|-----:|'
			'| `CMark` | **core** | 1 |'
			'| CMark-Roassal | *view* | 22 |'
			'| short |' )
]

{ #category : 'fixtures' }
CMarkFixtures class >> tasks [
	"Task lists: unchecked, checked (x and X), a nested task list and a plain item between tasks"

	^ self lines: #(
			'- [ ] write the decoder'
			'- [x] write the tests'
			'- [X] commit'
			'  - [ ] nested open'
			'  - [x] nested done'
			'- plain item' )
]

{ #category : 'fixtures' }
CMarkFixtures class >> unicode [
	"Characters of 2, 3 and 4 bytes of UTF-8 before and inside nodes: a heading, emphasis, code, a link, a table and an emoji outside the BMP"

	| e |
	e := (Character value: 16r1F600) asString.
	^ self lines: {
			  ('# ' , (self wide: #( 220 110 239 99 246 100 233 )) , ' ' , (Character value: 16r2713) asString).
			  ''.
			  ('Caf' , (Character value: 233) asString , ' *' , (self wide: #( 16r3053 16r3093 16r306B 16r3061 16r306F )) , '* `' , e , '` [' , (self wide: #( 16r03B1 16r03B2 )) , '](https://example.org/' , (Character value: 252) asString , ')').
			  ''.
			  ('| ' , e , ' | ' , (Character value: 16r00E9) asString , ' |').
			  '|---|---|'.
			  ('| ' , (self wide: #( 16r4E2D 16r6587 )) , ' | x |') }
]

{ #category : 'private' }
CMarkFixtures class >> wide: codePoints [
	"The String of codePoints"

	^ String withAll: (codePoints collect: [ :each | Character value: each ])
]
