title=Resource Resolver Mock		
type=page
status=published
~~~~~~

Mock for the resource resolver / factory for easier testing. It uses an in-memory map for storing the resource data, and supports reading, writing and a certain level of transaction and eventing support.

[TOC]


## Maven Dependency

#!xml
<dependency>
<groupId>org.apache.sling</groupId>
<artifactId>org.apache.sling.testing.resourceresolver-mock</artifactId>
</dependency>

See latest version on the [downloads page](/downloads.cgi).


## Implemented mock features

The mock implementation supports:

* All read and write operations of the Sling Resource API
* Mimics transactions using via commit()/revert() methods
* OSGi events for adding/changing/removing resources
* The implementation tries to be as close as possible to the behavior of the JCR resource implementation e.g. concerning date and binary handling


The following features are *not supported*:

* Authentication not supported ("login" always possible with null authentication info)
* Querying with queryResources/findResources not supported (always returns empty result set)
* Sling Mapping is not supported
* Resolving resource super types



## Usage

To create a mocked resource resolver:

#!java
MockResourceResolverFactory factory = new MockResourceResolverFactory();
ResourceResolver resolver = factory.getResourceResolver(null);

With the resolver you can use all Sling Resource features including reading and writing data using the Sling API.

You cannot do any operations that require the JCR API because no JCR is underlying and adapting to JCR objects will just return null.
