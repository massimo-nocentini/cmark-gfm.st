"
I am a link: my children are its text (inlines), `url` its destination, `title` its title (`''` when absent). The autolinks (`<https://x.y>`, `www.x.y`, emails) are links too, which the tape cannot tell apart.

```smalltalk
CMarkLink url: 'https://pharo.org' title: ''
```
"
Class {
	#name : 'CMarkLink',
	#superclass : 'CMarkInlineNode',
	#instVars : [
		'url',
		'title'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CMarkLink class >> typeCode [
	^ 16rC009
]

{ #category : 'accessing' }
CMarkLink class >> typeName [
	^ 'link'
]

{ #category : 'instance creation' }
CMarkLink class >> url: aString title: aTitleString [
	"A hand-built node of aString ('' for none) and aTitleString ('' for none)"

	^ self new
		url: aString;
		title: aTitleString;
		yourself
]

{ #category : 'visiting' }
CMarkLink >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitLink: self
]

{ #category : 'printing' }
CMarkLink >> cmarkPrintAttributesOn: aStream [
	self cmarkPrintShort: url on: aStream.
	^ true
]

{ #category : 'printing' }
CMarkLink >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' url='.
	self cmarkPrintLiteral: url on: aStream.
	aStream nextPutAll: ' title='.
	self cmarkPrintLiteral: title on: aStream
]

{ #category : 'decoding' }
CMarkLink >> cmarkRead: aDecoder record: base [
	url := aDecoder string1At: base.
	title := aDecoder string2At: base
]

{ #category : 'testing' }
CMarkLink >> hasTitle [
	^ title notEmpty
]

{ #category : 'initialization' }
CMarkLink >> initialize [
	super initialize.
	url := ''.
	title := ''
]

{ #category : 'testing' }
CMarkLink >> isAnchor [
	"Whether my url points inside the document (#slug)"

	^ url notEmpty and: [ url first = $# ]
]

{ #category : 'testing' }
CMarkLink >> isLink [
	^ true
]

{ #category : 'accessing' }
CMarkLink >> title [
	"The title, '' when absent"

	^ title
]

{ #category : 'accessing' }
CMarkLink >> title: aString [
	title := aString
]

{ #category : 'accessing' }
CMarkLink >> url [
	"The destination, '' when absent"

	^ url
]

{ #category : 'accessing' }
CMarkLink >> url: aString [
	url := aString
]
