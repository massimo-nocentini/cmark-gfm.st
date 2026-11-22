"
I am signalled by CMarkTreeDecoder when an answer of the plugin breaks an invariant of the tape (docs/CMark.md, Tree format): a wrong record size or count, a parent that does not come before its child, a document that is not record 1, a string outside the strings, bytes that are not UTF-8, a footnote reference to a record that is not a definition.  The plugin never answers such a tape; a hand-made one can.
"
Class {
	#name : 'CMarkMalformedTree',
	#superclass : 'CMarkError',
	#category : 'CMark-Errors',
	#package : 'CMark',
	#tag : 'Errors'
}
