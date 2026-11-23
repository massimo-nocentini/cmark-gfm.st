"
I am the abstract test of the Markdown tab of Calypso.

My tests make scratch classes (`scratchClass:`, in the package `CMark-Calypso-Tests-Scratch`, removed with it by `tearDown`) whose comments they set and change, so that no class of the image is touched; the presenters they make are unsubscribed by `tearDown`, and the browsers closed.

The tests run in the Morphic UI process (`runCase`, `inUIProcess:`), one after the other with the work that the browsers and windows defer to it. My helpers for that:

- `requireUIProcess` skips a test that needs it,
- `runUICycle` runs that work (one cycle of the world) within a test, and
- `recordingPresenterOn:` makes a presenter that records the process of each of its drawings.

`richComment` is a comment with a heading, a list, a code block and a table.
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
CMarkCalypsoTestCase >> browserOnPackage: aPackage [
	"A full Calypso browser on aPackage, no class selected, as browserOn:"

	| browser |
	browser := ClyFullBrowserMorph on: ClyNavigationEnvironment currentImage.
	browsers add: browser.
	browser prepareInitialStateBy: [ :each | each selectPackage: aPackage ].
	browser ensureInitialState.
	^ browser
]

{ #category : 'running' }
CMarkCalypsoTestCase >> inUIProcess: aBlock [
	"Run aBlock in the Morphic UI process and answer its value.  The browsers and windows of the tests defer work to the UI process (a Calypso view with an empty selection defers ensureVisibleLastItem, which rebuilds the tabs) and the UI process draws the windows that the tests open: run from the test's process, a test raced with that work and failed now and then.  In the UI process the deferred work runs after the block, and before the next block deferred.  Its failures, errors and skips are signalled again in the test's process.  Without a UI process, or when it is the active one, aBlock runs here"

	| uiProcess done state caught value |
	uiProcess := MorphicUIManager uiProcess.
	(uiProcess isNil or: [ uiProcess == Processor activeProcess or: [ uiProcess isTerminated ] ]) ifTrue: [ ^ aBlock value ].
	done := Semaphore new.
	state := #waiting.
	self currentWorld defer: [
		state == #waiting ifTrue: [
			state := #running.
			[
			[ value := aBlock value ]
				on: Error , TestFailure , TestSkipped
				do: [ :exception | caught := exception. exception return: nil ] ] ensure: [ done signal ] ] ].
	(done waitTimeoutSeconds: 120) ifTrue: [
		state == #waiting ifFalse: [ ^ self fail: 'the UI process did not end the test within 120 seconds' ].
		"no world loop runs the deferred blocks"
		state := #cancelled.
		^ aBlock value ].
	caught ifNil: [ ^ value ].
	(caught isKindOf: TestSkipped) ifTrue: [ ^ self skip: caught messageText ].
	(caught isKindOf: TestFailure) ifTrue: [ ^ self fail: caught messageText ].
	^ self error: 'in the UI process: ' , caught class name , ': ' , caught messageText asString
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

{ #category : 'running' }
CMarkCalypsoTestCase >> runCase [
	"setUp, the test and tearDown in the UI process, as the browsers and windows that the test makes (inUIProcess:); the next test, deferred to the UI process too, starts once the work that this one deferred is done"

	self inUIProcess: [ super runCase ]
]

{ #category : 'helpers' }
CMarkCalypsoTestCase >> presenterOn: aClass [
	"A CMarkCommentPresenter on aClass, unsubscribed by tearDown"

	^ presenters add: (CMarkCommentPresenter on: aClass)
]

{ #category : 'helpers' }
CMarkCalypsoTestCase >> recordingPresenterOn: aClass [
	"A CMarkRecordingCommentPresenter on aClass (it records the process of each drawing), unsubscribed by tearDown"

	^ presenters add: (CMarkRecordingCommentPresenter on: aClass)
]

{ #category : 'helpers' }
CMarkCalypsoTestCase >> requireUIProcess [
	"Skip unless the test runs in the Morphic UI process (runCase), the process that runs the work deferred to it"

	MorphicUIManager uiProcess == Processor activeProcess ifFalse: [
		self skip: 'the test does not run in the Morphic UI process: no world loop runs the work deferred to it' ]
]

{ #category : 'helpers' }
CMarkCalypsoTestCase >> runUICycle [
	"One cycle of the world, here in the UI process: the work deferred to the UI process runs, and the world is drawn"

	self currentWorld doOneCycleNow
]

{ #category : 'fixtures' }
CMarkCalypsoTestCase >> richComment [
	^ '# Rendering

A comment drawn by **cmark-gfm**.

- a list item
- another, with `code`

```smalltalk
(CMarkCommentPresenter on: Object) open
```

| Column | Value |
|:-------|------:|
| one    | 1     |
| two    | 2     |
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
		"a scratch class that a test removed is named AnObsolete..."
		(name beginsWith: 'AnObsolete') ifTrue: [ name := (name allButFirst: 'AnObsolete' size) asSymbol ].
		each isObsolete ifFalse: [ each removeFromSystem ].
		"removing a class leaves its binding in Undeclared; nothing refers to a scratch class by name"
		Undeclared removeKey: name ifAbsent: [ nil ] ].
	(PackageOrganizer default packageNamed: self scratchPackageName ifAbsent: [ nil ]) ifNotNil: [ :package | package removeFromSystem ].
	super tearDown
]
