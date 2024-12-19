title=Apache Sling 13 released		
type=page
status=published
tags=launchpad
~~~~~~

The Sling 13 release contains numerous improvements, such as official Java 21 support, and various performance improvements and updates.

Read on to see more details about the individual improvements. To find out more about running Sling, see our [getting started page](/documentation/getting-started.html).

## Official support for Java 21

The Sling Starter and included modules are validated to work on Java 11, 17 and 21.

Note that for Java 17+ the `org.apache.sling.commons.threads` will not clean up leftover `ThreadLocal` instances unless the  `--add-opens java.base/java.lang=ALL-UNNAMED` is passed to the JVM. This fix is already applied to the [official Sling Starter Docker image](https://hub.docker.com/r/apache/sling) and we anticipate further fixes in this area.


## Drop support for Java 8

Some of the Sling modules and their dependencies started to switch to Java 11 as minimum version, so Java 8 is no longer supported for the Sling Starter.


## Update to Oak 1.72.0

[Apache Jackrabbit Oak](https://jackrabbit.apache.org/oak/) 1.72.0 brings numerous performance improvements and new features that are now available in the Sling Starter.


## Switch to jakarta.json

A lot of modules have been migrated from `org.json` to `jakarta.json`, some modules are still using `org.json`. Thus the Sling Starter includes both [Apache Johnzon](https://johnzon.apache.org/) 1.x and 2.x for supporting both. It is expected that all modules will be migrated to `jakarta.json` soon and Johnzon 1.x will be removed from the Sling Starter.

## Sling Models

Sling Models comes with a couple of small improvements:

* [SLING-8706](https://issues.apache.org/jira/browse/SLING-8706) Injections for java.util.Optional<> should be automatic optional 
* [SLING-11917](https://issues.apache.org/jira/browse/SLING-11917) Sling Models: Support parameter name evaluation in constructor injection 
* [SLING-12359](https://issues.apache.org/jira/browse/SLING-12359) Support constructor injection for Java Record classes 

## Sling XSS

The Sling XSS module implementation switched from [OWASP AntiSamy](https://www.owasp.org/index.php/Category:OWASP_AntiSamy_Project) to the [OWASP Java HTML Sanitizer](https://www.owasp.org/index.php/OWASP_Java_HTML_Sanitizer_Project) library ([SLING-7231](https://issues.apache.org/jira/browse/SLING-7231)).


## Version updates

All bundles have been updated to the latest versions.

New bundles added to Sling Starter:
* `com.fasterxml.jackson.dataformat:jackson-dataformat-xml`
* `com.fasterxml.woodstox:woodstox-core`
* `org.apache.commons:commons-text`
* `org.apache.felix:org.apache.felix.http.inventoryprinter`
* `org.apache.felix:org.apache.felix.http.webconsoleplugin`
* `org.owasp.encoder:encoder`                  

The following bundles are removed from the Sling Starter:
* `com.google.guava:guava`
* `org.apache.jackrabbit:jackrabbit-jcr-rmi`

A couple of bundles changed their artifact ID and are thus replaced with the latest version using the latest artifact ID (e.g. switch to Groovy 4).


### OSGi Core R8 compliance

Sling Starter ships with [Apache Felix 7](https://felix.apache.org/documentation/index.html) which implements [OSGi Core R8](https://docs.osgi.org/specification/osgi.core/8.0.0/) fully. In addition it comes with Felix SCR 2.2 which implements [Declarative Services 1.5](https://docs.osgi.org/specification/osgi.cmpn/8.0.0/service.component.html) (part of OSGi Compendium R8).
