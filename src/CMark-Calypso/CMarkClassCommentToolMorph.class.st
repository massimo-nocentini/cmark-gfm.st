"
# The Markdown tab of Calypso

I show the comment of the selected class as **Markdown**: cmark-gfm parses it and `CMarkRoassalRenderer` draws it, in a `CMarkCommentPresenter` whose Spec morph fills me.

- I am activated like the *UML-Class* tab of Roassal (a class is selected), but only for a class whose comment is not empty (or only blanks).
- My `activationPriority`, -200 like the UML-Class tab's, leaves the default selection to the definition and the comment.
- I need nothing of Roassal-UML-Calypso, only Calypso.
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
		'presenter'
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

{ #category : 'building' }
CMarkClassCommentToolMorph >> build [
	| morph |
	presenter := CMarkCommentPresenter on: targetClass.
	morph := presenter build.
	morph
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	self addMorph: morph fullFrame: LayoutFrame identity
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
	presenter ifNotNil: [ :aPresenter | aPresenter unsubscribe ]
]

{ #category : 'testing' }
CMarkClassCommentToolMorph >> isSimilarTo: anotherBrowserTool [
	(super isSimilarTo: anotherBrowserTool) ifFalse: [ ^ false ].
	^ targetClass = anotherBrowserTool targetClass
]

{ #category : 'accessing' }
CMarkClassCommentToolMorph >> presenter [
	"My CMarkCommentPresenter, once I am built"

	^ presenter
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

{ #category : 'accessing' }
CMarkClassCommentToolMorph >> targetClass: aClass [
	targetClass := aClass
]
