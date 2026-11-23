"
I show the comment of a class as Markdown: cmark-gfm parses it (`CMarkOptions gfm`, without footnotes: see `options`) and `CMarkRoassalRenderer` draws it in the canvas of an `SpRoassalPresenter`.

- As with `CMarkRoassalRenderer>>canvasFor:`, the camera fits the width and shows the top, again whenever the view is resized, and a canvas controller zooms and pans (the wheel, a drag, the keys once a click gave the canvas the focus).
- The theme follows the UI theme of Pharo (`CMarkRoassalTheme dark` on a dark UI theme, `default` on a light one, both wrapping long code lines and long words so that the page keeps the width of the theme) unless `markdownTheme:` sets one; once built, I draw again when the UI theme changes (`uiThemeChanged`).

```smalltalk
(CMarkCommentPresenter on: CMarkRoassalRenderer) open.
```

I am the content of the Markdown tab of the Calypso browser (`CMarkClassCommentToolMorph`), and work alone too.

## Drawing again

I draw again when the comment of my class changes (`ClassCommented`, from the `SystemAnnouncer`, to which I subscribe weakly when I am made) and when `targetClass:` gives me another class.

I draw in the Morphic UI process only (`refresh`): a change announced by another process (a load in the background, a theme set by a script) is drawn by the UI process at its next cycle, and the changes that wait for it are drawn once.

I unsubscribe when my window closes (`windowIsClosing`) or when told to (`unsubscribe`: the Calypso tab does it when it is removed, and when its browser closes).

I never fail on a comment: an empty comment, a VM without the `CMarkPlugin` and a comment that cmark refuses each show a short muted note instead.
"
Class {
	#name : 'CMarkCommentPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'targetClass',
		'roassal',
		'markdownTheme',
		'shape',
		'refreshPending'
	],
	#category : 'CMark-Calypso-Presenter',
	#package : 'CMark-Calypso',
	#tag : 'Presenter'
}

{ #category : 'comments' }
CMarkCommentPresenter class >> commentOf: aClassOrNil [
	"The comment of aClassOrNil (of its instance side: a metaclass has its class's comment), '' when it has none, when it was removed (obsolete) or when its comment cannot be read (the changes file being written by another process)"

	(aClassOrNil isNil or: [ aClassOrNil isObsolete ]) ifTrue: [ ^ '' ].
	^ [ aClassOrNil instanceSide comment ifNil: [ '' ] ]
		  on: Error
		  do: [ :error | '' ]
]

{ #category : 'comments' }
CMarkCommentPresenter class >> hasCommentToShow: aClassOrNil [
	"Whether aClassOrNil has a comment that is not only blanks (isBlank:)"

	^ ((self commentOf: aClassOrNil) allSatisfy: [ :each | self isBlank: each ]) not
]

{ #category : 'comments' }
CMarkCommentPresenter class >> isBlank: aCharacter [
	"Whether aCharacter shows nothing: a separator, a Unicode space (White_Space: no-break space, en quad to hair space, narrow no-break space, ideographic space...), a zero width space or a byte order mark"

	aCharacter isSeparator ifTrue: [ ^ true ].
	^ #( 16r85 16rA0 16r1680 16r2000 16r2001 16r2002 16r2003 16r2004 16r2005 16r2006 16r2007 16r2008 16r2009 16r200A 16r200B 16r2028 16r2029 16r202F 16r205F 16r3000 16rFEFF )
		  includes: aCharacter asInteger
]

{ #category : 'theme' }
CMarkCommentPresenter class >> isDarkTheme: aUITheme [
	"Whether aUITheme is dark: its background is darker than mid-grey"

	^ [ aUITheme backgroundColor luminance < 0.5 ]
		  on: Error
		  do: [ :error | false ]
]

{ #category : 'theme' }
CMarkCommentPresenter class >> isDarkUITheme [
	"Whether the UI theme of Pharo is dark"

	^ self isDarkTheme: Smalltalk ui theme
]

{ #category : 'notes' }
CMarkCommentPresenter class >> noteDocument: aString [
	"A hand-built document of one paragraph, aString in emphasis: a note, which the presenter draws in the muted colour of its theme"

	^ CMarkDocument withAll: { (CMarkParagraph with: { (CMarkEmph with: { (CMarkText literal: aString) }) }) }
]

{ #category : 'parsing' }
CMarkCommentPresenter class >> options [
	"The options of the parse of a comment: GitHub Flavored Markdown, without footnotes, as everywhere in CMark: cmark-gfm 0.29.0.gfm.14 cuts short a footnote label that holds an inline or a line break, and the cut text disappears (README, Limitations).  Class comments are full of Smalltalk code such as [^self error: '...'], and seldom have footnotes"

	^ CMarkOptions gfm
]

{ #category : 'accessing' }
CMarkCommentPresenter >> canvas [
	"The canvas of my Roassal presenter, drawn: when I am not built yet, it is drawn now, and my build shows it"

	roassal currentCanvas ifNil: [
		| canvas |
		canvas := RSCanvas new.
		self drawOn: canvas.
		roassal canvas: canvas ].
	^ roassal currentCanvas
]

{ #category : 'announcements' }
CMarkCommentPresenter >> classCommented: aClassCommented [
	"The comment of a class changed: draw again when it is mine (refresh: in the UI process, as the announcing process may be another one)"

	(targetClass notNil and: [ aClassCommented classCommented instanceSide == targetClass instanceSide ]) ifTrue: [ self refresh ]
]

{ #category : 'accessing' }
CMarkCommentPresenter >> comment [
	"The comment that I show"

	^ self class commentOf: targetClass
]

{ #category : 'rendering' }
CMarkCommentPresenter >> contents [
	"What I draw: the comment parsed into a CMarkDocument, or the String of a note when there is no comment, no CMarkPlugin, or cmark refuses the comment"

	(self class hasCommentToShow: targetClass) ifFalse: [ ^ self emptyNote ].
	CMark isAvailable ifFalse: [ ^ self noPluginNote ].
	^ [ CMark parse: self comment options: self class options ]
		  on: CMarkError
		  do: [ :error | 'The comment cannot be shown as Markdown: ' , error description ]
]

{ #category : 'layout' }
CMarkCommentPresenter >> defaultLayout [
	^ SpBoxLayout newTopToBottom
		  add: roassal;
		  yourself
]

{ #category : 'rendering' }
CMarkCommentPresenter >> drawOn: aCanvas [
	"The script of my Roassal presenter: draw my contents on aCanvas, a new canvas (a note in the muted colour of the theme), and keep the shape"

	| theme contents |
	theme := self markdownTheme.
	contents := self contents.
	contents isString ifTrue: [
		theme := theme copy
			         textColor: theme mutedColor;
			         yourself.
		contents := self class noteDocument: contents ].
	shape := (CMarkRoassalRenderer theme: theme) show: contents on: aCanvas.
	"the morph of the canvas announces the changes of the UI theme of Pharo"
	aCanvas when: RSThemeChangedEvent do: [ :event | self uiThemeChanged ] for: self
	"the keys of the canvas controller act once a click gave the canvas the focus (RSAthensMorph>>mouseDown:); the pointer passing over it does not take the keys from the lists of the browser"
]

{ #category : 'notes' }
CMarkCommentPresenter >> emptyNote [
	^ 'This class has no comment.'
]

{ #category : 'initialization' }
CMarkCommentPresenter >> initialize [
	super initialize.
	self subscribe
]

{ #category : 'initialization' }
CMarkCommentPresenter >> initializePresenters [
	roassal := self instantiate: SpRoassalPresenter.
	roassal script: [ :canvas | self drawOn: canvas ]
]

{ #category : 'initialization' }
CMarkCommentPresenter >> initializeWindow: aWindowPresenter [
	aWindowPresenter
		title: self windowTitle;
		initialExtent: 720 @ 640
]

{ #category : 'announcements' }
CMarkCommentPresenter >> isSubscribed [
	"Whether I listen to the changes of comments"

	^ SystemAnnouncer uniqueInstance hasSubscriber: self
]

{ #category : 'accessing' }
CMarkCommentPresenter >> markdownTheme [
	"The CMarkRoassalTheme of the drawing: the one set (used as it is), else dark on a dark UI theme and default on a light one, both wrapping long code lines and long words.  The camera fits the width of the page: a code line that does not wrap would widen the page and shrink all of its text (tab-indented Smalltalk in a comment is a code block; the comment of Color was drawn at a quarter of its size)"

	^ markdownTheme ifNil: [
		  (self class isDarkUITheme
			   ifTrue: [ CMarkRoassalTheme dark ]
			   ifFalse: [ CMarkRoassalTheme default ])
			  codeWrap: #characters;
			  breakLongWords: true;
			  yourself ]
]

{ #category : 'accessing' }
CMarkCommentPresenter >> markdownTheme: aThemeOrNil [
	"Draw with aThemeOrNil (nil: follow the UI theme), by refresh, in the UI process"

	markdownTheme := aThemeOrNil.
	self refresh
]

{ #category : 'notes' }
CMarkCommentPresenter >> noPluginNote [
	^ 'The VM has no CMarkPlugin: the comment cannot be shown as Markdown.'
]

{ #category : 'accessing' }
CMarkCommentPresenter >> roassal [
	"My SpRoassalPresenter"

	^ roassal
]

{ #category : 'rendering' }
CMarkCommentPresenter >> refresh [
	"Draw again, in the Morphic UI process: now when I am in it (or when there is none: no world loop draws my morph), else at the next cycle of the UI process.  A comment changed by another process (a load in the background) was drawn by that process while the UI process drew the world, and the drawing failed now and then (MessageNotUnderstood: receiver of #intersect: is nil, in RSMorphicHost>>dirtyRectangle:).  A refresh asked while another one waits for the UI process adds nothing: the one that waits draws what there is when it runs.  When I am not built, no morph of mine is drawn by the UI process: the refresh is done now, in any process, so that the next canvas or shape of the caller shows the change"

	(roassal isNil or: [ roassal adapter isNil ]) ifTrue: [ ^ self refreshNow ].
	self isInUIProcess ifTrue: [ ^ self refreshNow ].
	refreshPending == true ifTrue: [ ^ self ].
	refreshPending := true.
	self currentWorld defer: [ refreshPending == true ifTrue: [ self refreshNow ] ]
]

{ #category : 'rendering' }
CMarkCommentPresenter >> isInUIProcess [
	"Whether the active process may draw my canvas: it is the Morphic UI process, or there is no UI process (no world loop runs the work deferred to it)"

	| uiProcess |
	uiProcess := MorphicUIManager uiProcess.
	^ uiProcess isNil or: [ uiProcess == Processor activeProcess or: [ uiProcess isTerminated ] ]
]

{ #category : 'rendering' }
CMarkCommentPresenter >> isRefreshPending [
	"Whether a refresh waits for the UI process (refresh)"

	^ refreshPending == true
]

{ #category : 'rendering' }
CMarkCommentPresenter >> refreshNow [
	"Draw again here, in the UI process or, when I am not built, in any process (refresh): on a new canvas of my Roassal presenter once it is built, else when it is built (or when canvas is asked).  A refresh that waits for the UI process has nothing more to do"

	refreshPending := false.
	roassal ifNil: [ ^ self ].
	roassal adapter
		ifNil: [ roassal canvas: nil ]
		ifNotNil: [ roassal refresh ].
	self withWindowDo: [ :window | window title: self windowTitle ]
]

{ #category : 'initialization' }
CMarkCommentPresenter >> setModel: aClass [
	self targetClass: aClass
]

{ #category : 'initialization' }
CMarkCommentPresenter >> setModelBeforeInitialization: aClass [
	targetClass := aClass
]

{ #category : 'accessing' }
CMarkCommentPresenter >> shape [
	"The RSComposite of the last drawing (its model is the document drawn), or nil before the first"

	^ shape
]

{ #category : 'announcements' }
CMarkCommentPresenter >> subscribe [
	"Listen to the changes of comments, weakly: a presenter that nobody holds any more is not kept by the subscription"

	self isSubscribed ifTrue: [ ^ self ].
	SystemAnnouncer uniqueInstance weak
		when: ClassCommented
		send: #classCommented:
		to: self
]

{ #category : 'accessing' }
CMarkCommentPresenter >> targetClass [
	"The class whose comment I show"

	^ targetClass
]

{ #category : 'accessing' }
CMarkCommentPresenter >> targetClass: aClass [
	"Show the comment of aClass (drawn by refresh, in the UI process)"

	targetClass := aClass.
	self refresh
]

{ #category : 'theme' }
CMarkCommentPresenter >> uiThemeChanged [
	"The UI theme of Pharo changed (the morph of my canvas got themeChanged, in the process that set the theme): draw again when my theme follows it (refresh: in the UI process)"

	markdownTheme ifNil: [ self refresh ]
]

{ #category : 'announcements' }
CMarkCommentPresenter >> unsubscribe [
	"Stop listening to the changes of comments"

	SystemAnnouncer uniqueInstance unsubscribe: self
]

{ #category : 'announcements' }
CMarkCommentPresenter >> windowIsClosing [
	self unsubscribe.
	super windowIsClosing
]

{ #category : 'accessing' }
CMarkCommentPresenter >> windowTitle [
	^ targetClass
		  ifNil: [ 'Comment' ]
		  ifNotNil: [ :aClass | 'Comment of ' , aClass instanceSide name ]
]
