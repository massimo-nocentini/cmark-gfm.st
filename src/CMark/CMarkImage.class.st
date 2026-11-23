"
I am an image: my children are its description (inlines; `altText` is their plain text), `url` its source, `title` its title (`''` when absent).

```smalltalk
CMarkImage url: 'logo.png' title: ''
```
"
Class {
	#name : 'CMarkImage',
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
CMarkImage class >> typeCode [
	^ 16rC00A
]

{ #category : 'accessing' }
CMarkImage class >> typeName [
	^ 'image'
]

{ #category : 'instance creation' }
CMarkImage class >> url: aString title: aTitleString [
	"A hand-built node of aString ('' for none) and aTitleString ('' for none)"

	^ self new
		url: aString;
		title: aTitleString;
		yourself
]

{ #category : 'visiting' }
CMarkImage >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitImage: self
]

{ #category : 'accessing' }
CMarkImage >> altText [
	"The plain text of my description"

	^ self plainText
]

{ #category : 'printing' }
CMarkImage >> cmarkPrintAttributesOn: aStream [
	self cmarkPrintShort: url on: aStream.
	^ true
]

{ #category : 'printing' }
CMarkImage >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' url='.
	self cmarkPrintLiteral: url on: aStream.
	aStream nextPutAll: ' title='.
	self cmarkPrintLiteral: title on: aStream
]

{ #category : 'decoding' }
CMarkImage >> cmarkRead: aDecoder record: base [
	url := aDecoder string1At: base.
	title := aDecoder string2At: base
]

{ #category : 'testing' }
CMarkImage >> hasTitle [
	^ title notEmpty
]

{ #category : 'initialization' }
CMarkImage >> initialize [
	super initialize.
	url := ''.
	title := ''
]

{ #category : 'accessing' }
CMarkImage >> title [
	"The title, '' when absent"

	^ title
]

{ #category : 'accessing' }
CMarkImage >> title: aString [
	title := aString
]

{ #category : 'accessing' }
CMarkImage >> url [
	"The destination, '' when absent"

	^ url
]

{ #category : 'accessing' }
CMarkImage >> url: aString [
	url := aString
]
