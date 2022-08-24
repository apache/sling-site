title=Sling Metrics		
type=page
status=published
tags=metrics
~~~~~~

Sling Metrics bundle provides integration with [Dropwizard Metrics][1] library
which provides a toolkit to capture runtime performance statistics in your 
application. 

## Features

* Registers a [MetricsService][3] which can be used to create various types of Metric
  instances
* WebConsole Plugin which provides a HTML Reporter for the various Metric instances
* Inventory Plugin which dumps the Metric state in plain text format

## Basic Usage

    ::java
    import org.apache.sling.metrics.Counter;
    import org.apache.sling.metrics.MetricsService;
    
    @Reference
    private MetricsService metricsService;
    
    private Counter counter;
    
    @Activate
    private void activate(){
        counter = metricsService.counter("sessionCounter");
    }
    
    public void onSessionCreation(){
        counter.increment();
    }
    
To make use of `MetricsService`

1. Get a reference to `org.apache.sling.metrics.MetricsService`
2. Initialize the metric e.g. Counter in above case. This avoids 
   any potential lookup cost in critical code paths
3. Make use of metric instance to capture require stats

Refer to [Metric Getting Started][2] guide to see how various types
of Metric instances can be used. Note that when using Sling Commons Metrics
bundle class names belong to the `org.apache.sling.commons.metrics` package.

## Best Practices

1. Use descriptive names - Qualify the name with class/package name where the
   metric is being used.
2. Do not use the metrics for operation which take less than 1E-7s i.e. 1000 nano 
   seconds otherwise timer overhead (Metrics makes use of System.nanoTime)
   would start affecting the performance.

## API

Sling Metrics bundle provides its own Metric classes which are modelled on 
[Dropwizard Metrics][1] library. The metric interfaces defined by Sling bundle
only provides methods related to data collection. 

* [org.apache.sling.commons.metrics.Meter][4] - Similar to [Dropwizard Meter][dw-meter]
* [org.apache.sling.commons.metrics.Timer][6] - Similar to [Dropwizard Timer][dw-timer]
* [org.apache.sling.commons.metrics.Counter][5] - Similar to [Dropwizard Counter][dw-counter]
* [org.apache.sling.commons.metrics.Histogram][7] - Similar to [Dropwizard Histogram][dw-histogram]
* [org.apache.sling.commons.metrics.Gauge][8] - Similar to [Dropwizard Gauge][dw-gauge]

Further it provides a `MetricsService` which enables creation of different
type of Metrics like Meter, Timer, Counter and Histogram, Gauge.

### The special case of Gauge

Unlike other metric types, the gauge metric is a generic class, through which it can support many different types of gauge values. 
It can be easiest used by providing a Supplier or Lambda to return the requested value. Here the example of a gauge which returns a constant value.

    ::java
    import org.apache.sling.metrics.Gauge;
    import org.apache.sling.metrics.MetricsService;
    
    @Reference
    private MetricsService metricsService;
    
    private Gauge<Integer> cacheHitRatio;

    @Activate
    private void activate(){
        cacheHitRatio = metricsService.counter("org.myapp.metrics.constantValue", () -> {
           return 42;
        });
    }



### Requirement of wrapper interfaces

* Abstraction - Provides an abstraction around how metrics are collected and how
  they are reported and consumed. Most of the code would only be concerned with
  collecting interesting data. How it gets consumed or reported is implementation 
  detail.
* Ability to turnoff stats collection - We can easily turn off data collection
  by switching to NOOP variant of `MetricsService` in case it starts adding appreciable
  overhead. Turning on and off can also be done on individual metric basis.
  
It also allows us to later extend the type of data collected. For e.g. we can also collect
[TimerSeries][9] type of data for each metric without modifying the caller logic.
  
### Access to Dropwizard Metrics API

Sling Metrics bundle also registers the `MetricRegistry` instance with OSGi service registry. 
The instance registered has a service property `name` set to `sling` (so as allow distinguishing 
from any other registered `MetricRegistry` instance). It can be used to get direct access to Dropwizard 
Metric API if required.

    ::java
    @Reference(target = "(name=sling)")
    private MetricRegistry registry;
  
Also the wrapper Metric instance can be converted to actual instance via `adaptTo` calls.

    ::java
    import org.apache.sling.commons.metrics.Counter

    Counter counter = metricService.counter("login");
    com.codahale.metrics.Counter = counter.adaptTo(com.codahale.metrics.Counter.class)

## WebConsole Plugin

A Web Console plugin is also provided which is accessible at 
http://localhost:8080/system/console/slingmetrics. It lists down all registered
Metric instances and their state. 

![Metric Plugin](/documentation/bundles/metric-web-console.png)

The plugin lists all Metric instances from any `MetricRegistry` instance found in 
the OSGi service registry. If the `MetricRegistry` service has a `name` property defined
then that would be prefixed to the Metric names from that registry. This allows 
use of same name in different registry instances.

## JMX support
This library also registers all metrics as MBeans by default. That means that existing JMX-based monitoring can be used to access
the metrics as well.

## JMX Exporter
Starting with version 1.2.12 Sling Commons Metrics also supports the other way around. As some third-party libraries provide metrics data only via JMX, the JMX Exporter Factory can be used to export those values as metrics.

Create an instance of the "JMX to Metrics Exporter" (pid: `org.apache.sling.commons.metrics.internal.JmxExporterFactory`) and provide the name of the MBean you want to export in the `objectname` property (multi-value). All attributes of these MBeans matching the following types will be exported as metrics (others are silently ignored):

* Long
* String
* Double
* Boolean (with [SLING-11509](https://issues.apache.org/jira/browse/SLING-11509))


[1]: http://metrics.dropwizard.io/
[dw-meter]: https://metrics.dropwizard.io/3.2.3/manual/core.html#man-core-meters
[dw-counter]: https://metrics.dropwizard.io/3.2.3/manual/core.html#man-core-counters
[dw-histogram]: https://metrics.dropwizard.io/3.2.3/manual/core.html#man-core-histograms
[dw-timer]: https://metrics.dropwizard.io/3.2.3/manual/core.html#man-core-timers
[dw-gauge]: https://metrics.dropwizard.io/3.2.3/manual/core.html#man-core-gauges
[2]: https://dropwizard.github.io/metrics/3.2.3/getting-started/#counters
[3]: https://github.com/apache/sling/blob/trunk/bundles/commons/metrics/src/main/java/org/apache/sling/commons/metrics/MetricsService.java
[4]: https://github.com/apache/sling/blob/trunk/bundles/commons/metrics/src/main/java/org/apache/sling/commons/metrics/Meter.java
[5]: https://github.com/apache/sling/blob/trunk/bundles/commons/metrics/src/main/java/org/apache/sling/commons/metrics/Counter.java
[6]: https://github.com/apache/sling/blob/trunk/bundles/commons/metrics/src/main/java/org/apache/sling/commons/metrics/Timer.java
[7]: https://github.com/apache/sling/blob/trunk/bundles/commons/metrics/src/main/java/org/apache/sling/commons/metrics/Histogram.java
[8]: https://github.com/apache/sling/blob/trunk/bundles/commons/metrics/src/main/java/org/apache/sling/commons/metrics/Gauge.java
[9]: https://jackrabbit.apache.org/api/2.6/org/apache/jackrabbit/api/stats/TimeSeries.html
