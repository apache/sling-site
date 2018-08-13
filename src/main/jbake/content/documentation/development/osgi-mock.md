title=OSGi Mocks		
type=page
status=published
tags=development,testing,mocks,osgi
~~~~~~

Mock implementation of selected OSGi APIs for easier testing.

[TOC]


## Maven Dependency

For JUnit 4:

    #!xml
    <dependency>
      <groupId>org.apache.sling</groupId>
      <artifactId>org.apache.sling.testing.osgi-mock.junit4</artifactId>
    </dependency>

For JUnit 5:

    #!xml
    <dependency>
      <groupId>org.apache.sling</groupId>
      <artifactId>org.apache.sling.testing.osgi-mock.junit5</artifactId>
    </dependency>

See latest version on the [downloads page](/downloads.cgi).

There are two major version ranges available:

* osgi-mock 1.x: compatible with OSGi R4 and above, JUnit 4
* osgi-mock 2.x: compatible with OSGi R6 and above, JUnit 4 and JUnit 5


## Implemented mock features

The mock implementation supports:

* Instantiating OSGi `Bundle`, `BundleContext` and `ComponentContext` objects and navigate between them.
* Register OSGi SCR services and get references to service instances
* Supports reading OSGi SCR metadata from `/OSGI-INF/<pid>.xml` and from `/OSGI-INF/serviceComponents.xml`
* Apply service properties/component configuration provided in unit test and from SCR metadata
* Inject SCR dependencies - static and dynamic
* Call lifecycle methods for activating, deactivating or modifying SCR components
* Service and bundle listener implementation
* Mock implementation of `LogService` which logs to SLF4J in JUnit context
* Mock implementation of `EventAdmin` which supports `EventHandler` services
* Mock implementation of `ConfigAdmin`
* Context Plugins

Since osgi-mock 2.0.0:

* Support OSGi R6 and Declarative Services 1.3: Field-based reference bindings and component property types


## Usage

The `OsgiContext` object provides access to mock implementations of:

* OSGi Component Context
* OSGi Bundle Context

Additionally it supports:

* Registering and activating OSGi services and inject dependencies


### JUnit 4: OSGi Context JUnit Rule

The OSGi mock context can be injected into a JUnit test using a custom JUnit rule named `OsgiContext`.
This rule takes care of all initialization and cleanup tasks required to make sure all unit tests can run 
independently (and in parallel, if required).

Example:

    #!java
    public class ExampleTest {

      @Rule
      public final OsgiContext context = new OsgiContext();

      @Test
      public void testSomething() {

        // register and activate service with configuration
        MyService service1 = context.registerInjectActivateService(new MyService(),
            "prop1", "value1");

        // get service instance
        OtherService service2 = context.getService(OtherService.class);

      }

    }

It is possible to combine such a unit test with a `@RunWith` annotation e.g. for
[Mockito JUnit Runner][mockito-junit4-testrunner].


### JUnit 5: OSGi Context JUnit Extension

The OSGi mock context can be injected into a JUnit test using a custom JUnit extension named `OsgiContextExtension`.
This extension takes care of all initialization and cleanup tasks required to make sure all unit tests can run 
independently (and in parallel, if required).

Example:

    #!java
    @ExtendWith(OsgiContextExtension.class)
    public class ExampleTest {

      private final OsgiContext context = new OsgiContext();

      @Test
      public void testSomething() {

        // register and activate service with configuration
        MyService service1 = context.registerInjectActivateService(new MyService(),
            "prop1", "value1");

        // get service instance
        OtherService service2 = context.getService(OtherService.class);

      }

    }

It is possible to combine such a unit test with a `@ExtendWith` annotation e.g. for
[Mockito JUnit Jupiter Extension][mockito-junit5-extension].


### Getting OSGi mock objects

The factory class `MockOsgi` allows to instantiate the different mock implementations.

Example:

    #!java
    // get bundle context
    BundleContext bundleContext = MockOsgi.newBundleContext();

    // get component context with configuration
    BundleContext bundleContext = MockOsgi.newComponentContext(properties,
        "prop1", "value1");

It is possible to simulate registering of OSGi services (backed by a simple hash map internally):

    #!java
    // register service
    bundleContext.registerService(MyClass.class, myService, properties);

    // get service instance
    ServiceReference ref = bundleContext.getServiceReference(MyClass.class.getName());
    MyClass service = bundleContext.getService(ref);


### Activation and Dependency Injection

It is possible to simulate OSGi service activation, deactivation and dependency injection and the mock implementation
tries to to its best to execute all as expected for an OSGi environment.

Example:

    #!java
    // get bundle context
    BundleContext bundleContext = MockOsgi.newBundleContext();

    // create service instance manually
    MyService service = new MyService();

    // inject dependencies
    MockOsgi.injectServices(service, bundleContext);

    // activate service
    MockOsgi.activate(service, props);

    // operate with service...

    // deactivate service
    MockOsgi.deactivate(service);

Please note:

* You should ensure that you register you services in the correct order of their dependency chain. 
Only dynamic references will be handled automatically independent of registration order.
* The injectServices, activate and deactivate Methods can only work properly when the SCR XML metadata files
are preset in the classpath at `/OSGI-INF`. They are generated automatically by the Maven SCR plugin, but might be
missing if your clean and build the project within your IDE (e.g. Eclipse). In this case you have to compile the
project again with maven and can run the tests - or use a Maven IDE Integration like m2eclipse.


### Provide your own configuration via ConfigAdmin

If you want to provide your own configuration to an OSGi service that you do not register and activate itself in the mock context you can provide your own custom OSGi configuration via the mock implementation of the `ConfigAdmin` service.

Example:

    #!java

    ConfigurationAdmin configAdmin = context.getService(ConfigurationAdmin.class);
    Configuration myServiceConfig = configAdmin.getConfiguration(MY_SERVICE_PID);
    Dictionary<String, Object> props = new Hashtable<String, Object>();
    props.put("prop1", "value1");
    myServiceConfig.update(props);


### Context Plugins

OSGi Mocks supports "Context Plugins" that hook into the lifecycle of each test run and can prepare test setup before or after the other setUp actions, and execute test tear down code before or after the other tearDown action.

To define a plugin implement the `org.apache.sling.testing.mock.osgi.context.ContextPlugin<OsgiContextImpl>` interface. For convenience it is recommended to extend the abstract class `org.apache.sling.testing.mock.osgi.context.AbstractContextPlugin<OsgiContextImpl>`. These plugins can be used with OSGi Mock context, but also with context instances deriving from it like Sling Mocks and AEM Mocks. In most cases you would just override the `afterSetUp` method. In this method you can register additional OSGi services or do other preparation work. It is recommended to define a constant pointing to a singleton of a plugin instance for using it.

To use a plugin in your unit test class, use the `OsgiContextBuilder` class instead of directly instantiating the `OsgiContext`class. This allows you in a fluent style to configure more options, with the `plugin(...)` method you can add one or more plugins.

Example: 

    #!java
    public OsgiContext context = new OsgiContextBuilder().plugin(MY_PLUGIN).build();

More examples:

* [Apache Sling Context-Aware Configuration Mock Plugin][caconfig-mock-plugin]
* [Apache Sling Context-Aware Configuration Mock Plugin Test][caconfig-mock-plugin-test]



[mockito-junit4-testrunner]: https://www.javadoc.io/page/org.mockito/mockito-core/latest/org/mockito/junit/MockitoJUnitRunner.html
[mockito-junit5-extension]: https://www.javadoc.io/page/org.mockito/mockito-junit-jupiter/latest/org/mockito/junit/jupiter/MockitoExtension.html
[caconfig-mock-plugin]: https://github.com/apache/sling/blob/trunk/contrib/extensions/contextaware-config/testing/mocks/caconfig-mock-plugin/src/main/java/org/apache/sling/testing/mock/caconfig/ContextPlugins.java
[caconfig-mock-plugin-test]: https://github.com/apache/sling/blob/trunk/contrib/extensions/contextaware-config/testing/mocks/caconfig-mock-plugin/src/test/java/org/apache/sling/testing/mock/caconfig/ContextPluginsTest.java
