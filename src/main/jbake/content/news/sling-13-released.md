title=Apache Sling 13 released		
type=page
status=published
tags=launchpad
~~~~~~

The Sling 13 release contains numerous improvements, such as official Java 21 support, TODO, and various performance improvements and updates.

Read on to see more details about the individual improvements. To find out more about running Sling, see our [getting started page](/documentation/getting-started.html).

## Official support for Java 21

The Sling Starter and included modules are validated to work on Java 11, 17 and 21. Note that for Java 17+ the `org.apache.sling.commons.threads` will not clean up leftover `ThreadLocal` instances unless the  `--add-opens java.base/java.lang=ALL-UNNAMED` is passed to the JVM.

This fix is already applied to the [official Sling Starter Docker image](https://hub.docker.com/r/apache/sling) and we anticipate further fixes in this area.

Modules started to switch to Java 11 as minimum version, so Java 8 is no longer supported for the Sling Starter.


## Update to Oak 1.72.0

[Apache Jackrabbit Oak](https://jackrabbit.apache.org/oak/) 1.72.0 brings numerous performance improvements and new features that are now available in the Sling Starter.

