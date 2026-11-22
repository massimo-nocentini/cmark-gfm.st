# cmark-gfm.st

Markdown for Pharo 12 to 15: [cmark-gfm](https://github.com/github/cmark-gfm) 0.29.0.gfm.14, GitHub's CommonMark parser with the GFM extensions (tables, strikethrough, autolinks, the tag filter, task lists) and footnotes, parses the source, and Smalltalk walks the parse tree as objects: one class per node type, with navigation, source positions and a visitor. The package `CMark-Roassal` draws a parsed document as one composite Roassal shape.

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
| `RoassalFork` | the user's Roassal fork (`github://massimo-nocentini/Roassal:Pharo15/src`), then `Roassal`; opt-in, and loading it over a stock image needs `MCMergeOrLoadWarning` answered with `load` |
| `default` | `Core`, `Tests`, `Roassal` and `RoassalTests` |

From a checkout of the VM, `plugins/CMarkPlugin/tests/load-cmark.st` loads the submodule, and `run-st-tests.sh` runs the tests.

## API

### Parsing

```smalltalk
doc := CMark parse: '# Hello *world*'.          "a CMarkDocument, with CMarkOptions gfm"
doc := CMark parse: aString options: (CMarkOptions commonMark smart: true).
CMark html: '# Hi'.                              "'<h1>Hi</h1>', LF"
CMark render: '# Hi' format: #latex.             "#html #xml #commonmark #plaintext #latex #man"
CMark isAvailable.                               "whether the VM has the CMarkPlugin"
```

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

## Tree format

`docs/CMark.md` of the VM, section "Tree format", is the canonical description of the tape: the record layout, the flags, the codes and the fields of each type. Private data of cmark that its public API does not expose is not in the tape: the bullet character (`-`, `*` or `+`; `CMarkItem>>markerText` reads it from the source), setext versus ATX headings, and the kind of an HTML block.

## Limitations

- The positions are cmark's own. Columns count bytes, and the soft and line breaks have none.
- cmark-gfm 0.29.0.gfm.14 is used without patches. With `footnotes: true`, a footnote label that contains an inline (``[^a<b>c]``) is cut short, and the dropped text disappears from the document: an upstream regression of gfm.14. Footnotes are therefore off by default. The XML render of a footnote is not well-formed (`<<unknown> />`). Angle autolinks (`<https://x.y>`) get wrong columns, which the plugin clamps (`isClamped`).
- GitHub alerts (`> [!NOTE]`) are GitHub post-processing: cmark parses them as plain block quotes.
- A parse is one primitive call: the VM does nothing else while it runs.

## Licence

MIT (`LICENSE`). cmark-gfm is BSD-2-Clause, with parts under MIT. Its notice ships with the VM (`LICENSE.cmark-gfm`, and `THIRD-PARTY-NOTICES.txt` on WebAssembly). This repository copies no cmark-gfm code. Its test fixtures are our own text: no text of the CommonMark or GFM specifications (CC-BY-SA) is copied.
