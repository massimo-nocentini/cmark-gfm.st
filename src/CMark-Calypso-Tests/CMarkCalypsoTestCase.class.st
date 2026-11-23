"
I am the abstract test of the Markdown tab of Calypso.  My tests make scratch classes (scratchClass:, in the package CMark-Calypso-Tests-Scratch, removed with it by tearDown) whose comments they set and change, so that no class of the image is touched; the presenters they make are unsubscribed by tearDown, and the browsers closed.

richComment is a comment with a heading, a list, a code block, a table and a footnote.
"
Class {
	#name : 'CMarkCalypsoTestCase',
	#superclass : 'CMarkRoassalTestCase',
	#instVars : [
		'scratchClasses',
		'presenters',
		'browsers'
	],
	#category : 'CMark-Calypso-Tests-Support',
	#package : 'CMark-Calypso-Tests',
	#tag : 'Support'
}

{ #category : 'testing' }
CMarkCalypsoTestCase class >> isAbstract [
	^ self == CMarkCalypsoTestCase
]

{ #category : 'helpers' }
CMarkCalypsoTestCase >> browserOn: aClass [
	"A full Calypso browser on aClass, built as when it opens but in no window (so that the UI process does not draw it while the test changes it), closed by tearDown"

	| browser |
	browser := ClyFullBrowserMorph on: ClyNavigationEnvironment currentImage.
	browsers add: browser.
	browser prepareInitialStateBy: [ :each | each selectClass: aClass ].
	browser ensureInitialState.
	^ browser
]

{ #category : 'helpers' }
CMarkCalypsoTestCase >> markdownToolOf: aBrowser [
	"The Markdown tab of aBrowser, or nil"

	^ aBrowser tabManager tools
		  detect: [ :each | each class == CMarkClassCommentToolMorph ]
		  ifNone: [ nil ]
]

{ #category : 'helpers' }
CMarkCalypsoTestCase >> markdownToolsOf: aBrowser [
	"All the Markdown tabs of aBrowser (there must be one at most)"

	^ (aBrowser tabManager tools select: [ :each | each class == CMarkClassCommentToolMorph ]) asArray
]

{ #category : 'helpers' }
CMarkCalypsoTestCase >> presenterOn: aClass [
	"A CMarkCommentPresenter on aClass, unsubscribed by tearDown"

	^ presenters add: (CMarkCommentPresenter on: aClass)
]

{ #category : 'fixtures' }
CMarkCalypsoTestCase >> richComment [
	^ '# Rendering

A comment drawn by **cmark-gfm**, with a footnote[^1].

- a list item
- another, with `code`

```smalltalk
(CMarkCommentPresenter on: Object) open
```

| Column | Value |
|:-------|------:|
| one    | 1     |
| two    | 2     |

[^1]: The footnote.
'
]

{ #category : 'helpers' }
CMarkCalypsoTestCase >> scratchClass: aSymbol [
	"A new class named aSymbol (a subclass of Object, no comment) in the package CMark-Calypso-Tests-Scratch, removed by tearDown"

	| aClass |
	Smalltalk globals at: aSymbol ifPresent: [ :old | old removeFromSystem ].
	aClass := Smalltalk classInstaller make: [ :builder |
		          builder
			          name: aSymbol;
			          superclass: Object;
			          package: self scratchPackageName ].
	scratchClasses add: aClass.
	^ aClass
]

{ #category : 'helpers' }
CMarkCalypsoTestCase >> scratchClass: aSymbol comment: aString [
	^ (self scratchClass: aSymbol)
		  comment: aString;
		  yourself
]

{ #category : 'helpers' }
CMarkCalypsoTestCase >> scratchPackageName [
	^ 'CMark-Calypso-Tests-Scratch'
]

{ #category : 'running' }
CMarkCalypsoTestCase >> setUp [
	super setUp.
	scratchClasses := OrderedCollection new.
	presenters := OrderedCollection new.
	browsers := OrderedCollection new
]

{ #category : 'helpers' }
CMarkCalypsoTestCase >> subscribersOfClassCommented [
	"The subscribers of the SystemAnnouncer to ClassCommented"

	| announcement subscribers |
	announcement := ClassCommented new.
	subscribers := OrderedCollection new.
	SystemAnnouncer uniqueInstance subscriptions subscriptions do: [ :each |
		(each handlesAnnouncement: announcement) ifTrue: [ subscribers add: each subscriber ] ].
	^ subscribers
]

{ #category : 'running' }
CMarkCalypsoTestCase >> tearDown [
	browsers do: [ :each | each windowIsClosing ].
	presenters do: [ :each | each unsubscribe ].
	scratchClasses do: [ :each |
		| name |
		name := each name.
		each isObsolete ifFalse: [ each removeFromSystem ].
		"removing a class leaves its binding in Undeclared; nothing refers to a scratch class by name"
		Undeclared removeKey: name ifAbsent: [ nil ] ].
	(PackageOrganizer default packageNamed: self scratchPackageName ifAbsent: [ nil ]) ifNotNil: [ :package | package removeFromSystem ].
	super tearDown
]
