"
The baseline of CMark (https://github.com/massimo-nocentini/cmark-gfm.st): Markdown for Pharo 12 to 15, parsed by cmark-gfm 0.29.0.gfm.14 (https://github.com/github/cmark-gfm) in the CMarkPlugin of the VM (plugins/CMarkPlugin and docs/CMark.md of https://github.com/massimo-nocentini/pharo-vm), walked as a tree of CMarkNodes, and rendered as one composite Roassal shape.

Groups: Core (the package CMark: the parse tree, its visitor, the decoder of the plugin's tape, the facade), Tests (CMark-Tests), Roassal (Core and CMark-Roassal, the renderer, on the Roassal of the stock image), RoassalTests (CMark-Roassal-Tests), Calypso (Roassal and CMark-Calypso: the Markdown tab of the Calypso browser, a class comment drawn by the renderer in a Spec presenter), CalypsoTests (CMark-Calypso-Tests), RoassalFork (the user's Roassal fork, branch Pharo15, then Roassal); default loads Core, Tests, Roassal, RoassalTests, Calypso and CalypsoTests.

There is no external dependency in default: Roassal, Athens, Spec and Calypso are in the stock images (CMark-Calypso needs no Roassal-UML-Calypso, which the stock images do not have).  RoassalFork is opt-in and no package requires the fork, so default never pulls it, VMPluginsPrimitives or RoassalExporters.  RoassalFork does not order RoassalMN before CMark-Roassal; that is harmless because CMark-Roassal uses only the Roassal API of the stock images (the batteries image loads the fork first anyway).  The features of the fork that CMark-Roassal deliberately does not use: the geometry backed by the UtilsPlugin, Roassal-Exporters and RSPangoText.  Loading RoassalFork over a stock image needs MCMergeOrLoadWarning answered with load.
"
Class {
	#name : 'BaselineOfCMark',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfCMark',
	#package : 'BaselineOfCMark'
}

{ #category : 'baselines' }
BaselineOfCMark >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec
			package: 'CMark';
			package: 'CMark-Tests' with: [ spec requires: #( 'CMark' ) ];
			package: 'CMark-Roassal' with: [ spec requires: #( 'CMark' ) ];
			package: 'CMark-Roassal-Tests' with: [ spec requires: #( 'CMark-Roassal' 'CMark-Tests' ) ];
			package: 'CMark-Calypso' with: [ spec requires: #( 'CMark-Roassal' ) ];
			package: 'CMark-Calypso-Tests' with: [ spec requires: #( 'CMark-Calypso' 'CMark-Roassal-Tests' ) ].
		self roassalMN: spec.
		spec
			group: 'Core' with: #( 'CMark' );
			group: 'Tests' with: #( 'CMark-Tests' );
			group: 'Roassal' with: #( 'Core' 'CMark-Roassal' );
			group: 'RoassalTests' with: #( 'Roassal' 'CMark-Roassal-Tests' );
			group: 'Calypso' with: #( 'Roassal' 'CMark-Calypso' );
			group: 'CalypsoTests' with: #( 'Calypso' 'RoassalTests' 'CMark-Calypso-Tests' );
			group: 'RoassalFork' with: #( 'RoassalMN' 'Roassal' );
			group: 'default' with: #( 'Core' 'Tests' 'Roassal' 'RoassalTests' 'Calypso' 'CalypsoTests' ) ]
]

{ #category : 'baselines' }
BaselineOfCMark >> roassalMN: spec [
	"The user's Roassal fork (branch Pharo15), only for the opt-in group RoassalFork: no package requires it, so the default never pulls the fork, VMPluginsPrimitives and RoassalExporters"

	spec baseline: 'RoassalMN' with: [
		spec
			repository: 'github://massimo-nocentini/Roassal:Pharo15/src';
			loads: #( 'Full' ) ]
]
