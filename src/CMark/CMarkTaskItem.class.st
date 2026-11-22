"
I am a task list item of the tasklist extension (- [ ] open, - [x] done): checked says whether my box is ticked.  The tape codes me as an item with the TASK flag, so I answer no typeCode of my own.

	CMarkTaskItem checked: true
"
Class {
	#name : 'CMarkTaskItem',
	#superclass : 'CMarkItem',
	#instVars : [
		'checked'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CMarkTaskItem class >> checked: aBoolean [
	"A hand-built task item, ticked when aBoolean"

	^ self new
		checked: aBoolean;
		yourself
]

{ #category : 'accessing' }
CMarkTaskItem class >> typeCode [
	"None: the tape codes me with the flag of my superclass's code"

	^ nil
]

{ #category : 'accessing' }
CMarkTaskItem class >> typeName [
	^ 'tasklist'
]

{ #category : 'visiting' }
CMarkTaskItem >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitTaskItem: self
]

{ #category : 'accessing' }
CMarkTaskItem >> checked [
	^ checked
]

{ #category : 'accessing' }
CMarkTaskItem >> checked: aBoolean [
	checked := aBoolean
]

{ #category : 'printing' }
CMarkTaskItem >> cmarkPrintAttributesOn: aStream [
	aStream nextPutAll: (checked ifTrue: [ 'checked' ] ifFalse: [ 'unchecked' ]).
	^ true
]

{ #category : 'printing' }
CMarkTaskItem >> cmarkPrintTreeAttributesOn: aStream [
	super cmarkPrintTreeAttributesOn: aStream.
	aStream nextPutAll: ' checked='; print: (checked ifTrue: [ 1 ] ifFalse: [ 0 ])
]

{ #category : 'decoding' }
CMarkTaskItem >> cmarkRead: aDecoder record: base [
	super cmarkRead: aDecoder record: base.
	checked := self cmarkHasFlag: CMarkTreeDecoder flagChecked
]

{ #category : 'initialization' }
CMarkTaskItem >> initialize [
	super initialize.
	checked := false
]

{ #category : 'testing' }
CMarkTaskItem >> isChecked [
	^ checked
]

{ #category : 'testing' }
CMarkTaskItem >> isTask [
	^ true
]

{ #category : 'accessing' }
CMarkTaskItem >> typeCode [
	"The code of the tape: an item"

	^ CMarkItem typeCode
]
