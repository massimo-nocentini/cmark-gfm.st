"
I test the interactions of the rendering and the hygiene of the package:

- one shared `RSPopup` on every piece of a link (labels, code chips, images) and on footnote references,
- a click subscription made with `when:do:for:` (the renderer is the subscriber),
- popup texts,
- link actions, and
- no sender of the deprecated `when:do:` in `CMark-Roassal` (which would rewrite the package at run time and leave it dirty).
"
Class {
	#name : 'CMarkRoassalInteractionTest',
	#superclass : 'CMarkRoassalTestCase',
	#category : 'CMark-Roassal-Tests-Tests',
	#package : 'CMark-Roassal-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkRoassalInteractionTest >> linkDocument [
	"A paragraph whose link holds text, a code span and an image"

	| link |
	link := (CMarkLink url: 'https://example.org/page' title: '') addAll: {
			        (self text: 'linked words ').
			        (self code: 'code here').
			        ((CMarkImage url: 'missing.png' title: '') addAll: { (self text: 'alt') }; yourself) }; yourself.
	^ self document: { (self paragraph: { (self text: 'before '). link. (self text: ' after') }) }
]

{ #category : 'helpers' }
CMarkRoassalInteractionTest >> subscribersOf: aShape [
	^ (aShape announcer subscriptions subscriptions collect: [ :each | each subscriber ]) asIdentitySet
]

{ #category : 'tests' }
CMarkRoassalInteractionTest >> testFootnotePopupKeepsTheParagraphsApart [
	| definition reference |
	definition := CMarkFootnoteDefinition label: 'n'.
	definition addChild: (self paragraph: { (self text: 'The first paragraph.') }).
	definition addChild: (self paragraph: { (self text: 'The second one.') }).
	definition addChild: (CMarkCodeBlock literal: 'x := 1.' , String lf info: 'smalltalk').
	reference := CMarkFootnoteReference new.
	definition addReference: reference.
	self assert: reference cmarkRoassalPopupText equals: 'The first paragraph. The second one. x := 1.'
]

{ #category : 'tests' }
CMarkRoassalInteractionTest >> testLinkAction [
	| doc theme followed shape link |
	followed := OrderedCollection new.
	theme := CMarkRoassalTheme default
		         linkAction: [ :url | followed add: url ];
		         yourself.
	doc := self linkDocument.
	shape := self render: doc theme: theme.
	link := (self labelsOf: shape) detect: [ :each | each key text = 'linked words' ].
	link key announce: (RSMouseLeftClick new
			 shape: link key;
			 yourself).
	self assert: followed asArray equals: #( 'https://example.org/page' )
]

{ #category : 'tests' }
CMarkRoassalInteractionTest >> testNoSenderOfWhenDo [
	| package |
	package := (Smalltalk globals at: #PackageOrganizer ifAbsent: [ Smalltalk globals at: #RPackageOrganizer ]) default packageNamed: 'CMark-Roassal'.
	self assert: package methods notEmpty.
	package methods do: [ :each | self deny: (each sendsSelector: #when:do:) description: each printString ]
]

{ #category : 'tests' }
CMarkRoassalInteractionTest >> testPackageStaysClean [
	"Rendering and clicking a link do not change the methods of CMark-Roassal (the deprecated when:do: would rewrite them)"

	| package before |
	package := (Smalltalk globals at: #PackageOrganizer ifAbsent: [ Smalltalk globals at: #RPackageOrganizer ]) default packageNamed: 'CMark-Roassal'.
	before := package methods collect: [ :each | each -> each sourceCode ].
	self testLinkAction.
	self testSharedPopupOnEveryPieceOfALink.
	before do: [ :each | self assert: each key sourceCode equals: each value ].
	self assert: (package methods collect: [ :each | each sourceCode ]) asSet equals: (before collect: [ :each | each value ]) asSet
]

{ #category : 'tests' }
CMarkRoassalInteractionTest >> testPopupTexts [
	| link image reference definition |
	link := (CMarkLink url: 'https://x.y' title: '') addAll: { (self text: 't') }; yourself.
	self assert: link children first cmarkRoassalPopupText equals: 'https://x.y'.
	image := CMarkImage url: 'pic.png' title: ''.
	self assert: image cmarkRoassalPopupText equals: 'pic.png'.
	link addChild: image.
	self assert: image cmarkRoassalPopupText equals: 'https://x.y'.
	definition := CMarkFootnoteDefinition label: 'n'.
	definition addChild: (self paragraph: { (self text: 'the note') }).
	reference := CMarkFootnoteReference new.
	definition addReference: reference.
	self assert: reference cmarkRoassalPopupText equals: 'the note'.
	self assert: (self text: 'plain') cmarkRoassalPopupText equals: ''
]

{ #category : 'tests' }
CMarkRoassalInteractionTest >> testSharedPopupOnEveryPieceOfALink [
	| doc shape pieces popup plain |
	doc := self linkDocument.
	shape := self render: doc.
	popup := renderer popup.
	self assert: popup class identicalTo: RSPopup.
	pieces := OrderedCollection new.
	self walk: shape do: [ :each :rect :depth | (each model notNil and: [ each model enclosingLink notNil ]) ifTrue: [ pieces add: each ] ].
	"two labels (words, code), the chip box, the placeholder of the image and its label and box"
	self assert: (pieces count: [ :each | each isLabel ]) >= 2.
	self assert: (pieces anySatisfy: [ :each | each class == RSBox and: [ each model isKindOf: CMarkCode ] ]).
	pieces
		select: [ :each | (each isLabel and: [ (each model isKindOf: CMarkImage) not ]) or: [ (each model isKindOf: CMarkCode) or: [ each isComposite ] ] ]
		thenDo: [ :each |
			| subscribers |
			subscribers := self subscribersOf: each.
			self assert: (subscribers includes: popup) description: each printString.
			self assert: (subscribers includes: renderer) description: each printString ].
	plain := (self labelsOf: shape) detect: [ :each | each key text = 'before' ].
	self deny: ((self subscribersOf: plain key) includes: popup)
]
