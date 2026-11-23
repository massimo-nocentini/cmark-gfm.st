"
I parse Markdown into a `CMarkDocument` through the `CMarkPlugin`, with my options (a `CMarkOptions`, `CMarkOptions gfm` by default).

```smalltalk
CMarkParser parse: '# Hi'.
(CMarkParser new
	options: (CMarkOptions gfm footnotes: true; yourself);
	yourself) parse: aString.
```

`parse:` takes a ByteString (Latin-1), a WideString or a ByteArray of UTF-8; any other String (a Symbol) and a Text are converted (`cmarkSource`), anything else is a `CMarkError`. A source larger than the `maxInputSize` of the options signals `CMarkInputTooLarge` before any call.

Then the plugin parses (the budget loop of `CMarkPrimitives`), and `CMarkTreeDecoder` makes the tree. The statuses of the plugin signal `CMarkInputTooLarge`, `CMarkTooDeep` and `CMarkMemoryLimit`; without the plugin, `CMarkUnavailable`. The document keeps a copy of the options.
"
Class {
	#name : 'CMarkParser',
	#superclass : 'Object',
	#instVars : [
		'options'
	],
	#category : 'CMark-Facade',
	#package : 'CMark',
	#tag : 'Facade'
}

{ #category : 'parsing' }
CMarkParser class >> parse: aStringOrByteArray [
	"The CMarkDocument of aStringOrByteArray, with CMarkOptions gfm"

	^ self new parse: aStringOrByteArray
]

{ #category : 'parsing' }
CMarkParser class >> parse: aStringOrByteArray options: aCMarkOptions [
	"The CMarkDocument of aStringOrByteArray, with aCMarkOptions"

	^ self new
		  options: aCMarkOptions;
		  parse: aStringOrByteArray
]

{ #category : 'accessing' }
CMarkParser >> options [
	"The CMarkOptions I parse with (CMarkOptions gfm unless set)"

	^ options ifNil: [ options := CMarkOptions gfm ]
]

{ #category : 'accessing' }
CMarkParser >> options: aCMarkOptions [
	options := aCMarkOptions
]

{ #category : 'parsing' }
CMarkParser >> parse: aStringOrByteArray [
	"The CMarkDocument of the Markdown aStringOrByteArray"

	| source o answer |
	source := aStringOrByteArray cmarkSource.
	o := self options copy.
	o checkInputSize: source.
	answer := CMarkPrimitives
		          parse: source
		          options: o optionBits
		          extensions: o extensionBits
		          maxDepth: o maxDepthArgument
		          cBudget: o cBudgetArgument.
	(answer at: 1) = 0 ifFalse: [
		^ CMarkPrimitives signalStatusOf: answer maxDepth: o maxDepth cBudget: o cBudgetArgument ].
	^ CMarkTreeDecoder new decode: answer source: source options: o
]
