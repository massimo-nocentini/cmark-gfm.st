"
I test CMarkCommentPresenter: the canvas of a class comment (the CMark shape, the camera of canvasFor:, the theme), the notes of an empty comment and of a VM without the plugin, drawing again when the comment or the class changes, and the subscription to the changes of comments, which ends when the window closes.
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
	self assert: (CMarkCommentPresenter hasCommentToShow: scratchClasses last class)
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
	"footnotes are on"
	self assert: document footnoteDefinitions size equals: 1.
	self assert: ((self labelsOf: presenter shape) anySatisfy: [ :each | each key text = 'Rendering' ])
]

{ #category : 'tests' }
CMarkCommentPresenterTest >> testThemeFollowsTheUITheme [
	| presenter expected |
	self requireCanvas.
	presenter := self presenterOn: (self scratchClass: #CMarkCalypsoScratchA comment: 'text').
	expected := CMarkCommentPresenter isDarkUITheme
		            ifTrue: [ CMarkRoassalTheme dark ]
		            ifFalse: [ CMarkRoassalTheme default ].
	self assert: presenter markdownTheme background equals: expected background.
	self assert: presenter markdownTheme textColor equals: expected textColor.
	presenter markdownTheme: CMarkRoassalTheme dark.
	self assert: presenter canvas color equals: CMarkRoassalTheme dark background.
	presenter markdownTheme: nil.
	self assert: presenter markdownTheme textColor equals: expected textColor
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
