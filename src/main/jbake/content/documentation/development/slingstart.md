title=The Apache Sling Provisioning Model and Apache SlingStart		
type=page
status=published
~~~~~~

[TOC]

The Apache Sling provisioning model is a model to describe OSGi based application. It can also be used to define a partial application aka feature (or subsystem in OSGi terms).

The model is describing an instance, it is not directly related to any particular tooling or packaging/provisioning vehicle.

For Apache Maven users, the `slingstart-maven-plugin` uses the model to create an executable application and/or a web application based on the model. Sling's Launchpad is defined using the model and built by this Maven plugin. See [SlingStart Maven Plugin](http://sling.apache.org/components/slingstart-maven-plugin/) for a documentation of the supported goals and parameters.


## The Model

The model is a simple API consisting of data objects:

 * Model: This is the central object. It consists of features.
 * Feature : this is the central object describing a (partial) system. A feature consists of variables and run modes.
 * Variables: These can be used to define artifact versions, settings values or configuration property values.
 * Run Mode : A run mode contains artifacts, configurations, and settings. The artifacts are divided into artifact groups.
 * Artifact Group: A group of artifacts with an associated start level (the artifacts are usually bundles)
 * Artifact: A deployable artifact described by Maven coordinates.
 * Configuration: A OSGi configuration
 * Settings : Framework settings for the OSGi framework

### Run Modes

The default run mode is always active, and all information provided there will be used/started.
Custom run modes can be used to configure for different situations. Depending on which run mode is used to start the instance a different set of artifacts or configurations is used.
Each run mode is associated with a set of run mode names. Only if all listed run modes are active, the definition is used.

The model also supports special run modes, which have special meaning. By default, these pre defined special run modes are available:
 
 * :standalone Artifacts for the standalone application - in contrast to a war.
 * :webapp Artifacts for the webapp only
 
Other special run modes can be defined by using a single run mode name which starts with a colon, like :test. These run modes can be used by special tooling.

### Start Levels

Each run mode has start levels. These start levels correspond to OSGi start levels. The default start level has the level 0 and should be used for all non bundle artifacts. If a non bundle artifact is configured with a start level, it's still provisioned, however the start level information might not have any meaning. As usually the provisioned artifacts are bundles and as start levels are pretty handy, this was conscious design decision in order to keep the model files small.

### Artifacts

An artifact is defined by Maven coordinates, that is group id, artifact id and version. Type and classifier can be specified, too. Type defaults to "jar". Although the maven way of referring to an artifact is used, the model is in no way tied to Maven and can be used with any tooling. For a plain jar the text definition for an artifact is:

                groupId/artifactId/version
                org.apache.sling/api/2.8.0

If you want to specify the type, it's appended after the version:

                groupId/artifactId/version/type
                org.apache.sling/api/2.8.0/jar
                
If you want to specify the classifier, it gets appended after the type:
                
                groupId/artifactId/version/type/classifier
                org.apache.sling/api/2.8.0/jar/test

### Configurations

A configuration has a pid, or a factory pid and an alias and of course the properties of the configuration object.

Special configurations can be marked with a leading ":" of the pid. Special configurations are not added to the OSGi config admin. There are some predefined special configurations

 * :web.xml This configuration must be part of the :webapp runmode and contains a complete web.xml for the web application
 * :bootstrap This configuration must be part of either the :boot, :base, :standalone, or :webapp run mode and define the contents for the bootstrap command file executed by Launchpad. 

#### Bootstrap Command File

The bootstrap configuration is a text block consisting of uninstall directives. This block is only executed on the first startup.

    [feature name=:launchpad]

    [configurations]
       # uninstall obsolete bundles which are neither not required anymore or are
       # replaced with new bundles
    :bootstrap
      uninstall org.apache.sling.fragment.activation 1.2
      uninstall org.apache.sling.installer.api [1.0,2.0)
      uninstall org.apache.sling.tests

Each uninstall directive starts with the text "uninstall" followed by the bundle symbolic name. A version range can be specified as well. If no version information is specified, the bundle with that symbolic name is uninstalled on startup. If a version is specified, the bundle is only uninstalled if it's installed with the exact same version. If a range is specified, the bundle is only uninstalled, if the version is within that range.

### Settings

Settings are key value pairs that are added to the framework properties. For now, only settings for the run modes :boot, :base, :standalone, or :webapp are supported.

### Features

Features group run modes and define a special functionality. The model also defines two special features:

 * :launchpad This feature contains the dependency to Sling's launchpad artifact to be used. This mode is required if Apache Sling Launchpad should be used to start the application.
 * :boot The artifacts that are installed before the framework is started. They're used to bootstrap the system.

## Model Files

The model comes also with a textual description language:

    [feature name=my-feature]
        [variables]
            eventadmin.version=1.0.0
            metatype.version=1.2.0

        [artifacts]
           org.apache.sling/eventadmin/${eventadmin.version}
           org.apache.sling/metatype/${metatype.version}
           org.apache.sling/coordinator/3.0.0
           
        [configurations]
           org.apache.sling.eventadmin
              useQueue=true
              ignoreTopics=["myTopic"]

A configuration for a run mode looks like this:

    [feature name=my-feature]
        [variables]
            eventadmin.version=1.0.0
            metatype.version=1.2.0

        [artifacts runModes=mymode]
           org.apache.sling/metatype/${metatype.version}

        [artifacts startLevel=5 runModes=mymode]
           org.apache.sling/eventadmin/${eventadmin.version}
        
        [configurations runModes=mymode]
           org.apache.sling.eventadmin
              useQueue=true
              ignoreTopics=["myTopic"]
### Comments

Each object in the model can be annotated with comments. A comment is a line starting with a '#'. Leading spaces are ignored.

### Configurations in the Model file
 	 
Configuration names are related to the PID and factory PID. The structure of the name is as follows:
 	 

    name ::= <pid> ( '-' <subname> )

 	 
If the form is just `<pid>`, the configuration contains the properties for a Managed Service. The `<pid>` is then the PID of the Managed Service. See the Configuration Admin service for details.
 	 
When a Managed Service Factory is used, the situation is different. The `<pid>` part then describes the PID of the Managed Service Factory. You can pick any `<subname>` which is used as a unique alias. For example:
 	 
    # Configuration for Managed Service com.acme.xyz
    com.acme.xyz // 
    # Managed Service Factory, creates an instance for com.acme.abc
    com.acme.abc-default


### Default Configuration Format

Configurations use by default the format of the Apache Felix ConfigAdmin implementation. It allows to specify the type and cardinality of a configuration property and is not limited to string values.

The first line of such a file might start with a comment line (a line starting with a #). Comments within the file are not allowed.

The format is:

    file ::= (comment) (header) *
    comment ::= '#' <any>
    header ::= prop '=' value
    prop ::= symbolic-name // 1.4.2 of OSGi Core Specification
    symbolic-name ::= token { '.' token } 
    token ::= { [ 0..9 ] | [ a..z ] | [ A..Z ] | '_' | '-' }
    value ::= [ type ] ( '[' values ']' | '(' values ')' | simple ) 
    values ::= simple { ',' simple } 
    simple ::= '"' stringsimple '"'
    type ::= <1-char type code>
    stringsimple ::= <quoted string representation of the value> (see below)

The 1 character type code is one of:

* 'T' : simple string
* 'I' : Integer
* 'L' : Long
* 'F' : Float
* 'D' : Double
* 'X' : Byte
* 'S' : Short
* 'C' : Character
* 'B' : Boolean

Apart from the escaping of the usual characters like the quotes, double quotes, backslash etc. the equals sign and spaces need to be escaped as well!


###  Configurations Defined through Properties

While the default configuration form is very powerful, it might also sometimes be a little bit too heavy to specify a configuration. For these usage cases, the configuration can be described as properties:

    com.acme.xyz [format=properties] 	 
        ftp.port = 21
        
Notice that this definition only supports string properties. Therefore the service consuming the configuration needs to be able to adapt a string value to the correct type.

## Slingstart and Slingfeature projects

The `slingstart-maven-plugin` introduces two new packaging types:

* `slingstart` : This type requires a model at src/main/provisioning. It reads all text files in that directory and merges them in alphabetical order. The resulting artifact is a runnable jar. The assembled model is also attached to the project artifacts.
* `slingfeature` : This type requires a model at src/main/provisioning. It reads all text files in that directory and merges them in alphabetical order and creates a merged model which is the final artifact of this project.

A model can reference other slingstart or slingfeature artifacts. When such an artifact is reference, the type needs to be specified, for example:

    [artifacts]
        org.apache.sling/org.apache.sling.launchpad/8-SNAPSHOT/slingstart
        org.apache.sling/org.apache.sling.launchpad.test-bundles/0.0.1-SNAPSHOT/slingfeature

The resulting model is a merged model, starting with the dependencies and then merging in the current model.

By default the Maven classpath is extended by the dependencies of the merged model. This behaviour can be disabled though via setting the parameter `disableExtendingMavenClasspath` to `true` ([SLING-6541](https://issues.apache.org/jira/browse/SLING-6541)).

## Model Merging

If two or more models are supplied, they are merged feature by feature, each feature being treated as a separate unit. 

Within a feature each run mode is treated separately as well. 

Within a run mode, a model can overwrite definitions from the base model. For example, it can define a different configuration or a different version and/or start level for an artifact.

The supplied models are ordered alphanumercally by their filenames for merging.

### Removing and Changing of Artifacts

In addition, it can also remove artifacts and configurations. For this the special runmode :remove needs to be used together with all run modes the artifact or configuration is currently in.

Let's look at an example base model

    [artifacts]
        my/special/artifact/1.0.0
        commons/library/1.0.0
       
    [artifacts runModes=test]
        another/one/2.1.0

Another model wants to use the above model as it's base but:

* Change the version of the commons library to 1.1.0 and move it to a different start level.
* Remove the "special artifact"
* Remove the "another one"

The changing model would mention the above as one artifact and in addition have:
    [artifacts startLevel=5]
        commons/library/1.1.0
    
    [artifacts runModes=:remove]
        my/special/artifact/0.0.0
    
    [artifacts runModes=:remove,test]
        another/one/0.0.0

Note that the version for removal does not play a role, it's not compared for an exact match. But please keep in mind that the remove directive needs to be specified in the same feature and run mode as the original.

### Removing and Changing of Configurations

Configurations can be removed in the same way by just specifying their PID in the :remove run mode. This is the base model:

    [configurations]
        my.special.configuration.b
          foo="bar"
        another.special.configuration.a
          x="y"

When this model is merged with the following model, the resulting model has a different configuration for my.special.configuration.b and no configuration for another.special.configuration.a:

    [configurations]
        my.special.configuration.b
          a="b"

    [configurations runModes=:remove]
        another.special.configuration.a

By default if a model inherits from another and uses the same configuration pid, the configuration is overwritten! In the above example, the configuration my.special.configuration.b contains a single property named "a". 

It is also possible to merge configurations:

    [configurations]
        my.special.configuration.b [mode=merge]
          a="b"

When the merge directive is used, the configurations are merged and the properties are applied as a delta to the base configuration. Therefore the configuration my.special.configuration.b will have two properties "a" and "foo".

If a merged configuration redefines a property that already exists, it overwrites it, so the last configuration supplied in a merge wins.

## Starting a server

Use the goal with name `start` to start one or multiple servers. The goal is bound by default to the [`pre-integration-test` lifecycle phase](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html#Lifecycle_Reference). The launchpad JAR used to start the server is being looked up from the following locations:

1. the file path given in the configuration field `launchpadJar` or parameter `launchpad.jar`
2. the slingstart artifact being referenced in the configuration element `launchpadDependency`
3. the artifact being created through the Maven project itself (through model definitions found below `src/main/provisioning` or `src/test/provisioning` which are consumed by the goals `prepare-package` and `package` ([SLING-6068](https://issues.apache.org/jira/browse/SLING-6068)) ).
4. the first dependency of type `slingstart`

The server itself is configured within an element `server` below the configuration element `servers`. It supports the following configuration settings

Name | Type | Description | Default Value | Mandatory
---- | ---- | ----------- | ------------- | ---------
port     | String | The port on which the server is listening for HTTP requests. Arbitrary if not set. | (-) | no
id       | String | The instance id for this server. If not set the id is automatically generated from the run modes and the port. | (-) | no
runmode  | String | The comma-separated list of [run modes](/documentation/bundles/sling-settings-org-apache-sling-settings.html#run-modes) to be set for this server. Those will be set in addition to the ones being defined by the underlying model. | (-) | no
contextPath | String | The context path. If not set then Sling is deployed in the root context. | (-) | no
controlPort | String | The TCP [control port](/documentation/the-sling-engine/the-sling-launchpad.html#control-port) on which the server is listening for control commands. Arbitrary if not set. | (-) | no
instances | int | The number of instances which should be created from this server element. In this case the configuration acts as template. The port and controlPort for all servers being generated from this configuration are random (except for the first server). | 1 | no
folder | String | The folder from where to start Sling. If not set is a folder in the project's build directory named like the `id`. | (-) | no
vmOpts | String | The JVM options to use. | `-Xmx1024m -XX:MaxPermSize=256m -Djava.awt.headless=true` | no
opts | String | Additional application options. | (-) | no
debug | String | See below for an explanation. | (-) | no
stdOutFile | String | The relative filename of the file which receives both the standard output (stdout) and standard error (stderr) of the server processes. If null or empty string the server process inherits stdout from the parent process (i.e. the Maven process). The given filename must be relative to the working directory of the according server. This was added with [SLING-6545](https://issues.apache.org/jira/browse/SLING-6545). | null | no

### Debugging

Since version 1.2.0 of this plugin it is possible to easily start a Sling server in debug mode ([SLING-4677](https://issues.apache.org/jira/browse/SLING-4677)). For that you either configure the property `debug` inside you server configuration in the pom.xml accordingly or by using the parameter `Dlaunchpad.debug`. Both values can either be `true` (in which case the [JDWP options](http://docs.oracle.com/javase/7/docs/technotes/guides/jpda/conninv.html#Invocation) `-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000` are appended to the VM options) or just some arbitrary string defining debugging options.
In case both are used the parameter `Dlaunchpad.debug` takes precedence.

## Stopping a server 

Use the goal with name `stop` to stop one or multiple servers. The goal is bound by default to the [`post-integration-test` lifecycle phase](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html#Lifecycle_Reference).

## Known Issues

### Support of configuration formats

The provisioning model supports two formats to define configurations, properties and the format of the Apache Felix ConfigAdmin implementation.

Starting with version 1.2.0 of the provisioning model and version 1.2.0 of the slingstart-maven-plugin, the implementation uses the latest format from Apache Felix, version 1.8.6 (or higher) of the ConfigAdmin. This requires you to use version 3.6.6 (or higher) of the OSGi installer core bundle to handle these configurations.

If you want to stick with the old format from config admin, you can configure the maven plugin as follows:

    <plugin>
        <groupId>org.apache.sling</groupId>
        <artifactId>slingstart-maven-plugin</artifactId>
        <extensions>true</extensions>
        <version>1.3.4</version>
        <dependencies>
            <dependency>
                <groupId>org.apache.felix</groupId>
                <artifactId>org.apache.felix.configadmin</artifactId>
                <version>1.8.4</version>
            </dependency>
        </dependencies>
    </plugin>

