"
I test rendering through the `CMarkPlugin` (each test calls `requirePlugin`): the six formats of a small document against literal expectations, the tag filter, `unsafe`, the wrap width, the positions, the breaks, non-ASCII output, ByteArray sources and answers, and the unknown formats.
"
Class {
	#name : 'CMarkRenderTest',
	#superclass : 'CMarkTestCase',
	#category : 'CMark-Tests-Tests',
	#package : 'CMark-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkRenderTest >> lines: anArray [
	^ CMarkFixtures lines: anArray
]

{ #category : 'running' }
CMarkRenderTest >> setUp [
	super setUp.
	self requirePlugin
]

{ #category : 'tests' }
CMarkRenderTest >> testBreaks [
	self assert: (CMark html: 'a' , String lf , 'b') equals: (self lines: #( '<p>a' 'b</p>' )).
	self
		assert: (CMark render: 'a' , String lf , 'b' format: #html options: (CMarkOptions gfm hardBreaks: true; yourself))
		equals: (self lines: #( '<p>a<br />' 'b</p>' )).
	self
		assert: (CMark render: 'a' , String lf , 'b' format: #html options: (CMarkOptions gfm noBreaks: true; yourself))
		equals: (self lines: #( '<p>a b</p>' ))
]

{ #category : 'tests' }
CMarkRenderTest >> testByteArrays [
	| check bytes |
	check := (String with: (Character value: 16r2713)).
	bytes := CMarkFormatter renderBytes: ('# ' , check) utf8Encoded format: #html options: CMarkOptions gfm.
	self assert: bytes class identicalTo: ByteArray.
	self assert: bytes equals: ('<h1>' , check , '</h1>' , String lf) utf8Encoded.
	self assert: (CMark html: #[ 35 32 72 105 ]) equals: '<h1>Hi</h1>' , String lf.
	"an invalid byte is rendered as U+FFFD"
	self assert: (CMark html: #[ 97 16rFF ]) equals: '<p>a' , (String with: (Character value: 16rFFFD)) , '</p>' , String lf.
	"a U+FEFF of the output is kept"
	self
		assert: (CMark html: 'x' , String lf , String lf , (self stringOf: #( 16rFEFF 121 16rFEFF )))
		equals: '<p>x</p>' , String lf , '<p>' , (self stringOf: #( 16rFEFF 121 16rFEFF )) , '</p>' , String lf.
	self
		assert: (CMark render: (self stringOf: #( 120 16rFEFF )) format: #commonmark options: CMarkOptions gfm)
		equals: (self stringOf: #( 120 16rFEFF 10 ))
]

{ #category : 'tests' }
CMarkRenderTest >> testFormats [
	| source |
	source := self lines: #( '# Hi *x*' '' 'para' ).
	self assert: (CMark html: source) equals: (self lines: #( '<h1>Hi <em>x</em></h1>' '<p>para</p>' )).
	self assert: (CMark render: source format: #html) equals: (CMark html: source).
	self assert: (CMark render: source format: #xml) equals: (self lines: #(
				 '<?xml version="1.0" encoding="UTF-8"?>'
				 '<!DOCTYPE document SYSTEM "CommonMark.dtd">'
				 '<document xmlns="http://commonmark.org/xml/1.0">'
				 '  <heading level="1">'
				 '    <text xml:space="preserve">Hi </text>'
				 '    <emph>'
				 '      <text xml:space="preserve">x</text>'
				 '    </emph>'
				 '  </heading>'
				 '  <paragraph>'
				 '    <text xml:space="preserve">para</text>'
				 '  </paragraph>'
				 '</document>' )).
	self assert: (CMark render: source format: #commonmark) equals: (self lines: #( '# Hi *x*' '' 'para' )).
	self assert: (CMark render: source format: #plaintext) equals: (self lines: #( 'Hi x' '' 'para' )).
	self assert: (CMark render: source format: #latex) equals: (self lines: #( '\section{Hi \emph{x}}' '' 'para' )).
	self assert: (CMark render: source format: #man) equals: (self lines: #( '.SH' 'Hi \f[I]x\f[]' '.PP' 'para' ))
]

{ #category : 'tests' }
CMarkRenderTest >> testFormatter [
	| formatter |
	formatter := CMarkFormatter new.
	self assert: formatter format equals: #html.
	self assert: formatter options equals: CMarkOptions gfm.
	formatter format: #plaintext.
	self assert: (formatter render: '*a*') equals: 'a' , String lf.
	self assert: (formatter renderBytes: '*a*') equals: ('a' , String lf) asByteArray.
	self assert: CMarkFormatter formats equals: #( #html #xml #commonmark #plaintext #latex #man ).
	self assert: (CMarkFormatter formats collect: [ :each | CMarkFormatter formatCode: each ]) equals: #( 1 2 3 4 5 6 )
]

{ #category : 'tests' }
CMarkRenderTest >> testKnownXmlFootnotes [
	"Known gfm.14 behaviour (the candidate patch 0002 of the CMarkPlugin would fix it): the XML render of a footnote is not well-formed"

	| xml |
	xml := CMark render: (self lines: #( 'x[^1]' '' '[^1]: y' )) format: #xml options: (CMarkOptions gfm footnotes: true; yourself).
	self assert: (xml includesSubstring: '<<unknown> />').
	"without footnotes, [^1]: y is the definition of a link reference ^1"
	self assert: (CMark html: (self lines: #( 'x[^1]' '' '[^1]: y' ))) equals: (self lines: #( '<p>x<a href="y">^1</a></p>' ))
]

{ #category : 'tests' }
CMarkRenderTest >> testNonAscii [
	| check html |
	check := String with: (Character value: 16r2713).
	html := CMark html: '# ' , check.
	self assert: html equals: '<h1>' , check , '</h1>' , String lf.
	self assert: html class identicalTo: WideString.
	html := CMark html: '# ' , (String with: (Character value: 233)).
	self assert: html equals: '<h1>' , (String with: (Character value: 233)) , '</h1>' , String lf.
	self assert: html class identicalTo: ByteString.
	self assert: (CMark html: '# e') class identicalTo: ByteString
]

{ #category : 'tests' }
CMarkRenderTest >> testSourcePos [
	self assert: (CMark html: '# Hi') equals: '<h1>Hi</h1>' , String lf.
	self
		assert: (CMark render: '# Hi' format: #html options: (CMarkOptions gfm sourcePos: true; yourself))
		equals: '<h1 data-sourcepos="1:1-1:4">Hi</h1>' , String lf
]

{ #category : 'tests' }
CMarkRenderTest >> testTagFilterAndUnsafe [
	| unsafe |
	self assert: (CMark html: '<b>x</b>') equals: '<p><!-- raw HTML omitted -->x<!-- raw HTML omitted --></p>' , String lf.
	unsafe := CMarkOptions gfm unsafe: true; yourself.
	self assert: (CMark render: '<b>x</b>' format: #html options: unsafe) equals: '<p><b>x</b></p>' , String lf.
	self assert: (CMark render: '<script>x</script>' format: #html options: unsafe) equals: '&lt;script>x&lt;/script>' , String lf.
	unsafe removeExtension: #tagfilter.
	self assert: (CMark render: '<script>x</script>' format: #html options: unsafe) equals: '<script>x</script>' , String lf
]

{ #category : 'tests' }
CMarkRenderTest >> testUnknownFormat [
	| before |
	before := CMark statistics at: #renders.
	self should: [ CMark render: '# Hi' format: #pdf ] raise: CMarkError.
	self should: [ CMarkFormatter new format: #pdf ] raise: CMarkError.
	self should: [ CMarkFormatter formatCode: nil ] raise: CMarkError.
	self assert: (CMark statistics at: #renders) equals: before
]

{ #category : 'tests' }
CMarkRenderTest >> testWidth [
	| source |
	source := 'aaa bbb ccc ddd eee fff ggg hhh iii jjj kkk'.
	self
		assert: (CMark render: source format: #plaintext options: (CMarkOptions gfm width: 20; yourself))
		equals: (self lines: #( 'aaa bbb ccc ddd eee' 'fff ggg hhh iii jjj' 'kkk' )).
	self assert: (CMark render: source format: #plaintext) equals: source , String lf.
	"html ignores the width"
	self
		assert: (CMark render: source format: #html options: (CMarkOptions gfm width: 20; yourself))
		equals: '<p>' , source , '</p>' , String lf
]
