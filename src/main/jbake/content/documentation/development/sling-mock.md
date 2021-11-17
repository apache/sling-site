title=Sling Mocks		
type=page
status=published
tags=development,mocks
~~~~~~

Mock implementation of selected Sling APIs for easier testing.

[TOC]


## Maven Dependency

For JUnit 5:

    #!xml
    <dependency>
      <groupId>org.apache.sling</groupId>
      <artifactId>org.apache.sling.testing.sling-mock.junit5</artifactId>
    </dependency>

For JUnit 4:

    #!xml
    <dependency>
      <groupId>org.apache.sling</groupId>
      <artifactId>org.apache.sling.testing.sling-mock.junit4</artifactId>
    </dependency>

See latest version on the [downloads page](/downloads.cgi).


There are three major version ranges available:

* sling-mock 1.x: compatible with older Sling versions from 2014 (Sling API 2.4 and above), JUnit 4
* sling-mock 2.x: compatible with Sling versions from 2016 (Sling API 2.11 and above), since 2.4.0 with Sling versions from 2017 (Sling API 2.16.2 and above, [SLING-8978](https://issues.apache.org/jira/browse/SLING-8978)), JUnit 4 and JUnit 5 
* sling-mock 3.x: compatible with Sling versions from 2018 (Sling API 2.16.4 and above, [SLING-10045](https://issues.apache.org/jira/browse/SLING-10045)), JUnit 4 and JUnit 5


## Implemented mock features

The mock implementation supports:

* `ResourceResolver` implementation for reading and writing resource data using the Sling Resource API
    * Backed by a [mocked][jcr-mock] or real Jackrabbit JCR implementation
    * Uses the productive [Sling JCR resource provider implementation][jcr-resource] internally to do the Resource-JCR mapping
    * Alternatively the non-JCR mock implementation provided by the 
   [Sling resourceresolver-mock implementation][resourceresolver-mock] can be used
* `AdapterManager` implementation for registering adapter factories and resolving adaptions
    * The implementation is thread-safe so it can be used in parallel running unit tests
* `SlingScriptHelper` implementation providing access to mocked request/response objects and supports getting
   OSGi services from the [mocked OSGi][osgi-mock] environment.
* Implementations of the servlet-related Sling API classes like `SlingHttpServletRequest` and `SlingHttpServletRequest`
    * It is possible to set request data to simulate a certain Sling HTTP request
* Support for Sling Models (Sling Models API 1.1 and Impl 1.1 or higher required), all relevant Sling Models services are registered by default
* Additional services: `MimeTypeService`
* Context Plugins

The following features are *not supported*:

* It is not possible (nor intended) to really execute sling components/scripts and render their results.
    * The goal is to test supporting classes in Sling context, not the sling components/scripts themselves


### Additional features

Additional features provided:

* `SlingContext` JUnit Rule for easily setting up a Sling Mock environment in your JUnit test cases
* `ContentLoader` supports importing JSON data and binary data into the mock resource hierarchy to easily 
  prepare a test fixture consisting of a hierarchy of resources and properties.
    * The same JSON format can be used that is provided by the Sling GET servlet for output
* `ContentBuilder` and `ResourceBuilder` make it easier to create resources and properties as test fixture


## Usage

The `SlingContext` object provides access to mock implementations of:

* OSGi Component Context
* OSGi Bundle Context
* Sling Resource Resolver
* Sling Request
* Sling Response
* Sling Script Helper

Additionally it supports:

* Registering OSGi services
* Registering adapter factories
* Accessing ContentLoader, and ContentBuilder and ResourceBuilder


### JUnit 5: Sling Context JUnit Extension

The Sling mock context can be injected into a JUnit test using a custom JUnit extension named `SlingContextExtension`.
This extension takes care of all initialization and cleanup tasks required to make sure all unit tests can run 
independently (and in parallel, if required).

Example:

    #!java
    @ExtendWith(SlingContextExtension.class)
    public class ExampleTest {

      private final SlingContext context = new SlingContext();

      @Test
      public void testSomething() {
        Resource resource = context.resourceResolver().getResource("/content/sample/en");
        // further testing
      }

    }

It is possible to combine such a unit test with a `@ExtendWith` annotation e.g. for
[Mockito JUnit Jupiter Extension][mockito-junit5-extension].


### JUnit 4: Sling Context JUnit Rule

The Sling mock context can be injected into a JUnit test using a custom JUnit rule named `SlingContext`.
This rule takes care of all initialization and cleanup tasks required to make sure all unit tests can run 
independently (and in parallel, if required).

Example:

    #!java
    public class ExampleTest {

      @Rule
      public final SlingContext context = new SlingContext();

      @Test
      public void testSomething() {
        Resource resource = context.resourceResolver().getResource("/content/sample/en");
        // further testing
      }

    }

It is possible to combine such a unit test with a `@RunWith` annotation e.g. for
[Mockito JUnit Runner][mockito-junit4-testrunner].


### Choosing Resource Resolver Mock Type

The Sling mock context supports different resource resolver types. Example:

    #!java
    public final SlingContext context = new SlingContext(ResourceResolverType.RESOURCERESOLVER_MOCK);

Different resource resolver mock types are supported with pros and cons, see next chapter for details.


### Resource Resolver Types

The Sling Mocks resource resolver implementation supports different "types" of adapters for the mocks.
Depending on the type an underlying JCR repository is used or not, and the data is stored in-memory or in a real 
repository.

Resource resolver types currently supported:

**RESOURCERESOLVER_MOCK (default)**

* Simulates an In-Memory resource tree, does not provide adaptions to JCR API.
* Based on the [Sling resourceresolver-mock implementation][resourceresolver-mock] implementation
* You can use it to make sure the code you want to test does not contain references to JCR API.
* Behaves slightly different from JCR resource mapping e.g. handling binary and date values.
* This resource resolver type is very fast because data is stored in memory and no JCR mapping is applied.

**JCR_MOCK**

* Based on the [JCR Mocks][jcr-mock] implementation
* Uses the productive [Sling JCR resource provider implementation][jcr-resource] internally to do the Resource-JCR mapping
* Is quite fast because data is stored only in-memory

**NONE**

* Uses the productive Sling resource factory implementation without any ResourceProvider. You have to register one yourself to do anything useful with it.
* The performance of this resource resolver type depends on the resource provider registered.
* This is useful if you want to test your own resource provides mapped to root without any JCR.

**JCR_OAK**

* Uses a real JCR Jackrabbit Oak implementation based on the `MemoryNodeStore`
* Full JCR/Sling features supported e.g. observations manager, transactions, versioning
* Uses the productive [Sling JCR resource provider implementation][jcr-resource] internally to do the Resource-JCR mapping
* Takes some seconds for startup on the first access
* Node types defined in OSGi bundle header 'Sling-Nodetypes' found in MANIFEST.MF files in the classpath are registered automatically.
* Lucene indexing is not included, thus fulltext search queries will return no result

To use this type you have to declare an additional dependency in your test project:

    #!xml
    <dependency>
      <groupId>org.apache.sling</groupId>
      <artifactId>org.apache.sling.testing.sling-mock-oak</artifactId>
      <scope>test</scope>
    </dependency>

See latest version on the [downloads page](/downloads.cgi).

**JCR_JACKRABBIT**

* Uses a real JCR Jackrabbit implementation (not Oak) as provided by [sling/commons/testing][sling-commons-testing]
* Full JCR/Sling features supported e.g. observations manager, transactions, versioning
* Uses the productive [Sling JCR resource provider implementation][jcr-resource] internally to do the Resource-JCR mapping
* Takes some seconds for startup on the first access 
* Node types defined in OSGi bundle header 'Sling-Nodetypes' found in MANIFEST.MF files in the classpath are registered automatically.

To use this type you have to declare an additional dependency in your test project:

    #!xml
    <dependency>
      <groupId>org.apache.sling</groupId>
      <artifactId>org.apache.sling.testing.sling-mock-jackrabbit</artifactId>
      <scope>test</scope>
    </dependency>

See latest version on the [downloads page](/downloads.cgi).

_Remarks on the JCR_JACKRABBIT type:_

* The repository is not cleared for each unit test, so make sure to use a unique node path for each unit test. You may use the `uniquePath()` helper object of the SlingContext rule for this.
* The [sling/commons/testing][sling-commons-testing] dependency introduces a lot of further dependencies from
  jackrabbit and others, be careful that they do not conflict and are imported in the right order in your test project



### Sling Resource Resolver

Example:

    #!java
    // get a resource resolver
    ResourceResolver resolver = MockSling.newResourceResolver();

    // get a resource resolver backed by a specific repository type
    ResourceResolver resolver = MockSling.newResourceResolver(ResourceResolverType.JCR_MOCK);

If you use the `SlingContext` JUnit rule you case just use `context.resourceResolver()`.

### Sling Models

You should use the following approach to test Sling Models.

#### Model Registration

First you need to make sure that the model you want to test is registered. 
Since Sling Mocks 1.9.0/2.2.0 the Sling Models from the classpath are automatically registered ([SLING-6363](https://issues.apache.org/jira/browse/SLING-6363)) when the Manifest contains the right bundle headers (`Sling-Model-Packages` or `Sling-Model-Classes`).  This behaviour can be tweaked since version 2.2.20 with the `SlingContextBuilder.registerSlingModelsFromClassPath(false)` method ([SLING-7712](https://issues.apache.org/jira/browse/SLING-7712)).

Manual registration is supported via `SlingContext.addModelsForPackage(...)` and `SlingContext.addModelsForClasses(...)`.

#### Model Instantiation

Preferably use the `ModelFactory.createModel(...)` method rather than the adaptTo method to benefit from better error messages in case of errors.


    #!java
    // load some content into the mocked repo
    context.load().json(..., "/resource1");
    
    // load resource
    Resource myResource = content.resourceResolver().getResource("/resource1");
    
    // instantiate Sling Model (adaptable via Resource)
    // this will throw exceptions if model cannot be instantiated
    MyModel myModel = context.getService(ModelFactory.class).createModel(myResource, MyModel.class);



### Adapter Factories

You can register your own or existing adapter factories to support adaptions e.g. for classes extending `SlingAdaptable`.

Example:

    #!java
    // register adapter factory
    BundleContext bundleContext = MockOsgi.newBundleContext();
    MockSling.setAdapterManagerBundleContext(bundleContext);
    bundleContext.registerService(myAdapterFactory);

    // test adaption
    MyClass object = resource.adaptTo(MyClass.class);

    // cleanup after unit test
    MockSling.clearAdapterManagerBundleContext();

Make sure you clean up the adapter manager bundle association after running the unit test otherwise it can 
interfere with the following tests. If you use the `SlingContext` JUnit rule this is done automatically for you.

If you use the `SlingContext` JUnit rule you case just use `context.registerService()`.


### SlingScriptHelper

Example:

    #!java
    // get script helper
    SlingScriptHelper scriptHelper = MockSling.newSlingScriptHelper();

    // get request
    SlingHttpServletRequest request = scriptHelper.getRequest();

    // get service
    MyService object = scriptHelper.getService(MyService.class);

To support getting OSGi services you have to register them via the `BundleContext` interface of the
[JCR Mocks][jcr-mock] before. You can use an alternative factory method for the `SlingScriptHelper` providing
existing instances of request, response and bundle context. 

If you use the `SlingContext` JUnit rule you case just use `context.slingScriptHelper()`.


### SlingHttpServletRequest

Example for preparing a sling request with custom request data:

    #!java
    // prepare sling request
    ResourceResolver resourceResolver = MockSling.newResourceResolver();
    MockSlingHttpServletRequest request = new MockSlingHttpServletRequest(resourceResolver);

    // simulate query string
    request.setQueryString("param1=aaa&param2=bbb");

    // alternative - set query parameters as map
    request.setParameterMap(ImmutableMap.<String,Object>builder()
        .put("param1", "aaa")
        .put("param2", "bbb")
        .build());

    // set current resource
    request.setResource(resourceResolver.getResource("/content/sample"));

    // set sling request path info properties
    MockRequestPathInfo requestPathInfo = (MockRequestPathInfo)request.getRequestPathInfo();
    requestPathInfo.setSelectorString("selector1.selector2");
    requestPathInfo.setExtension("html");

    // set method
    request.setMethod(HttpConstants.METHOD_POST);

    // set attributes
    request.setAttribute("attr1", "value1");

    // set headers
    request.addHeader("header1", "value1");

    // set cookies
    request.addCookie(new Cookie("cookie1", "value1"));


### SlingHttpServletResponse

Example for preparing a sling response which can collect the data that was written to it:

    #!java
    // prepare sling response
    MockSlingHttpServletResponse response = new MockSlingHttpServletResponse();

    // execute your unit test code that writes to the response...

    // validate status code
    assertEquals(HttpServletResponse.SC_OK, response.getStatus());

    // validate content type and content length
    assertEquals("text/plain;charset=UTF-8", response.getContentType());
    assertEquals(CharEncoding.UTF_8, response.getCharacterEncoding());
    assertEquals(55, response.getContentLength());

    // validate headers
    assertTrue(response.containsHeader("header1"));
    assertEquals("5", response.getHeader("header2"));

    // validate response body as string
    assertEquals(TEST_CONTENT, response.getOutputAsString());

    // validate response body as binary data
    assertArrayEquals(TEST_DATA, response.getOutput());


### Import resource data from JSON file in classpath

With the `ContentLoader` it is possible to import structured resource and property data from a JSON file stored
in the classpath beneath the unit tests. This data can be used as text fixture for unit tests.

Example JSON data:

    {
      "jcr:primaryType": "app:Page",
      "jcr:content": {
        "jcr:primaryType": "app:PageContent",
        "jcr:title": "English",
        "app:template": "/apps/sample/templates/homepage",
        "sling:resourceType": "sample/components/homepage",
        "jcr:createdBy": "admin",
        "jcr:created": "Thu Aug 07 2014 16:32:59 GMT+0200",
        "par": {
          "jcr:primaryType": "nt:unstructured",
          "sling:resourceType": "foundation/components/parsys",
          "colctrl": {
            "jcr:primaryType": "nt:unstructured",
            "layout": "2;colctrl-lt0",
            "sling:resourceType": "foundation/components/parsys/colctrl"
          }
        }
      }
    }

Example code to import the JSON data:

    #!java
    context.load().json("/sample-data.json", "/content/sample/en");

This codes creates a new resource at `/content/sample/en` (and - if not existent - the parent resources) and
imports the JSON data to this node. It can be accessed using the Sling Resource or JCR API afterwards.


### Import binary data from file in classpath

With the `ContentLoader` it is possible to import a binary file stored in the classpath beneath the unit tests.
The data is stored using a nt:file/nt:resource or nt:resource node type. 

Example code to import a binary file:

    #!java
    context.load().binaryFile("/sample-file.gif", "/content/binary/sample-file.gif");

This codes creates a new resource at `/content/binary/sample-file.gif` (and - if not existent - the parent 
resources) and imports the binary data to a jcr:content subnode.


### Building content

Sling Mocks provides two alterantives for quickly building test content in the repository with as few code as possible. Sling Mocks provides two alternatives. Both are quite similar in their results, but follow different API concepts. You can choose whatever matches your needs and mix them as well.

* `ContentBuilder`: Part of Sling Mocks since its first release. If you need a references to each created resource this is the easiest way.
* `ResourceBuilder`: Separate bundle that can also be used in integration tests or live instances. Supports a "fluent" API to create a bunch of resources in hierarchy at once.


#### Building content using `ContentBuilder`

The entry point for the `ContentBuilder` is the `create()` method on the Sling context.

Example:

    #!java
    context.create().resource("/content/test1", ImmutableMap.<String, Object>builder()
            .put("prop1", "value1")
            .put("prop2", "value2")
            .build());

Simplified syntax without using a map:

    #!java
    context.create().resource("/content/test1",
            "prop1", "value1",
            "prop2", "value2");


If you use the `SlingContext` JUnit rule you case just use `context.create()`.


#### Building content using `ResourceBuilder`

The entry point for the `ResourceBuilder` is the `build()` method on the Sling context.

Example:

    #!java
    context.build().resource("/content/test1")
            .siblingsMode()
            .resource("test1.1", "stringParam", "configValue1.1")
            .resource("test1.2", "stringParam", "configValue1.2")
            .resource("test1.2", "stringParam", "configValue1.3");

See JavaDocs of the class `org.apache.sling.resourcebuilder.api.ResourceBuilder` for a detailed documentation.


### Context Plugins

Sling Mocks supports "Context Plugins" that hook into the lifecycle of each test run and can prepare test setup before or after the other setUp actions, and execute test tear down code before or after the other tearDown action.

To define a plugin implement the `org.apache.sling.testing.mock.osgi.context.ContextPlugin<SlingContextImpl>` interface. For convenience it is recommended to extend the abstract class `org.apache.sling.testing.mock.osgi.context.AbstractContextPlugin<SlingContextImpl>`. These plugins can be used with Sling Mock context, but also with context instances deriving from it like AEM Mocks. In most cases you would just override the `afterSetUp` method. In this method you can register additional OSGi services or do other preparation work. It is recommended to define a constant pointing to a singleton of a plugin instance for using it.

To use a plugin in your unit test class, use the `SlingContextBuilder` class instead of directly instantiating the `SlingContext`class. This allows you in a fluent style to configure more options, with the `plugin(...)` method you can add one or more plugins.

Example: 

    #!java
    SlingContext context = new SlingContextBuilder().plugin(MY_PLUGIN).build();

More examples:

* [Apache Sling Context-Aware Configuration Mock Plugin][caconfig-mock-plugin]
* [Apache Sling Context-Aware Configuration Mock Plugin Test][caconfig-mock-plugin-test]

[osgi-mock]: /documentation/development/osgi-mock.html
[jcr-mock]: /documentation/development/jcr-mock.html
[resourceresolver-mock]: /documentation/development/resourceresolver-mock.html
[jcr-resource]: https://github.com/apache/sling-org-apache-sling-jcr-resource
[sling-commons-testing]: https://github.com/apache/sling-org-apache-sling-commons-testing
[mockito-junit4-testrunner]: https://www.javadoc.io/page/org.mockito/mockito-core/latest/org/mockito/junit/MockitoJUnitRunner.html
[mockito-junit5-extension]: https://www.javadoc.io/page/org.mockito/mockito-junit-jupiter/latest/org/mockito/junit/jupiter/MockitoExtension.html
[caconfig-mock-plugin]: https://github.com/apache/sling-org-apache-sling-testing-caconfig-mock-plugin/blob/master/src/main/java/org/apache/sling/testing/mock/caconfig/ContextPlugins.java
[caconfig-mock-plugin-test]: https://github.com/apache/sling-org-apache-sling-testing-caconfig-mock-plugin/blob/master/src/test/java/org/apache/sling/testing/mock/caconfig/ContextPluginsTest.java
