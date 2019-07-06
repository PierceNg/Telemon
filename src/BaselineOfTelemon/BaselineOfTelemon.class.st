"
BaselineOfTelemon
"
Class {
	#name : #BaselineOfTelemon,
	#superclass : #BaselineOf,
	#category : #BaselineOfTelemon
}

{ #category : #baselines }
BaselineOfTelemon >> baseline: spec [
	<baseline>
	
	spec for: #'common' do: [ 
		spec package: 'Telemon'.
		spec group: #'default' with: #('Telemon') ] 
]
