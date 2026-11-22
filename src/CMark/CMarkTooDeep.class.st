"
I am signalled when the tree of a source is deeper than the maxDepth of the CMarkOptions (status 3 of the plugin): actual is the depth of the first node too deep (maxDepth + 1).  The document has depth 1.  No tree is answered (strict mode); maxDepth: nil lifts the limit.
"
Class {
	#name : 'CMarkTooDeep',
	#superclass : 'CMarkLimitExceeded',
	#category : 'CMark-Errors',
	#package : 'CMark',
	#tag : 'Errors'
}

{ #category : 'accessing' }
CMarkTooDeep >> limitName [
	^ 'the tree depth'
]
