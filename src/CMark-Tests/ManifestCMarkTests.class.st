"
The tests of CMark.

Without the plugin (they always run):

- `CMarkDecoderTest` decodes tapes built by hand (`CMarkTapeBuilder`) for every code, flag and field, and malformed ones;
- `CMarkNodeTest` the hand-building API, the navigation, the walks, printing, the headings' anchors and the `cmarkSource` conversions;
- `CMarkVisitorTest` the double dispatch and the defaults of `CMarkVisitor`;
- `CMarkOptionsTest` the bits of the options;
- `CMarkErrorTest` the errors and `CMarkFailure`;
- `CMarkUnavailableTest` what parsing and rendering do without the plugin (the test hooks `#pluginMissing` and `#protocol` of `CMarkPrimitives`).

With the plugin (each test calls `requirePlugin`, and skips without it):

- `CMarkParseTest` the tree of the sample against the golden tree of the C tests of the `CMarkPlugin`, the sources, footnotes, options, extensions and limits;
- `CMarkRenderTest` the six formats;
- `CMarkBudgetTest` the budget loop;
- `CMarkPrimitiveContractTest` the primitives themselves;
- `CMarkPerformanceTest` prints the time of a 10 MB parse.

`CMarkFixtures` holds the Markdown fixtures, our own text (no CommonMark or GFM spec text: it is CC-BY-SA).
"
Class {
	#name : 'ManifestCMarkTests',
	#superclass : 'PackageManifest',
	#category : 'CMark-Tests-Manifest',
	#package : 'CMark-Tests',
	#tag : 'Manifest'
}
