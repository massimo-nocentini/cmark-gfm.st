"
I test the double dispatch of the nodes (each concrete class sends its own visit method) and the defaults of `CMarkVisitor` (every visit method reaches `visitNode:`, `visitTaskItem:` goes through `visitItem:`, `visitTableHeaderRow:` through `visitTableRow:`).
"
Class {
	#name : 'CMarkVisitorTest',
	#superclass : 'CMarkTestCase',
	#category : 'CMark-Tests-Tests',
	#package : 'CMark-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CMarkVisitorTest >> concreteClasses [
	^ (CMarkNode allSubclasses reject: [ :each | each isAbstract ]) asArray
]

{ #category : 'tests' }
CMarkVisitorTest >> testDefaultsReachVisitNode [
	| doc visitor task header row |
	doc := CMarkDocument withAll: ((self concreteClasses copyWithout: CMarkDocument) collect: [ :each | each new ]).
	visitor := CMarkRecordingVisitor new.
	self assert: (visitor visit: doc) identicalTo: doc.
	self assert: visitor visited asArray equals: doc allNodes.
	task := doc children detect: [ :each | each class == CMarkTaskItem ].
	header := doc children detect: [ :each | each class == CMarkTableHeaderRow ].
	row := doc children detect: [ :each | each class == CMarkTableRow ].
	self assert: (visitor items includes: task).
	self assert: (visitor items includes: (doc children detect: [ :each | each class == CMarkItem ])).
	self assert: visitor items size equals: 2.
	self assert: (visitor rows includes: header).
	self assert: (visitor rows includes: row).
	self assert: visitor rows size equals: 2
]

{ #category : 'tests' }
CMarkVisitorTest >> testEveryClassSendsItsVisit [
	self concreteClasses do: [ :each |
		| recorder selector node |
		recorder := CMarkSelectorRecorder new.
		node := each new.
		self assert: (node acceptCMarkVisitor: recorder) identicalTo: node.
		selector := ('visit' , (each name allButFirst: 5) , ':') asSymbol.
		self assert: recorder selectors asArray equals: { selector }.
		self assert: (CMarkVisitor includesSelector: selector) ]
]

{ #category : 'tests' }
CMarkVisitorTest >> testVisitChildrenInOrder [
	| p visitor |
	p := CMarkParagraph with: {
			     (CMarkText literal: 'a').
			     (CMarkStrong with: { (CMarkText literal: 'b') }).
			     (CMarkText literal: 'c') }.
	visitor := CMarkRecordingVisitor new.
	self assert: (visitor visitChildren: p) identicalTo: p.
	self assert: (visitor visited collect: [ :each | each typeName ]) asArray equals: #( 'text' 'strong' 'text' 'text' )
]
