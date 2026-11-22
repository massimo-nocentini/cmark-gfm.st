Extension { #name : 'CMarkImage' }

{ #category : '*CMark-Roassal' }
CMarkImage >> cmarkRoassalPopupText [
	"The url of my enclosing link, or mine"

	^ self enclosingLink
		  ifNil: [ url ]
		  ifNotNil: [ :link | link url ]
]
