"
I am a run of inline content, as `CMarkInlineRunCollector` makes it from the inline nodes of a block and `CMarkInlineFlow` lays it out: a kind, a string, a style (`CMarkInlineStyle`) and the node that produced me (the model of my shapes).

Kinds:

- `#text` (text, split at blanks by the flow),
- `#space` (a soft break: one blank),
- `#break` (a line break),
- `#code` (a code span, split at its spaces into chips),
- `#atom` (an image or its placeholder: `shape` and `ascent`, the part of the shape above the baseline).
"
Class {
	#name : 'CMarkInlineRun',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'string',
		'style',
		'node',
		'shape',
		'ascent'
	],
	#category : 'CMark-Roassal-Inline',
	#package : 'CMark-Roassal',
	#tag : 'Inline'
}

{ #category : 'instance creation' }
CMarkInlineRun class >> atom: aShape ascent: aNumber style: aStyle node: aNode [
	^ self new
		  setKind: #atom string: '' style: aStyle node: aNode;
		  setShape: aShape ascent: aNumber;
		  yourself
]

{ #category : 'instance creation' }
CMarkInlineRun class >> kind: aSymbol string: aString style: aStyle node: aNode [
	^ self new
		  setKind: aSymbol string: aString style: aStyle node: aNode;
		  yourself
]

{ #category : 'accessing' }
CMarkInlineRun >> ascent [
	"For an atom: the height of its shape above the baseline"

	^ ascent
]

{ #category : 'accessing' }
CMarkInlineRun >> kind [
	^ kind
]

{ #category : 'accessing' }
CMarkInlineRun >> node [
	^ node
]

{ #category : 'printing' }
CMarkInlineRun >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: kind;
		space;
		print: string;
		nextPut: $)
]

{ #category : 'private' }
CMarkInlineRun >> setKind: aSymbol string: aString style: aStyle node: aNode [
	kind := aSymbol.
	string := aString.
	style := aStyle.
	node := aNode
]

{ #category : 'private' }
CMarkInlineRun >> setShape: aShape ascent: aNumber [
	shape := aShape.
	ascent := aNumber
]

{ #category : 'accessing' }
CMarkInlineRun >> shape [
	"For an atom: its shape"

	^ shape
]

{ #category : 'accessing' }
CMarkInlineRun >> string [
	^ string
]

{ #category : 'accessing' }
CMarkInlineRun >> style [
	^ style
]
