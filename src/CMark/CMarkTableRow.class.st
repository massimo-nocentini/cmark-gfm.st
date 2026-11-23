"
I am a body row of a `CMarkTable`: my children are `CMarkTableCell`s. The header row is a `CMarkTableHeaderRow`.
"
Class {
	#name : 'CMarkTableRow',
	#superclass : 'CMarkBlockNode',
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'decoding' }
CMarkTableRow class >> cmarkClassForFlags: anInteger [
	"CMarkTableHeaderRow for the header row, else CMarkTableRow"

	^ (anInteger bitAnd: CMarkTreeDecoder flagHeader) ~= 0
		  ifTrue: [ CMarkTableHeaderRow ]
		  ifFalse: [ CMarkTableRow ]
]

{ #category : 'accessing' }
CMarkTableRow class >> typeCode [
	^ 16r8101
]

{ #category : 'accessing' }
CMarkTableRow class >> typeName [
	^ 'table_row'
]

{ #category : 'visiting' }
CMarkTableRow >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitTableRow: self
]

{ #category : 'accessing' }
CMarkTableRow >> cells [
	"My cells"

	^ children
]

{ #category : 'testing' }
CMarkTableRow >> isHeader [
	"Whether I am the header row"

	^ false
]

{ #category : 'accessing' }
CMarkTableRow >> table [
	"My table, or nil"

	^ parent
]
