Extension { #name : 'CMarkFootnoteReference' }

{ #category : '*CMark-Roassal' }
CMarkFootnoteReference >> cmarkRoassalFollowIn: aRenderer targets: aDictionary canvas: aCanvas [
	"A click on me moves the camera to my definition"

	definition ifNil: [ ^ self ].
	aRenderer moveTo: (aDictionary at: definition ifAbsent: [ nil ]) in: aCanvas
]

{ #category : '*CMark-Roassal' }
CMarkFootnoteReference >> cmarkRoassalPopupText [
	"The text of my definition, its blocks a space apart (cmarkRoassalFlatText)"

	^ definition
		  ifNil: [ '[^' , ordinal printString , ']' ]
		  ifNotNil: [ :each | each cmarkRoassalFlatText ]
]
