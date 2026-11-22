Extension { #name : 'CMarkNode' }

{ #category : '*CMark-Roassal' }
CMarkNode >> asRoassalCanvas [
	"An RSCanvas showing me in the default theme, fitted to the width with the top in view"

	^ CMarkRoassalRenderer new canvasFor: self
]

{ #category : '*CMark-Roassal' }
CMarkNode >> asRoassalShape [
	"One RSComposite showing me in the default theme (CMarkRoassalRenderer)"

	^ CMarkRoassalRenderer new render: self
]

{ #category : '*CMark-Roassal' }
CMarkNode >> asRoassalShapeWidth: aNumber [
	"One RSComposite showing me in the default theme, aNumber units wide (without the padding of a document)"

	^ CMarkRoassalRenderer new
		  maxWidth: aNumber;
		  render: self
]

{ #category : '*CMark-Roassal' }
CMarkNode >> cmarkRoassalFollowIn: aRenderer targets: aDictionary canvas: aCanvas [
	"A click on a piece that follows me: nothing by default"
]

{ #category : '*CMark-Roassal' }
CMarkNode >> cmarkRoassalPopupText [
	"The text of the popup of a shape whose model I am: the url of my enclosing link"

	^ self enclosingLink
		  ifNil: [ '' ]
		  ifNotNil: [ :link | link url ]
]

{ #category : '*CMark-Roassal' }
CMarkNode >> inspectionCMarkRendered [
	<inspectorPresentationOrder: 1 title: 'Rendered'>
	^ self asRoassalCanvas asPresenter
]

{ #category : '*CMark-Roassal' }
CMarkNode >> inspectionCMarkRenderedContext: aContext [
	"Render only trees of up to 5000 nodes in the inspector, so that inspecting a node of a huge document does not render it all"

	aContext active: self allNodes size <= 5000
]
