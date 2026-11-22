Extension { #name : 'CMarkLink' }

{ #category : '*CMark-Roassal' }
CMarkLink >> cmarkRoassalFollowIn: aRenderer targets: aDictionary canvas: aCanvas [
	"A click on my text: an anchor (#slug) moves the camera to its heading, any other url goes to the linkAction of the theme"

	self isAnchor
		ifTrue: [ aRenderer followAnchor: url allButFirst targets: aDictionary canvas: aCanvas ]
		ifFalse: [ aRenderer followUrl: url ]
]
