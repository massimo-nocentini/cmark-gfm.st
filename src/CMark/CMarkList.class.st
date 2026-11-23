"
I am a list: my children are `CMarkItem`s (`CMarkTaskItem`s for the task list items).

- `listType` is `#bullet` or `#ordered`;
- `delimiter` `#period`, `#paren` or nil (bullets);
- `start` the number of the first ordered item (0 for bullets);
- `tight` whether cmark found no blank line between and inside the items.

The bullet character (`-` `*` `+`) is private to cmark and not in the tape.

```smalltalk
CMarkList bullet
CMarkList ordered: 3
```
"
Class {
	#name : 'CMarkList',
	#superclass : 'CMarkBlockNode',
	#instVars : [
		'listType',
		'delimiter',
		'start',
		'tight'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CMarkList class >> bullet [
	"A hand-built tight bullet list"

	^ self new
]

{ #category : 'instance creation' }
CMarkList class >> ordered: anInteger [
	"A hand-built tight ordered list starting at anInteger, delimiter #period"

	^ self new
		listType: #ordered;
		delimiter: #period;
		start: anInteger;
		yourself
]

{ #category : 'accessing' }
CMarkList class >> typeCode [
	^ 16r8003
]

{ #category : 'accessing' }
CMarkList class >> typeName [
	^ 'list'
]

{ #category : 'visiting' }
CMarkList >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitList: self
]

{ #category : 'printing' }
CMarkList >> cmarkPrintAttributesOn: aStream [
	aStream nextPutAll: listType.
	self isOrdered ifTrue: [ aStream nextPutAll: ' start '; print: start ].
	tight ifTrue: [ aStream nextPutAll: ' tight' ].
	^ true
]

{ #category : 'printing' }
CMarkList >> cmarkPrintTreeAttributesOn: aStream [
	aStream
		nextPutAll: ' list='; nextPutAll: listType;
		nextPutAll: ' delim='; nextPutAll: (delimiter ifNil: [ 'none' ]);
		nextPutAll: ' start='; print: start;
		nextPutAll: ' tight='; print: (tight ifTrue: [ 1 ] ifFalse: [ 0 ])
]

{ #category : 'decoding' }
CMarkList >> cmarkRead: aDecoder record: base [
	| d |
	listType := (aDecoder int1At: base) = 2
					ifTrue: [ #ordered ]
					ifFalse: [ #bullet ].
	d := aDecoder int2At: base.
	delimiter := d = 1
					 ifTrue: [ #period ]
					 ifFalse: [
						 d = 2
							 ifTrue: [ #paren ]
							 ifFalse: [ nil ] ].
	start := aDecoder int3At: base.
	tight := self cmarkHasFlag: CMarkTreeDecoder flagTight
]

{ #category : 'accessing' }
CMarkList >> delimiter [
	"#period, #paren, or nil for a bullet list"

	^ delimiter
]

{ #category : 'accessing' }
CMarkList >> delimiter: aSymbolOrNil [
	delimiter := aSymbolOrNil
]

{ #category : 'initialization' }
CMarkList >> initialize [
	super initialize.
	listType := #bullet.
	delimiter := nil.
	start := 0.
	tight := true
]

{ #category : 'testing' }
CMarkList >> isBullet [
	^ listType = #bullet
]

{ #category : 'testing' }
CMarkList >> isOrdered [
	^ listType = #ordered
]

{ #category : 'testing' }
CMarkList >> isTight [
	^ tight
]

{ #category : 'accessing' }
CMarkList >> listType [
	"#bullet or #ordered"

	^ listType
]

{ #category : 'accessing' }
CMarkList >> listType: aSymbol [
	listType := aSymbol
]

{ #category : 'accessing' }
CMarkList >> start [
	"The number of the first item of an ordered list, 0 for a bullet list"

	^ start
]

{ #category : 'accessing' }
CMarkList >> start: anInteger [
	start := anInteger
]

{ #category : 'accessing' }
CMarkList >> tight [
	^ tight
]

{ #category : 'accessing' }
CMarkList >> tight: aBoolean [
	tight := aBoolean
]
