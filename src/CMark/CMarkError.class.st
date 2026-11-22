"
I am the root of the errors of CMark: on: CMarkError catches every one of them.  The stock OutOfMemory, signalled when growing the object memory did not make room for an answer of the plugin, is a condition of the VM, not of CMark, and escapes on: CMarkError.
"
Class {
	#name : 'CMarkError',
	#superclass : 'Error',
	#category : 'CMark-Errors',
	#package : 'CMark',
	#tag : 'Errors'
}
