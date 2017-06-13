Title: Configuration


## Introduction

Configuration in Sling is aligned with respective support by the OSGi specification:

   * Framework and Java system properties are available through the `BundleContext.getProperty(String)` method. These properties are provided in Sling through the Sling launcher.
   * Bundle Header values are available through the `Bundle.getHeaders()` and `Bundle.getHeaders(String)` methods. These header values are set by the bundle developer in the `META-INF/MANIFEST.MF` file. In fact, all main manifest attributes are available through these methods.
   * Components managed by the Service Component Runtime and declared in component descriptor files listed in the `Service-Component` manifest header access configuration properties through the `ComponentContext.getProperties()` method. These properties have three sources:
       1. Configuration specified specifically for factory components
       2. Properties retrieved from the Configuration Admin Service
       3. Properties set in the component descriptor
   * Configuration properties provided to `ManagedService` and `ManagedServiceFactory` instances by the Configuration Admin Service.

For the discussion to follow we differentiate between initial configuration provided by Framework and system properties and managed configuration provided by the Configuration Admin Service.

Components managed by the Service Component Runtime are generally configured (as listed above) through the descriptor properties and configuration set by Configuration Admin Service configuration. The descriptor property values may be seen as configuration default values set by the component developer, which may be overwritten by user configuration through the Configuration Admin Service. Components may but are not required to make use of Framework properties by accessing the `BundleContext` through the `ComponentContext` given to the `activate(ComponentContext)` method of the component.



## Initial Configuration

The lifecycle of the OSGi framework implemented by an instance of the `org.apache.felix.framework.Felix` class is managed by the Sling launcher class `org.apache.sling.launcher.Sling`. This class is used by the standalone main class (`org.apache.sling.launcher.main.Main`) and the Sling Servlet (`org.apache.sling.launcher.servlet.SlingServlet`) to control the lifecycle.

The Sling launcher is responsible to provide the Framework properties to the OSGi framework. The properties are prepared as a `java.util.Map<String, String>` instance as follows (later steps may overwrite properties defined in earlier steps) :

1. Load core properties from the embedded `sling.properties` file.
1. Resolve any property file inclusions. This is mainly used to resolve the correct JRE package definitions for the JRE version used.
1. Overwrite with any properties provided by the main class or the Sling Servlet.
1. Make sure the `sling.home` property is set defining a sensible default value if missing
1. Load the contents of the `${sling.home}/sling.properties` file
1. Overwrite properties with Java system properties. This step only considers system properties of the same names as properties already existing. That is, the system properties are not just copied into the properties here. Additionally this step my be omitted if the `sling.ignoreSystemProperties` property is set to `true`.
1. Resolve any property file inclusions. This may be used to provide more configurability depending on the integration.
1. Handle OSGi boot delegation support (see below).
1. Resolve property references of the form `${propName`}
1. For each property value starting with `ontext:/` do the following, assuming the value to be an URL with scheme `context:`:
    * Copy the application resource to `${sling.home`} preserving the URL path unless such a file already exists.
    * Replace the property value with the path to the newly created file. The path has the form `${sling.home}/relpath`.
1. Store the properties as `${sling.home}/sling.properties` to be re-used on next startup
1. Setup Bundle auto installation for the Felix Framework

Using file system copies of the initial configuration and referred files, it is easy to modify this configuration without the need to unpack and repackage the web application archive.

The only property really required is actually the `sling.home` property, which defines the file system location where runtime files will be placed. The default if this property is missing will be *sling* in the current working directory as defined the `user.dir` system property.



### Standalone Application

When launching Sling as a standalone application the `sling-app.jar` file is used. This is an executable JAR File. The `sling.properties` file as well as the `sling_install.properties` and JRE specific properties files are located at the root of the JAR file hierarchy.

The standalone application currently sets properties for the third step of the configuration setup to ensure the HTTP Servlet integration is using the Apache Felix *http.jetty* bundle. Additionally system properties may be set using the `-D` command line switch of the Java binary.

In addition the following command line arguments are accepted:

| Argument | Sling property | Description |
|--|--|--|
| `-l loglevel` | `org.apache.sling.osgi.log.level` | The initial loglevel (0..4, FATAL, ERROR, WARN, INFO, DEBUG) |
| `-f logfile` | `org.apache.sling.osgi.log.file` | The log file, "-" for stdout |
| `-c slinghome` | `sling.home` | the sling context directory |
| `-a address` | -- | the interfact to bind to (use 0.0.0.0 for any) (not supported yet) |
| `-p port` | `org.osgi.service.http.port` | the port to listen to (default 8080) |
| `-h` | -- | Prints a simple usage message and exits. |

The standalone application exits with status code 0 (zero) if Sling terminates normally, that is if the OSGi framework is stopped or if just the usage note has been displayed. If any error occurrs during command line parsing, the cause is printed to the error output and the application exists with status code 1 (one). If the OSGi framework fails to start, the cause is printed to the error output and the application exists with status code 2.


### Web Application

When launching Sling as a web application using the `sling-servlet.war` or any derived Web Application archive file, the `sling.properties` file is located in the `WEB-INF` folder along with the `sling_install.properties` and JRE specific properties files.

The Sling Servlet uses the Servlet Context and Servlet `init-param` configurations to prepare the properties for the third step of the configuration setup.

If the OSGi framework fails to startup for any reason a `javax.servlet.UnavailableException`.



### Property File Inclusions

Twice in the configuration setup (second and seventh step) any property file inclusions will be handled. Property files may be included by defining one or more properties containing a comma-separated list of properties files to include. Property file inclusion looks at the `sling.include` property and any other property whose prefix is `sling.include.`. When such properties exist, the files listed in those properties are included.

The order of handling the property file inclusion properties is defined as natural sort order of the actual property names. So the properties of the files listed in the `sling.include.first` property will be loaded before the files listed in the `sling.include.second` but after the files listed in the `sling.include.a` property.

Any file which does not exist is silently ignored.

The names of the files are resolved as follows:

1. If a resource exists at the same location as the initial `sling.properties` file packaged with the application, that resource is used
1. If the name is a relative file name, it is looked for in the `sling.home` directory
1. If the name is an absolute file name, it is used as is

*Example*

The packaged `sling.properties` file contains the following properties file inclusion setting:


    sling.include.jre = jre-${java.specification.version}.properties


This is used to include the JRE package list to be made visible inside the OSGi framework.



### OSGi Boot Delegation Support

Some packages may have to be shared between bundles in an OSGi framework and the rest of Java VM in which the framework has been launched. This is especially true for OSGi framework instances launched in embedding such as Servlet Containers. In the case of a Sling Application accessing a JCR Repository launched in a different Web Application, this mainly concerns an API packages as well as the JNDI Initial Factory package(s).

To cope with this sharing issue, the OSGi core specification defines two properties, which may list packages to be used from the environment:


* *`org.osgi.framework.system.packages`* - This property lists package names which are added to the list of exported packages of the system bundle of the OSGi framework. These packages are used in the resolution process just as any package listed in an `Export-Package` bundle manifest header.
* *`org.osgi.framework.bootdelegation`* -  This property lists packages, which are always used from the environment. As such, these packages will never be looked up in package wirings as are packages imported by listing them in the `Import-Package` bundle manifest header.


Sometimes, especially in the Servlet Container case, it is important to use the shared classes from the container and not resolve using standard OSGi resolution. In such cases, the packages of these shared classes must be listed in the `org.osgi.framework.bootdelegation` property. Sling provides a mechanism to extend the default setting of the `org.osgi.framework.bootdelegation` property by adding properties prefixed with `sling.bootdelegation.`. The value of each of these prefixed properties is conditionally appended to the `org.osgi.framework.bootdelegation` property. *Conditionally* means, that the property name may contain the fully qualified name of a class, which is checked to see whether to add the property value or not.

*Examples*

| Configuration | Description |
|--|--|
| `sling.bootdelegation.simple = com.some.package` | This setting unconditionally adds the `com.some.package` package to the `org.osgi.framework.bootdelegation` property |
| `sling.bootdelegation.class.com.some.other.Main = com.some.other` | This setting checks whether the `com.some.other.Main` class is known. If so, the `com.some.other` package is added to the `org.osgi.framework.bootdelegation` property. Otherwise the `com.some.other` package is not added - and therefore must be exported by a bundle if required for use inside the framework. |


*Note* Even though packages listed in the `org.osgi.framework.bootdelegation` property will always be loaded from the environment, any bundles using these packages must still import them (through `Import-Package` or `DynamicImport-Package`) and the bundles must resolve for being usable.



### OSGi System Packages Support

As listed in the above section on OSGi Boot Delegation Support, the `org.osgi.framework.system.packages` property may be used to extend the export list of the system bundle. Similar to the support for extending the boot delegation packages list, Sling supports extending the system packages list. The mechanism to extend the default setting of the `org.osgi.framework.system.packages` property by adding properties prefixed with `sling.system.packages.`. The value of each of these prefixed properties is conditionally appended to the `org.osgi.framework.system.packages` property. *Conditionally* means, that the property name may contain the fully qualified name of a class, which is checked to see whether to add the property value or not.

*Examples*

| Configuration | Description |
|--|--|
| `sling.system.packages.simple = com.some.package` | This setting unconditionally adds the `com.some.package` package to the `org.osgi.framework.system.packages` property |
| `sling.system.packages.class.com.some.other.Main = com.some.other` | This setting checks whether the `com.some.other.Main` class is known. If so, the `com.some.other` package is added to the `org.osgi.framework.system.packages` property. Otherwise the `com.some.other` package is not added - and therefore must be exported by a bundle if required for use inside the framework. |


*Note* Packages listed in the `org.osgi.framework.system.packages` required by any bundles must be imported by those bundles by listing them in the `Import-Package` or `DynamicImport-Package` manifest header.



## Recommendations for property names

The following system property names are reserved:

   * Names starting with `org.osgi.` are reserved for OSGi defined Framework properties
   * Names starting with `org.apache.felix.` are reserved for the Felix Framework
   * Names starting with `sling.` and `org.apache.sling.` are reserved for Sling

To prevent property name collisions, I suggest the following convention:

   * Use fully qualified property names for initial configuration through Framework properties
   * Use unqualified property names for configuration through the Configuration Admin Service


## Well Known Properties

The following table is a collection of well known property names from different parts of Project Sling.

| Property | Description |
|--|--|
| `sling.home` | Defines the file system location where Project Sling will write copies of the initial configuration. This property should also be used to define other local file system locations such as the directory to use for the Apache Felix Bundle Cache (`${sling.home}/felix` by default). If this property is not set it defaults to `${user.dir}/sling`. |
| `sling.home.url` | Contains the Sling directory set in the `sling.home` property as a valid URL. This property may be used in situations where the Sling directory is required as an URL. This property is automatically set by the Sling application and may not be modified by configuration files. |
| `sling.ignoreSystemProperties` | Whether to overwrite any configuration properties with Java system properties or not. By default this property is set to `true` by the Sling Servlet but not set by the Sling main class. The reason to set this by default in the Sling Servlet is to not induce values from the environment, which may not be appropriate in the Web Application case. |
| `obr.repository.url` | A comma-separated list of OSGi Bundle Repository URLs. See *sling.properties* on the page [the Sling Launchpad]({{ refs.the-sling-launchpad.path }}#slingproperties). |
| `org.apache.sling.commons.log.*` | Properties providing initial configuration to the Sling Log Service. See *sling.properties* on the page [the Sling Launchpad]({{ refs.the-sling-launchpad.path }}#slingproperties). |



## Configuration Admin Service

Configuration of the system entities, such as services and components, by the system administrator is supported the Configuration Admin Service. The Configuration Admin Service acts as the center for the management of the configuration data, to which GUI-based tools will connect to retrieve and update configuration data. The Configuration Admin Service is responsible for persisting the configuration data and for providing configuration consumers with the configuration data. Specifically services registered with the `ManagedService` or `ManagedServiceFactory` interfaces are updated with the configuration upon updated. The Service Component Runtime on the other hand recognizes updated configuration and provides it to the managed components as defined in the OSGi Declarative Services Specification.

By default the Configuration Admin Service is installed when Sling is started for the first time. This service is used by the Service Component Runtime launching the OSGi components declared in the bundles with configuration values. The Sling Management Console provides a simple GUI to manage these configuration elements on the 'Configuration' page.

For more information on the Configuration Admin Service refer to the OSGi Configuration Admin Service Specification in the OSGi Service Platform Service Compendium book.
