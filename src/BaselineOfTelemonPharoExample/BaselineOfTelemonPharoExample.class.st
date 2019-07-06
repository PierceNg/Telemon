"
BaselineOfTelemonPharoExample
"
Class {
	#name : #BaselineOfTelemonPharoExample,
	#superclass : #BaselineOf,
	#category : #BaselineOfTelemonPharoExample
}

{ #category : #baselines }
BaselineOfTelemonPharoExample >> baseline: spec [
	<baseline>
	
	spec for: #'common' do: [ 
		spec package: 'TelemonPharoExample' with: [ spec requires: 'Telemon' ].
		spec group: #'default' with: #('TelemonPharoExample') ] 
]
