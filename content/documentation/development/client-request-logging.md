Title: Client Request Logging

Sling provides extensive support to log various information at the before and after processing client requests. Out of the box, there are two loggers configured to write traditional `access.log` and `request.log` files. In addition more logging can be configured by providing OSGi Configuration Admin configuration.

## Traditional access.log and request.log Files

In the Web Console configure the *Apache Sling Request Logger* (PID=`org.apache.sling.engine.impl.log.RequestLogger`) configuration.

In the Sling Web Console locate the Configuration page (`/system/console/configMgr`) and click on the pencil (edit) symbol on the *Apache Sling Request Logger* line. This opens a dialog to enter the configuration whose properties can be configured as follows:

| Parameter | Name | Default | Description |
|--|--|--|--|
| Request Log Name | `request.log.output` | logs/request.log | Name of the destination for the request log. The request log logs the entry and exit of each request into and out of the system together with the entry time, exit time, time to process the request, a request counter as well as the final status code and response content type. In terms of Request Logger Service formats, request entry is logged with the format `%t \[%R\] \-> %m %U%q %H` and request exit is logged with the format `%\{end}t \[%R] <\- %s %\{Content-Type}o %Dms` (See [Log Format Specification](#log-format-specification) below for the specification of the format). |
| Request Log Type | `request.log.outputtype` | Logger Name | Type of Logger named with the Logger Name parameter. See [Log Output](#log-output) below |
| Enable Request Log | `request.log.enabled` | true | Whether to enable Request logging or not. |
| Access Log Name | `access.log.output` | logs/access.log | Name of the destination for the access log. The access log writes an entry for each request as the request terminates using the NCSA extended/combined log format. In terms of Request Logger Service formats the access log is written with the format `%h %l %u %t "%r" %>s %b "%\{Referer}i" "%\{User-Agent}i"` (See [Log Format Specification](#log-format-specification) below for the specification of the format). |
| Access Log Type | `access.log.outputtype` | Logger Name | Type of Logger named with the Logger Name parameter. See [Log Output](#log-output) below |
| Enable Access Log | `access.log.enabled` | true | Whether to enable Access logging or not. |


#### Log Output

Output of client request logging is defined by the Logger Type and and Logger Name where the use of the Logger Name property value depends on the Logger Type:

| Type Code | Type Name | Description and Logger Name interpretation |
|--|--|--|
| 0 | Logger Name | Writes the logging information to a named SLF4J Logger. The name of the Logger is defined in the Logger Name property. The actual destination of the log messages is defined the SLF4J configuration for the named logger |
| 1 | File Name | Writes the logging information to a file, on message per line. The file name is an absolute or relative path name. If the name is relative, it is resolved against the `sling.home` framework property. |
| 2 | RequestLog Service | Sends the logging information to a `org.apache.sling.engine.RequestLog` service whose `requestlog.name` service registration property must the same as the value of the Logger Name property. If more than one such service is registered, all services are called. If no such service is registered, the logging information is discarded. Using RequestLog Services is deprecated. |

**Note:** If logging to a file, this file is not rotated and/or limited by size. To get log file rotation use the *Logger Name* logging type. See [Rotating Logger Files](#rotating-logger-files) below for information on how logging information can be written to rotated and/or size limited files.


### Additional per-request Loggers

In the Web Console create *Apache Sling Customizable Request Data Logger* (Factory PID=`org.apache.sling.engine.impl.log.RequestLoggerService`) configuration.

In the Sling Web Console locate the Configuration page (`/system/console/configMgr`) and click on the `+` (plus) symbol on the *Apache Sling Customizable Request Data Logger* line. This opens a dialog to enter the configuration whose properties can be configured as follows:

| Parameter | Name | Default | Description |
|--|--|--|--|
| Log Format | `request.log.service.format` | &nbsp; | Specify a [Log Format Specification](#log-format-specification) as described below |
| Logger Type | `request.log.service.outputtype` | Logger Name/`0` | Type of Logger named with the Logger Name parameter. See [Log Output](#log-output) above |
| Logger Name | `request.log.service.output` | `request.log` | Name of the Logger to be used. See [Log Output](#log-output) above |
| Request Entry | `request.log.service.onentry` | unchecked/`false` | Whether logger is called at the start of request processing or after processing the request |



#### Log Format Specification

The log format specification generally follows the [definition of the `format` argument for the `LogFormat` and `CustomLog` directives of Apache httpd](http://httpd.apache.org/docs/current/mod/mod_log_config.html). Please see the below table for details and exceptions.

The characteristics of the request itself are logged by placing "%" directives in the format string, which are replaced in the log file by the values as follows:

| Format String | Description |
|--|--|
| `%%`  | The percent sign |
| `%a`  | Remote IP-address |
| `%A`  | Local IP-address |
| `%B`  | Size of response in bytes, excluding HTTP headers. |
| `%b`  | Size of response in bytes, excluding HTTP headers. In CLF format, i.e. a '-' rather than a 0 when no bytes are sent. |
| `%\{Foobar}C`  | The contents of cookie Foobar in the request sent to the server. |
| `%D`  | The time taken to serve the request, in milliseconds. Please note that this deviates from the Apache httpd format. |
| `%\{FOOBAR}e`  |Not supported in Sling; prints nothing. |
| `%f`  | The absolute path of the resolved resource |
| `%h`  | Remote host |
| `%H`  | The request protocol |
| `%\{Foobar}i`  | The contents of Foobar: header line(s) in the request sent to the server. |
| `%k`  | Not supported in Sling; prints nothing. |
| `%l`  | Not supported in Sling; prints nothing. |
| `%m`  | The request method |
| `%\{Foobar}n`  | Not supported in Sling; prints nothing. |
| `%\{Foobar}o`  | The contents of Foobar: header line(s) in the reply. |
| `%p`  | The canonical port of the server serving the request |
| `%\{format}p`  | The canonical port of the server serving the request or the server's actual port or the client's actual port. Valid formats are canonical, local, or remote. |
| `%P`  | The *name of the thread* ~~process ID of the child~~ that serviced the request. |
| `%\{format}P`  | Same as `%P`; the `format` parameter is ignored. |
| `%q`  | The query string (prepended with a ? if a query string exists, otherwise an empty string) |
| `%r`  | First line of request |
| `%R`  | The number of requests processed by Sling since the last start. |
| `%s`  | Status. |
| `%t`  | Time the request was received (standard english format) |
| `%\{format}t`  | Same as `%t`; the `format` parameter is ignored unless it is the literal value *end* indicating to use the time of request terminating (instead of the time of request receipt). |
| `%T`  | The time taken to serve the request, in seconds. |
| `%u`  | Remote user (from auth; may be bogus if return status (%s) is 401) |
| `%U`  | The URL path requested, not including any query string. |
| `%v`  | The canonical ServerName of the server serving the request. |
| `%V`  | Same as `%v`. |
| `%X`  | Not supported in Sling; prints nothing. |
| `%I`  | Not supported in Sling; prints nothing. |
| `%O`  | Not supported in Sling; prints nothing. |


**Modifiers**

Particular items can be restricted to print only for responses with specific HTTP status codes by placing a comma-separated list of status codes immediately following the "%". For example, "%400,501\{User-agent}i" logs User-agent on 400 errors and 501 errors only. For other status codes, the literal string "-" will be logged. The status code list may be preceded by a "!" to indicate negation: "%!200,304,302\{Referer}i" logs Referer on all requests that do not return one of the three specified codes.

The Apache httpd modifiers "<" and ">"  are not supported by Sling and currently ignored.


**Some Notes**

For security reasons non-printable and other special characters in %C, %i and %o are escaped using \uhhhh sequences, where hhhh stands for the hexadecimal representation of the character's unicode value. Exceptions from this rule are " and \, which are escaped by prepending a backslash, and all whitespace characters, which are written in their Java-style notation (\n, \t, etc).


#### Rotating Logger Files

If you want to write the request (and access) logging information into a rotated file, you should configure as follows:

1. Configure the Log Type to be a *Logger Name* and some usefull Logger name. For example `clientlog.request`.
1. Create an *Apache Sling Logging Logger Configuration* for this Logger name according to [Logging Configuration]({{ refs.logging-logger-configuration.path }}) with the following setup:
    * Allow message at INFO (Information) level to be logged which is the level used by the request loggers
    * Define the appropriate log file name, for example `logs/client.request.log`
    * Use only `\{5`} as the message format because request logger messages are generally already fully formated with required timestamp etc.
    * Add any Logger names used for the client request log configuration, `clientlog.request` in the example above, to the Logger field. By clicking on the `+` (plus) button you may add more than a single logger name whose messages are written to this file.
1. Optionally, you may create an *Apache Sling Logging Writer Configuration* for the log file defined in the previous step to better control rotation setup. See [Log Writer Configuration]({{ refs.logging-log-writer-configuration.path }}) for full details.