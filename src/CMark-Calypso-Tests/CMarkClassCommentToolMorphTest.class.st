"
I test CMarkClassCommentToolMorph, the Markdown tab of Calypso: its title, icon, tabOrder (strictly after the Comment tab of Calypso and before the UML-Class tab of Roassal) and activationPriority, and, in a real ClyFullBrowserMorph on a scratch class, that the tab is there only for a commented class, between Comment and UML-Class (when Roassal-UML-Calypso is loaded), not selected by default, that it draws the comment, and that its presenter stops listening when the tab is removed or the browser closes.
"
Class {
	#name : 'CMarkClassCommentToolMorphTest',
	#superclass : 'CMarkCalypsoTestCase',
	#category : 'CMark-Calypso-Tests-Tests',
	#package : 'CMark-Calypso-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkClassCommentToolMorphTest >> commentToolClass [
	"The Comment tab of the Calypso of this image"

	^ Smalltalk globals
		  at: #ClyRichTextClassCommentEditorToolMorph
		  ifAbsent: [ Smalltalk globals at: #ClyClassCommentEditorToolMorph ]
]

{ #category : 'helpers' }
CMarkClassCommentToolMorphTest >> show: aTool in: aBrowser [
	"Select the tab of aTool, which builds it (Calypso builds a tab when it is shown)"

	aBrowser tabManager tabMorph page: aTool containerTab.
	self assert: aTool presenter notNil
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testActivationPriorityLeavesTheDefaultSelection [
	| priority |
	priority := CMarkClassCommentToolMorph new activationPriority.
	self assert: priority < self commentToolClass new activationPriority.
	self assert: priority < ClyClassDefinitionEditorToolMorph new activationPriority.
	Smalltalk globals at: #RSUMLClassCalypso ifPresent: [ :uml | self assert: priority <= uml new activationPriority ]
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testActivationStrategy [
	| annotation |
	annotation := CMarkClassCommentToolMorph classMarkdownTabActivation.
	self assert: (annotation isKindOf: ClyTabActivationStrategyAnnotation).
	self assert: (CMarkClassCommentToolMorph classSide includesSelector: #shouldBeActivatedInContext:)
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testBrowserClosingUnsubscribesThePresenter [
	| browser tool presenter |
	self requireCanvas.
	browser := self browserOn: (self scratchClass: #CMarkCalypsoScratchA comment: self richComment).
	tool := self markdownToolOf: browser.
	self show: tool in: browser.
	presenter := tool presenter.
	self assert: presenter isSubscribed.
	browser windowIsClosing.
	self deny: presenter isSubscribed.
	self deny: (self subscribersOfClassCommented includes: presenter)
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testBrowserDrawsTheComment [
	| aClass browser tool |
	self requireCanvas.
	self requirePlugin.
	aClass := self scratchClass: #CMarkCalypsoScratchA comment: self richComment.
	browser := self browserOn: aClass.
	tool := self markdownToolOf: browser.
	self assert: tool targetClass identicalTo: aClass.
	self show: tool in: browser.
	self assert: tool presenter targetClass identicalTo: aClass.
	self assert: tool presenter shape model sourceString equals: aClass comment.
	self assert: (tool allMorphs includes: tool presenter roassal adapter widget).
	aClass comment: '# Changed'.
	self assert: tool presenter shape model headings first plainText equals: 'Changed'
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testBrowserHasNoTabForAnUncommentedClass [
	| browser |
	browser := self browserOn: (self scratchClass: #CMarkCalypsoScratchA).
	self assert: (browser tabManager tools anySatisfy: [ :each | each class == self commentToolClass ]).
	self assert: (self markdownToolOf: browser) isNil.
	browser selectClass: (self scratchClass: #CMarkCalypsoScratchB comment: '   ').
	self assert: (self markdownToolOf: browser) isNil
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testBrowserOrdersTheTabs [
	"The tabs that the browser shows, in order: Comment, Markdown, then UML-Class when Roassal-UML-Calypso is loaded; the Markdown tab is not selected"

	| browser labels comment markdown |
	browser := self browserOn: (self scratchClass: #CMarkCalypsoScratchA comment: self richComment).
	labels := (browser tabManager tabMorph pages collect: [ :each | each label asString ]) asArray.
	comment := labels indexOf: 'Comment'.
	markdown := labels indexOf: 'Markdown'.
	self assert: comment > 0.
	self assert: markdown equals: comment + 1.
	(labels includes: 'UML-Class') ifTrue: [ self assert: (labels indexOf: 'UML-Class') > markdown ].
	self deny: (browser tabManager selectedTools anySatisfy: [ :each | each class == CMarkClassCommentToolMorph ])
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testBrowserShowsTheTabForTheClassSide [
	| aClass browser tool |
	aClass := self scratchClass: #CMarkCalypsoScratchA comment: 'text'.
	browser := self browserOn: aClass.
	browser selectClass: aClass class.
	tool := self markdownToolOf: browser.
	self assert: tool notNil.
	self assert: tool targetClass identicalTo: aClass
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testIsValidInTheContextsOfItsClass [
	"Calypso keeps a tool that is valid in the new context (ClyTargetTool>>match:) instead of making another"

	| a b browser tool |
	a := self scratchClass: #CMarkCalypsoScratchA comment: 'one'.
	b := self scratchClass: #CMarkCalypsoScratchB comment: 'two'.
	browser := self browserOn: a.
	tool := self markdownToolOf: browser.
	self assert: (tool isValidInContext: tool context).
	browser selectClass: a class.
	self assert: (self markdownToolOf: browser) identicalTo: tool.
	self assert: (tool isValidInContext: (self markdownToolOf: browser) context).
	browser selectClass: b.
	self deny: (tool isValidInContext: (self markdownToolOf: browser) context)
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testKeepsOneTabWhenTheSystemChanges [
	"A method compiled, in the class or in another one, a comment accepted and a method selected keep the same built Markdown tab: Calypso rebuilds its tools on every change of the system (ClyBrowserMorph>>rebuildToolsForChangedEnvironment)"

	| a b browser tool |
	self requireCanvas.
	a := self scratchClass: #CMarkCalypsoScratchA comment: self richComment.
	b := self scratchClass: #CMarkCalypsoScratchB.
	browser := self browserOn: a.
	tool := self markdownToolOf: browser.
	self show: tool in: browser.
	a compile: 'scratchMethod ^ 1' classified: 'scratch'.
	browser rebuildToolsForChangedEnvironment.
	self assert: (self markdownToolsOf: browser) equals: { tool }.
	b compile: 'otherMethod ^ 2' classified: 'scratch'.
	browser rebuildToolsForChangedEnvironment.
	self assert: (self markdownToolsOf: browser) equals: { tool }.
	a comment: '# Edited'.
	browser rebuildToolsForChangedEnvironment.
	self assert: (self markdownToolsOf: browser) equals: { tool }.
	browser selectMethod: a >> #scratchMethod.
	self assert: (self markdownToolsOf: browser) equals: { tool }.
	self assert: tool isBuilt
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testBlankCommentRemovesTheTab [
	"Clearing the comment of the class removes its built Markdown tab, which would else show the note of an empty comment; the presenter stops listening"

	| aClass browser tool presenter |
	self requireCanvas.
	aClass := self scratchClass: #CMarkCalypsoScratchA comment: self richComment.
	browser := self browserOn: aClass.
	tool := self markdownToolOf: browser.
	self show: tool in: browser.
	presenter := tool presenter.
	aClass comment: ''.
	browser rebuildToolsForChangedEnvironment.
	self assert: (self markdownToolsOf: browser) isEmpty.
	self deny: presenter isSubscribed.
	aClass comment: (String new: 3 withAll: (Character value: 160)).
	browser rebuildToolsForChangedEnvironment.
	self assert: (self markdownToolsOf: browser) isEmpty
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testRemovingTheClassRemovesTheTab [
	"The Markdown tab of a removed class goes away with its other tabs, built or not, and its presenter stops listening"

	| aClass browser tool presenter |
	self requireCanvas.
	aClass := self scratchClass: #CMarkCalypsoScratchA comment: self richComment.
	browser := self browserOn: aClass.
	tool := self markdownToolOf: browser.
	self show: tool in: browser.
	presenter := tool presenter.
	aClass removeFromSystem.
	browser rebuildToolsForChangedEnvironment.
	self assert: (self markdownToolsOf: browser) isEmpty.
	self deny: presenter isSubscribed.
	"not shown"
	aClass := self scratchClass: #CMarkCalypsoScratchB comment: self richComment.
	browser selectClass: aClass.
	self assert: (self markdownToolsOf: browser) size equals: 1.
	aClass removeFromSystem.
	browser rebuildToolsForChangedEnvironment.
	self assert: (self markdownToolsOf: browser) isEmpty
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testIconAndTitle [
	| tool |
	tool := CMarkClassCommentToolMorph new.
	self assert: tool defaultTitle equals: 'Markdown'.
	self assert: (Smalltalk ui icons iconNamed: tool defaultIconName ifNone: [ nil ]) notNil
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testSelectingAnotherClassUnsubscribesThePresenter [
	| browser tool presenter other |
	self requireCanvas.
	browser := self browserOn: (self scratchClass: #CMarkCalypsoScratchA comment: 'one').
	tool := self markdownToolOf: browser.
	self show: tool in: browser.
	presenter := tool presenter.
	other := self scratchClass: #CMarkCalypsoScratchB comment: 'two'.
	browser selectClass: other.
	self deny: presenter isSubscribed.
	self assert: (self markdownToolOf: browser) targetClass identicalTo: other
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testSimilarity [
	| a b one two |
	a := self scratchClass: #CMarkCalypsoScratchA comment: 'one'.
	b := self scratchClass: #CMarkCalypsoScratchB comment: 'two'.
	one := CMarkClassCommentToolMorph new targetClass: a; yourself.
	two := CMarkClassCommentToolMorph new targetClass: a; yourself.
	self assert: (one isSimilarTo: two).
	two targetClass: b.
	self deny: (one isSimilarTo: two)
]

{ #category : 'tests' }
CMarkClassCommentToolMorphTest >> testTabOrderIsBetweenTheCommentAndTheUMLTabs [
	| order |
	order := CMarkClassCommentToolMorph tabOrder.
	self assert: order > self commentToolClass tabOrder.
	self assert: order > ClyClassDefinitionEditorToolMorph tabOrder.
	self assert: order < 200.
	Smalltalk globals at: #RSUMLClassCalypso ifPresent: [ :uml | self assert: order < uml tabOrder ].
	"right after the comment: before the setUp tab of the test classes too"
	Smalltalk globals at: #ClyTestSetUpEditorToolMorph ifPresent: [ :setUp | self assert: order < setUp tabOrder ]
]
