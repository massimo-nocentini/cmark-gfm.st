"
I test `CMarkOptions`: the defaults, the bits of each option and extension against the constants of cmark (`docs/CMark.md`, Primitive contract), the fresh instances of `gfm` and `commonMark`, the unknown extensions, copying, equality and the checks of the setters.
"
Class {
	#name : 'CMarkOptionsTest',
	#superclass : 'CMarkTestCase',
	#category : 'CMark-Tests-Tests',
	#package : 'CMark-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
CMarkOptionsTest >> testCopyAndEquality [
	| a b |
	a := CMarkOptions gfm.
	b := a copy.
	self assert: a equals: b.
	self assert: a hash equals: b hash.
	b removeExtension: #table.
	self assert: (a hasExtension: #table).
	self deny: (b hasExtension: #table).
	self deny: a = b.
	b addExtension: #table.
	self assert: a equals: b.
	b smart: true.
	self deny: a = b.
	self deny: CMarkOptions new = (CMarkOptions new width: 72).
	self deny: CMarkOptions new = (CMarkOptions new maxDepth: nil).
	self deny: CMarkOptions new = 42
]

{ #category : 'tests' }
CMarkOptionsTest >> testDefaults [
	| o |
	o := CMarkOptions new.
	self assert: o extensions isEmpty.
	self assert: o optionBits equals: 0.
	self assert: o extensionBits equals: 0.
	self assert: o width equals: 0.
	self assert: o maxDepth equals: 1000.
	self assert: o maxDepthArgument equals: 1000.
	self assert: o cBudget isNil.
	self assert: o cBudgetArgument equals: -1.
	self assert: o maxInputSize equals: CMarkOptions defaultMaxInputSize.
	self assert: CMarkOptions defaultMaxInputSize equals: CMarkPrimitives defaultMaxInputSize.
	self assert: CMarkOptions defaultMaxInputSize equals: (CMarkPrimitives platform = 'emscripten'
			 ifTrue: [ 16 * 1024 * 1024 ]
			 ifFalse: [ 32 * 1024 * 1024 ]).
	#( #sourcePos #hardBreaks #noBreaks #smart #githubPreLang #liberalHtmlTag #footnotes #strikethroughDoubleTilde
	   #tablePreferStyleAttributes #fullInfoString #unsafe ) do: [ :each | self deny: (o perform: each) ].
	self assert: (o maxDepth: nil; maxDepthArgument) equals: 0.
	self assert: (o cBudget: 4096; cBudgetArgument) equals: 4096
]

{ #category : 'tests' }
CMarkOptionsTest >> testExtensionBits [
	| o |
	self assert: CMarkOptions allExtensionNames equals: #( #table #strikethrough #autolink #tagfilter #tasklist ).
	self assert: CMarkOptions gfm extensionBits equals: 31.
	self assert: CMarkOptions commonMark extensionBits equals: 0.
	CMarkOptions allExtensionNames doWithIndex: [ :each :i |
		o := CMarkOptions new addExtension: each.
		self assert: o extensionBits equals: (1 bitShift: i - 1).
		self assert: o extensions equals: { each } ].
	o := CMarkOptions new extensions: #( #tasklist #table ).
	self assert: o extensionBits equals: 17.
	self assert: o extensions equals: #( #table #tasklist ).
	self assert: (CMarkOptions new extensions: #( 'autolink' )) extensionBits equals: 4.
	o := CMarkOptions gfm removeExtension: #strikethrough.
	self assert: o extensionBits equals: 29.
	o removeExtension: #strikethrough.
	self assert: o extensionBits equals: 29
]

{ #category : 'tests' }
CMarkOptionsTest >> testFreshInstances [
	| a |
	a := CMarkOptions gfm.
	self deny: a identicalTo: CMarkOptions gfm.
	self assert: a equals: CMarkOptions gfm.
	a removeExtension: #table.
	self assert: CMarkOptions gfm extensionBits equals: 31.
	self deny: CMarkOptions gfm footnotes.
	self deny: CMarkOptions commonMark identicalTo: CMarkOptions commonMark.
	self assert: CMarkOptions commonMark equals: CMarkOptions new
]

{ #category : 'tests' }
CMarkOptionsTest >> testOptionBits [
	| expected all |
	expected := {
		            (#sourcePos -> 2).
		            (#hardBreaks -> 4).
		            (#noBreaks -> 16).
		            (#smart -> 1024).
		            (#githubPreLang -> 2048).
		            (#liberalHtmlTag -> 4096).
		            (#footnotes -> 8192).
		            (#strikethroughDoubleTilde -> 16384).
		            (#tablePreferStyleAttributes -> 32768).
		            (#fullInfoString -> 65536).
		            (#unsafe -> 131072) }.
	all := CMarkOptions new.
	expected do: [ :each |
		| o |
		o := CMarkOptions new.
		self assert: (o perform: (each key , ':') asSymbol with: true) identicalTo: o.
		self assert: (o perform: each key).
		self assert: o optionBits equals: each value.
		self assert: (CMarkOptions perform: (each key , 'Bit') asSymbol) equals: each value.
		all perform: (each key , ':') asSymbol with: true ].
	self assert: all optionBits equals: 261142.
	"every bit is allowed by the plugin (CM_OPT_ALLOWED 16r3FF1E); SAFE, NORMALIZE and VALIDATE_UTF8 are not options here"
	self assert: (all optionBits bitAnd: 16r3FF1E) equals: all optionBits.
	self assert: (16r3FF1E - all optionBits) equals: 8 + 256 + 512.
	all smart: false.
	self assert: all optionBits equals: 261142 - 1024.
	self deny: (CMarkOptions new smart: 1) smart
]

{ #category : 'tests' }
CMarkOptionsTest >> testSettersCheck [
	| o |
	o := CMarkOptions new.
	self assert: (o width: 72) identicalTo: o.
	self assert: o width equals: 72.
	self assert: (o maxInputSize: nil) identicalTo: o.
	self assert: o maxInputSize isNil.
	self should: [ o width: -1 ] raise: CMarkError.
	self should: [ o width: 10001 ] raise: CMarkError.
	self should: [ o width: nil ] raise: CMarkError.
	self should: [ o maxDepth: -1 ] raise: CMarkError.
	self should: [ o maxDepth: 1.5 ] raise: CMarkError.
	self should: [ o cBudget: -1 ] raise: CMarkError.
	self should: [ o maxInputSize: 'x' ] raise: CMarkError.
	self assert: o width equals: 72
]

{ #category : 'tests' }
CMarkOptionsTest >> testUnknownExtensions [
	self should: [ CMarkOptions new addExtension: #footnotes ] raise: CMarkError.
	self should: [ CMarkOptions new removeExtension: #foo ] raise: CMarkError.
	self should: [ CMarkOptions new extensions: #( #table #foo ) ] raise: CMarkError.
	self deny: (CMarkOptions new hasExtension: #foo).
	self assert: (CMarkOptions gfm printString includesSubstring: 'table strikethrough autolink tagfilter tasklist')
]
