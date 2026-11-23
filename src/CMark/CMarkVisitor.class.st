"
I visit a tree of `CMarkNode`s by double dispatch: `visit: aNode` sends `aNode acceptCMarkVisitor: me`, which sends me the visit method of its class (`visitHeading:`, `visitLink:`...). Each visit method defaults to `visitNode:`, which visits the children in order (`visitChildren:`) and answers the node; `visitTaskItem:` defaults to `visitItem:` and `visitTableHeaderRow:` to `visitTableRow:`. Subclasses override the methods of the nodes they care about.

Visiting recurses, once per level of the tree, so it is for bounded trees (`CMarkOptions maxDepth` bounds the parsed ones); the walks of the library (`CMarkNode>>do:`, `plainText`, `treeString`, `CMarkTreeDecoder`) are iterative.
"
Class {
	#name : 'CMarkVisitor',
	#superclass : 'Object',
	#category : 'CMark-Visitors',
	#package : 'CMark',
	#tag : 'Visitors'
}

{ #category : 'visiting' }
CMarkVisitor >> visit: aNode [
	^ aNode acceptCMarkVisitor: self
]

{ #category : 'visiting' }
CMarkVisitor >> visitBlockQuote: aBlockQuote [
	^ self visitNode: aBlockQuote
]

{ #category : 'visiting' }
CMarkVisitor >> visitChildren: aNode [
	"Visit the children of aNode in order; answer aNode"

	aNode children do: [ :each | self visit: each ].
	^ aNode
]

{ #category : 'visiting' }
CMarkVisitor >> visitCode: aCode [
	^ self visitNode: aCode
]

{ #category : 'visiting' }
CMarkVisitor >> visitCodeBlock: aCodeBlock [
	^ self visitNode: aCodeBlock
]

{ #category : 'visiting' }
CMarkVisitor >> visitCustomBlock: aCustomBlock [
	^ self visitNode: aCustomBlock
]

{ #category : 'visiting' }
CMarkVisitor >> visitCustomInline: aCustomInline [
	^ self visitNode: aCustomInline
]

{ #category : 'visiting' }
CMarkVisitor >> visitDocument: aDocument [
	^ self visitNode: aDocument
]

{ #category : 'visiting' }
CMarkVisitor >> visitEmph: anEmph [
	^ self visitNode: anEmph
]

{ #category : 'visiting' }
CMarkVisitor >> visitFootnoteDefinition: aFootnoteDefinition [
	^ self visitNode: aFootnoteDefinition
]

{ #category : 'visiting' }
CMarkVisitor >> visitFootnoteReference: aFootnoteReference [
	^ self visitNode: aFootnoteReference
]

{ #category : 'visiting' }
CMarkVisitor >> visitHeading: aHeading [
	^ self visitNode: aHeading
]

{ #category : 'visiting' }
CMarkVisitor >> visitHtmlBlock: aHtmlBlock [
	^ self visitNode: aHtmlBlock
]

{ #category : 'visiting' }
CMarkVisitor >> visitHtmlInline: aHtmlInline [
	^ self visitNode: aHtmlInline
]

{ #category : 'visiting' }
CMarkVisitor >> visitImage: anImage [
	^ self visitNode: anImage
]

{ #category : 'visiting' }
CMarkVisitor >> visitItem: anItem [
	^ self visitNode: anItem
]

{ #category : 'visiting' }
CMarkVisitor >> visitLineBreak: aLineBreak [
	^ self visitNode: aLineBreak
]

{ #category : 'visiting' }
CMarkVisitor >> visitLink: aLink [
	^ self visitNode: aLink
]

{ #category : 'visiting' }
CMarkVisitor >> visitList: aList [
	^ self visitNode: aList
]

{ #category : 'visiting' }
CMarkVisitor >> visitNode: aNode [
	"The default of every visit method: visit the children"

	^ self visitChildren: aNode
]

{ #category : 'visiting' }
CMarkVisitor >> visitParagraph: aParagraph [
	^ self visitNode: aParagraph
]

{ #category : 'visiting' }
CMarkVisitor >> visitSoftBreak: aSoftBreak [
	^ self visitNode: aSoftBreak
]

{ #category : 'visiting' }
CMarkVisitor >> visitStrikethrough: aStrikethrough [
	^ self visitNode: aStrikethrough
]

{ #category : 'visiting' }
CMarkVisitor >> visitStrong: aStrong [
	^ self visitNode: aStrong
]

{ #category : 'visiting' }
CMarkVisitor >> visitTable: aTable [
	^ self visitNode: aTable
]

{ #category : 'visiting' }
CMarkVisitor >> visitTableCell: aTableCell [
	^ self visitNode: aTableCell
]

{ #category : 'visiting' }
CMarkVisitor >> visitTableHeaderRow: aTableHeaderRow [
	^ self visitTableRow: aTableHeaderRow
]

{ #category : 'visiting' }
CMarkVisitor >> visitTableRow: aTableRow [
	^ self visitNode: aTableRow
]

{ #category : 'visiting' }
CMarkVisitor >> visitTaskItem: aTaskItem [
	^ self visitItem: aTaskItem
]

{ #category : 'visiting' }
CMarkVisitor >> visitText: aText [
	^ self visitNode: aText
]

{ #category : 'visiting' }
CMarkVisitor >> visitThematicBreak: aThematicBreak [
	^ self visitNode: aThematicBreak
]

{ #category : 'visiting' }
CMarkVisitor >> visitUnknownBlock: anUnknownBlock [
	^ self visitNode: anUnknownBlock
]

{ #category : 'visiting' }
CMarkVisitor >> visitUnknownInline: anUnknownInline [
	^ self visitNode: anUnknownInline
]
