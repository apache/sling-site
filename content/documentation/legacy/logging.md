title=Logging		
type=page
status=published
~~~~~~

<div class="note">
This document is for 3.x release of Sling Commons Log components. Refer to
<a href="http://sling.apache.org/documentation/development/logging.html">Logging</a> for documentation related
to newer version.
</div>

## Introduction

Logging in Sling is supported by the `org.apache.sling.commons.log` bundle, which is one of the first bundles installed and started by the Sling Launcher. The `org.apache.sling.commons.log` bundle has the following tasks:

* Implements the OSGi Log Service Specification and registers the `LogService` and `LogReader` services
* Exports three commonly used logging APIs:
* [Simple Logging Facade for Java (SLF4J)](http://www.slf4j.org)
* [Apache Commons Logging](http://jakarta.apache.org/commons/logging)
* [log4j](http://logging.apache.org/log4j/index.html)
* [java.util.logging](http://download.oracle.com/javase/6/docs/api/java/util/logging/package-summary.html) (as of r1169918)
* Configures logging through our own implementation of the SLF4J backend API


## Initial Configuration

The `org.apache.sling.commons.log` bundle gets the initial configuration from the following `BundleContext` properties:


| Property | Default | Description |
|--|--|--|
| `org.apache.sling.commons.log.level` | `INFO` | Sets the initial logging level of the root logger. This may be any of the defined logging levels `DEBUG`, `INFO`, `WARN`, `ERROR` and `FATAL`. |
| `org.apache.sling.commons.log.file` | undefined | Sets the log file to which log messages are written. If this property is empty or missing, log messages are written to `System.out`. |
| `org.apache.sling.commons.log.file.number` | 5 | The number of rotated files to keep. |
| `org.apache.sling.commons.log.file.size` | '.'yyyy-MM-dd | Defines how the log file is rotated (by schedule or by size) and when to rotate. See the section *Log File Rotation* below for full details on log file rotation. |
| `org.apache.sling.commons.log.pattern` | {0,date,dd.MM.yyyy HH:mm:ss.SSS} *{4}* [{2}]({{ refs.-2.path }}) {3} {5} | The `MessageFormat` pattern to use for formatting log messages with the root logger. |
| `org.apache.sling.commons.log.julenabled` | n/a | Enables the `java.util.logging` support. |


## User Configuration

User Configuration after initial configuration is provided by the Configuration Admin Service. To this avail two `org.osgi.services.cm.ManagedServiceFactory` services are registered under the PIDs `org.apache.sling.commons.log.LogManager.factory.writer` and `org.apache.sling.commons.log.LogManager.factory.config` which may receive configuration.


### Logger Configuration

Loggers (or Categories) can be configured to log to specific files at specific levels using configurable patterns. To this avail factory configuration instances with factory PID `org.apache.sling.commons.log.LogManager.factory.config` may be created and configured with the Configuration Admin Service.

The following properties may be set:

| Property | Type | Default | Description |
|--|--|--|--|
| `org.apache.sling.commons.log.level` | `String` | `INFO` | Sets the logging level of the loggers. This may be any of the defined logging levels `DEBUG`, `INFO`, `WARN`, `ERROR` and `FATAL`. |
| `org.apache.sling.commons.log.file` | `String` | undefined | Sets the log file to which log messages are written. If this property is empty or missing, log messages are written to `System.out`. This property should refer to the file name of a configured Log Writer (see below). If no Log Writer is configured with the same file name an implicit Log Writer configuration with default configuration is created. |
| `org.apache.sling.commons.log.pattern` | `String` | {0,date,dd.MM.yyyy HH:mm:ss.SSS} *{4}* [{2}]({{ refs.-2.path }}) {3} {5} | The `java.util.MessageFormat` pattern to use for formatting log messages with the root logger. This is a `java.util.MessageFormat` pattern supporting up to six arguments: {0} The timestamp of type `java.util.Date`, {1} the log marker, {2} the name of the current thread, {3} the name of the logger, {4} the debug level and {5} the actual debug message. If the log call includes a Throwable, the stacktrace is just appended to the message regardless of the pattern. |
| `org.apache.sling.commons.log.names` | `String[]` | -- | A list of logger names to which this configuration applies. |


Note that multiple Logger Configurations may refer to the same Log Writer Configuration. If no Log Writer Configuration exists whose file name matches the file name set on the Logger Configuration an implicit Log Writer Configuration with default setup (daily log rotation) is internally created.


### Log Writer Configuration

Log Writer Configuration is used to setup file output and log file rotation characteristics for log writers used by the Loggers.

The following properties may be set:

| Property | Default | Description |
|--|--|--|
| `org.apache.sling.commons.log.file` | undefined | Sets the log file to which log messages are written. If this property is empty or missing, log messages are written to `System.out`. |
| `org.apache.sling.commons.log.file.number` | 5 | The number of rotated files to keep. |
| `org.apache.sling.commons.log.file.size` | '.'yyyy-MM-dd | Defines how the log file is rotated (by schedule or by size) and when to rotate. See the section *Log File Rotation* below for full details on log file rotation. |

See the section *Log File Rotation* below for full details on the `org.apache.sling.commons.log.file.size` and `org.apache.sling.commons.log.file.number` properties.



## Log File Rotation

Log files can grow rather quickly and fill up available disk space. To cope with this growth log files may be rotated in two ways: At specific times or when the log file reaches a configurable size. The first method is called *Scheduled Rotation* and is used by specifying a `SimpleDateFormat` pattern as the log file "size". The second method is called *Size Rotation* and is used by setting a maximum file size as the log file size.

As of version 2.0.6 of the Sling Commons Log bundle, the default value for log file scheduling is `'.'yyyy-MM-dd` causing daily log rotation. Previously log rotation defaulted to a 10MB file size limit.



### Scheduled Rotation

The rolling schedule is specified by setting the `org.apache.sling.commons.log.file.size` property to a `java.text.SimpleDateFormat` pattern. Literal text (such as a leading dot) to be included must be *enclosed* within a pair of single quotes. A formatted version of the date pattern is used as the suffix for the rolled file name.

For example, if the log file is configured as `/foo/bar.log` and the pattern set to `'.'yyyy-MM-dd`, on 2001-02-16 at midnight, the logging file `/foo/bar.log` will be renamed to `/foo/bar.log.2001-02-16` and logging for 2001-02-17 will continue in a new `/foo/bar.log` file until it rolls over the next day.

It is possible to specify monthly, weekly, half-daily, daily, hourly, or minutely rollover schedules.

| DatePattern | Rollover schedule | Example |
|--|--|--|
| `'.'yyyy-MM` | Rollover at the beginning of each month | At midnight of May 31st, 2002 `/foo/bar.log` will be copied to `/foo/bar.log.2002-05`. Logging for the month of June will be output to `/foo/bar.log` until it is also rolled over the next month. |
| `'.'yyyy-ww` | Rollover at the first day of each week. The first day of the week depends on the locale. | Assuming the first day of the week is Sunday, on Saturday midnight, June 9th 2002, the file `/foo/bar.log` will be copied to `/foo/bar.log.2002-23`. Logging for the 24th week of 2002 will be output to `/foo/bar.log` until it is rolled over the next week. |
| `'.'yyyy-MM-dd` | Rollover at midnight each day.| At midnight, on March 8th, 2002, `/foo/bar.log` will be copied to `/foo/bar.log.2002-03-08`. Logging for the 9th day of March will be output to `/foo/bar.log` until it is rolled over the next day.|
| `'.'yyyy-MM-dd-a` | Rollover at midnight and midday of each day.| at noon, on March 9th, 2002, `/foo/bar.log` will be copied to  `/foo/bar.log.2002-03-09-AM`. Logging for the afternoon of the 9th will be output to `/foo/bar.log` until it is rolled over at midnight.|
| `'.'yyyy-MM-dd-HH` | Rollover at the top of every hour.| At approximately 11:00.000 o'clock on March 9th, 2002, `/foo/bar.log` will be copied to `/foo/bar.log.2002-03-09-10`. Logging for the 11th hour of the 9th of March will be output to `/foo/bar.log` until it is rolled over at the beginning of the next hour.|
| `'.'yyyy-MM-dd-HH-mm` | Rollover at the beginning of every minute.| At approximately 11:23,000, on March 9th, 2001, `/foo/bar.log` will be copied to `/foo/bar.log.2001-03-09-10-22`. Logging for the minute of 11:23 (9th of March) will be output to `/foo/bar.log` until it is rolled over the next minute.|

Do not use the colon ":" character in anywhere in the pattern option. The text before the colon is interpeted as the protocol specificaion of a URL which is probably not what you want.

Note that Scheduled Rotation ignores the `org.apache.sling.commons.log.file.number` property since the old log files are not numbered but "dated".


### Size Rotation

Log file rotation by size is specified by setting the `org.apache.sling.commons.log.file.size` property to a plain number or a number plus a size multiplier. The size multiplier may be any of `K`, `KB`, `M`, `MB`, `G`, or `GB` where the case is ignored and the meaning is probably obvious.

When using Size Rotation, the `org.apache.sling.commons.log.file.number` defines the number of old log file generations to keep. For example to keep 5 old log files indexed by 0 through 4, set the `org.apache.sling.commons.log.file.number` to `5` (which happens to be the default).
