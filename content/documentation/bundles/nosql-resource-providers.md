Title: NoSQL Resource Providers (org.apache.sling.nosql)
[TOC]


## Introduction

Apache Sling provides resource-based access to NoSQL document stores like MongoDB and Couchbase via its Resource API using the NoSQL resource providers. This is possible in combination with a JCR-based repository (e.g. only on a special path in the resource tree), or a only persistence for the whole resource tree depending on the resource provider configuration.

The general concept of retrieving from and storing resource data in NoSQL document stores is the same independently from the NoSQL product used:

* For each resource a structured document is stored (usually in JSON format)
* The path of the resource is the key of the document
* The properties of the resource are stored in a map-like form in the document
* Special mapping applies to convert special data types like numbers, dates and binary data to a format that can safely stored in the document event if the format is not natively supported (e.g. converting dates to strings and binary to base64)
* The Sling CRUD support defines a simple transaction model with buffering all changes in memory until a call to "commit()" persists them to the NoSQL database
* Iterating over child resources and deleting a resource including all descendants requires some basic query capabilities in the NoSQL store

All these general features are implemented in an abstraction layer called ["Apache Sling NoSQL Generic Resource Provider"](https://github.com/apache/sling/tree/trunk/contrib/nosql/generic), which is used by the resource provider implementations per NoSQL product. Those implementation than only implement a thin "adapter" which maps the resource data to the NoSQL product-specific storage formats and query capabilities, without having to care about all the complex resource provider handling.

This generic resource provider also contains a set of integration tests covering the most relevant resource read- and write usecases which can be used to test a NoSQL product-specific  resource provider implementation and the underlying NoSQL database.


## MongoDB NoSQL Resource Provider

Resource provider for [MongoDB](https://www.mongodb.org/) NoSQL database.

Tested with MongoDB Server 3.0.6 and MongoDB Java Driver 3.1.1.

Configuration example:

    org.apache.sling.nosql.mongodb.resourceprovider.MongoDBNoSqlResourceProviderFactory.factory.config-default
        provider.roots=["/"]
        connectionString="localhost:27017"
        database="sling"
        collection="resources"

See Apache Felix OSGi console for detailed documentation of the parameters. All resource data is stored in one Collection of one MongoDB database. Each resource is stored as a document with the path stored in an "_id" property.

Source code: [Apache Sling NoSQL MongoDB Resource Provider](https://github.com/apache/sling/tree/trunk/contrib/nosql/mongodb-resourceprovider)

Please note: there is an [alternative MongoDB resource provider implementation](https://github.com/apache/sling/tree/trunk/contrib/extensions/mongodb) from 2012 which has less features, a slightly different concept for storing resource data (in multiple collections), and it does not use the "Generic Resource Provider".


## Couchbase NoSQL Resource Provider

Resource provider for [Couchbase](http://www.couchbase.com/) NoSQL database.

Tested with Couchbase Server 4.0.0 and Couchbase Java SDK 2.2.4. Please note: Couchbase 4 or higher is mandatory because N1QL support is required.

Configuration example:

    org.apache.sling.nosql.couchbase.resourceprovider.CouchbaseNoSqlResourceProviderFactory.factory.config-default
        provider.roots=["/"]

    org.apache.sling.nosql.couchbase.client.CouchbaseClient.factory.config-default
        clientId="sling-resourceprovider-couchbase"
        couchbaseHosts="localhost:8091"
        bucketName="sling"
        enabled=B"true"

See Apache Felix OSGi console for detailed documentation of the parameters. All resource data is stored in one Couchbase bucket. Each resource is stored as a document with the path as key.

Source code: [Apache Sling NoSQL Couchbase Resource Provider](https://github.com/apache/sling/tree/trunk/contrib/nosql/couchbase-resourceprovider)

The resource provider requires and additional bundle [Apache Sling NoSQL Couchbase Client](https://github.com/apache/sling/tree/trunk/contrib/nosql/couchbase-client) which wraps the Couchbase Java SDK (which itself is not an OSGi bundle), and ensures that the Couchbase Environment instance is used as a singleton in the VM.


## Example Launchpad

An example launchpad is provided that contains the NoSQL resource providers configured as main resource provider at `/`.

Source code: [Apache Sling NoSQL Launchpad](https://github.com/apache/sling/tree/trunk/contrib/nosql/launchpad)

See README for details how to start the launchpad.
