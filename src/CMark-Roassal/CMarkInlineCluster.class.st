"
I am a cluster of `CMarkInlineFlow`: the pieces between two break opportunities, which always stay on one line together (so `[link](u).` and `**bold**,` and `foo*bar*baz` are each one cluster), with the opportunity before me: the line breaks before me (`breaksBefore`) and the blank before me (`spaceText` and `spaceWidth`: one collapsed space, or nothing between the segments of a code span).
"
Class {
	#name : 'CMarkInlineCluster',
	#superclass : 'Object',
	#instVars : [
		'pieces',
		'width',
		'spaceText',
		'spaceWidth',
		'breaksBefore'
	],
	#category : 'CMark-Roassal-Inline',
	#package : 'CMark-Roassal',
	#tag : 'Inline'
}

{ #category : 'instance creation' }
CMarkInlineCluster class >> spaceText: aString spaceWidth: aNumber breaksBefore: anInteger [
	^ self new
		  setSpaceText: aString spaceWidth: aNumber breaksBefore: anInteger;
		  yourself
]

{ #category : 'adding' }
CMarkInlineCluster >> add: aPiece [
	pieces add: aPiece.
	width := width + aPiece width
]

{ #category : 'accessing' }
CMarkInlineCluster >> breaksBefore [
	"The number of line breaks before me"

	^ breaksBefore
]

{ #category : 'accessing' }
CMarkInlineCluster >> pieces [
	^ pieces
]

{ #category : 'private' }
CMarkInlineCluster >> setSpaceText: aString spaceWidth: aNumber breaksBefore: anInteger [
	pieces := OrderedCollection new.
	width := 0.
	spaceText := aString.
	spaceWidth := aNumber.
	breaksBefore := anInteger
]

{ #category : 'accessing' }
CMarkInlineCluster >> spaceText [
	"The text of the blank before me when I do not start a line"

	^ spaceText
]

{ #category : 'accessing' }
CMarkInlineCluster >> spaceWidth [
	"The advance of the blank before me when I do not start a line"

	^ spaceWidth
]

{ #category : 'accessing' }
CMarkInlineCluster >> width [
	"The sum of the advances of my pieces"

	^ width
]
