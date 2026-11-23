# cmark-gfm.st

Markdown for Pharo 12 to 15: [cmark-gfm](https://github.com/github/cmark-gfm) 0.29.0.gfm.14, GitHub's CommonMark parser with the GFM extensions (tables, strikethrough, autolinks, the tag filter, task lists) and footnotes, parses the source, and Smalltalk walks the parse tree as objects: one class per node type, with navigation, source positions and a visitor. The package `CMark-Roassal` draws a parsed document as one composite Roassal shape, and `CMark-Calypso` uses it for a Markdown tab of class comments in the Calypso browser.

The parsing is done by the CMarkPlugin of the VM of [massimo-nocentini/pharo-vm](https://github.com/massimo-nocentini/pharo-vm) (`plugins/CMarkPlugin`, whose `docs/CMark.md` is the contract). It is built into the native VMs and the WebAssembly VMs of that fork. There is no FFI binding and no Smalltalk parser. Without the plugin, trees can still be built by hand, walked, visited and drawn, but no Markdown can be parsed or rendered.

The plugin answers the whole tree in one primitive call, as a flat tape: 16 words per node, in pre-order, and the node strings as UTF-8. `CMarkTreeDecoder` turns the tape into nodes in pure Smalltalk, without recursion. No C pointer outlives the call, so there is nothing to finalise.

The API is explicit and opt-in. Nothing in Pharo is replaced or changed, and every extension selector on a class of Pharo begins with `cmark` (`cmarkSource`, `cmarkFailed`).

This repository is the submodule `plugins/CMarkPlugin/cmark-gfm.st` of that VM. Its commit is the version of the Smalltalk code that goes with the plugin.

## Requirements

- Pharo 12, 13, 14 or 15, 64-bit.
- To parse or render Markdown: a VM with the CMarkPlugin (protocol 1).

## Loading

```smalltalk
Metacello new
	baseline: 'CMark';
	repository: 'github://massimo-nocentini/cmark-gfm.st:master/src';
	load: #( 'Core' )
```

| Group | Packages |
|---|---|
| `Core` | `CMark`: the parse tree, the visitor, the options, the errors, the decoder of the tape, the facade |
| `Tests` | `CMark-Tests` |
| `Roassal` | `Core` and `CMark-Roassal`: the renderer, on the Roassal of the stock image |
| `RoassalTests` | `CMark-Roassal-Tests` |
| `Calypso` | `Roassal` and `CMark-Calypso`: the Markdown tab of the Calypso browser |
| `CalypsoTests` | `CMark-Calypso-Tests` |
| `RoassalFork` | the user's Roassal fork (`github://massimo-nocentini/Roassal:Pharo15/src`), then `Roassal`; opt-in, and loading it over a stock image needs `MCMergeOrLoadWarning` answered with `load` |
| `default` | `Core`, `Tests`, `Roassal`, `RoassalTests`, `Calypso` and `CalypsoTests` |

From a checkout of the VM, `plugins/CMarkPlugin/tests/load-cmark.st` loads the submodule, and `run-st-tests.sh` runs the tests.

## API

### Parsing

```smalltalk
doc := CMark parse: '# Hello *world*'.          "a CMarkDocument, with CMarkOptions gfm"
doc := CMark parse: aString options: (CMarkOptions commonMark smart: true).
CMark html: '# Hi'.                              "'<h1>Hi</h1>', LF"
CMark render: '# Hi' format: #latex.             "#html #xml #commonmark #plaintext #latex #man"
CMark isAvailable.                               "whether the VM has the CMarkPlugin"
CMark version.                                   "'0.29.0.gfm.14', or nil without the plugin"
CMark statistics.                                "the plugin's counters: parses, renders, reused..."
```

`CMark` only delegates. `CMarkParser` (`parse:`, `options:`) answers a `CMarkDocument`, and `CMarkFormatter` (`render:`, `renderBytes:`, `format:`, `options:`) renders source text with cmark-gfm's own renderers: `#html`, `#xml`, `#commonmark`, `#plaintext`, `#latex` or `#man`. An unknown format is a `CMarkError`. The formatter takes source text only: there is no CommonMark writer in Smalltalk, so a hand-built tree cannot be rendered this way.

A parse is one call of the plugin. The answer is sized before it is allocated. When it would not fit in the free object memory, `CMarkPrimitives` grows the memory and calls again, and the plugin answers from the result it kept, without parsing again.

A source is a String (a ByteString is Latin-1 and a WideString any Unicode; a Symbol or a Text is converted) or a ByteArray of UTF-8. Bytes that are not valid UTF-8, and NUL, are parsed as U+FFFD. Anything else is a `CMarkError`.

`CMarkOptions` is a mutable builder whose setters cascade. `CMarkOptions gfm` turns on the five extensions and `CMarkOptions commonMark` none. Both answer a fresh instance every time.

```smalltalk
CMarkOptions gfm
	smart: true;                 "curly quotes, dashes, ellipses"
	footnotes: true;             "off by default: see Limitations"
	hardBreaks: true;            "a newline in a paragraph is a line break"
	unsafe: true;                "the renders keep raw HTML; the tree always has it"
	width: 72;                   "the wrap width of the text renders"
	maxDepth: 1000;              "the deepest node accepted (nil: no limit)"
	cBudget: 64 * 1024 * 1024;   "the C memory a call may hold (nil: the plugin's default)"
	maxInputSize: nil;           "no image-side cap (default 32 Mi characters, 16 Mi on WebAssembly)"
	yourself
```

### The tree

Each node type has its own class: `CMarkDocument`, `CMarkBlockQuote`, `CMarkList`, `CMarkItem` and `CMarkTaskItem`, `CMarkCodeBlock`, `CMarkHtmlBlock`, `CMarkParagraph`, `CMarkHeading`, `CMarkThematicBreak`, `CMarkFootnoteDefinition`, `CMarkTable`, `CMarkTableRow` and `CMarkTableHeaderRow`, `CMarkTableCell`; the inlines `CMarkText`, `CMarkSoftBreak`, `CMarkLineBreak`, `CMarkCode`, `CMarkHtmlInline`, `CMarkEmph`, `CMarkStrong`, `CMarkStrikethrough`, `CMarkLink`, `CMarkImage` and `CMarkFootnoteReference`; the custom nodes; and `CMarkUnknownBlock`/`CMarkUnknownInline` for types the tape has no code for.

```smalltalk
heading := doc firstChild.            "a CMarkHeading(level 1, 1:1-1:15)"
heading level.                        "1"
heading plainText.                    "'Hello world'"
heading anchor.                       "'hello-world', as GitHub makes it (-1, -2... for repeats)"
heading sourceText.                   "'# Hello *world*': the characters of the source"
heading sourceInterval.               "(1 to: 15)"
heading startLine. heading startByteColumn.   "cmark's positions: columns count bytes of UTF-8"
heading children. heading parent. heading document.
heading nextSibling. heading previousSibling. heading indexInParent. heading ancestors. heading depth.
doc headings. doc links. doc footnoteDefinitions.
doc do: [ :node | ... ].              "pre-order, iterative: any depth"
doc select: [ :node | node isLink ].
doc treeString.                       "one line per node: type, position, fields"
```

`startIndex` and `endIndex` are 1-based character indices into `doc sourceString`: the source itself when it is a String, and the decoded UTF-8 when it is a ByteArray (with U+FFFD for each invalid byte, so that the indices still match). Soft and line breaks, the cells that cmark adds to pad a short table row, and hand-built nodes have no position.

The walks of the library (`do:`, `allNodes`, `select:`, `detect:ifNone:`, `plainText`, `treeString`, the decoder) use an explicit stack, so a tree 200,000 levels deep walks in constant stack. Visitors recurse:

```smalltalk
CMarkVisitor subclass: #LinkCollector ...
LinkCollector >> visitLink: aLink [ urls add: aLink url. ^ self visitChildren: aLink ]
LinkCollector new visit: doc
```

Every `visitX:` defaults to `visitNode:`, which visits the children. `visitTaskItem:` defaults to `visitItem:`, and `visitTableHeaderRow:` to `visitTableRow:`.

### Building by hand

No plugin is needed:

```smalltalk
CMarkDocument withAll: {
	CMarkHeading level: 1 with: { CMarkText literal: 'Title' }.
	CMarkParagraph with: {
		CMarkText literal: 'See '.
		(CMarkLink url: 'https://pharo.org' title: '') addChild: (CMarkText literal: 'Pharo'); yourself }.
	(CMarkList ordered: 1) addChild: ((CMarkTaskItem checked: true) addChild: (CMarkParagraph with: { CMarkText literal: 'done' }); yourself); yourself.
	CMarkCodeBlock literal: 'Transcript show: ''hi''' , String lf info: 'smalltalk'.
	(CMarkTable alignments: #( #left #right )) addChild: (CMarkTableHeaderRow with: { CMarkTableCell new. CMarkTableCell new }); yourself }
```

`addChild:` sets the parent and answers the child. A table cell's `column` and `alignment` are computed from its row and table, so hand-built cells have them too. A hand-built tree cannot be rendered to HTML or the other formats: there is no CommonMark writer in Smalltalk, and the C renderers take source text only.

### Errors

Every error of CMark is a `CMarkError`: `CMarkUnavailable` (no plugin, or another protocol), `CMarkInputTooLarge`, `CMarkTooDeep`, `CMarkMemoryLimit` (`reason`: `#budget`, `#block` or `#malloc`), and `CMarkMalformedTree`. When growing the object memory does not make room for an answer, the stock `OutOfMemory` is signalled: it is a VM condition, and `on: CMarkError` does not catch it.

## Rendering with Roassal

The package `CMark-Roassal` (group `Roassal`) draws a node as one `RSComposite` whose model is the node: a document as a page, any other node alone. It uses only the Roassal API that the stock images of Pharo 12 to 15 share, so it needs neither the user's Roassal fork nor the plugin (a hand-built tree draws too).

```smalltalk
doc := CMark parse: aString options: (CMarkOptions gfm footnotes: true; yourself).
doc asRoassalShape.                   "an RSComposite, the default theme, 640 wide"
doc asRoassalShapeWidth: 320.
doc asRoassalCanvas open.             "an RSCanvas: the camera fits the width and shows the top"

renderer := CMarkRoassalRenderer new
	theme: CMarkRoassalTheme dark;    "default, dark or compact"
	maxWidth: 480;
	baseDirectory: FileLocator imageDirectory asFileReference;   "for relative image URLs"
	yourself.
shape := renderer render: doc.
(renderer canvasFor: doc) open.

CMarkRoassalExporter exportPng: shape to: 'doc.png' asFileReference scale: 2.
CMarkRoassalExporter exportSvg: shape to: 'doc.svg' asFileReference.
CMarkRoassalExamples exampleSample.   "also exampleDark, exampleNarrow, exampleTable, exampleTasks, exampleHandBuilt, exampleReadme"
```

How it lays out:
- Blocks are stacked composites, each with a transparent frame box as its first child (the hit area, with the node as model). A block composite is never given an explicit extent: Roassal clips the children of a composite to its own rectangle.
- Paragraphs and headings go through `CMarkInlineFlow`, not `RSFlowLayout`. Lines break only at blanks (space, tab, CR, LF; a no-break space is not one), soft breaks and line breaks, so that `[link](u).` or `**bold**,` never lose their punctuation to the next line. Text is measured by the advance of each character, and the words of one run on a line are one `RSLabel`, so that underlines and strikes are continuous. Every piece of a line sits on one baseline. A code span is a row of chips that may break at its spaces.
- Tables get an automatic layout: each column gets at least its widest word, and the rest of the width goes to the columns that need it. Lists put their markers on the first baseline of the item (bullets by depth, numbers as written from the list's start, a checkbox with a tick for a checked task). Quotes get a bar, code blocks a rounded box (tabs every 4 columns), footnote definitions come last.
- Links carry one shared popup (the URL) and a click. A click on `#anchor` or on a footnote reference moves the camera to the heading or the definition; other URLs go to `theme linkAction` (the `WebBrowser` of the image, when there is one).

`CMarkRoassalTheme` holds the fonts (Source Sans Pro and Source Code Pro, else the default family of `RSLabel`, at whole point sizes), sizes, colours and gaps, and:
- `htmlStyle`: raw HTML is never executed. `#basic` (the default) hides comments, makes `<br>` a line break and `<img src alt>` an image or a placeholder, and strips other tags but keeps their text; `#literal` shows the HTML as muted code; `#hide` drops it.
- `codeWrap`: `#none` (a long code line widens its box), `#characters` or `#clip`. `breakLongWords` breaks words wider than the column.
- the caps `maxNesting` (64: deeper blocks are drawn flat, deeper inlines keep their style), `maxShapes` (100,000) and `maxTableCells` (10,000), beyond which a muted placeholder says what is not shown.
- `imageResolver`: images come from local `.png`, `.jpg`, `.jpeg`, `.gif` and `.bmp` files only, absolute or relative to `baseDirectory:`, never from the network. Images wider than the column are scaled down.

The inspector of a node has a `Rendered` tab (for trees of at most 5000 nodes).

Limits of the view: the fonts of the image only, so CJK characters and emoji are drawn as boxes (no glyph fallback); no syntax highlighting, no math, no selection; GitHub alerts are plain quotes; `codeWrap: #none` code lines, words wider than the column and tables whose words do not fit are the only things wider than `maxWidth`.

## Class comments in Calypso

The package `CMark-Calypso` (group `Calypso`, in `default`) adds a **Markdown** tab to the Calypso browser, between the `Comment` and the `UML-Class` tabs: the comment of the selected class, parsed by cmark-gfm (`CMarkOptions gfm`; footnotes stay off, as `[^self error: ...]` in a comment would be taken for a footnote label and lose text, see Limitations) and drawn by `CMarkRoassalRenderer`. It needs only the Calypso, Spec and Roassal of the stock images, not Roassal-UML-Calypso (which the stock images do not have; the user's Roassal fork has it).

```smalltalk
(CMarkCommentPresenter on: CMarkRoassalRenderer) open.     "the same view in a window of its own"
```

- `CMarkCommentPresenter` is a Spec presenter holding an `SpRoassalPresenter`. Its canvas is drawn by `CMarkRoassalRenderer>>show:on:` (which `canvasFor:` uses too): the camera fits the width and shows the top, again when the view is resized, and a canvas controller zooms and pans. The theme follows the UI theme of Pharo (`CMarkRoassalTheme dark` on a dark UI theme, `default` on a light one), unless `markdownTheme:` sets one. It draws again when the comment of its class changes (it subscribes weakly to `ClassCommented`, and unsubscribes when its window closes or when told to: `unsubscribe`) and when `targetClass:` gives it another class. An empty comment, a VM without the CMarkPlugin and a comment that cmark refuses show a short muted note instead.
- `CMarkClassCommentToolMorph` is the tab (a `ClyBrowserToolMorph`): it is activated when a class whose comment is not blank is selected (on either side), with `tabOrder` 10.5, after the Comment tab (`ClyRichTextClassCommentEditorToolMorph`, 10 on Pharo 12 to 15, like the class definition) and before the setUp tab of the test classes (11) and the UML-Class tab (200). Its `activationPriority`, -200 like the UML-Class tab's, never takes the default selection from the definition or the comment. Calypso builds a tab when it is first shown, and the tab unsubscribes its presenter when Calypso removes it (another class selected, the browser closed).

## Tests

`CMark-Tests` (105 tests), `CMark-Roassal-Tests` (78 tests, with golden structural dumps of the rendered fixtures) and `CMark-Calypso-Tests` (25 tests: the presenter, the tab and its order in a real `ClyFullBrowserMorph`, on scratch classes that the tests make and remove). Without the plugin, the tests that parse skip themselves (45, 11 and 5 of them): the rest covers the decoder on hand-made tapes, the hand-built trees, the visitor, the options and the renderer on hand-built trees. The structure of a dump is compared under any cairo, its bounds only under cairo 1.18 (the goldens' `CMarkRoassalGoldens cairoVersion`, which this repository's VM builds): cairo's text metrics differ between versions, and under another cairo, such as the 1.17.4 of the VMs of files.pharo.org, the golden tests skip once the structure matched. From a checkout of the VM:

```sh
sh plugins/CMarkPlugin/tests/run-st-tests.sh build/build/vm Pharo.image
CMARK_GROUPS='Core Tests Roassal RoassalTests' sh plugins/CMarkPlugin/tests/run-st-tests.sh build/build/vm Pharo.image
CMARK_GROUPS='default' sh plugins/CMarkPlugin/tests/run-st-tests.sh build/build/vm Pharo.image
```

## Tree format

`docs/CMark.md` of the VM, section "Tree format", is the canonical description of the tape: the record layout, the flags, the codes and the fields of each type. Private data of cmark that its public API does not expose is not in the tape: the bullet character (`-`, `*` or `+`; `CMarkItem>>markerText` reads it from the source), setext versus ATX headings, and the kind of an HTML block.

## Limitations

- The positions are cmark's own. Columns count bytes, and the soft and line breaks have none.
- cmark-gfm 0.29.0.gfm.14 is used without patches. With `footnotes: true`, a footnote label that contains an inline (``[^a<b>c]``) is cut short, and the dropped text disappears from the document: an upstream regression of gfm.14. Footnotes are therefore off by default. The XML render of a footnote is not well-formed (`<<unknown> />`). Angle autolinks (`<https://x.y>`) get wrong columns, which the plugin clamps (`isClamped`). In a table cell, the inlines after an escaped pipe (`\|`) start and end one column early per escaped pipe before them; those columns stay inside the line, so they are not clamped and their `sourceText` is off.
- GitHub alerts (`> [!NOTE]`) are GitHub post-processing: cmark parses them as plain block quotes.
- A parse is one primitive call: the VM does nothing else while it runs.

## Licence

MIT (`LICENSE`). cmark-gfm is BSD-2-Clause, with parts under MIT. Its notice ships with the VM (`LICENSE.cmark-gfm`, and `THIRD-PARTY-NOTICES.txt` on WebAssembly). This repository copies no cmark-gfm code. Its test fixtures are our own text: no text of the CommonMark or GFM specifications (CC-BY-SA) is copied.
