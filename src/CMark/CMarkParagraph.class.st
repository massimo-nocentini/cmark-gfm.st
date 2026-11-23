"
I am a paragraph: my children are inlines.

```smalltalk
CMarkParagraph with: { CMarkText literal: 'Hello' }
```
"
Class {
	#name : 'CMarkParagraph',
	#superclass : 'CMarkBlockNode',
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CMarkParagraph class >> typeCode [
	^ 16r8008
]

{ #category : 'accessing' }
CMarkParagraph class >> typeName [
	^ 'paragraph'
]

{ #category : 'visiting' }
CMarkParagraph >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitParagraph: self
]
