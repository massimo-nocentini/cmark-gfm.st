"
I am a visitor that records the nodes that reach visitNode:, in order, and the items and rows that reach visitItem: and visitTableRow:.
"
Class {
	#name : 'CMarkRecordingVisitor',
	#superclass : 'CMarkVisitor',
	#instVars : [
		'visited',
		'items',
		'rows'
	],
	#category : 'CMark-Tests-Support',
	#package : 'CMark-Tests',
	#tag : 'Support'
}

{ #category : 'initialization' }
CMarkRecordingVisitor >> initialize [
	super initialize.
	visited := OrderedCollection new.
	items := OrderedCollection new.
	rows := OrderedCollection new
]

{ #category : 'accessing' }
CMarkRecordingVisitor >> items [
	^ items
]

{ #category : 'accessing' }
CMarkRecordingVisitor >> rows [
	^ rows
]

{ #category : 'visiting' }
CMarkRecordingVisitor >> visitItem: anItem [
	items add: anItem.
	^ super visitItem: anItem
]

{ #category : 'visiting' }
CMarkRecordingVisitor >> visitNode: aNode [
	visited add: aNode.
	^ super visitNode: aNode
]

{ #category : 'visiting' }
CMarkRecordingVisitor >> visitTableRow: aTableRow [
	rows add: aTableRow.
	^ super visitTableRow: aTableRow
]

{ #category : 'accessing' }
CMarkRecordingVisitor >> visited [
	^ visited
]
