title=Logging		
type=page
status=published
tags=logging,operations
~~~~~~

<div class="note">
This document is for the new (November 2013) 4.x release of the Sling Commons Log components. Refer to
<a href="http://sling.apache.org/documentation/legacy/logging.html">Logging 3.x</a> for older versions.
</div>

[TOC]

## Introduction

Logging in Sling is supported by the `org.apache.sling.commons.log` bundle, which is one of the first bundles installed
and started by the Sling Launcher. This bundle along with other bundles manages the Sling Logging and provides the
following features:

* Implements the OSGi Log Service Specification and registers the `LogService` and `LogReader` services
* Exports three commonly used logging APIs:
  * [Simple Logging Facade for Java (SLF4J)](http://www.slf4j.org)
  * [Apache Commons Logging](http://jakarta.apache.org/commons/logging)
  * [log4j](http://logging.apache.org/log4j/index.html)
  * [java.util.logging](http://download.oracle.com/javase/6/docs/api/java/util/logging/package-summary.html)
* Configures logging through Logback which is integrated with the OSGi environment
* Allows logging to be configured both via editing Logback xml or via OSGi Configurations

### v5.0.0 release

With Sling Log 5.0.0. release the webconsole support has been moved to a 
different bundle named Sling Commons Log WebConsole (org.apache.sling.commons.log.webconsole:1.0.0)

Also with this release Logback 1.1.7 version is embedded and thus it requires 
slf4j-api:1.7.15. See [SLING-6144][SLING-6144] for details

## WebConsole Plugin

The Web Console Plugin supports the following features:

* Display the list of loggers which have levels or appenders configured.
* List the file appenders with the location of current active log files.
* Show the contents of LogBack config files.
* Show the contents of various Logback config fragments.
* Show Logback Status logs.
* Inline edit the Logger setting
* Configure Logger with content assist for logger names
* Provides links to log file content allows log file content to be viewed from Web UI

<img src="sling-log-support.png" />

## WebTail

The Web Console Plugin also supports tailing of the current active log files.
It generates link to all active log files which can be used to see there content
from within the browser. The url used is like

```
http://localhost:8080/system/console/slinglog/tailer.txt?tail=1000&grep=lucene&name=%2Flogs%2Ferror.log
```

It supports following parameters

* `name` - Appender name like _/logs/error.log_
* `tail` - Number of lines to include in dump. -1 to include whole file
* `grep` - Filter the log lines based on `grep` value which can be
    * Simple string phrase - In this case search is done in case insensitive way via String.contains
    * regex - In this case the search would be done via regex pattern matching

## Initial Configuration

The `org.apache.sling.commons.log` bundle gets its initial configuration from the following `BundleContext` properties:


| Property | Default | Description |
|--|--|--|
| `org.apache.sling.commons.log.level` | `INFO` | Sets the initial logging level of the root logger. This may be any of the defined logging levels `DEBUG`, `INFO`, `WARN`, `ERROR` and `FATAL`. |
| `org.apache.sling.commons.log.file` | undefined | Sets the log file to which log messages are written. If this property is empty or missing, log messages are written to `System.out`. |
| `org.apache.sling.commons.log.file.number` | 5 | The number of rotated files to keep. |
| `org.apache.sling.commons.log.file.size` | '.'yyyy-MM-dd | Defines how the log file is rotated (by schedule or by size) and when to rotate. See the section *Log File Rotation* below for full details on log file rotation. |
| `org.apache.sling.commons.log.pattern` | \{0,date,dd.MM.yyyy HH:mm:ss.SSS\} \*\{4\}\* \{2\} \{3\} \{5\} | The `MessageFormat` pattern to use for formatting log messages with the root logger. |
| `org.apache.sling.commons.log.julenabled` | n/a | Enables the `java.util.logging` support. |
| `org.apache.sling.commons.log.configurationFile` | n/a | Path for the Logback config file which would be used to configure logging. If the path is not absolute then it would be resolved against Sling Home |
| `org.apache.sling.commons.log.packagingDataEnabled` | true | Boolean property to control packaging data support of Logback. See [Packaging Data][11] section of Logback for more details |
| `org.apache.sling.commons.log.numOfLines` | 1000 | Number of lines from each log files to include while generating the dump in 'txt' mode. If set to -1 then whole file would be included |
| `org.apache.sling.commons.log.maxOldFileCountInDump` | 3 | Maximum number of old rolled over files for each active file to be included while generating the dump as part of Status zip support |
| `sling.log.root` | Sling Home | The directory, which is used to resolve relative path names against. If not specified it would map to sling.home. Since [4.0.2](https://issues.apache.org/jira/browse/SLING-4225)|

## User Configuration - OSGi Based

User Configuration after initial configuration is provided by the Configuration Admin Service. To this avail two
`org.osgi.services.cm.ManagedServiceFactory` services are registered under the PIDs `org.apache.sling.commons.log.LogManager.factory.writer`
and `org.apache.sling.commons.log.LogManager.factory.config` to receive configurations.


### Logger Configuration

Loggers (or Categories) can be configured to log to specific files at specific levels using configurable patterns.
To this avail factory configuration instances with factory PID `org.apache.sling.commons.log.LogManager.factory.config`
may be created and configured with the Configuration Admin Service.

The following properties may be set:

| Property | Type | Default | Description |
|--|--|--|--|
| `org.apache.sling.commons.log.level` | `String` | `INFO` | Sets the logging level of the loggers. This may be any of the defined logging levels `DEBUG`, `INFO`, `WARN`, `ERROR` and `FATAL`. |
| `org.apache.sling.commons.log.file` | `String` | undefined | Sets the log file to which log messages are written. If this property is empty or missing, log messages are written to `System.out`. This property should refer to the file name of a configured Log Writer (see below). If no Log Writer is configured with the same file name an implicit Log Writer configuration with default configuration is created. |
| `org.apache.sling.commons.log.pattern` | `String` | \{0,date,dd.MM.yyyy HH:mm:ss.SSS\} \*\{4\}\* \{2\} \{3\} \{5\} | The `java.util.MessageFormat` pattern to use for formatting log messages with the root logger. This is a `java.util.MessageFormat` pattern supporting up to six arguments: \{0\} The timestamp of type `java.util.Date`, \{1\} the log marker, \{2\} the name of the current thread, \{3\} the name of the logger, \{4\} the log level and \{5\} the actual log message. If the log call includes a Throwable, the stacktrace is just appended to the message regardless of the pattern. |
| `org.apache.sling.commons.log.names` | `String\[\]` | -- | A list of logger names to which this configuration applies. |
| `org.apache.sling.commons.log.additiv` | `Boolean` | false | If set to false then logs from these loggers would not be sent to any appender attached higher in the hierarchy |


Note that multiple Logger Configurations may refer to the same Log Writer Configuration. If no Log Writer Configuration
exists whose file name matches the file name set on the Logger Configuration an implicit Log Writer Configuration
with default setup (daily log rotation) is internally created. While the log level configuration is case insensitive, it
is suggested to always use upper case letters.


### Log Writer Configuration

Log Writer Configuration is used to setup file output and log file rotation characteristics for log writers used by the Loggers.

The following properties may be set:

| Property | Default | Description |
|--|--|--|
| `org.apache.sling.commons.log.file` | undefined | Sets the log file to which log messages are written. If this property is empty or missing, log messages are written to `System.out`. |
| `org.apache.sling.commons.log.file.number` | 5 | The number of rotated files to keep. |
| `org.apache.sling.commons.log.file.size` | '.'yyyy-MM-dd | Defines how the log file is rotated (by schedule or by size) and when to rotate. See the section *Log File Rotation* below for full details on log file rotation. |

See the section *Log File Rotation* below for full details on the `org.apache.sling.commons.log.file.size` and
`org.apache.sling.commons.log.file.number` properties.

#### Log File Rotation

Log files can grow rather quickly and fill up available disk space. To cope with this growth log files may be rotated in
two ways: At specific times or when the log file reaches a configurable size. The first method is called *Scheduled Rotation*
and is used by specifying a `SimpleDateFormat` pattern as the log file "size". The second method is called *Size Rotation*
and is used by setting a maximum file size as the log file size.

As of version 2.0.6 of the Sling Commons Log bundle, the default value for log file scheduling is `'.'yyyy-MM-dd`
causing daily log rotation. In previous version, log rotation defaults to a 10MB file size limit.

##### Scheduled Rotation

The rolling schedule is specified by setting the `org.apache.sling.commons.log.file.size` property to a
`java.text.SimpleDateFormat` pattern. Literal text (such as a leading dot) to be included must be *enclosed* within a
pair of single quotes. A formatted version of the date pattern is used as the suffix for the rolled file name. Internally
the Log bundle configures a `TimeBasedRollingPolicy` for the appender. Refer to [TimeBasedRollingPolicy][10] for
more details around the pattern format

For example, if the log file is configured as `/foo/bar.log` and the pattern set to `'.'yyyy-MM-dd`, on
2001-02-16 at midnight, the logging file `/foo/bar.log` will be renamed to `/foo/bar.log.2001-02-16` and logging for
2001-02-17 will continue in a new `/foo/bar.log` file until it rolls over the next day.

It is possible to specify monthly, weekly, half-daily, daily, hourly, or minutely rollover schedules.

| DatePattern | Rollover schedule | Example |
|--|--|--|
| `'.'yyyy-MM` | Rollover at the beginning of each month | At midnight of May 31st, 2002 `/foo/bar.log` will be copied to `/foo/bar.log.2002-05`. Logging for the month of June will be output to `/foo/bar.log` until it is also rolled over the next month. |
| `'.'yyyy-ww` | Rollover at the first day of each week. The first day of the week depends on the locale. | Assuming the first day of the week is Sunday, on Saturday midnight, June 9th 2002, the file `/foo/bar.log` will be copied to `/foo/bar.log.2002-23`. Logging for the 24th week of 2002 will be output to `/foo/bar.log` until it is rolled over the next week. |
| `'.'yyyy-MM-dd` | Rollover at midnight each day.| At midnight, on March 8th, 2002, `/foo/bar.log` will be copied to `/foo/bar.log.2002-03-08`. Logging for the 9th day of March will be output to `/foo/bar.log` until it is rolled over the next day.|
| `'.'yyyy-MM-dd-a` | Rollover at midnight and midday of each day.| at noon, on March 9th, 2002, `/foo/bar.log` will be copied to  `/foo/bar.log.2002-03-09-AM`. Logging for the afternoon of the 9th will be output to `/foo/bar.log` until it is rolled over at midnight.|
| `'.'yyyy-MM-dd-HH` | Rollover at the top of every hour.| At approximately 11:00.000 o'clock on March 9th, 2002, `/foo/bar.log` will be copied to `/foo/bar.log.2002-03-09-10`. Logging for the 11th hour of the 9th of March will be output to `/foo/bar.log` until it is rolled over at the beginning of the next hour.|
| `'.'yyyy-MM-dd-HH-mm` | Rollover at the beginning of every minute.| At approximately 11:23,000, on March 9th, 2001, `/foo/bar.log` will be copied to `/foo/bar.log.2001-03-09-10-22`. Logging for the minute of 11:23 (9th of March) will be output to `/foo/bar.log` until it is rolled over the next minute.|

Do not use the colon ":" character in anywhere in the pattern option. The text before the colon is interpreted as the
protocol specification of a URL which is probably not what you want.

Note that Scheduled Rotation ignores the `org.apache.sling.commons.log.file.number` property since the old log files are
not numbered but "dated".

##### Size Rotation

Log file rotation by size is specified by setting the `org.apache.sling.commons.log.file.size` property to a plain number
or a number plus a size multiplier. The size multiplier may be any of `K`, `KB`, `M`, `MB`, `G`, or `GB` where the case
is ignored and the meaning is probably obvious.

When using Size Rotation, the `org.apache.sling.commons.log.file.number` defines the number of old log file generations
to keep. For example to keep 5 old log files indexed by 0 through 4, set the `org.apache.sling.commons.log.file.number`
to `5` (which happens to be the default).

## Logback Integration

Logback integration provides following features

* LogBack configuration can be provided via Logback config xml
* Supports Appenders registered as OSGi Services
* Supports Filters and TurboFilters registered as OSGi Services
* Support providing Logback configuration as fragments through OSGi Service Registry
* Support for referring to Appenders registered as OSGi services from with Logback config
* Exposes Logback runtime state through the Felix WebConsole Plugin

The following sections provide more details.

### TurboFilters as OSGi Services

[Logback TurboFilters][3] operate globally and are invoked for every Logback call. To register an OSGi `TurboFilter`,
just to register an service that implements the `ch.qos.logback.classic.turbo.TurboFilter` interface.

    :::java
    import import ch.qos.logback.classic.turbo.MatchingFilter;

    SimpleTurboFilter stf = new SimpleTurboFilter();
    ServiceRegistration sr  = bundleContext.registerService(TurboFilter.class.getName(), stf, null);

    private static class SimpleTurboFilter extends MatchingFilter {
        @Override
        public FilterReply decide(Marker marker, Logger logger, Level level, String format,
         Object[] params, Throwable t) {
            if(logger.getName().equals("turbofilter.foo.bar")){
                    return FilterReply.DENY;
            }
            return FilterReply.NEUTRAL;
        }
    }

As these filters are invoked for every call they must execute quickly.

### Filters as OSGi services

[Logback Filters][1] are attached to appenders and are used to determine if any LoggingEvent needs to
be passed to the appender. When registering a filter the bundle needs to configure a service property
`appenders` which refers to list of appender names to which the Filter must be attached


    :::java
    import ch.qos.logback.core.filter.Filter;

    SimpleFilter stf = new SimpleFilter();
    Dictionary<String, Object> props = new Hashtable<String, Object>();
    props.put("appenders", "TestAppender");
    ServiceRegistration sr  = bundleContext.registerService(Filter.class.getName(), stf, props);

    private static class SimpleFilter extends Filter<ILoggingEvent> {

        @Override
        public FilterReply decide(ILoggingEvent event) {
            if(event.getLoggerName().equals("filter.foo.bar")){
                return FilterReply.DENY;
            }
            return FilterReply.NEUTRAL;
        }
    }

If the `appenders` value is set to `*` then the filter would be registered with all the appenders (`Since 4.0.4`)

### Appenders as OSGi services

[Logback Appenders][2] handle the logging events produced by Logback. To register an OSGi `Appender`,
just register a service that implements the `ch.qos.logback.core.Appender` interface.  Such a service must
have a `loggers` service property, which refers to list of logger names to which the Appender must be attached.

    :::java
    Dictionary<String,Object> props = new Hashtable<String, Object>();

    String[] loggers = {
            "foo.bar:DEBUG",
            "foo.bar.zoo:INFO",
    };

    props.put("loggers",loggers);
    sr = bundleContext.registerService(Appender.class.getName(),this,props);

### Logback Config Fragment Support

Logback supports including parts of a configuration file from another file (See [File Inclusion][4]). This module
extends that support by allowing other bundles to provide config fragments. There are two ways to achieve that, 
described below.

#### Logback config fragments as String objects

If you have the config as string then you can register that String instance as a service with property `logbackConfig`
set to true. The Sling Logback Extension monitors such objects and passes them to logback.


    :::java
    Properties props = new Properties();
    props.setProperty("logbackConfig","true");

    String config = "<included>\n" +
            "  <appender name=\"FOOFILE\" class=\"ch.qos.logback.core.FileAppender\">\n" +
            "    <file>${sling.home}/logs/foo.log</file>\n" +
            "    <encoder>\n" +
            "      <pattern>%d %-5level %logger{35} - %msg %n</pattern>\n" +
            "    </encoder>\n" +
            "  </appender>\n" +
            "\n" +
            "  <logger name=\"foo.bar.include\" level=\"INFO\">\n" +
            "       <appender-ref ref=\"FOOFILE\" />\n" +
            "  </logger>\n" +
            "\n" +
            "</included>";

    registration = context.registerService(String.class.getName(),config,props);


If the config needs to be updated just re-register the service so that changes are picked up.

#### Logback config fragments as ConfigProvider instances

Another way to provide config fragments is with services that implement the 
`org.apache.sling.commons.log.logback.ConfigProvider` interface.

    :::java
    @Component
    @Service
    public class ConfigProviderExample implements ConfigProvider {
        public InputSource getConfigSource() {
            return new InputSource(getClass().getClassLoader().getResourceAsStream("foo-config.xml"));
        }
    }

If the config changes then sending an OSGi event with the `org/apache/sling/commons/log/RESET` topic 
resets the Logback runtime.

    :::java
    eventAdmin.sendEvent(new Event("org/apache/sling/commons/log/RESET",new Properties()));

### External Config File

Logback can be configured with an external file. The file name can be specified through

1. OSGi config - Look for a config with name `Apache Sling Logging Configuration` and specify the config file path.
2. OSGi Framework Properties - Logback support also looks for a file named according to the OSGi framwork `org.apache.sling.commons.log.configurationFile` property.
   
If you are providing an external config file then to support OSGi integration you need to add following
action entry:

    :::xml
    <newRule pattern="*/configuration/osgi"
             actionClass="org.apache.sling.commons.log.logback.OsgiAction"/>
    <newRule pattern="*/configuration/appender-ref-osgi"
             actionClass="org.apache.sling.commons.log.logback.OsgiAppenderRefAction"/>
    <osgi/>

The `osgi` element enables the OSGi integration support

### Java Util Logging (JUL) Integration

The bundle also support [SLF4JBridgeHandler][9]. The two steps listed below enable the JUL integration.
This allows for routing logging messages from JUL to the Logbback appenders.

1. Set the `org.apache.sling.commons.log.julenabled` framework property to true.


If `org.apache.sling.commons.log.julenabled` is found to be true then [LevelChangePropagator][8] would be 
registered automatically with Logback 

### <a name="config-override"></a>Configuring OSGi appenders in the Logback Config

So far Sling used to configure the appenders based on OSGi config. This provides a very limited
set of configuration options. To make use of other Logback features you can override the OSGi config
from within the Logback config file. OSGi config based appenders are named based on the file name.

For example, for the following OSGi config

    org.apache.sling.commons.log.file="logs/error.log"
    org.apache.sling.commons.log.level="INFO"
    org.apache.sling.commons.log.file.size="'.'yyyy-MM-dd"
    org.apache.sling.commons.log.file.number=I"7"
    org.apache.sling.commons.log.pattern="{0,date,dd.MM.yyyy HH:mm:ss.SSS} *{4}* [{2}] {3} {5}"

The Logback appender would be named `logs/error.log`. To extend/override the config in a Logback config
create an appender with the name `logs/error.log`:

    :::xml
    <appender name="/logs/error.log" class="ch.qos.logback.core.FileAppender">
      <file>${sling.home}/logs/error.log</file>
      <encoder>
        <pattern>%d %-5level %X{sling.userId:-NA} [%thread] %logger{30} %marker- %msg %n</pattern>
        <immediateFlush>true</immediateFlush>
      </encoder>
    </appender>

In this case the logging module creates an appender based on the Logback config instead of the OSGi config. 
This can be used to move the application from OSGi based configs to Logback based configs.

## Using Slf4j API 1.7

With Slf4j API 1.7 onwards its possible to use logger methods with varargs i.e. log n arguments without 
constructing an object array e.g. `log.info("This is a test {} , {}, {}, {}",1,2,3,4)`. Without var args
you need to construct an object array `log.info("This is a test {} , {}, {}, {}",new Object[] {1,2,3,4})`. 
To make use of this API and still be able to use your bundle on Sling systems which package older version
of the API jar, follow the below steps. (See [SLING-3243][SLING-3243]) for more details.

1. Update the api version in the pom:

        :::xml
        <dependencies>
            <dependency>
              <groupId>org.slf4j</groupId>
              <artifactId>slf4j-api</artifactId>
              <version>1.7.5</version>
              <scope>provided</scope>
            </dependency>
           ...
        </dependency>

2. Add an `Import-Package` instruction with a custom version range: 

        :::xml
        <build>
            <plugins>
              <plugin>
                <groupId>org.apache.felix</groupId>
                <artifactId>maven-bundle-plugin</artifactId>
                <extensions>true</extensions>
                <configuration>
                  <instructions>
                    ...
                    <Import-Package>
                      org.slf4j;version="[1.5,2)",
                      *
                    </Import-Package>
                  </instructions>
                </configuration>
              </plugin>
              ...
           </plugins>
        </build>

The Slf4j API bundle 1.7.x is binary compatible with 1.6.x.

This setup allows your bundles to make use of the var args feature while making logging calls, but the bundles
can still be deployed on older systems which provide only the 1.6.4 version of the slf4j api.

## Log Tracer

Log Tracer provides support for enabling the logs for specific category at specific 
level and only for specific request. It provides a very fine level of control via config provided
as part of HTTP request around how the logging should be performed for given category.

Refer to [Log Tracer Doc](/documentation/bundles/log-tracers.html) for more details

## Slf4j MDC

Sling MDC Inserting Filter exposes various request details as part of [MDC][11].
 
Currently it exposes following variables:

1. `req.remoteHost` - Request remote host
2. `req.userAgent` - User Agent Header
3. `req.requestURI` - Request URI
4. `req.queryString` - Query String from request
5. `req.requestURL` -
6. `req.xForwardedFor` -
7. `sling.userId` - UserID associated with the request. Obtained from ResourceResolver
8. `jcr.sessionId` - Session ID of the JCR Session associated with current request.

The filter also allow configuration to extract data from request cookie, header and parameters. 
Look for configuration with name 'Apache Sling Logging MDC Inserting Filter' for details on 
specifying header, cookie, param names.

![MDC Filter Config](/documentation/bundles/mdc-filter-config.png)

<a name="mdc-pattern">
### Including MDC in Log Message

To include the MDC value in log message you MUST use the [Logback pattern][15] based on Logback 
and not the old MessageFormat based pattern. 

    %d{dd.MM.yyyy HH:mm:ss.SSS} *%p* [%X{req.remoteHost}] [%t] %c %msg%n

### Installation

Download the bundle from [here][12] or use following Maven dependency

    ::xml
    <dependency>
        <groupId>org.apache.sling</groupId>
        <artifactId>org.apache.sling.extensions.slf4j.mdc</artifactId>
        <version>1.0.0</version>
    </dependency>
    
## Logback Groovy Fragment

This fragment is required to make use of Groovy based event evaluation support 
provided by Logback. This enables programatic filtering of the log messages and
is useful to get desired logs without flooding the system. For example Oak
logs the JCR operations being performed via a particular session. if this lo is 
enabled it would flood the log with messages from all the active session. However
if you need logging only from session created in a particular thread then that 
can be done in following way

    ::xml
    <?xml version="1.0" encoding="UTF-8"?>
    <configuration scan="true" scanPeriod="1 second">
      <jmxConfigurator/>
      <newRule pattern="*/configuration/osgi" actionClass="org.apache.sling.commons.log.logback.OsgiAction"/>
      <newRule pattern="*/configuration/appender-ref-osgi" actionClass="org.apache.sling.commons.log.logback.OsgiAppenderRefAction"/>
      <osgi/>
    
       <appender name="OAK" class="ch.qos.logback.core.FileAppender">
        <filter class="ch.qos.logback.core.filter.EvaluatorFilter">      
          <evaluator class="ch.qos.logback.classic.boolex.GEventEvaluator"> 
            <expression><![CDATA[
                return e.getThreadName().contains("JobHandler");
            ]]></expression>
          </evaluator>
          <OnMismatch>DENY</OnMismatch>
          <OnMatch>ACCEPT</OnMatch>
        </filter>
        <file>${sling.home}/logs/oak.log</file>
        <encoder>
          <pattern>%d %-5level [%thread] %marker- %msg %n</pattern> 
          <immediateFlush>true</immediateFlush>
        </encoder>
      </appender>
    
      <logger name="org.apache.jackrabbit.oak.jcr.operations" level="DEBUG" additivity="false">
          <appender-ref ref="OAK"/>
      </logger>
    </configuration>
    
Logback exposes a variable `e` which is of type [ILoggingEvent][13]. It provides access to current logging
event. Above logback config would route all log messages from `org.apache.jackrabbit.oak.jcr.operations`
category to `${sling.home}/logs/oak.log`. Further only those log messages would be logged
where the `threadName` contains `JobHandler`. Depending on the requirement the expression can
be customised.

### Installation

Currently the bundle is not released and has to be build from [here][14]

    ::xml
    <dependency>
        <groupId>org.apache.sling</groupId>
        <artifactId>org.apache.sling.extensions.logback-groovy-fragment</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </dependency>

## FAQ

##### Q. Can Sling Commons Log bundle be used in non Sling environments

This bundle does not depend on any other Sling bundle and can be easily used in any OSGi framework. 
To get complete log support working you need to deploy following bundles

* Slf4j-Api - org.slf4j:slf4j-api
* Jcl over Slf4j - org.slf4j:jcl-over-slf4j
* Log4j over Slf4j - org.slf4j:log4j-over-slf4j 
* Sling Log Service - org.apache.sling:org.apache.sling.commons.logservice:1.0.2
* Sling Commons Log - org.apache.sling:org.apache.sling.commons.log:4.0.0 or above
* Sling Log WebConsole - org.apache.sling.commons.log.webconsole:1.0.0 or above

##### Q. How to start Sling with an external logback.xml file

You need to specify the location of logback.xml via `org.apache.sling.commons.log.configurationFile`

        java -jar org.apache.sling.launchpad-XXX-standalone.jar -Dorg.apache.sling.commons.log.configurationFile=/path/to/logback
 

[1]: http://logback.qos.ch/manual/filters.html
[2]: http://logback.qos.ch/manual/appenders.html
[3]: http://logback.qos.ch/manual/filters.html#TurboFilter
[4]: http://logback.qos.ch/manual/configuration.html#fileInclusion
[8]: http://logback.qos.ch/manual/configuration.html#LevelChangePropagator
[9]: http://www.slf4j.org/api/org/slf4j/bridge/SLF4JBridgeHandler.html
[10]: http://logback.qos.ch/manual/appenders.html#TimeBasedRollingPolicy
[SLING-3243]: https://issues.apache.org/jira/browse/SLING-3243
[11]: http://www.slf4j.org/manual.html#mdc
[12]: http://sling.apache.org/downloads.cgi
[13]: http://logback.qos.ch/apidocs/ch/qos/logback/classic/spi/ILoggingEvent.html
[14]: http://svn.apache.org/repos/asf/sling/trunk/contrib/extensions/logback-groovy-fragment/
[15]: http://logback.qos.ch/manual/layouts.html#conversionWord
[SLING-6144]: https://issues.apache.org/jira/browse/SLING-6144
