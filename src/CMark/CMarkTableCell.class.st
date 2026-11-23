"
I am a cell of a table row: my children are inlines. `column` (my index in my row) and `alignment` (from my table) are computed, so hand-built cells have them too. `isAutocompleted` says whether cmark padded a short row with me: I then have no children and no position.

Known gfm.14 behaviour (`docs/CMark.md`, Limitations): the table extension unescapes each `\|` of my text before it parses my inlines, and keeps their offsets, so the inlines after an escaped pipe start (and end) one column early per `\|` before them, and their `sourceText` is wrong. The positions stay inside the line, so the plugin does not clamp them (`isClamped` is false); my own position is right.
"
Class {
	#name : 'CMarkTableCell',
	#superclass : 'CMarkBlockNode',
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CMarkTableCell class >> typeCode [
	^ 16r8102
]

{ #category : 'accessing' }
CMarkTableCell class >> typeName [
	^ 'table_cell'
]

{ #category : 'visiting' }
CMarkTableCell >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitTableCell: self
]

{ #category : 'accessing' }
CMarkTableCell >> alignment [
	"#left, #center, #right or nil, from my table"

	| t c |
	t := self table.
	c := self column.
	(t isNil or: [ c isNil or: [ c > t alignments size ] ]) ifTrue: [ ^ nil ].
	^ t alignments at: c
]

{ #category : 'accessing' }
CMarkTableCell >> column [
	"My 1-based column: my index in my row, or nil without a row"

	^ self indexInParent
]

{ #category : 'testing' }
CMarkTableCell >> isAutocompleted [
	"Whether cmark padded a short row with me: no children and no position"

	^ children isEmpty and: [ self hasSourcePosition not ]
]

{ #category : 'accessing' }
CMarkTableCell >> row [
	"My row, or nil"

	^ parent
]

{ #category : 'accessing' }
CMarkTableCell >> table [
	"My table, or nil"

	^ parent ifNotNil: [ :r | r parent ]
]
