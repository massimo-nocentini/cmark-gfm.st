Extension { #name : 'CMarkCodeBlock' }

{ #category : '*CMark-Roassal' }
CMarkCodeBlock >> cmarkRoassalOwnFlatText [
	"My lines a space apart: plainText has no code block literal, but a flat rendering shows the code too"

	^ ' ' join: self lines
]
