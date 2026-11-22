"
The tests of CMark.  Without the plugin (they always run): CMarkDecoderTest decodes tapes built by hand (CMarkTapeBuilder) for every code, flag and field, and malformed ones; CMarkNodeTest the hand-building API, the navigation, the walks, printing, the headings' anchors and the cmarkSource conversions; CMarkVisitorTest the double dispatch and the defaults of CMarkVisitor; CMarkOptionsTest the bits of the options; CMarkErrorTest the errors and CMarkFailure.  CMarkFixtures holds the Markdown fixtures, our own text (no CommonMark or GFM spec text: it is CC-BY-SA).
"
Class {
	#name : 'ManifestCMarkTests',
	#superclass : 'PackageManifest',
	#category : 'CMark-Tests-Manifest',
	#package : 'CMark-Tests',
	#tag : 'Manifest'
}
