title=Maven Launchpad Plugin		
type=page
status=published
~~~~~~

<div class="note">
This page is out of sync with the latest maven-launchpad-plugin features and settings. For now,
refer to the source code and the launchpad/builder and launchpad/testing modules for more information.
</div>

The Maven Launchpad Plugin provides goals which facilitate the creation of OSGi applications. It supports the following runtime scenarios:

 * A WAR file suitable for running in a JavaEE servlet container.
 * A standalone Java application, with HTTP support from the Felix HttpService implementation
 * Inside Apache Karaf

In addition, the Maven Launchpad Plugin supports the publishing of an application descriptor, in the form of a *bundle list*, as a Maven artifact. This descriptor can then be used by downstream application builders as the basis for other applications. In Sling, this is embodied by two Maven projects:

 * [org.apache.sling.launchpad](http://svn.apache.org/repos/asf/sling/trunk/launchpad/builder) - produces an application descriptor.
 * [org.apache.sling.launchpad.testing](http://svn.apache.org/repos/asf/sling/trunk/launchpad/testing/) - uses the application descriptor from `org.apache.sling.launchpad` and adds two bundles.

Maven Launchpad Plugin provides the following goals: 

| Goals | Description | 
|--|--|
| launchpad:prepare-package | Create the file system structure required by Sling's Launchpad framework. | 
| launchpad:attach-bundle-list | Attach the bundle list descriptor to the current project as a Maven artifact. | 
| launchpad:create-karaf-descriptor | Create an Apache Karaf Feature descriptor. | 
| launchpad:create-bundle-jar | Create a JAR file containing the bundles in a Launchpad-structured JAR file. | 
| launchpad:check-bundle-list-for-snapshots | Validate that the bundle list does not contain any SNAPSHOT versions. | 
| launchpad:run | Run a Launchpad application. |
| launchpad:start | Start a Launchpad application. |
| launchpad:stop | Stop a Launchpad application. |
| launchpad:output-bundle-list | Output the bundle list to the console as XML. (added in version 2.0.8) |

### General Configuration

In general, the bulk of the configuration of the Maven Launchpad Plugin is concerned with setting up the bundle list which all of the goals will use. This bundle list is created using the following steps:

 1. If `includeDefaultBundles` is `true` (the default), the default bundle list is loaded. By default, this is `org.apache.sling.launchpad:org.apache.sling.launchpad:RELEASE:xml:bundlelist`, but can be overridden by setting the `defaultBundleList` plugin parameter.
 1. If `includeDefaultBundles` is `false`, an empty list is created.
 1. If the bundle list file exists (by default, at `src/main/bundles/list.xml`), the bundles defined in it are added to the bundle list.
 1. If the `additionalBundles` plugin parameter is defined, those bundles are added to the bundle list.
 1. If the `bundleExclusions` plugin parameter is defined, those bundles are removed from the bundle list.

When a bundle is added to the bundle list, if a bundle with the same groupId, artifactId, type, and classifier is already in the bundle list, the version of the existing bundle is modified. However, the start level of a bundle is never changed once that bundle is added to the bundle list.

The plugin may also contribute bundles to (or remove bundles from) the bundle list as it sees fit.

### Framework Configuration

For the `run` and `start` goals, the plugin will look for a file named `src/test/config/sling.properties`. If this file is present, it will be filtered using standard Maven filtering and used to populate the OSGi framework properties. This can be used, for example, to specify a `repository.xml` file to be used during development:

    sling.repository.config.file.url=${basedir}/src/test/config/repository.xml


## Bundle List Files

The bundle list file uses a simple XML syntax representing a list of bundles organized into start levels:


    <?xml version="1.0"?>
    <bundles>
        <startLevel level="0">
            <bundle>
                <groupId>commons-io</groupId>
                <artifactId>commons-io</artifactId>
                <version>1.4</version>
            </bundle>
            <bundle>
                <groupId>commons-collections</groupId>
                <artifactId>commons-collections</artifactId>
                <version>3.2.1</version>
            </bundle>
        </startLevel>
    
        <startLevel level="10">
            <bundle>
                <groupId>org.apache.felix</groupId>
                <artifactId>org.apache.felix.eventadmin</artifactId>
                <version>1.0.0</version>
            </bundle>
        </startLevel>
    
        <startLevel level="15">
            <bundle>
                <groupId>org.apache.sling</groupId>
                <artifactId>org.apache.sling.jcr.api</artifactId>
                <version>2.0.2-incubator</version>
            </bundle>
        </startLevel>
    </bundles>


Within each `bundle` element, `type` and `classifier` are also supported.

The Http Service support can not be configured using the bundle list, but only using the `jarWebSupport` parameter, since it is specific to whether the Sling Launchpad is built as a java application (in which case the Jetty-based Http Service is used) or a web application (in which case the Http Service bridge is used).

## Artifact Definition

The `defaultBundleList`, `jarWebSupport`, `additionalBundles`, and `bundleExclusions` parameters are configured with artifact definitions. This is done using a syntax similar to Maven dependency elements:


    <configuration>
    ...
      <jarWebSupport>
        <groupId>GROUP_ID</groupId>
        <artifactId>ARTIFACT_ID</artifactId>
        <version>VERSION</version>
        <!-- type and classifier can also be specified if needed -->
      </jarWebSupport>
    ...
    </configuration>


For example, to use Pax Web instead of Felix HttpService as the HttpService provider, use the following:

    <configuration>
    ...
      <jarWebSupport>
        <groupId>org.ops4j.pax.web</groupId>
        <artifactId>pax-web-service</artifactId>
        <version>RELEASE</version>
        <!-- type and classifier can also be specified if needed -->
      </jarWebSupport>
    ...
    </configuration>


In the case of `additionalBundles` and `bundleExclusions`, these are arrays of definitions, so an intermediate `bundle` element is necessary:


    <configuration>
    ...
      <additionalBundles>
        <bundle>
          <groupId>GROUP_ID</groupId>
          <artifactId>ARTIFACT_ID</artifactId>
          <version>VERSION</version>
          <!-- type and classifier can also be specified if needed -->
        </bundle>
      </additionalBundles>
    ...
    </configuration>


By default, bundles are added to start level 0. To change, this use the `startLevel` element within each additional bundle definition.

## Integration Testing

For integration testing examples, see `/samples/inplace-integration-test` and `launchpad/testing` in the Sling source tree.

## Bundle List Rewriting

The Maven Launchpad Plugin supports the use of rules to rewrite the bundle list. These rules are executed by the [Drools](http://www.jboss.org/drools) rule engine. Typically, this is used along with Maven profiles. For example, Sling's testing project includes a profile called `test-reactor-sling-bundles`. When activated, this profile runs a Drools rule file which scans the project list from the Maven reactor and modifies the version number for bundles which were contained within the reactor.

In order for rules to interact with the Maven build, the following global variables are made available:

 * `mavenSession` - an instance of `org.apache.maven.execution.MavenSession`.
 * `mavenProject` - an instance of `org.apache.maven.project.MavenProject`.
