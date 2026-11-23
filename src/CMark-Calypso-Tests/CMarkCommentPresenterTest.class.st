"
I test CMarkCommentPresenter: the canvas of a class comment (the CMark shape, the camera of canvasFor:, long lines that wrap, Smalltalk code that keeps its text), the theme (dark or light UI theme, set or followed, a change of the UI theme), the notes of an empty comment, of a VM without the plugin and of a comment cmark refuses, drawing again when the comment or the class changes, the drawing in the Morphic UI process only when another process asks for it (once for all that wait), the window title, the keyboard focus, and the weak subscription to the changes of comments, which ends when the window closes.
"
Class {
	#name : 'CMarkCommentPresenterTest',
	#superclass : 'CMarkCalypsoTestCase',
	#category : 'CMark-Calypso-Tests-Tests',
	#package : 'CMark-Calypso-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkCommentPresenterTest >> noteOf: aPresenter [
	"The text of the note that aPresenter draws, and checks that it is drawn in the muted colour of the theme"

	| labels |
	labels := self labelsOf: aPresenter shape.
	self deny: labels isEmpty.
	labels do: [ :each | self assert: each key color equals: aPresenter markdownTheme mutedColor ].
	self assert: (aPresenter shape model isKindOf: CMarkDocument).
	^ aPresenter shape model plainText
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testBuiltPresenterShowsTheCanvas [
	| presenter morph |
	self requireCanvas.
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: 'Some *text*').
	morph := presenter build.
	self assert: (morph isKindOf: Morph).
	self assert: presenter roassal adapter notNil.
	self assert: presenter roassal currentCanvas shapes size equals: 1.
	self assert: presenter roassal currentCanvas shapes first identicalTo: presenter shape.
	self assert: presenter canvas identicalTo: presenter roassal currentCanvas
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testCameraFitsTheWidthAndShowsTheTop [
	| presenter canvas topLeft topRight |
	self requireCanvas.
	self requirePlugin.
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: self richComment).
	canvas := presenter canvas.
	canvas extent: 500 @ 300.
	topLeft := canvas camera fromSpaceToPixel: presenter shape encompassingRectangle topLeft.
	topRight := canvas camera fromSpaceToPixel: presenter shape encompassingRectangle topRight.
	self assert: topLeft x abs < 1.
	self assert: topLeft y abs < 1.
	self assert: (topRight x - 500) abs < 1.
	self assert: canvas controllerInteraction notNil
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testDrawsAgainForAnotherClass [
	| presenter other |
	self requireCanvas.
	self requirePlugin.
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: '# First').
	other := self scratchClass: #CMarkCalypsoScratchB comment: '# Second'.
	presenter build.
	presenter targetClass: other.
	self assert: presenter targetClass identicalTo: other.
	self assert: presenter shape model headings first plainText equals: 'Second'.
	self assert: presenter roassal currentCanvas shapes first identicalTo: presenter shape
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testAnotherProcessChangingTheCommentDrawsInTheUIProcess [
	"The comment changed and announced by other processes (a load in the background) while the UI process draws the window: only the UI process draws the canvas, nothing fails, and the last comment is shown once the UI process ran the work deferred to it.  Drawn by the announcing process, the canvas raced with the drawing of the world (MessageNotUnderstood: receiver of #intersect: is nil, in RSMorphicHost>>dirtyRectangle:)"

	| uiProcess aClass presenter window errors finished deadline |
	self requireCanvas.
	self requirePlugin.
	self requireUIProcess.
	uiProcess := Processor activeProcess.
	aClass := self scratchClass: #CMarkCalypsoScratchA comment: '# Comment 0'.
	presenter := self recordingPresenterOn: aClass.
	window := presenter open.
	[
	errors := OrderedCollection new.
	finished := 0.
	"above the priority of the UI process: each takes the processor from it when its delay ends, in the middle of a drawing too"
	{
		[
		1 to: 20 do: [ :index |
			aClass comment: '# Comment ' , index printString.
			(Delay forMilliseconds: 2) wait ] ].
		[
		1 to: 40 do: [ :index |
			SystemAnnouncer uniqueInstance classCommented: aClass.
			(Delay forMilliseconds: 1) wait ] ] } do: [ :each |
		[
		[ each value ]
			on: Error
			do: [ :error | errors add: error ].
		finished := finished + 1 ] forkAt: Processor userSchedulingPriority + 1 ].
	"meanwhile the UI process draws the window (imageForm: the world of a headless image draws nothing) and runs the work deferred to it"
	deadline := Time millisecondClockValue + 60000.
	[ finished < 2 and: [ Time millisecondClockValue < deadline ] ] whileTrue: [
		window window
			changed;
			imageForm.
		self runUICycle ].
	self assert: finished equals: 2.
	self assert: errors asArray equals: #(  ).
	self runUICycle.
	self deny: presenter isRefreshPending.
	self deny: presenter drawingProcesses isEmpty.
	self assert: (presenter drawingProcesses reject: [ :each | each == uiProcess ]) asArray equals: #(  ).
	self assert: presenter shape model headings first plainText equals: 'Comment 20'.
	self assert: presenter roassal currentCanvas shapes first identicalTo: presenter shape.
	self deny: (window window allMorphs anySatisfy: [ :each | each hasProperty: #errorOnDraw ]) ] ensure: [ window close ]
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testRefreshesFromAnotherProcessAreDrawnOnce [
	"The refreshes that another process asks while the UI process is busy wait for it and are drawn once, at its next cycle: ten changes of the comment, a change of the UI theme, a theme set and unset, another class (each way to draw again)"

	| first other presenter drawings done errors |
	self requireCanvas.
	self requirePlugin.
	self requireUIProcess.
	first := self scratchClass: #CMarkCalypsoScratchA comment: '# Comment 0'.
	other := self scratchClass: #CMarkCalypsoScratchB comment: '# Other'.
	presenter := self recordingPresenterOn: first.
	presenter build.
	drawings := presenter drawingProcesses size.
	self deny: presenter isRefreshPending.
	done := Semaphore new.
	errors := OrderedCollection new.
	[
	[
	1 to: 10 do: [ :index | first comment: '# Comment ' , index printString ].
	presenter uiThemeChanged.
	presenter markdownTheme: CMarkRoassalTheme dark.
	presenter targetClass: other.
	presenter markdownTheme: nil ]
		on: Error
		do: [ :error | errors add: error ].
	done signal ] fork.
	"this test runs in the UI process: it waits, and runs no deferred work meanwhile"
	self deny: (done waitTimeoutSeconds: 60).
	self assert: errors asArray equals: #(  ).
	self assert: presenter drawingProcesses size equals: drawings.
	self assert: presenter isRefreshPending.
	self assert: presenter targetClass identicalTo: other.
	self assert: presenter shape model headings first plainText equals: 'Comment 0'.
	self runUICycle.
	self assert: presenter drawingProcesses size equals: drawings + 1.
	self deny: presenter isRefreshPending.
	self assert: presenter shape model headings first plainText equals: 'Other'.
	self assert: presenter roassal currentCanvas shapes first identicalTo: presenter shape.
	self assert: presenter roassal currentCanvas color equals: presenter markdownTheme background
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testRefreshInTheUIProcessIsDrawnAtOnce [
	"In the UI process a refresh draws at once, and a refresh that waited for the UI process then draws nothing more"

	| presenter drawings done |
	self requireCanvas.
	self requireUIProcess.
	presenter := self recordingPresenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: 'text').
	presenter build.
	drawings := presenter drawingProcesses size.
	presenter refresh.
	self assert: presenter drawingProcesses size equals: drawings + 1.
	done := Semaphore new.
	[
	presenter refresh.
	done signal ] fork.
	self deny: (done waitTimeoutSeconds: 60).
	self assert: presenter isRefreshPending.
	self assert: presenter drawingProcesses size equals: drawings + 1.
	presenter refresh.
	self deny: presenter isRefreshPending.
	self assert: presenter drawingProcesses size equals: drawings + 2.
	self runUICycle.
	self assert: presenter drawingProcesses size equals: drawings + 2.
	self assert: (presenter drawingProcesses allSatisfy: [ :each | each == Processor activeProcess ])
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testDrawsAgainWhenTheCommentChanges [
	| aClass built unbuilt first |
	self requireCanvas.
	self requirePlugin.
	aClass := self scratchClass: #CMarkCalypsoScratchA comment: '# Before'.
	built := self presenterOn: aClass.
	built build.
	unbuilt := self presenterOn: aClass.
	unbuilt canvas.
	first := built shape.
	self assert: first model headings first plainText equals: 'Before'.
	aClass comment: '# After'.
	self deny: built shape identicalTo: first.
	self assert: built shape model headings first plainText equals: 'After'.
	self assert: built roassal currentCanvas shapes first identicalTo: built shape.
	self assert: unbuilt canvas shapes first model headings first plainText equals: 'After'
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testEmptyCommentNote [
	| presenter |
	self requireCanvas.
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA).
	self assert: presenter contents equals: presenter emptyNote.
	presenter canvas.
	self assert: (self noteOf: presenter) equals: presenter emptyNote.
	presenter targetClass: (self scratchClass: #CMarkCalypsoScratchB comment: '  ' , String lf , '  ').
	self assert: presenter contents equals: presenter emptyNote
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testFocusComesWithAClickNotWithThePointer [
	"The pointer passing over the canvas leaves the keyboard focus where it is (the lists of the browser); a click gives it to the canvas, for the keys of the canvas controller"

	| presenter window morph hand |
	self requireCanvas.
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: 'text').
	window := presenter open.
	[
	morph := presenter roassal adapter widget.
	hand := self currentHand.
	hand newKeyboardFocus: window window.
	morph handleMouseEnter: (MouseEvent new
			 setType: #mouseEnter
			 position: morph center
			 buttons: 0
			 hand: hand).
	self deny: hand keyboardFocus identicalTo: morph.
	morph mouseDown: (MouseButtonEvent new
			 setType: #mouseDown
			 position: morph center
			 which: MouseButtonEvent redButton
			 buttons: MouseButtonEvent redButton
			 hand: hand
			 stamp: Time millisecondClockValue).
	self assert: hand keyboardFocus identicalTo: morph ] ensure: [
		hand ifNotNil: [ hand releaseKeyboardFocus ].
		window close ]
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testHasCommentToShow [
	| nbsp |
	nbsp := String new: 3 withAll: (Character value: 160).
	self deny: (CMarkCommentPresenter hasCommentToShow: nil).
	self deny: (CMarkCommentPresenter hasCommentToShow: (self scratchClass: #CMarkCalypsoScratchA)).
	self deny: (CMarkCommentPresenter hasCommentToShow: (self scratchClass: #CMarkCalypsoScratchB comment: nbsp)).
	(scratchClasses last) comment: (String withAll: ((#( 16r2003 16r200B 16r202F 16r3000 16rFEFF 9 10 13 32 ) collect: [ :each | Character value: each ]))).
	self deny: (CMarkCommentPresenter hasCommentToShow: scratchClasses last).
	scratchClasses last comment: nbsp , 'x'.
	self assert: (CMarkCommentPresenter hasCommentToShow: scratchClasses last).
	self assert: (CMarkCommentPresenter hasCommentToShow: scratchClasses last class).
	"a removed class shows nothing"
	scratchClasses last removeFromSystem.
	self assert: scratchClasses last isObsolete.
	self assert: (CMarkCommentPresenter commentOf: scratchClasses last) equals: ''.
	self deny: (CMarkCommentPresenter hasCommentToShow: scratchClasses last)
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testIgnoresTheCommentsOfOtherClasses [
	| presenter other first |
	self requireCanvas.
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: '# Mine').
	other := self scratchClass: #CMarkCalypsoScratchB.
	presenter build.
	first := presenter shape.
	other comment: '# Not mine'.
	self assert: presenter shape identicalTo: first
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testLongLinesWrap [
	"A long code line (a tab-indented line of Smalltalk is a code block) and a long word wrap: the page keeps the width of the theme, so that the camera, which fits the width, keeps the text readable"

	| presenter width canvas theme |
	self requireCanvas.
	self requirePlugin.
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: 'Some text.

	' , (String new: 600 withAll: $x) , '

A word: ' , (String new: 400 withAll: $y) , '.
').
	self assert: presenter markdownTheme codeWrap equals: #characters.
	self assert: presenter markdownTheme breakLongWords.
	theme := presenter markdownTheme.
	canvas := presenter canvas.
	width := presenter shape encompassingRectangle width.
	"the page: the column and its padding on both sides"
	self assert: width <= (theme maxWidth + (2 * theme padding) + 1).
	canvas extent: 1000 @ 800.
	self assert: canvas camera scale >= (1000 / (theme maxWidth + (2 * theme padding) + 1)).
	"a theme set is used as it is"
	presenter markdownTheme: CMarkRoassalTheme default.
	self assert: presenter markdownTheme codeWrap equals: #none
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testMetaclassShowsTheComment [
	| aClass presenter |
	aClass := self scratchClass: #CMarkCalypsoScratchA comment: '# Class side'.
	presenter := self presenterOn: aClass class.
	self assert: presenter comment equals: '# Class side'.
	self assert: (CMarkCommentPresenter hasCommentToShow: aClass class).
	self assert: presenter windowTitle equals: 'Comment of CMarkCalypsoScratchA'
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testNoPluginNote [
	| presenter |
	self requireCanvas.
	CMarkPrimitives testHook: #pluginMissing value: true.
	self deny: CMark isAvailable.
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: self richComment).
	self assert: presenter contents equals: presenter noPluginNote.
	presenter build.
	self assert: (self noteOf: presenter) equals: presenter noPluginNote
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testRefusedCommentNote [
	"A comment that cmark refuses (deeper than the plugin's limit of 1000) shows a muted note, not an error in the Roassal script"

	| presenter note |
	self requireCanvas.
	self requirePlugin.
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: (String new: 1500 withAll: $>)).
	note := presenter contents.
	self assert: note isString.
	self assert: (note beginsWith: 'The comment cannot be shown as Markdown: ').
	presenter canvas.
	self assert: (self noteOf: presenter) equals: note
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testRendersTheComment [
	| aClass presenter canvas document |
	self requireCanvas.
	self requirePlugin.
	aClass := self scratchClass: #CMarkCalypsoScratchA comment: self richComment.
	presenter := self presenterOn: aClass.
	canvas := presenter canvas.
	self assert: canvas shapes size equals: 1.
	self assert: canvas shapes first identicalTo: presenter shape.
	document := presenter shape model.
	self assert: (document isKindOf: CMarkDocument).
	self assert: document sourceString equals: aClass comment.
	self assert: document headings first plainText equals: 'Rendering'.
	self assert: (document detect: [ :each | each isKindOf: CMarkTable ] ifNone: [ nil ]) notNil.
	self assert: (document detect: [ :each | each isKindOf: CMarkCodeBlock ] ifNone: [ nil ]) notNil.
	self assert: ((self labelsOf: presenter shape) anySatisfy: [ :each | each key text = 'Rendering' ])
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testSmalltalkCodeKeepsItsText [
	"Footnotes are off: with them, cmark-gfm 0.29.0.gfm.14 takes [^... for a footnote label and drops the text of a label that holds an inline or a line break (the comment of GZipConstants in Pharo 12 lost 'is not part of RFC1952')"

	| presenter text |
	self requireCanvas.
	self requirePlugin.
	self assert: CMarkCommentPresenter options equals: CMarkOptions gfm.
	self deny: CMarkCommentPresenter options footnotes.
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: 'amending the text as follows..
    ifTrue:[^self error:''Cannot decompress encrypted stream. Encryption
is not part of RFC1952''].

Then [^self error: ''a <b>c''] and more text here.

[^x]: not a footnote
').
	presenter canvas.
	text := presenter shape model plainText.
	self assert: (text includesSubstring: 'Encryption is not part of RFC1952').
	self assert: (text includesSubstring: '''a <b>c''] and more text here.').
	self assert: (text includesSubstring: '[^x]: not a footnote').
	self assert: presenter shape model footnoteDefinitions isEmpty
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testDrawsAgainWhenTheUIThemeChanges [
	"An open presenter follows a change of the UI theme of Pharo (UITheme current:, as the Settings do), unless it has a theme of its own"

	| previous following fixed windows |
	self requireCanvas.
	previous := Smalltalk ui theme.
	windows := OrderedCollection new.
	[
	UITheme current: PharoLightTheme new.
	following := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: 'text').
	fixed := self presenterOn: (self scratchClass: #CMarkCalypsoScratchB comment: 'text').
	fixed markdownTheme: CMarkRoassalTheme default.
	windows add: following open; add: fixed open.
	self assert: following canvas color equals: CMarkRoassalTheme default background.
	UITheme current: PharoDarkTheme new.
	self assert: following canvas color equals: CMarkRoassalTheme dark background.
	self assert: fixed canvas color equals: CMarkRoassalTheme default background.
	UITheme current: PharoLightTheme new.
	self assert: following canvas color equals: CMarkRoassalTheme default background ] ensure: [
		windows do: [ :each | each close ].
		UITheme current: previous ]
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testIsDarkTheme [
	self assert: (CMarkCommentPresenter isDarkTheme: PharoDarkTheme new).
	self deny: (CMarkCommentPresenter isDarkTheme: PharoLightTheme new).
	self deny: (CMarkCommentPresenter isDarkTheme: nil).
	self assert: CMarkCommentPresenter isDarkUITheme equals: (CMarkCommentPresenter isDarkTheme: Smalltalk ui theme)
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testSubscriptionIsWeak [
	"A presenter that nobody holds is not kept by its subscription to ClassCommented"

	| aClass mine |
	aClass := self scratchClass: #CMarkCalypsoScratchA comment: 'text'.
	mine := [ self subscribersOfClassCommented select: [ :each | each class == CMarkCommentPresenter and: [ each targetClass == aClass ] ] ].
	[
	CMarkCommentPresenter on: aClass.
	self assert: mine value size equals: 1.
	Smalltalk garbageCollect.
	self assert: mine value isEmpty ] ensure: [ mine value do: [ :each | each unsubscribe ] ]
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testThemeFollowsTheUITheme [
	"markdownTheme: draws again with the theme given; nil follows the UI theme"

	| presenter |
	self requireCanvas.
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: 'text').
	presenter canvas.
	presenter markdownTheme: CMarkRoassalTheme dark.
	self assert: presenter canvas color equals: CMarkRoassalTheme dark background.
	presenter markdownTheme: CMarkRoassalTheme default.
	self assert: presenter canvas color equals: CMarkRoassalTheme default background.
	presenter markdownTheme: nil.
	self
		assert: presenter canvas color
		equals: (CMarkCommentPresenter isDarkUITheme
				 ifTrue: [ CMarkRoassalTheme dark background ]
				 ifFalse: [ CMarkRoassalTheme default background ])
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testTitleFollowsTheClass [
	| presenter window |
	self requireCanvas.
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: 'one').
	window := presenter open.
	[
	self assert: window title equals: 'Comment of CMarkCalypsoScratchA'.
	presenter targetClass: (self scratchClass: #CMarkCalypsoScratchB comment: 'two').
	self assert: window title equals: 'Comment of CMarkCalypsoScratchB'.
	presenter targetClass: nil.
	self assert: window title equals: 'Comment' ] ensure: [ window close ]
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testUnsubscribe [
	| presenter |
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: 'text').
	self assert: presenter isSubscribed.
	self assert: (self subscribersOfClassCommented includes: presenter).
	presenter unsubscribe.
	self deny: presenter isSubscribed.
	self deny: (self subscribersOfClassCommented includes: presenter)
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testUnsubscribesWhenItsWindowCloses [
	| presenter window |
	self requireCanvas.
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: 'text').
	window := presenter open.
	[
	self assert: window title equals: 'Comment of CMarkCalypsoScratchA'.
	self assert: presenter isSubscribed ] ensure: [ window close ].
	self deny: presenter isSubscribed.
	self deny: (self subscribersOfClassCommented includes: presenter)
]
