"
I am the abstract node of a parse tree of cmark-gfm.  My subclasses are one class per node type (CMarkHeading, CMarkParagraph, CMarkLink...), under CMarkBlockNode and CMarkInlineNode; the task items (CMarkTaskItem) and the header rows (CMarkTableHeaderRow) are classes of their own too.

I hold my parent, my children (an Array; leaves share an empty literal), the flags of the tape, the position of cmark (startLine, startByteColumn, endLine, endByteColumn: the columns count bytes of the UTF-8 line, as cmark does) and the 1-based character indices in the source of my first and last characters (startIndex, endIndex; sourceInterval, sourceText).  A node without a position (a soft or line break, a cell that cmark padded, a hand-built node) has 0 everywhere and hasSourcePosition false.

Navigation: parent, children, document, firstChild, lastChild, nextSibling, previousSibling, indexInParent, ancestors (nearest first), depth (the document has 1).  The walks do:, allNodes, select:, detect:ifNone:, plainText and treeString are iterative, with an explicit stack, so a tree of any depth walks in constant stack; the visitor (acceptCMarkVisitor:, CMarkVisitor) recurses and is for bounded trees.

Building by hand: new answers a node with no children, addChild: sets the parent and answers the child, withAll: and with: take a collection of children, and the subclasses have constructors (CMarkText literal:, CMarkHeading level:with:, CMarkList ordered:, CMarkTable alignments:...).

Decoding (CMarkTreeDecoder): typeCode is defined only by the class that owns a code of the tape (a subclass inherits it, but the decoder maps the code to the owner), cmarkClassForFlags: picks the flag variant, and cmarkRead:record: reads the fields of the type.
"
Class {
	#name : 'CMarkNode',
	#superclass : 'Object',
	#instVars : [
		'parent',
		'children',
		'flags',
		'startLine',
		'startByteColumn',
		'endLine',
		'endByteColumn',
		'startIndex',
		'endIndex'
	],
	#category : 'CMark-Nodes',
	#package : 'CMark',
	#tag : 'Nodes'
}

{ #category : 'decoding' }
CMarkNode class >> cmarkClassForFlags: anInteger [
	"The class of a node of my code with the flags anInteger: me"

	^ self
]

{ #category : 'testing' }
CMarkNode class >> isAbstract [
	^ self == CMarkNode
]

{ #category : 'instance creation' }
CMarkNode class >> new [
	"A node with no children and no position"

	^ self basicNew initialize
]

{ #category : 'accessing' }
CMarkNode class >> typeCode [
	"The code of my type in the tape of the plugin, or nil: only the class that owns a code defines it to answer the code (not the abstract classes, not the flag variants CMarkTaskItem and CMarkTableHeaderRow, which answer nil); a subclass of an owner inherits the code but does not own it, so the tape still decodes to the owner"

	^ nil
]

{ #category : 'accessing' }
CMarkNode class >> typeName [
	"The name of my type, as cmark names it (cmark_node_get_type_string)"

	^ 'node'
]

{ #category : 'instance creation' }
CMarkNode class >> with: anArray [
	"A node whose children are the nodes of anArray"

	^ self withAll: anArray
]

{ #category : 'instance creation' }
CMarkNode class >> withAll: aCollection [
	"A node whose children are the nodes of aCollection"

	^ self new
		addAll: aCollection;
		yourself
]

{ #category : 'visiting' }
CMarkNode >> acceptCMarkVisitor: aVisitor [
	^ self subclassResponsibility
]

{ #category : 'building' }
CMarkNode >> addAll: aCollection [
	"Add the nodes of aCollection as my last children, in order (taking each from its parent, if any); answer aCollection.  The whole collection is checked first: a node that comes twice, or that is me or one of my ancestors, signals CMarkError, and then nothing has changed"

	| nodes |
	nodes := aCollection asArray.
	nodes asIdentitySet size = nodes size ifFalse: [ CMarkError signal: 'a node cannot be added twice' ].
	nodes do: [ :each | self cmarkCheckAdoptable: each ].
	nodes do: [ :each | self cmarkAdopt: each ].
	children := children , nodes.
	^ aCollection
]

{ #category : 'building' }
CMarkNode >> addChild: aNode [
	"Add aNode as my last child (taking it from its parent, if any); answer aNode"

	self cmarkAdopt: aNode.
	children := children copyWith: aNode.
	^ aNode
]

{ #category : 'walking' }
CMarkNode >> allNodes [
	"Me and my descendants, in pre-order (document order)"

	| all |
	all := OrderedCollection new.
	self do: [ :each | all add: each ].
	^ all asArray
]

{ #category : 'navigation' }
CMarkNode >> ancestors [
	"My parent, its parent, and so on up to the root"

	| all node |
	all := OrderedCollection new.
	node := parent.
	[ node notNil ] whileTrue: [
		all add: node.
		node := node parent ].
	^ all asArray
]

{ #category : 'accessing' }
CMarkNode >> children [
	"My children, in order (an Array: do not change it, use addChild:)"

	^ children
]

{ #category : 'decoding' }
CMarkNode >> cmarkAddDecodedReference: aFootnoteReference [
	"A footnote reference of the tape points at me: only a footnote definition accepts it"

	^ CMarkMalformedTree signal: 'a footnote reference points at a ' , self typeName
]

{ #category : 'private' }
CMarkNode >> cmarkAdopt: aNode [
	"Make me the parent of aNode, which leaves its old parent; a node cannot be its own ancestor"

	self cmarkCheckAdoptable: aNode.
	aNode parent ifNotNil: [ :oldParent | oldParent removeChild: aNode ].
	aNode cmarkParent: self
]

{ #category : 'private' }
CMarkNode >> cmarkCheckAdoptable: aNode [
	"Signal CMarkError when aNode is me or one of my ancestors: it cannot become my child"

	| node |
	node := self.
	[ node notNil ] whileTrue: [
		node == aNode ifTrue: [ CMarkError signal: 'a node cannot be added to itself or to its descendants' ].
		node := node parent ]
]

{ #category : 'plain text' }
CMarkNode >> cmarkAppendPlainTextOn: aStream [
	"Append my own part of plainText (not my children's)"
]

{ #category : 'private' }
CMarkNode >> cmarkChildren: anArray [
	children := anArray
]

{ #category : 'decoding' }
CMarkNode >> cmarkDecodedFlags: anInteger startLine: sl startByteColumn: sc endLine: el endByteColumn: ec startIndex: si endIndex: ei [
	flags := anInteger.
	startLine := sl.
	startByteColumn := sc.
	endLine := el.
	endByteColumn := ec.
	startIndex := si.
	endIndex := ei
]

{ #category : 'testing' }
CMarkNode >> cmarkHasFlag: aMask [
	"Whether the flag aMask (CMarkTreeDecoder flagTight...) is set"

	^ (flags bitAnd: aMask) ~= 0
]

{ #category : 'private' }
CMarkNode >> cmarkParent: aNode [
	parent := aNode
]

{ #category : 'printing' }
CMarkNode >> cmarkPrintAttributesOn: aStream [
	"Print my own fields, as name value pairs separated by commas, for printOn:; answer whether I printed anything"

	^ false
]

{ #category : 'printing' }
CMarkNode >> cmarkPrintLiteral: aString on: aStream [
	"Print aString quoted, as the dump of cmark does: backslash, quote, newline, carriage return and tab escaped"

	aStream nextPut: $".
	aString do: [ :each |
		each = $\ ifTrue: [ aStream nextPutAll: '\\' ] ifFalse: [
		each = $" ifTrue: [ aStream nextPutAll: '\"' ] ifFalse: [
		each = Character lf ifTrue: [ aStream nextPutAll: '\n' ] ifFalse: [
		each = Character cr ifTrue: [ aStream nextPutAll: '\r' ] ifFalse: [
		each = Character tab ifTrue: [ aStream nextPutAll: '\t' ] ifFalse: [
		aStream nextPut: each ] ] ] ] ] ].
	aStream nextPut: $"
]

{ #category : 'printing' }
CMarkNode >> cmarkPrintShort: aString on: aStream [
	"Print aString for printOn:, cut after 40 characters"

	aString size <= 40
		ifTrue: [ aStream print: aString ]
		ifFalse: [ aStream print: (aString copyFrom: 1 to: 40); nextPutAll: '...' ]
]

{ #category : 'printing' }
CMarkNode >> cmarkPrintTreeAttributesOn: aStream [
	"Print my own fields for treeString, each as a space and name=value"
]

{ #category : 'printing' }
CMarkNode >> cmarkPrintTreeLineOn: aStream [
	"Print my line of treeString: type name, position of cmark, fields"

	aStream
		nextPutAll: self typeName;
		space;
		print: startLine;
		nextPut: $:;
		print: startByteColumn;
		nextPut: $-;
		print: endLine;
		nextPut: $:;
		print: endByteColumn.
	self cmarkPrintTreeAttributesOn: aStream
]

{ #category : 'decoding' }
CMarkNode >> cmarkRead: aDecoder record: base [
	"Read my own fields from the record of aDecoder that starts after the word base: none"
]

{ #category : 'decoding' }
CMarkNode >> cmarkSortReferences [
	"Put my footnote references in source order: I have none"
]

{ #category : 'navigation' }
CMarkNode >> depth [
	"My depth in my tree: 1 for the root (the document)"

	| d node |
	d := 1.
	node := parent.
	[ node notNil ] whileTrue: [
		d := d + 1.
		node := node parent ].
	^ d
]

{ #category : 'walking' }
CMarkNode >> detect: aBlock ifNone: exceptionBlock [
	"The first of me and my descendants, in pre-order, for which aBlock answers true, or the value of exceptionBlock"

	self do: [ :each | (aBlock value: each) ifTrue: [ ^ each ] ].
	^ exceptionBlock value
]

{ #category : 'walking' }
CMarkNode >> do: aBlock [
	"Evaluate aBlock with me and each of my descendants, in pre-order (document order), with an explicit stack"

	| stack node kids |
	stack := OrderedCollection with: self.
	[ stack isEmpty ] whileFalse: [
		node := stack removeLast.
		aBlock value: node.
		kids := node children.
		kids size to: 1 by: -1 do: [ :i | stack addLast: (kids at: i) ] ]
]

{ #category : 'navigation' }
CMarkNode >> document [
	"The CMarkDocument at the root of my tree, or nil when the root is not a document"

	| node |
	node := self root.
	^ node isDocument
		  ifTrue: [ node ]
		  ifFalse: [ nil ]
]

{ #category : 'navigation' }
CMarkNode >> enclosingLink [
	"The nearest CMarkLink among my ancestors, or nil"

	| node |
	node := parent.
	[ node notNil ] whileTrue: [
		node isLink ifTrue: [ ^ node ].
		node := node parent ].
	^ nil
]

{ #category : 'positions' }
CMarkNode >> endByteColumn [
	"The end column of cmark: the 1-based byte offset in its UTF-8 line of my last byte, inclusive; 0 means that I end at the end of the line before endLine (or that I have no position)"

	^ endByteColumn
]

{ #category : 'positions' }
CMarkNode >> endIndex [
	"The 1-based index in the source of my last character, inclusive (startIndex - 1 for an empty span), or 0 without a position"

	^ endIndex
]

{ #category : 'positions' }
CMarkNode >> endLine [
	"The 1-based end line of cmark, or 0 without a position"

	^ endLine
]

{ #category : 'navigation' }
CMarkNode >> firstChild [
	"My first child, or nil"

	^ children isEmpty
		  ifTrue: [ nil ]
		  ifFalse: [ children first ]
]

{ #category : 'accessing' }
CMarkNode >> flags [
	"The flags of my record of the tape (CMarkTreeDecoder flagTight...), 0 for a hand-built node"

	^ flags
]

{ #category : 'positions' }
CMarkNode >> hasSourcePosition [
	"Whether I have a position in the source (hand-built nodes, soft and line breaks and the cells that cmark padded have none)"

	^ self cmarkHasFlag: CMarkTreeDecoder flagHasPosition
]

{ #category : 'navigation' }
CMarkNode >> indexInParent [
	"My index among the children of my parent, or nil without a parent"

	^ parent ifNotNil: [ :p | p children identityIndexOf: self ]
]

{ #category : 'initialization' }
CMarkNode >> initialize [
	super initialize.
	children := #(  ).
	flags := 0.
	startLine := 0.
	startByteColumn := 0.
	endLine := 0.
	endByteColumn := 0.
	startIndex := 0.
	endIndex := 0
]

{ #category : 'initialization' }
CMarkNode >> initializeDecoded [
	"Initialize me before CMarkTreeDecoder sets my fields"

	self initialize
]

{ #category : 'inspector' }
CMarkNode >> inspectionCMarkSource [
	"The source text of my node, for the inspector"

	<inspectorPresentationOrder: 2 title: 'Source'>
	^ SpTextPresenter new
		  text: (self sourceText ifNil: [ '' ]);
		  yourself
]

{ #category : 'inspector' }
CMarkNode >> inspectionCMarkSourceContext: aContext [
	aContext active: self hasSourcePosition
]

{ #category : 'inspector' }
CMarkNode >> inspectionCMarkTree [
	"My tree, for the inspector"

	<inspectorPresentationOrder: 0 title: 'CMark'>
	^ SpTreePresenter new
		  roots: { self };
		  children: [ :each | each children ];
		  display: [ :each | each printString ];
		  yourself
]

{ #category : 'testing' }
CMarkNode >> isBlock [
	"Whether I am a block node"

	^ false
]

{ #category : 'testing' }
CMarkNode >> isClamped [
	"Whether the plugin clamped one of my positions, which pointed outside the source (the angle autolinks of gfm.14, docs/CMark.md, Limitations); a wrong position inside the line, such as those of the inlines after an escaped pipe in a table cell (see CMarkTableCell), is not clamped"

	^ self cmarkHasFlag: CMarkTreeDecoder flagClamped
]

{ #category : 'testing' }
CMarkNode >> isDocument [
	^ false
]

{ #category : 'testing' }
CMarkNode >> isExtension [
	"Whether I come from an extension of cmark (table, strikethrough, tasklist)"

	^ self cmarkHasFlag: CMarkTreeDecoder flagExtension
]

{ #category : 'testing' }
CMarkNode >> isFootnoteDefinition [
	^ false
]

{ #category : 'testing' }
CMarkNode >> isHeading [
	^ false
]

{ #category : 'testing' }
CMarkNode >> isInline [
	"Whether I am an inline node"

	^ false
]

{ #category : 'testing' }
CMarkNode >> isLeaf [
	"Whether I have no children"

	^ children isEmpty
]

{ #category : 'testing' }
CMarkNode >> isLink [
	^ false
]

{ #category : 'navigation' }
CMarkNode >> lastChild [
	"My last child, or nil"

	^ children isEmpty
		  ifTrue: [ nil ]
		  ifFalse: [ children last ]
]

{ #category : 'navigation' }
CMarkNode >> nextSibling [
	"The child of my parent after me, or nil"

	| i siblings |
	parent ifNil: [ ^ nil ].
	siblings := parent children.
	i := siblings identityIndexOf: self.
	^ i < siblings size
		  ifTrue: [ siblings at: i + 1 ]
		  ifFalse: [ nil ]
]

{ #category : 'accessing' }
CMarkNode >> parent [
	"My parent, or nil for the root"

	^ parent
]

{ #category : 'plain text' }
CMarkNode >> plainText [
	"The text of me and my descendants: the literals of the texts, code spans and inline HTML, a soft break as a space, a line break as a line feed"

	^ String streamContents: [ :stream |
		  self do: [ :each | each cmarkAppendPlainTextOn: stream ] ]
]

{ #category : 'navigation' }
CMarkNode >> previousSibling [
	"The child of my parent before me, or nil"

	| i siblings |
	parent ifNil: [ ^ nil ].
	siblings := parent children.
	i := siblings identityIndexOf: self.
	^ i > 1
		  ifTrue: [ siblings at: i - 1 ]
		  ifFalse: [ nil ]
]

{ #category : 'printing' }
CMarkNode >> printOn: aStream [
	"a CMarkHeading(level 1, 1:1-1:15): my own fields, then my position of cmark when I have one"

	| inner |
	super printOn: aStream.
	inner := String streamContents: [ :s |
		         | any |
		         any := self cmarkPrintAttributesOn: s.
		         self hasSourcePosition ifTrue: [
			         any ifTrue: [ s nextPutAll: ', ' ].
			         s
				         print: startLine;
				         nextPut: $:;
				         print: startByteColumn;
				         nextPut: $-;
				         print: endLine;
				         nextPut: $:;
				         print: endByteColumn ] ].
	inner isEmpty ifFalse: [
		aStream
			nextPut: $(;
			nextPutAll: inner;
			nextPut: $) ]
]

{ #category : 'building' }
CMarkNode >> removeChild: aNode [
	"Remove aNode from my children; answer it.  A node that is not my child signals CMarkError, and keeps its parent"

	(children identityIncludes: aNode) ifFalse: [ CMarkError signal: 'the node is not a child of this node' ].
	children := children reject: [ :each | each == aNode ].
	aNode cmarkParent: nil.
	^ aNode
]

{ #category : 'navigation' }
CMarkNode >> root [
	"The root of my tree: me when I have no parent"

	| node |
	node := self.
	[ node parent notNil ] whileTrue: [ node := node parent ].
	^ node
]

{ #category : 'walking' }
CMarkNode >> select: aBlock [
	"Me and my descendants, in pre-order, for which aBlock answers true"

	| all |
	all := OrderedCollection new.
	self do: [ :each | (aBlock value: each) ifTrue: [ all add: each ] ].
	^ all asArray
]

{ #category : 'positions' }
CMarkNode >> sourceInterval [
	"The interval of the indices of my characters in the source, or nil without a position"

	^ self hasSourcePosition
		  ifTrue: [ startIndex to: endIndex ]
		  ifFalse: [ nil ]
]

{ #category : 'positions' }
CMarkNode >> sourceText [
	"My characters in the sourceString of my document, or nil without a position or a document; a block that ends at the end of a line (endByteColumn 0) includes the line terminator"

	| source |
	self hasSourcePosition ifFalse: [ ^ nil ].
	source := self document ifNotNil: [ :d | d sourceString ].
	source ifNil: [ ^ nil ].
	(startIndex >= 1 and: [ endIndex <= source size and: [ startIndex <= (endIndex + 1) ] ]) ifFalse: [
		^ nil ].
	^ source copyFrom: startIndex to: endIndex
]

{ #category : 'positions' }
CMarkNode >> startByteColumn [
	"The start column of cmark: the 1-based byte offset in its UTF-8 line of my first byte, or 0 without a position"

	^ startByteColumn
]

{ #category : 'positions' }
CMarkNode >> startIndex [
	"The 1-based index in the source of my first character, or 0 without a position"

	^ startIndex
]

{ #category : 'positions' }
CMarkNode >> startLine [
	"The 1-based start line of cmark, or 0 without a position"

	^ startLine
]

{ #category : 'printing' }
CMarkNode >> treeString [
	"One line per node of my tree, in pre-order, indented by two spaces per level (at most 40 levels): the type name, the position of cmark (sl:sc-el:ec, byte columns, 0:0-0:0 without a position) and the fields"

	| stack depths node depth |
	stack := OrderedCollection with: self.
	depths := OrderedCollection with: 0.
	^ String streamContents: [ :stream |
		  [ stack isEmpty ] whileFalse: [
			  | kids |
			  node := stack removeLast.
			  depth := depths removeLast.
			  stream next: 2 * (depth min: 40) put: Character space.
			  node cmarkPrintTreeLineOn: stream.
			  stream nextPut: Character lf.
			  kids := node children.
			  kids size to: 1 by: -1 do: [ :i |
				  stack addLast: (kids at: i).
				  depths addLast: depth + 1 ] ] ]
]

{ #category : 'accessing' }
CMarkNode >> typeCode [
	"The code of my type in the tape"

	^ self class typeCode
]

{ #category : 'accessing' }
CMarkNode >> typeName [
	"The name of my type, as cmark names it"

	^ self class typeName
]
