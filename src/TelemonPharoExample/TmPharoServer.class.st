"
I am TmPharoServer, a demonstration server for Telemon. I act as a source of metrics using Telemon. I also act as a sink that is compatible with Telegraf's HTTP output plugin.

Start me by running below snippet.

| appServer |
appServer := TmPharoServer new. 
(appServer metricsSource fields)
	at: 'loremTimes' put: [ appServer requestCount ];
	at: 'loremBytes' put: [ appServer requestBytes ].
(appServer metricsSource tags)
	at: 'app' put: 'lorem'.
appServer 
	startServer;
	inspect.
	
Then run a Telegraf agent with the following as telegraf.conf.

[global_tags]

[agent]
  interval = ""60s""
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = ""10s""
  flush_interval = ""10s""
  flush_jitter = ""6s""
  precision = ""0s""
  debug = false
  quiet = false
  logfile = """"
  hostname = ""myhost""
  omit_hostname = false

[[outputs.http]]
  url = ""http://<myip>:8079/telegraf""

[[inputs.http]]
  urls = [""http://<myip>:8079/metrics""]
  timeout = ""5s""
  data_format = ""influx""

Make some requests to http://<myip:8079/lorem. In Pharo, watch appserver's metricsSink inst-var.


"
Class {
	#name : #TmPharoServer,
	#superclass : #Object,
	#instVars : [
		'metricsSource',
		'metricsSink',
		'requestCount',
		'requestBytes',
		'httpServer'
	],
	#category : #TelemonPharoExample
}

{ #category : #initialization }
TmPharoServer >> initialize [ 

	metricsSink := OrderedCollection new.
	requestCount := requestBytes := 0.
	
]

{ #category : #'HTTP handlers' }
TmPharoServer >> loremIpsum: request [
	| count |
	
	count := Integer readFrom: request uri lastPathSegment ifFail: [ 64 ].
	requestCount := requestCount + 1.
	requestBytes := requestBytes + count.
	^ ZnResponse ok: (ZnEntity textCRLF: (String loremIpsum: count))
]

{ #category : #accessing }
TmPharoServer >> metricsSource [
	^ metricsSource ifNil: [ metricsSource := TmMetricsDelegate new ]
]

{ #category : #accessing }
TmPharoServer >> metricsSource: anObject [
	metricsSource := anObject
]

{ #category : #accessing }
TmPharoServer >> requestBytes [
	^ requestBytes
]

{ #category : #accessing }
TmPharoServer >> requestCount [
	^ requestCount
]

{ #category : #'starting/stopping' }
TmPharoServer >> startServer [
	
	self stopServer.
	
	httpServer := ZnMultiThreadedServer new 	
		logLevel: 0;
		port: 8079;
		delegate: (ZnDefaultServerDelegate new
			map: 'metrics' to: [ :req | self metricsSource handleRequest: req ];
			map: 'lorem' to: [ :req | self loremIpsum: req ];
			map: 'telegraf' to: [ :req | self telegraf: req ]).
			
	httpServer start
			
]

{ #category : #'starting/stopping' }
TmPharoServer >> stopServer [
	httpServer ifNotNil: [ httpServer stop ]
]

{ #category : #'HTTP handlers' }
TmPharoServer >> telegraf: request [
	"Here I act as  a Telegraf HTTP output sink."
	
	metricsSink add: request entity contents.	
	^ ZnResponse accepted
]
