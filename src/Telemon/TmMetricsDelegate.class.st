"
I am TmMetricsDelegate, a Zinc HTTP server delegate that implements Telegraf's HTTP input plugin interface. 

See https://github.com/influxdata/telegraf/tree/master/plugins/inputs/http.
"
Class {
	#name : #TmMetricsDelegate,
	#superclass : #Object,
	#instVars : [
		'measurement',
		'tags',
		'fields',
		'defaultFields'
	],
	#category : #Telemon
}

{ #category : #accessing }
TmMetricsDelegate >> defaultFields [
	| oldspace youngspace memory free |
	
	oldspace := SmalltalkImage current vm oldSpace.
	youngspace := SmalltalkImage current vm youngSpaceSize.
	memory := SmalltalkImage current vm memorySize.
	free := oldspace + (SmalltalkImage current vm edenSpaceSize) - youngspace.
	
	defaultFields ifNil: [  defaultFields := SmallDictionary new ].
	defaultFields at: 'uptime' put:  Time millisecondClockValue;
		at: 'oldSpace' put: oldspace;
		at: 'youngSpace' put: youngspace;
		at: 'memory' put: memory;
		at: 'memoryFree' put: free;
		at: 'fullGCs' put: SmalltalkImage current vm fullGCCount;
		at: 'fullGCTime' put: SmalltalkImage current vm totalFullGCTime;
		at: 'incrGCs' put: SmalltalkImage current vm incrementalGCCount;
		at: 'incrGCTime' put: SmalltalkImage current vm totalIncrementalGCTime;
		at: 'tenureCount' put: SmalltalkImage current vm tenureCount.
	^ defaultFields
		
]

{ #category : #accessing }
TmMetricsDelegate >> defaultTags [
	^ SmallDictionary new
]

{ #category : #accessing }
TmMetricsDelegate >> fields [
	^ fields ifNil: [ fields := SmallDictionary new ]
]

{ #category : #accessing }
TmMetricsDelegate >> fields: anObject [
	fields := anObject
]

{ #category : #public }
TmMetricsDelegate >> handleRequest: aRequest [

	(#(GET) includes: aRequest method)
		ifFalse: [ ^ ZnResponse methodNotAllowed:  aRequest ].

	^ ZnResponse ok: (ZnEntity text: (self renderInfluxDB))
]

{ #category : #accessing }
TmMetricsDelegate >> measurement [
	^ measurement ifNil: [ 'pharo' ]
]

{ #category : #accessing }
TmMetricsDelegate >> measurement: anObject [
	measurement := anObject
]

{ #category : #rendering }
TmMetricsDelegate >> renderInfluxDB [
	"See https://docs.influxdata.com/influxdb/v1.7/write_protocols/line_protocol_tutorial/."
	
	^ String streamContents: [ :s |
		s nextPutAll: self measurement.
		self renderInfluxDBTags: (self tags, self defaultTags) on: s. 
		self renderInfluxDBValueFields: self defaultFields on: s. 
		self renderInfluxDBBlockFields: self fields on: s.
		"Optional: Print timestamp either in RFC 3339 or nanosec-precision Unix time format." ]
]

{ #category : #'rendering - private' }
TmMetricsDelegate >> renderInfluxDBBlockFields: fieldsMap on: stream [
	
	fieldsMap isEmpty ifFalse: [
		stream nextPut: $,. 
		fieldsMap keys sorted do: [ :k |
			stream nextPutAll: k;
				nextPut: $=;
				nextPutAll: (fieldsMap at: k) value asString;
				nextPut: $, ].
			stream skip: -1 "eat the last comma" ]
]

{ #category : #'rendering - private' }
TmMetricsDelegate >> renderInfluxDBTags: tagsMap on: stream [

	tagsMap isEmpty 
		ifFalse: [ 
			stream nextPut: $,. 
			tagsMap keysAndValuesDo: [ :k :v |
				stream nextPutAll: k;
					nextPut: $=;
					nextPutAll: v asString;
					nextPut: $, ].
			stream skip: -1 "to eat the last comma" ].
		stream nextPut: Character space.

]

{ #category : #'rendering - private' }
TmMetricsDelegate >> renderInfluxDBValueFields: fieldsMap on: stream [
	
	fieldsMap keysAndValuesDo: [ :k :v |
		stream nextPutAll: k;
			nextPut: $=;
			nextPutAll: v asString;
			nextPut: $, ].
		stream skip: -1 "eat the last comma"
]

{ #category : #accessing }
TmMetricsDelegate >> tags [
	^ tags ifNil: [ tags := SmallDictionary new ]
]

{ #category : #accessing }
TmMetricsDelegate >> tags: anObject [
	tags := anObject
]
