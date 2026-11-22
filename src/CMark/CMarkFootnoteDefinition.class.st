"
I am a footnote definition ([^label]: text), parsed only with the option footnotes: my children are blocks.  label is my label as written, ordinal my number (1-based, in the order of the first references), references the CMarkFootnoteReferences that point at me, in source order.  cmark moves the referenced definitions to the end of the document, sorted by first reference, and drops the others.
"
Class {
	#name : 'CMarkFootnoteDefinition',
	#superclass : 'CMarkBlockNode',
	#instVars : [
		'label',
		'ordinal',
		'references'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CMarkFootnoteDefinition class >> label: aString [
	"A hand-built footnote definition"

	^ self new
		label: aString;
		yourself
]

{ #category : 'accessing' }
CMarkFootnoteDefinition class >> typeCode [
	^ 16r800B
]

{ #category : 'accessing' }
CMarkFootnoteDefinition class >> typeName [
	^ 'footnote_definition'
]

{ #category : 'visiting' }
CMarkFootnoteDefinition >> acceptCMarkVisitor: aVisitor [
	^ aVisitor visitFootnoteDefinition: self
]

{ #category : 'building' }
CMarkFootnoteDefinition >> addReference: aFootnoteReference [
	"Make aFootnoteReference point at me, as my last reference; answer it"

	references := references copyWith: aFootnoteReference.
	aFootnoteReference
		definition: self;
		referenceIndex: references size.
	^ aFootnoteReference
]

{ #category : 'decoding' }
CMarkFootnoteDefinition >> cmarkAddDecodedReference: aFootnoteReference [
	references := references copyWith: aFootnoteReference.
	aFootnoteReference definition: self
]

{ #category : 'printing' }
CMarkFootnoteDefinition >> cmarkPrintAttributesOn: aStream [
	aStream nextPutAll: 'ordinal '; print: ordinal.
	^ true
]

{ #category : 'printing' }
CMarkFootnoteDefinition >> cmarkPrintTreeAttributesOn: aStream [
	aStream nextPutAll: ' label='.
	self cmarkPrintLiteral: label on: aStream.
	aStream nextPutAll: ' ordinal='; print: ordinal
]

{ #category : 'decoding' }
CMarkFootnoteDefinition >> cmarkRead: aDecoder record: base [
	ordinal := aDecoder int1At: base.
	label := aDecoder string1At: base
]

{ #category : 'decoding' }
CMarkFootnoteDefinition >> cmarkSortReferences [
	references := references sorted: [ :a :b | a startIndex <= b startIndex ].
	references doWithIndex: [ :each :i | each referenceIndex: i ]
]

{ #category : 'initialization' }
CMarkFootnoteDefinition >> initialize [
	super initialize.
	label := ''.
	ordinal := 0.
	references := #(  )
]

{ #category : 'testing' }
CMarkFootnoteDefinition >> isFootnoteDefinition [
	^ true
]

{ #category : 'accessing' }
CMarkFootnoteDefinition >> label [
	^ label
]

{ #category : 'accessing' }
CMarkFootnoteDefinition >> label: aString [
	label := aString
]

{ #category : 'accessing' }
CMarkFootnoteDefinition >> ordinal [
	"My number, 1-based in the order of the first references"

	^ ordinal
]

{ #category : 'accessing' }
CMarkFootnoteDefinition >> ordinal: anInteger [
	ordinal := anInteger
]

{ #category : 'accessing' }
CMarkFootnoteDefinition >> references [
	"The footnote references that point at me, in source order"

	^ references
]
