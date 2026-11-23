"
# The Markdown tab of Calypso

I show the comment of the selected class as **Markdown**: cmark-gfm parses it and `CMarkRoassalRenderer` draws it, in a `CMarkCommentPresenter` whose Spec morph fills me.

- I am activated like the *UML-Class* tab of Roassal (a class is selected), but only for a class whose comment is not blank (spaces, Unicode ones included); I go away when the comment becomes blank (`wantsStayInDifferentContext`) and when my class is removed (`belongsToRemovedBrowserContext`).
- My `activationPriority`, -200 like the UML-Class tab's, leaves the default selection to the definition and the comment.
- I need nothing of Roassal-UML-Calypso, only Calypso.
- Calypso keeps me, built, while my class stays selected (`isValidInContext:`): through the changes of the system (a method compiled, a comment accepted), the switch to the class side and the selection of a method.
- The presenter subscribes to the changes of comments and draws the new comment; I unsubscribe it when Calypso removes me (`detachFromSystem`, sent when the tab is removed and when the browser closes).

My `tabOrder` puts me right after the Comment tab:

| Tab | Class | tabOrder |
|:----|:------|---------:|
| definition | `ClyClassDefinitionEditorToolMorph` | 10 |
| Comment | `ClyRichTextClassCommentEditorToolMorph` | 10 |
| Markdown | `CMarkClassCommentToolMorph` | 10.5 |
| setUp (test classes) | `ClyTestSetUpEditorToolMorph` | 11 |
| UML-Class (Roassal-UML-Calypso) | `RSUMLClassCalypso` | 200 |

The presenter works alone too:

```smalltalk
(CMarkCommentPresenter on: CMarkClassCommentToolMorph) open
```
"
Class {
	#name : 'CMarkClassCommentToolMorph',
	#superclass : 'ClyBrowserToolMorph',
	#instVars : [
		'targetClass',
		'commentPresenter'
	],
	#category : 'CMark-Calypso-Calypso',
	#package : 'CMark-Calypso',
	#tag : 'Calypso'
}

{ #category : 'activation' }
CMarkClassCommentToolMorph class >> classMarkdownTabActivation [
	<classAnnotation>
	^ ClyTabActivationStrategyAnnotation for: ClyClass asCalypsoItemContext
]

{ #category : 'testing' }
CMarkClassCommentToolMorph class >> shouldBeActivatedInContext: aBrowserContext [
	^ aBrowserContext isClassSelected and: [ CMarkCommentPresenter hasCommentToShow: aBrowserContext lastSelectedClass ]
]

{ #category : 'accessing' }
CMarkClassCommentToolMorph class >> tabOrder [
	"After the Comment tab (10) and before the setUp tab of the test classes (11) and the UML-Class tab (200)"

	^ 10.5
]

{ #category : 'accessing' }
CMarkClassCommentToolMorph >> activationPriority [
	"As the UML-Class tab: below the definition and the comment, so that the browser never selects me by default"

	^ -200
]

{ #category : 'testing' }
CMarkClassCommentToolMorph >> belongsToCurrentBrowserContext [
	^ (browser isClassSelected: targetClass) or: [ browser isClassSelected: targetClass classSide ]
]

{ #category : 'testing' }
CMarkClassCommentToolMorph >> belongsToRemovedBrowserContext [
	"My class was removed: Calypso removes me with the other tabs of the class"

	^ targetClass isObsolete
]

{ #category : 'building' }
CMarkClassCommentToolMorph >> build [
	| morph |
	commentPresenter := CMarkCommentPresenter on: targetClass.
	morph := commentPresenter build.
	morph
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	self addMorph: morph fullFrame: LayoutFrame identity
]

{ #category : 'accessing' }
CMarkClassCommentToolMorph >> commentPresenter [
	"My CMarkCommentPresenter, once I am built (not #presenter: Morph>>presenter and presenter: are a property that Spec sets)"

	^ commentPresenter
]

{ #category : 'initialization' }
CMarkClassCommentToolMorph >> defaultIconName [
	^ #page
]

{ #category : 'initialization' }
CMarkClassCommentToolMorph >> defaultTitle [
	^ 'Markdown'
]

{ #category : 'initialization' }
CMarkClassCommentToolMorph >> detachFromSystem [
	super detachFromSystem.
	commentPresenter ifNotNil: [ :aPresenter | aPresenter unsubscribe ]
]

{ #category : 'testing' }
CMarkClassCommentToolMorph >> isValidInContext: aBrowserContext [
	"Whether Calypso can keep me for aBrowserContext instead of making a new tab: a context of the same kind on my class, on either side (the comment is the same).  Without this, every change of the system (a method compiled, a comment accepted) would add a second Markdown tab, and selecting a method would replace me by a new tab drawn again"

	self context class = aBrowserContext class ifFalse: [ ^ false ].
	^ aBrowserContext isClassSelected and: [ targetClass = aBrowserContext lastSelectedClass instanceSide ]
]

{ #category : 'testing' }
CMarkClassCommentToolMorph >> isSimilarTo: anotherBrowserTool [
	(super isSimilarTo: anotherBrowserTool) ifFalse: [ ^ false ].
	^ targetClass = anotherBrowserTool targetClass
]

{ #category : 'initialization' }
CMarkClassCommentToolMorph >> setUpModelFromContext [
	super setUpModelFromContext.
	targetClass := context lastSelectedClass instanceSide
]

{ #category : 'accessing' }
CMarkClassCommentToolMorph >> targetClass [
	"The class whose comment I show (its instance side)"

	^ targetClass
]

{ #category : 'testing' }
CMarkClassCommentToolMorph >> wantsStayInDifferentContext [
	"Calypso keeps a built tab that is no longer activated (the user may be reading it) unless it answers false: I go away as soon as the comment of my class becomes blank, as I would not be activated for it"

	(CMarkCommentPresenter hasCommentToShow: targetClass) ifFalse: [ ^ false ].
	^ super wantsStayInDifferentContext
]

{ #category : 'accessing' }
CMarkClassCommentToolMorph >> targetClass: aClass [
	targetClass := aClass
]
