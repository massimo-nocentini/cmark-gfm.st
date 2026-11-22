"
I lay out the inline content of one block (the CMarkInlineRuns of CMarkInlineRunCollector) as lines of Roassal shapes, at a given width.  I do not use RSFlowLayout: it wraps on ink widths with one constant gap and cannot align mixed fonts on a baseline.

1. The runs become pieces: words (text split at blanks, which are exactly space, TAB, CR and LF and collapse; U+00A0 is not a blank), chips (a code span split at its spaces, each segment keeping its spacing) and atoms (images, placeholders).
2. Break opportunities exist only at blanks, soft and line breaks, and between the segments of a code span.  The pieces between two opportunities form one cluster (CMarkInlineCluster), across runs and atoms: [link](u). stays together.  A width is the sum of the advances per character (CMarkRoassalFonts), never RSLabel>>width.
3. Greedy breaking: a cluster moves to the next line when it does not fit and the line is not empty.  An overlong cluster overflows, or breaks by characters when the theme says breakLongWords.
4. On a line, consecutive words of the same run merge into one RSLabel (continuous underline and strike, far fewer shapes), and consecutive segments of one code span share one chip box (rounded and padded only at the ends of the span).  No label is ever made of an empty string.
5. Each line takes the largest ascent and descent of its pieces (and of the base font, so an empty line has the height of a line of the base font); every piece sits on the common baseline.  Lines are lineGap apart.  Lines are aligned left, centred or right (table cells).
6. The shape budget of the renderer (maxShapes) cuts my lines: once it is spent, no line after the first is made, and the renderer counts the block as cut short (budgeted: false exempts the messages of the budgets).

After layoutWidth:alignment:node: I answer my shapes (in local coordinates, the top-left of the first line at 0@0), my height, the y of my first baseline, the number and widths of my lines.  naturalWidth (the width of the widest line at an unlimited width) and minWidth (the widest cluster) need no layout: tables ask them first.
"
Class {
	#name : 'CMarkInlineFlow',
	#superclass : 'Object',
	#instVars : [
		'renderer',
		'fonts',
		'runs',
		'baseStyle',
		'clusters',
		'current',
		'pendingSpace',
		'pendingBreaks',
		'lines',
		'shapes',
		'height',
		'firstBaseline',
		'lineWidths',
		'budgeted'
	],
	#category : 'CMark-Roassal-Inline',
	#package : 'CMark-Roassal',
	#tag : 'Inline'
}

{ #category : 'instance creation' }
CMarkInlineFlow class >> renderer: aRenderer runs: aCollection baseStyle: aStyle [
	^ self new
		  setRenderer: aRenderer runs: aCollection baseStyle: aStyle;
		  yourself
]

{ #category : 'building' }
CMarkInlineFlow >> addAtom: aRun [
	| piece |
	piece := CMarkInlinePiece kind: #atom text: '' style: aRun style node: aRun node width: aRun shape width.
	piece shape: aRun shape.
	piece ascent: aRun ascent descent: (aRun shape height - aRun ascent max: 0).
	self addPiece: piece
]

{ #category : 'shapes' }
CMarkInlineFlow >> addAtomShapes: aPiece x: x baseline: baseline [
	| shape |
	shape := aPiece shape.
	shape translateTo: (x + (shape width / 2)) @ (baseline - aPiece ascent + (shape height / 2)).
	shapes add: shape
]

{ #category : 'building' }
CMarkInlineFlow >> addBlank: aStyle [
	current := nil.
	pendingSpace ifNil: [ pendingSpace := { ' '. fonts widthOf: ' ' in: aStyle } ]
]

{ #category : 'building' }
CMarkInlineFlow >> addBreak: aRun [
	current := nil.
	pendingSpace := nil.
	pendingBreaks := pendingBreaks + 1
]

{ #category : 'shapes' }
CMarkInlineFlow >> addChipShapes: aPiece x: x baseline: baseline [
	| mono text padY box label left boxWidth ascent |
	mono := aPiece style.
	text := aPiece isLast
		        ifTrue: [ aPiece text ]
		        ifFalse: [ aPiece text trimRight ].
	padY := renderer chipPadding y.
	ascent := fonts ascentOf: mono.
	boxWidth := (fonts widthOf: text in: mono) + (aPiece isFirst
		             ifTrue: [ aPiece pad ]
		             ifFalse: [ 0 ]) + (aPiece isLast
		             ifTrue: [ aPiece pad ]
		             ifFalse: [ 0 ]).
	box := renderer
		       chipBox: boxWidth @ ((fonts heightOf: mono) + (2 * padY))
		       first: aPiece isFirst
		       last: aPiece isLast
		       node: aPiece node.
	box translateTo: (x + (boxWidth / 2)) @ (baseline - ascent - padY + (box height / 2)).
	shapes add: box.
	mono isLink ifTrue: [ renderer attachInteractionsTo: box target: mono link ].
	text isEmpty ifTrue: [ ^ self ].
	label := renderer labelFor: text style: mono node: aPiece node.
	left := x + (aPiece isFirst
		         ifTrue: [ aPiece pad ]
		         ifFalse: [ 0 ]).
	label translateTo: (left + (label width / 2)) @ (baseline - ascent + (label height / 2)).
	shapes add: label.
	mono isLink ifTrue: [ renderer attachInteractionsTo: label target: mono link ]
]

{ #category : 'building' }
CMarkInlineFlow >> addCode: aRun [
	| mono text segments pad ascent descent padY |
	mono := renderer monoStyleFrom: aRun style.
	text := aRun string collect: [ :each |
		        (self isBlank: each)
			        ifTrue: [ Character space ]
			        ifFalse: [ each ] ].
	text isEmpty ifTrue: [ ^ self ].
	segments := self codeSegmentsOf: text.
	pad := renderer chipPadding x.
	padY := renderer chipPadding y.
	ascent := (fonts ascentOf: mono) + padY.
	descent := (fonts descentOf: mono) + padY.
	segments doWithIndex: [ :each :i |
		| piece first last |
		first := i = 1.
		last := i = segments size.
		first ifFalse: [
			current := nil.
			pendingSpace := { ''. 0 } ].
		piece := CMarkInlinePiece
			         kind: #chip
			         text: each
			         style: mono
			         node: aRun node
			         width: (fonts widthOf: each in: mono) + (first
					          ifTrue: [ pad ]
					          ifFalse: [ 0 ]) + (last
					          ifTrue: [ pad ]
					          ifFalse: [ 0 ]).
		piece ascent: ascent descent: descent.
		piece isFirst: first isLast: last pad: pad.
		self addPiece: piece ]
]

{ #category : 'building' }
CMarkInlineFlow >> addPiece: aPiece [
	current ifNil: [
		current := CMarkInlineCluster
			           spaceText: (pendingSpace
					            ifNil: [ '' ]
					            ifNotNil: [ :space | space first ])
			           spaceWidth: (pendingSpace
					            ifNil: [ 0 ]
					            ifNotNil: [ :space | space second ])
			           breaksBefore: pendingBreaks.
		clusters add: current.
		pendingSpace := nil.
		pendingBreaks := 0 ].
	current add: aPiece
]

{ #category : 'building' }
CMarkInlineFlow >> addSpace: aRun [
	self addBlank: aRun style
]

{ #category : 'building' }
CMarkInlineFlow >> addText: aRun [
	| word |
	word := WriteStream on: (String new: 16).
	aRun string do: [ :each |
		(self isBlank: each)
			ifTrue: [
				self addWord: word contents run: aRun.
				word reset.
				self addBlank: aRun style ]
			ifFalse: [ word nextPut: each ] ].
	self addWord: word contents run: aRun
]

{ #category : 'building' }
CMarkInlineFlow >> addWord: aString run: aRun [
	| style piece |
	aString isEmpty ifTrue: [ ^ self ].
	style := aRun style.
	piece := CMarkInlinePiece
		         kind: #word
		         text: aString
		         style: style
		         node: aRun node
		         width: (fonts widthOf: aString in: style).
	piece
		ascent: (fonts ascentOf: style) + style raise
		descent: ((fonts descentOf: style) - style raise max: 0).
	self addPiece: piece
]

{ #category : 'shapes' }
CMarkInlineFlow >> addWordShapes: aPiece x: x baseline: baseline [
	| label style top |
	style := aPiece style.
	label := renderer labelFor: aPiece text style: style node: aPiece node.
	top := baseline - (fonts ascentOf: style) - style raise.
	label translateTo: (x + (label width / 2)) @ (top + (label height / 2)).
	style background ifNotNil: [ :color |
		| box |
		box := renderer boxFrom: x @ top to: (x + aPiece width) @ (top + label height) color: color node: aPiece node.
		shapes add: box ].
	shapes add: label.
	style isLink ifTrue: [ renderer attachInteractionsTo: label target: style link ]
]

{ #category : 'layout' }
CMarkInlineFlow >> alignmentOffset: anAlignment width: aWidth line: aLineWidth [
	"How far a line of aLineWidth moves right in aWidth for anAlignment (#left or nil, #center, #right)"

	anAlignment = #right ifTrue: [ ^ aWidth - aLineWidth max: 0 ].
	anAlignment = #center ifTrue: [ ^ aWidth - aLineWidth / 2 max: 0 ].
	^ 0
]

{ #category : 'accessing' }
CMarkInlineFlow >> budgeted: aBoolean [
	"Whether the shape budget of the renderer may cut my lines (true unless set: the messages of the budgets themselves are shown whole)"

	budgeted := aBoolean
]

{ #category : 'building' }
CMarkInlineFlow >> buildClusters [
	clusters := OrderedCollection new.
	current := nil.
	pendingSpace := nil.
	pendingBreaks := 0.
	runs do: [ :each | self perform: ('add' , each kind capitalized , ':') asSymbol with: each ]
]

{ #category : 'layout' }
CMarkInlineFlow >> buildShapesWidth: aWidth alignment: anAlignment [
	"Make the shapes of my lines while the shape budget of the renderer lasts (the first line always): after a cut my other lines are dropped, and the renderer counts the block as cut short"

	| baseAscent baseDescent y |
	shapes := OrderedCollection new.
	lineWidths := OrderedCollection new.
	baseAscent := fonts ascentOf: baseStyle.
	baseDescent := fonts descentOf: baseStyle.
	y := 0.
	firstBaseline := nil.
	lines doWithIndex: [ :line :i |
		| groups ascent descent lineWidth dx |
		(i > 1 and: [ budgeted and: [ renderer isOverBudget ] ]) ifTrue: [
			renderer skipBlocks: 1.
			lines := lines first: i - 1.
			height := y.
			^ self ].
		i > 1 ifTrue: [ y := y + renderer theme lineGap ].
		groups := self groupsOf: line.
		ascent := baseAscent.
		descent := baseDescent.
		groups do: [ :each |
			ascent := ascent max: each first ascent.
			descent := descent max: each first descent ].
		lineWidth := groups isEmpty
			             ifTrue: [ 0 ]
			             ifFalse: [ groups last second + groups last first width ].
		dx := self alignmentOffset: anAlignment width: aWidth line: lineWidth.
		groups do: [ :each |
			self
				perform: ('add' , each first kind capitalized , 'Shapes:x:baseline:') asSymbol
				with: each first
				with: dx + each second
				with: y + ascent ].
		firstBaseline ifNil: [ firstBaseline := y + ascent ].
		lineWidths add: lineWidth.
		y := y + ascent + descent ].
	height := y
]

{ #category : 'accessing' }
CMarkInlineFlow >> clusters [
	^ clusters
]

{ #category : 'building' }
CMarkInlineFlow >> codeSegmentsOf: aString [
	"aString cut where a space is followed by another character: each segment keeps its spaces (the leading ones go with the first)"

	| segments buffer sawWord inTrail |
	segments := OrderedCollection new.
	buffer := WriteStream on: (String new: aString size).
	sawWord := false.
	inTrail := false.
	aString do: [ :each |
		each = Character space
			ifTrue: [
				buffer nextPut: each.
				sawWord ifTrue: [ inTrail := true ] ]
			ifFalse: [
				inTrail ifTrue: [
					segments add: buffer contents.
					buffer reset.
					inTrail := false ].
				buffer nextPut: each.
				sawWord := true ] ].
	buffer contents ifNotEmpty: [ :rest | segments add: rest ].
	^ segments
]

{ #category : 'accessing' }
CMarkInlineFlow >> firstBaseline [
	"The y of the baseline of my first line"

	^ firstBaseline
]

{ #category : 'layout' }
CMarkInlineFlow >> groupsOf: aLine [
	"The placements { piece. x. gap } of aLine merged: consecutive words of one run, consecutive segments of one code span; answer { piece. x } pairs"

	| groups |
	groups := OrderedCollection new.
	aLine do: [ :placement |
		| piece last merged |
		piece := placement first.
		last := groups isEmpty
			        ifTrue: [ nil ]
			        ifFalse: [ groups last ].
		(last notNil and: [ self merges: piece into: last first ])
			ifTrue: [
				merged := last first
					          copyWithText: last first text , placement third , piece text
					          width: placement second + piece width - last second.
				merged isFirst: last first isFirst isLast: piece isLast pad: piece pad.
				groups at: groups size put: { merged. last second } ]
			ifFalse: [ groups add: { piece. placement second } ] ].
	^ groups
]

{ #category : 'accessing' }
CMarkInlineFlow >> height [
	^ height
]

{ #category : 'testing' }
CMarkInlineFlow >> isBlank: aCharacter [
	"Blanks are exactly space, TAB, CR and LF (not U+00A0)"

	^ aCharacter = Character space or: [
		  aCharacter = Character tab or: [ aCharacter = Character cr or: [ aCharacter = Character lf ] ] ]
]

{ #category : 'testing' }
CMarkInlineFlow >> isEmpty [
	"Whether I have nothing to show"

	^ clusters isEmpty
]

{ #category : 'layout' }
CMarkInlineFlow >> layoutWidth: aWidth alignment: anAlignment [
	"Break my clusters into lines of aWidth and make the shapes, aligned by anAlignment (#left or nil, #center, #right)"

	| x |
	lines := OrderedCollection with: OrderedCollection new.
	x := 0.
	clusters do: [ :cluster |
		| space gap |
		cluster breaksBefore timesRepeat: [
			lines add: OrderedCollection new.
			x := 0 ].
		space := lines last isEmpty
			         ifTrue: [ 0 ]
			         ifFalse: [ cluster spaceWidth ].
		(lines last notEmpty and: [ x + space + cluster width > aWidth ]) ifTrue: [
			lines add: OrderedCollection new.
			x := 0.
			space := 0 ].
		(lines last isEmpty and: [ cluster width > aWidth and: [ renderer theme breakLongWords ] ])
			ifTrue: [ x := self placeBroken: cluster width: aWidth ]
			ifFalse: [
				gap := lines last isEmpty
					       ifTrue: [ '' ]
					       ifFalse: [ cluster spaceText ].
				x := x + space.
				cluster pieces doWithIndex: [ :piece :i |
					lines last add: { piece. x. (i = 1
						  ifTrue: [ gap ]
						  ifFalse: [ '' ]) }.
					x := x + piece width ] ] ].
	self buildShapesWidth: aWidth alignment: anAlignment
]

{ #category : 'accessing' }
CMarkInlineFlow >> lineCount [
	^ lines size
]

{ #category : 'accessing' }
CMarkInlineFlow >> lineWidths [
	"The advance of each line, before alignment"

	^ lineWidths
]

{ #category : 'testing' }
CMarkInlineFlow >> merges: aPiece into: aGroupPiece [
	"Whether aPiece continues the label (or the chip) of aGroupPiece"

	^ aPiece isAtom not and: [
		  aGroupPiece isAtom not and: [
			  aPiece kind = aGroupPiece kind and: [ aPiece node == aGroupPiece node and: [ aPiece style == aGroupPiece style ] ] ] ]
]

{ #category : 'accessing' }
CMarkInlineFlow >> minWidth [
	"The width of my widest cluster"

	^ clusters inject: 0 into: [ :max :each | max max: each width ]
]

{ #category : 'accessing' }
CMarkInlineFlow >> naturalWidth [
	"The width of my widest line at an unlimited width"

	| max sum first |
	max := 0.
	sum := 0.
	first := true.
	clusters do: [ :each |
		each breaksBefore > 0 ifTrue: [
			max := max max: sum.
			sum := 0.
			first := true ].
		sum := sum + (first
			        ifTrue: [ 0 ]
			        ifFalse: [ each spaceWidth ]) + each width.
		first := false ].
	^ max max: sum
]

{ #category : 'layout' }
CMarkInlineFlow >> placeBroken: aCluster width: aWidth [
	"Place the overlong aCluster from the start of a line, breaking its text by characters; answer the x after it"

	| x |
	x := 0.
	aCluster pieces do: [ :piece |
		piece isAtom
			ifTrue: [
				(lines last notEmpty and: [ x + piece width > aWidth ]) ifTrue: [
					lines add: OrderedCollection new.
					x := 0 ].
				lines last add: { piece. x. '' }.
				x := x + piece width ]
			ifFalse: [
				piece text doWithIndex: [ :each :k |
					| first last width part |
					first := piece isFirst and: [ k = 1 ].
					last := piece isLast and: [ k = piece text size ].
					width := fonts widthOf: (String with: each) in: piece style.
					piece isChip ifTrue: [
						first ifTrue: [ width := width + piece pad ].
						last ifTrue: [ width := width + piece pad ] ].
					(lines last notEmpty and: [ x + width > aWidth ]) ifTrue: [
						lines add: OrderedCollection new.
						x := 0 ].
					part := piece copyWithText: (String with: each) width: width.
					part isFirst: first isLast: last pad: piece pad.
					lines last add: { part. x. '' }.
					x := x + width ] ] ].
	^ x
]

{ #category : 'private' }
CMarkInlineFlow >> setRenderer: aRenderer runs: aCollection baseStyle: aStyle [
	renderer := aRenderer.
	fonts := aRenderer fonts.
	runs := aCollection.
	baseStyle := aStyle.
	budgeted := true.
	self buildClusters
]

{ #category : 'accessing' }
CMarkInlineFlow >> shapes [
	"My shapes after layoutWidth:alignment:, in local coordinates"

	^ shapes
]
