"
CMark - Markdown for Pharo 12 to 15: GitHub's cmark-gfm 0.29.0.gfm.14 (https://github.com/github/cmark-gfm, CommonMark plus the GFM extensions table, strikethrough, autolink, tagfilter and tasklist, and footnotes) parses in the CMarkPlugin of the VM (plugins/CMarkPlugin of https://github.com/massimo-nocentini/pharo-vm, whose docs/CMark.md is the contract: sections Tree format and Primitive contract), and Smalltalk walks the parse tree.

The plugin answers the whole tree as one flat tape (a Bitmap of 16 words per node, in pre-order, and a ByteArray of the strings), which CMarkTreeDecoder turns into CMarkNodes without recursion: one class per node type (CMarkHeading, CMarkParagraph, CMarkLink, CMarkTable...), with navigation (parent, children, firstChild, nextSibling, ancestors, document), the source positions of cmark (byte columns) and the character indices in the source (sourceInterval, sourceText), iterative walks (do:, plainText, treeString) and a visitor (CMarkVisitor, acceptCMarkVisitor:).  Trees can also be built by hand (CMarkParagraph with: { CMarkText literal: 'x' }), with no plugin: they have no positions.

The facade is CMark (CMark parse: '# Hi', CMark html: '# Hi', CMark render: aString format: #latex, CMark isAvailable): CMarkParser answers a CMarkDocument, CMarkFormatter renders source text with the renderers of cmark-gfm (html, xml, commonmark, plaintext, latex, man), and CMarkPrimitives holds the primitives and the budget loop.  Without the plugin, parsing and rendering signal CMarkUnavailable.

The API is explicit and opt-in: nothing of Pharo is replaced or changed, and every extension selector on a class of Pharo begins with cmark (cmarkSource, cmarkFailed).  CMarkOptions says what to parse with (CMarkOptions gfm, CMarkOptions commonMark); the errors are all under CMarkError.

Loading:
	Metacello new
		baseline: 'CMark';
		repository: 'github://massimo-nocentini/cmark-gfm.st:master/src';
		load: #( 'Core' )
"
Class {
	#name : 'ManifestCMark',
	#superclass : 'PackageManifest',
	#category : 'CMark-Manifest',
	#package : 'CMark',
	#tag : 'Manifest'
}
