"
I am the small tokenizer of raw HTML for the #basic htmlStyle of the Roassal rendering: a few rules over the literal, no DOM, no entities beyond those that cmark already decoded, and nothing is ever executed.

tokensOf: answers an Array of tokens, each an Array whose first element is the selector that handles it in CMarkInlineRunCollector:
- { #htmlText:node:. aString }: the text between tags;
- { #htmlBreak:node: }: <br>, and the start or end tag of a block element (p, div, h1-h6, li, tr, pre, details, summary...);
- { #htmlImage:node:. src. alt }: <img> with its src and alt attributes ('' when absent).
Comments (<!-- -->), declarations, processing instructions and every other tag vanish.  A < that does not open a tag is text.
"
Class {
	#name : 'CMarkHtmlLite',
	#superclass : 'Object',
	#category : 'CMark-Roassal-Inline',
	#package : 'CMark-Roassal',
	#tag : 'Inline'
}

{ #category : 'parsing' }
CMarkHtmlLite class >> attribute: aName in: aTagString [
	"The value of the attribute aName (lowercase) in the inside of a tag, or ''"

	| lower i n quote end |
	lower := aTagString asLowercase.
	i := 1.
	[
	i := lower indexOfSubCollection: aName startingAt: i.
	i > 0 ] whileTrue: [
		((i = 1 or: [ (lower at: i - 1) isSeparator ]) and: [
			 n := i + aName size.
			 [ n <= lower size and: [ (lower at: n) isSeparator ] ] whileTrue: [ n := n + 1 ].
			 n <= lower size and: [ (lower at: n) = $= ] ]) ifTrue: [
			n := n + 1.
			[ n <= lower size and: [ (lower at: n) isSeparator ] ] whileTrue: [ n := n + 1 ].
			n > lower size ifTrue: [ ^ '' ].
			quote := aTagString at: n.
			(quote = $" or: [ quote = $' ])
				ifTrue: [
					end := aTagString indexOf: quote startingAt: n + 1.
					end = 0 ifTrue: [ end := aTagString size + 1 ].
					^ aTagString copyFrom: n + 1 to: end - 1 ]
				ifFalse: [
					end := n.
					[ end <= aTagString size and: [ (aTagString at: end) isSeparator not and: [ (aTagString at: end) ~= $/ ] ] ] whileTrue: [ end := end + 1 ].
					^ aTagString copyFrom: n to: end - 1 ] ].
		i := i + aName size ].
	^ ''
]

{ #category : 'parsing' }
CMarkHtmlLite class >> blockElements [
	"The elements whose start and end tags break the line"

	^ #( 'address' 'article' 'aside' 'blockquote' 'center' 'dd' 'details' 'dialog' 'dir' 'div' 'dl' 'dt' 'figcaption' 'figure' 'footer' 'form' 'h1' 'h2' 'h3' 'h4' 'h5' 'h6' 'header' 'hr' 'li' 'main' 'nav' 'ol' 'p' 'pre' 'section' 'summary' 'table' 'tbody' 'thead' 'tfoot' 'tr' 'ul' )
]

{ #category : 'parsing' }
CMarkHtmlLite class >> tagName: aTagString [
	"The lowercase name of the element of the inside of a tag (after its optional /)"

	| start end |
	start := 1.
	(aTagString notEmpty and: [ aTagString first = $/ ]) ifTrue: [ start := 2 ].
	end := start.
	[ end <= aTagString size and: [ (aTagString at: end) isAlphaNumeric ] ] whileTrue: [ end := end + 1 ].
	^ (aTagString copyFrom: start to: end - 1) asLowercase
]

{ #category : 'parsing' }
CMarkHtmlLite class >> tokenForTag: aTagString [
	"The token of the inside of a tag, or nil when the tag vanishes"

	| name |
	name := self tagName: aTagString.
	name = 'br' ifTrue: [ ^ { #htmlBreak:node: } ].
	name = 'img' ifTrue: [ ^ { #htmlImage:node:. self attribute: 'src' in: aTagString. self attribute: 'alt' in: aTagString } ].
	(self blockElements includes: name) ifTrue: [ ^ { #htmlBreak:node: } ].
	^ nil
]

{ #category : 'parsing' }
CMarkHtmlLite class >> tokensOf: aString [
	"The tokens of the raw HTML aString (see my class comment)"

	| tokens text in flush |
	tokens := OrderedCollection new.
	text := WriteStream on: (String new: aString size).
	flush := [
	         text contents ifNotEmpty: [ :s | tokens add: { #htmlText:node:. s } ].
	         text reset ].
	in := ReadStream on: aString.
	[ in atEnd ] whileFalse: [
		| c start close inside token |
		c := in next.
		(c = $< and: [ in atEnd not and: [ in peek isLetter or: [ '/!?' includes: in peek ] ] ])
			ifTrue: [
				start := in position.
				(in peek = $! and: [ (aString copyFrom: start + 1 to: (start + 3 min: aString size)) = '!--' ])
					ifTrue: [
						close := aString indexOfSubCollection: '-->' startingAt: start + 4.
						in position: (close = 0
								 ifTrue: [ aString size ]
								 ifFalse: [ close + 2 ]) ]
					ifFalse: [
						close := aString indexOf: $> startingAt: start + 1.
						close = 0
							ifTrue: [ text nextPut: c ]
							ifFalse: [
								inside := aString copyFrom: start + 1 to: close - 1.
								in position: close.
								token := self tokenForTag: inside.
								token ifNotNil: [
									flush value.
									tokens add: token ] ] ] ]
			ifFalse: [ text nextPut: c ] ].
	flush value.
	^ tokens asArray
]
