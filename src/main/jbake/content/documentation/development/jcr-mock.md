title=JCR Mocks		
type=page
status=published
tags=development,testing,mocks
~~~~~~

Mock implementation of selected JCR APIs for easier testing. It stores all data in-memory in a HashMap to ensure instantly creating and destroying of the JCR repository.

[TOC]


## Maven Dependency

    #!xml
    <dependency>
      <groupId>org.apache.sling</groupId>
      <artifactId>org.apache.sling.testing.jcr-mock</artifactId>
    </dependency>

See latest version on the [downloads page](/downloads.cgi).


## Implemented mock features

The mock implementation supports:

* Reading and writing all data (primitive values, arrays, binary data) via the JCR API
* Creating any number of nodes and properties (stored in-memory in a hash map)
* Register namespaces
* Queries are supported by setting expected results for a given query

The following features are *not supported*:

* Node types are supported in the API, but their definitions and constraints are not applied
* Versioning not supported
* Transactions not supported
* Observation events can be registered but are ignored
* Access control always grants access
* Exporting/Importing data via document and system views not supported 
* Workspace management methods not supported


## Usage

### Getting JCR mock objects

The factory class `MockJcr` allows to instantiate the different mock implementations.

Example:

    #!java
    // get session
    Session session = MockJcr.newSession();

    // get repository
    Repository repository = MockJcr.newRepository();

The repository is empty and contains only the root node. You can use the JCR API to read or write content.


### Mocking queries

If you want to test code that contains a JCR query you can simulate a query execution and set the result to return during setting up your unit test.

Example:

    #!java
    // prepare mocked search result
    List<Node> resultNodes = ImmutableList.of(node1, node2, node3);

    // return this result for all queries
    MockJcr.setQueryResult(session, resultNodes);

    // return this result for a specific query
    MockJcr.setQueryResult(session, "your query statement", Query.JCR_SQL2, resultNodes);

Alternatively you can use the `MockJcr.addQueryResultHandler` method to pass a callback object that allows you to return a query result after inspecting the given query object.
