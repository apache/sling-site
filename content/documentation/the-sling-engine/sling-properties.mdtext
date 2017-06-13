Title: Well-known Sling Properties

This table lists properties which have known functionality in the OSGi and Sling frameworks.

With the exception of the Sling setup properties (`sling.home`, `sling.launchpad`, and `sling.properties`) all properties can be set on the command line using the `-D` command line option or in the `sling.properties` file. Properties defined on the command line or in the `web.xml` file always overwrite properties in the `sling.properties` file.

[TOC]


## Sling Setup Properties

| Property | Default Value | Description |
|---|---|---|
| `sling.home` | `sling` | Path to the main Sling Directory; relative path is resolved against current working directory as defined in the `user.dir` system property. Can also be set with the `-c` command line option. | Launchpad |
| `sling.launchpad` | `${sling.home}` | Location for the Sling launchpad JAR file and the startup folder containing bundles to be installed by the Bootstrap Installer. Can also be set with the `-i` command line option. | Launchpad |
| `sling.properties` | `${sling.home}/sling.properties` | Path to the `sling.properties` file; relative path is resolved against `${sling.home}` | Launchpad |

## Server Control Port Properties

| Property | Default Value | Description |
|---|---|---|
| `sling.control.socket` | `127.0.0.1:0` | Specification of the control port. Can also be set with the `-j` command line option. This property is only used by the Standalone Sling Application. | Launchpad |
| `sling.control.action` | -- | Action to execute. This is the same as specifying `start`, `status`, or `stop` on the command line. This property is only used by the Standalone Sling Application. | Launchpad |

## Logging Configuration

Logging configuration defined by these properties sets up initial configuration for the Sling Commons Log bundle. This configuration is used as long as there is no configuration from the Configuration Admin Service for the service PID `org.apache.sling.commons.log.LogManager`.

| Property | Default Value | Description |
|---|---|---|
| `org.apache.sling.commons.log.level` | `INFO` | Sets the initial logging level of the root logger. This may be any of the defined logging levels `DEBUG`, `INFO`, `WARN`, or `ERROR`.  This property can also be set with the `-l` command line option. |
| `org.apache.sling.commons.log.file` | `${sling.home}/logs/error.log` | Sets the log file to which log messages are written. If this property is empty or missing, log messages are written to System.out. This property can also be set with the `-f` command line option. |
| `org.apache.sling.commons.log.file.number` | `5` | The number of rotated files to keep. |
| `org.apache.sling.commons.log.file.size` | `'.'yyyy-MM-dd` | Defines how the log file is rotated (by schedule or by size) and when to rotate. See the section [Log File Rotation](http://sling.apache.org/site/logging.html#Logging-LogFileRotation) for full details on log file rotation. |
| `org.apache.sling.commons.log.pattern` | `{0,date,dd.MM.yyyy HH:mm:ss.SSS} *{4}* [{2}] {3} {5}` | The MessageFormat pattern to use for formatting log messages with the root logger. |
| org.apache.sling.commons.log.julenabled | `false` | Enables the java.util.logging support. |

See [Logging](http://sling.apache.org/site/logging.html) for full information on configuring the Sling Logging system.


## Http Service Properties

| Property | Default Value | Description |
|---|---|---|
| `org.apache.felix.http.context_path` | `/` | The servlet context path for the Http Service of the embedded servlet container. This property requires support by the Http Service bundle. |
| `org.apache.felix.http.host` | `0.0.0.0` | The host interface to bind the HTTP Server to. This property requires support by the Http Service bundle. |
| `org.osgi.service.http.port` | 8080 | The port to listen on for HTTP requests. This property requires support by the Http Service bundle. |

