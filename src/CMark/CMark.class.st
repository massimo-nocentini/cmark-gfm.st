"
I am the facade of CMark, on my class side only: I parse Markdown into a tree of CMarkNodes and render it to text through the CMarkPlugin of the VM, by delegating to CMarkParser and CMarkFormatter.

	CMark parse: '# Hello *world*'.                            ""a CMarkDocument, with CMarkOptions gfm""
	CMark parse: aString options: (CMarkOptions commonMark smart: true).
	CMark html: '# Hi'.                                         ""'<h1>Hi</h1>', LF""
	CMark render: '# Hi' format: #latex.                        ""#html #xml #commonmark #plaintext #latex #man""
	CMark isAvailable.  CMark version.  CMark statistics.

Without the plugin, parsing and rendering signal CMarkUnavailable; hand-built trees need no plugin.
"
Class {
	#name : 'CMark',
	#superclass : 'Object',
	#category : 'CMark-Facade',
	#package : 'CMark',
	#tag : 'Facade'
}

{ #category : 'rendering' }
CMark class >> html: aString [
	"The HTML of the Markdown aString, as GitHub Flavored Markdown (CMarkOptions gfm)"

	^ CMarkFormatter html: aString
]

{ #category : 'plugin' }
CMark class >> isAvailable [
	"Whether the VM has a CMarkPlugin that I can use"

	^ CMarkPrimitives isAvailable
]

{ #category : 'parsing' }
CMark class >> parse: aStringOrByteArray [
	"The CMarkDocument of the Markdown aStringOrByteArray (a String, or a ByteArray of UTF-8), as GitHub Flavored Markdown (CMarkOptions gfm)"

	^ CMarkParser parse: aStringOrByteArray
]

{ #category : 'parsing' }
CMark class >> parse: aStringOrByteArray options: aCMarkOptions [
	"The CMarkDocument of the Markdown aStringOrByteArray parsed with aCMarkOptions"

	^ CMarkParser parse: aStringOrByteArray options: aCMarkOptions
]

{ #category : 'rendering' }
CMark class >> render: aString format: aSymbol [
	"The Markdown aString rendered as aSymbol (#html #xml #commonmark #plaintext #latex #man), as GitHub Flavored Markdown"

	^ CMarkFormatter render: aString format: aSymbol
]

{ #category : 'rendering' }
CMark class >> render: aString format: aSymbol options: aCMarkOptions [
	"The Markdown aString rendered as aSymbol with aCMarkOptions"

	^ CMarkFormatter render: aString format: aSymbol options: aCMarkOptions
]

{ #category : 'plugin' }
CMark class >> statistics [
	"The counters of the plugin (a Dictionary: parses, renders, reused, overBudget, tooLarge, tooDeep, cLimit, kept), or nil without the plugin"

	^ CMarkPrimitives pluginStatistics
]

{ #category : 'plugin' }
CMark class >> version [
	"The version of cmark-gfm in the plugin ('0.29.0.gfm.14'), or nil without the plugin"

	^ CMarkPrimitives pluginInfo ifNotNil: [ :info | info at: 3 ]
]
