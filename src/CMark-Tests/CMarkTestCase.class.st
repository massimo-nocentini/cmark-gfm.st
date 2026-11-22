"
I am the abstract test of CMark, with the time limit of the slow WebAssembly VMs, and helpers to make strings of code points.  requirePlugin skips a test that needs the CMarkPlugin when the VM has none (or it is hidden by the test hook #pluginMissing); tearDown removes every test hook of CMarkPrimitives.
"
Class {
	#name : 'CMarkTestCase',
	#superclass : 'TestCase',
	#category : 'CMark-Tests-Support',
	#package : 'CMark-Tests',
	#tag : 'Support'
}

{ #category : 'accessing' }
CMarkTestCase class >> defaultTimeLimit [
	"The WebAssembly VMs run the large cases ten to forty times slower than the native ones"

	^ 2 minutes
]

{ #category : 'testing' }
CMarkTestCase class >> isAbstract [
	^ self == CMarkTestCase
]

{ #category : 'helpers' }
CMarkTestCase >> requirePlugin [
	"Skip the test unless the VM has a CMarkPlugin of the protocol of CMarkPrimitives"

	CMarkPrimitives isAvailable ifFalse: [ self skip: 'the test needs the CMarkPlugin' ]
]

{ #category : 'helpers' }
CMarkTestCase >> stringOf: codePoints [
	"The String of the code points codePoints (a ByteString when they all fit)"

	| s |
	s := WideString new: codePoints size.
	codePoints doWithIndex: [ :each :i | s at: i put: (Character value: each) ].
	^ (s allSatisfy: [ :each | each asInteger < 256 ])
		  ifTrue: [ s asByteString ]
		  ifFalse: [ s ]
]

{ #category : 'running' }
CMarkTestCase >> tearDown [
	CMarkPrimitives clearTestHooks.
	super tearDown
]
