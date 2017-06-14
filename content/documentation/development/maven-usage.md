title=TODO title for maven-usage.md 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: Maven Usage

Apache Sling uses Maven as a build tool. This page documents some of the choices that we made when using Maven.

## Parent POM

We separate the reactor POM from the parent POM. While the reactor POM functions as a simple aggregator, the parent POM, currently located at [parent/pom.xml](http://svn.apache.org/repos/asf/sling/trunk/parent/pom.xml), holds the common build configuration for all modules.

The reference to the parent POM is usually set to a released version since we don't deploy it as a SNAPSHOT during the build process. That reference must also contain an empty parentPath element, otherwise recent version of Maven will try to find it in the local filesystem, disregarding the version if the groupId and artifactId match. An example of how to reference the parent POM is

    #!xml
    <parent>
        <groupId>org.apache.sling</groupId>
        <artifactId>sling</artifactId>
        <version>$VERSION</version>
        <relativePath/>
    </parent>

Where `$VERSION` is replaced by the latest parent POM version.

## Java version

The version of Java targeted by a module can be declared by setting a property in the pom.xml named `sling.java.version`. Configuration inherited from the parent POM will ensure that all the plugins will be correctly configured, including

* maven-compiler-plugin: source and target arguments to use when compiling code
* animal-sniffer-maven-plugin: signatures to use when validating compliance with a given Java version
* maven-bundle-plugin: value of the Bundle-RequiredExecutionEnvironment header

## Dependency management

See [Dependency Management]({{ refs.dependency-management.path }})
