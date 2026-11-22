"
I am a reference to a footnote ([^label]), parsed only with the option footnotes: ordinal is the number of my definition, definition my CMarkFootnoteDefinition, referenceIndex my rank among the references to it (1 for the first, in source order).  A reference without a definition is the text [^label] instead.
"
Class {
	#name : 'CMarkFootnoteReference',
	#superclass : 'CMarkInlineNode',
	#instVars : [
		'ordinal',
		'definition',
		'referenceIndex'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CMarkFootnoteReference class >> typeCode [
	^ 16rC00B
]

{ #category : 'accessing' }
CMarkFootnoteReference class >> typeName [
	^ 'footnote_reference'
]

{ #category : 'visiting' }
CMarkFootnoteReference >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitFootnoteReference: self
]

{ #category : 'printing' }
CMarkFootnoteReference >> cmarkPrintAttributesOn: aStream [
	aStream nextPutAll: 'ordinal '; print: ordinal.
	^ true
]

{ #category : 'printing' }
CMarkFootnoteReference >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' ordinal='; print: ordinal; nextPutAll: ' ref='; print: referenceIndex
]

{ #category : 'decoding' }
CMarkFootnoteReference >> cmarkRead: aDecoder record: base [
	ordinal := aDecoder int1At: base.
	aDecoder noteFootnoteReference: self definitionRecord: (aDecoder int2At: base)
]

{ #category : 'accessing' }
CMarkFootnoteReference >> definition [
	"My CMarkFootnoteDefinition, or nil"

	^ definition
]

{ #category : 'accessing' }
CMarkFootnoteReference >> definition: aFootnoteDefinition [
	definition := aFootnoteDefinition
]

{ #category : 'initialization' }
CMarkFootnoteReference >> initialize [
	super initialize.
	ordinal := 0.
	referenceIndex := 0
]

{ #category : 'accessing' }
CMarkFootnoteReference >> ordinal [
	^ ordinal
]

{ #category : 'accessing' }
CMarkFootnoteReference >> ordinal: anInteger [
	ordinal := anInteger
]

{ #category : 'accessing' }
CMarkFootnoteReference >> referenceIndex [
	"My rank among the references to my definition, 1-based in source order (cmark's ref_ix)"

	^ referenceIndex
]

{ #category : 'accessing' }
CMarkFootnoteReference >> referenceIndex: anInteger [
	referenceIndex := anInteger
]
