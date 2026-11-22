"
I am what the renderer answers for a block node: its shape (an RSComposite whose top-left is its local 0@0 and whose first child is a transparent frame box), the y of its first baseline (for list markers and table rows), its natural width (the widest line it would make at an unlimited width, for tables), its minimum width (its widest unbreakable cluster, for tables), and its height.
"
Class {
	#name : 'CMarkRoassalBlock',
	#superclass : 'Object',
	#instVars : [
		'shape',
		'firstBaseline',
		'naturalWidth',
		'minWidth',
		'height'
	],
	#category : 'CMark-Roassal-Rendering',
	#package : 'CMark-Roassal',
	#tag : 'Rendering'
}

{ #category : 'instance creation' }
CMarkRoassalBlock class >> shape: aComposite firstBaseline: aBaseline naturalWidth: aWidth minWidth: aMinWidth height: aHeight [
	^ self new
		  setShape: aComposite
		  firstBaseline: aBaseline
		  naturalWidth: aWidth
		  minWidth: aMinWidth
		  height: aHeight;
		  yourself
]

{ #category : 'accessing' }
CMarkRoassalBlock >> firstBaseline [
	"The y of my first baseline, from my top"

	^ firstBaseline
]

{ #category : 'accessing' }
CMarkRoassalBlock >> height [
	^ height
]

{ #category : 'testing' }
CMarkRoassalBlock >> isEmpty [
	"Whether I take no vertical space (the stacks put no gap around me)"

	^ height <= 0
]

{ #category : 'accessing' }
CMarkRoassalBlock >> minWidth [
	"The width of my widest unbreakable cluster"

	^ minWidth
]

{ #category : 'accessing' }
CMarkRoassalBlock >> naturalWidth [
	"My width at an unlimited width"

	^ naturalWidth
]

{ #category : 'printing' }
CMarkRoassalBlock >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		print: shape model;
		nextPutAll: ' height ';
		print: height;
		nextPut: $)
]

{ #category : 'private' }
CMarkRoassalBlock >> setShape: aComposite firstBaseline: aBaseline naturalWidth: aWidth minWidth: aMinWidth height: aHeight [
	shape := aComposite.
	firstBaseline := aBaseline.
	naturalWidth := aWidth.
	minWidth := aMinWidth.
	height := aHeight
]

{ #category : 'accessing' }
CMarkRoassalBlock >> shape [
	"My RSComposite"

	^ shape
]
