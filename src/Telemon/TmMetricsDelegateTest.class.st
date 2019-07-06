"
Unit tests for TmMetricsDelegate.
"
Class {
	#name : #TmMetricsDelegateTest,
	#superclass : #TestCase,
	#instVars : [
		'd',
		'rx'
	],
	#category : #Telemon
}

{ #category : #tests }
TmMetricsDelegateTest >> fieldsMatcher [
	| regex |
	
	regex := String streamContents: [ :s |
		s nextPutAll: 'uptime=\d+,';
			nextPutAll: 'oldSpace=\d+,';
			nextPutAll: 'youngspace=\d+,';
			nextPutAll: 'memory=\d+,';
			nextPutAll: 'memoryFree=\d+,';
			nextPutAll: 'fullGCs=\d+,';
			nextPutAll: 'fullGCTime=\d+,';
			nextPutAll: 'incrGCs=\d+,';
			nextPutAll: 'incrGCTime=\d+,';
			nextPutAll: 'tenureCount=\d+';
			nextPutAll: '((,[\w\-]+=\d+)*)' ]. 
	^ RxMatcher forString: regex ignoreCase: true.

]

{ #category : #running }
TmMetricsDelegateTest >> setUp [ 		
		
	d := TmMetricsDelegate new.
	rx := self fieldsMatcher

]

{ #category : #tests }
TmMetricsDelegateTest >> testDefault [
	| output  |
	
	output := (d renderInfluxDB) splitOn: Character space.
	self assert: output first equals: 'pharo'.
	
	self assert: (rx matches: output second).
	self assert: (rx subexpression: 2) equals: ''
	
	
]

{ #category : #tests }
TmMetricsDelegateTest >> testDefaultOneTag [
	| output  tags |
	
	d tags at: 'host' put: 'telemon-1'.
	output := (d renderInfluxDB) splitOn: Character space.
	
	tags := output first splitOn: $,.
	self assert: tags first equals: 'pharo'.
	self assert: tags second equals: 'host=telemon-1'.
	
	self assert: (rx matches: output second).
	self assert: (rx subexpression: 2) equals: ''
	
	
]

{ #category : #tests }
TmMetricsDelegateTest >> testDefaultTwoTags [
	| output  tags |
	
	d tags at: 'host' put: 'telemon-1';
		at: 'instance' put: 'telemon-1-1'.
	output := (d renderInfluxDB) splitOn: Character space.
	
	tags := output first splitOn: $,.
	self assert: tags first equals: 'pharo'.
	self assert: tags second equals: 'host=telemon-1'.
	self assert: tags third equals: 'instance=telemon-1-1'.
	
	self assert: (rx matches: output second).
	self assert: (rx subexpression: 2) equals: ''
	
	
]

{ #category : #tests }
TmMetricsDelegateTest >> testInvalid [
	| output |
	
	output := (d renderInfluxDB) splitOn: Character space.
	self assert: output first equals: 'pharo'.
	
	output := output second, ','. "Add spurious comma at end."
	self deny: (rx matches: output)
	
	
]

{ #category : #tests }
TmMetricsDelegateTest >> testOneField [
	| output  |

	d fields at: 'meaning' put: [ 42 ].	
	output := (d renderInfluxDB) splitOn: Character space.
	self assert: output first equals: 'pharo'.
	
	self assert: (rx matches: output second).
	self assert: (rx subexpression: 2) equals: ',meaning=42'
	
	
]

{ #category : #tests }
TmMetricsDelegateTest >> testSetMeasurement [
	| output  |
	
	d measurement: 'telemon'. 
	output := (d renderInfluxDB) splitOn: Character space.
	self assert: output first equals: 'telemon'.
	
	self assert: (rx matches: output second).
	self assert: (rx subexpression: 2) equals: ''
	
	
]

{ #category : #tests }
TmMetricsDelegateTest >> testSetMeasurementOneField [
	| output  |
	
	d measurement: 'telemon'. 
	d fields at: 'meaning' put: [ 42 ].	
		
	output := (d renderInfluxDB) splitOn: Character space.
	self assert: output first equals: 'telemon'.
	
	self assert: (rx matches: output second).
	self assert: (rx subexpression: 2) equals: ',meaning=42'
	
	
]

{ #category : #tests }
TmMetricsDelegateTest >> testSetMeasurementOneTag [
	| output tags |
	
	d measurement: 'telemon'. 
	d tags at: 'host' put: 'telemon-1'.
	output := (d renderInfluxDB) splitOn: Character space.
	
	tags := output first splitOn: $,.
	self assert: tags first equals: 'telemon'.
	self assert: tags second equals: 'host=telemon-1'.

	self assert: (rx matches: output second).
	self assert: (rx subexpression: 2) equals: ''
	
	
]

{ #category : #tests }
TmMetricsDelegateTest >> testSetMeasurementOneTagOneField [
	| output tags |
	
	d measurement: 'telemon'. 
	d tags at: 'host' put: 'telemon-1'.
	d fields at: 'meaning' put: [ 42 ].			
	output := (d renderInfluxDB) splitOn: Character space.
	
	tags := output first splitOn: $,.
	self assert: tags first equals: 'telemon'.
	self assert: tags second equals: 'host=telemon-1'.
	
	self assert: (rx matches: output second).
	self assert: (rx subexpression: 2) equals: ',meaning=42'
	
	
]

{ #category : #tests }
TmMetricsDelegateTest >> testSetMeasurementTwoFields [
	| output  |
	
	d measurement: 'telemon'. 
	d fields at: 'meaning' put: [ 42 ];
		at: 'newMeaning' put: [ 84 ].	
		
	output := (d renderInfluxDB) splitOn: Character space.
	self assert: output first equals: 'telemon'.
	
	self assert: (rx matches: output second).
	self assert: (rx subexpression: 2) equals: ',meaning=42,newMeaning=84'.
	
	
]

{ #category : #tests }
TmMetricsDelegateTest >> testSetMeasurementTwoTags [
	| output tags |
	
	d measurement: 'telemon'. 
	d tags at: 'host' put: 'telemon-1';
		at: 'instance' put: 'telemon-1-1'.
	output := (d renderInfluxDB) splitOn: Character space.
	
	tags := output first splitOn: $,.
	self assert: tags first equals: 'telemon'.
	self assert: tags second equals: 'host=telemon-1'.
	self assert: tags third equals: 'instance=telemon-1-1'.

	self assert: (rx matches: output second).
	self assert: (rx subexpression: 2) equals: ''
	
	
]
