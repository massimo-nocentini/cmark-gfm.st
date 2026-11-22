"
I am a table of the table extension: my children are rows, the first one the CMarkTableHeaderRow.  columnCount is my number of columns, alignments an Array of #left, #center, #right or nil (none) per column.

	CMarkTable alignments: #( #left nil #right )
"
Class {
	#name : 'CMarkTable',
	#superclass : 'CMarkBlockNode',
	#instVars : [
		'columnCount',
		'alignments'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CMarkTable class >> alignments: anArray [
	"A hand-built table of anArray size columns aligned by anArray (#left, #center, #right or nil)"

	^ self new
		alignments: anArray;
		yourself
]

{ #category : 'accessing' }
CMarkTable class >> typeCode [
	^ 16r8100
]

{ #category : 'accessing' }
CMarkTable class >> typeName [
	^ 'table'
]

{ #category : 'visiting' }
CMarkTable >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitTable: self
]

{ #category : 'accessing' }
CMarkTable >> alignments [
	"#left, #center, #right or nil (none), per column"

	^ alignments
]

{ #category : 'accessing' }
CMarkTable >> alignments: anArray [
	alignments := anArray asArray.
	columnCount := alignments size
]

{ #category : 'accessing' }
CMarkTable >> bodyRows [
	"My rows after the header row"

	^ children reject: [ :each | each isHeader ]
]

{ #category : 'printing' }
CMarkTable >> cmarkPrintAttributesOn: aStream [
	aStream print: columnCount; nextPutAll: ' columns'.
	^ true
]

{ #category : 'printing' }
CMarkTable >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' columns='; print: columnCount; nextPutAll: ' align='.
	alignments do: [ :each |
		aStream nextPut: (each = #left
				 ifTrue: [ $l ]
				 ifFalse: [
					 each = #center
						 ifTrue: [ $c ]
						 ifFalse: [
							 each = #right
								 ifTrue: [ $r ]
								 ifFalse: [ $- ] ] ]) ]
]

{ #category : 'decoding' }
CMarkTable >> cmarkRead: aDecoder record: base [
	columnCount := aDecoder int1At: base.
	alignments := (aDecoder string1At: base) asArray collect: [ :each |
						each = $l
							ifTrue: [ #left ]
							ifFalse: [
								each = $c
									ifTrue: [ #center ]
									ifFalse: [
										each = $r
											ifTrue: [ #right ]
											ifFalse: [ nil ] ] ] ]
]

{ #category : 'accessing' }
CMarkTable >> columnCount [
	^ columnCount
]

{ #category : 'accessing' }
CMarkTable >> headerRow [
	"My header row, or nil"

	^ children detect: [ :each | each isHeader ] ifNone: [ nil ]
]

{ #category : 'initialization' }
CMarkTable >> initialize [
	super initialize.
	columnCount := 0.
	alignments := #(  )
]
