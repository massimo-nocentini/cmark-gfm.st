"
I am the header row of a CMarkTable.  The tape codes me as a row with the HEADER flag, so I answer no typeCode of my own.
"
Class {
	#name : 'CMarkTableHeaderRow',
	#superclass : 'CMarkTableRow',
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CMarkTableHeaderRow class >> typeCode [
	"None: the tape codes me with the flag of my superclass's code"

	^ nil
]

{ #category : 'accessing' }
CMarkTableHeaderRow class >> typeName [
	^ 'table_header'
]

{ #category : 'visiting' }
CMarkTableHeaderRow >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitTableHeaderRow: self
]

{ #category : 'testing' }
CMarkTableHeaderRow >> isHeader [
	^ true
]

{ #category : 'accessing' }
CMarkTableHeaderRow >> typeCode [
	"The code of the tape: a row"

	^ CMarkTableRow typeCode
]
