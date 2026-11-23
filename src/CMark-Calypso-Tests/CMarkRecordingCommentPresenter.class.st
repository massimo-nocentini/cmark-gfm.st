"
I am a CMarkCommentPresenter that records the process of each of its drawings (drawingProcesses), for the tests of the drawing in the Morphic UI process (CMarkCommentPresenterTest).
"
Class {
	#name : 'CMarkRecordingCommentPresenter',
	#superclass : 'CMarkCommentPresenter',
	#instVars : [
		'drawingProcesses'
	],
	#category : 'CMark-Calypso-Tests-Support',
	#package : 'CMark-Calypso-Tests',
	#tag : 'Support'
}

{ #category : 'rendering' }
CMarkRecordingCommentPresenter >> drawOn: aCanvas [
	self drawingProcesses add: Processor activeProcess.
	super drawOn: aCanvas
]

{ #category : 'accessing' }
CMarkRecordingCommentPresenter >> drawingProcesses [
	"The process of each of my drawings, the first first"

	^ drawingProcesses ifNil: [ drawingProcesses := OrderedCollection new ]
]
