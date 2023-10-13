title=OSGi Mocks		
type=page
status=published
tags=development,testing,mocks,osgi
~~~~~~

Mock implementation of selected OSGi APIs for easier testing.

[TOC]


## Maven Dependency

For JUnit 5:

    #!xml
    <dependency>
      <groupId>org.apache.sling</groupId>
      <artifactId>org.apache.sling.testing.osgi-mock.junit5</artifactId>
    </dependency>

For JUnit 4:

    #!xml
    <dependency>
      <groupId>org.apache.sling</groupId>
      <artifactId>org.apache.sling.testing.osgi-mock.junit4</artifactId>
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

Since osgi-mock 3.4.0:

* Support direct construction of component property type [Config Annotations](#config-annotations).


## Usage

The `OsgiContext` object provides access to mock implementations of:

* OSGi Component Context
* OSGi Bundle Context

Additionally it supports:

* Registering and activating OSGi services and inject dependencies


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
    OsgiContext context = new OsgiContextBuilder().plugin(MY_PLUGIN).build();

More examples:

* [Apache Sling Context-Aware Configuration Mock Plugin][caconfig-mock-plugin]
* [Apache Sling Context-Aware Configuration Mock Plugin Test][caconfig-mock-plugin-test]



[mockito-junit4-testrunner]: https://www.javadoc.io/page/org.mockito/mockito-core/latest/org/mockito/junit/MockitoJUnitRunner.html
[mockito-junit5-extension]: https://www.javadoc.io/page/org.mockito/mockito-junit-jupiter/latest/org/mockito/junit/jupiter/MockitoExtension.html
[caconfig-mock-plugin]: https://github.com/apache/sling-org-apache-sling-testing-caconfig-mock-plugin/blob/master/src/main/java/org/apache/sling/testing/mock/caconfig/ContextPlugins.java
[caconfig-mock-plugin-test]: https://github.com/apache/sling-org-apache-sling-testing-caconfig-mock-plugin/blob/master/src/test/java/org/apache/sling/testing/mock/caconfig/ContextPluginsTest.java

## Config Annotations

Since osgi-mock 3.4.0, it is possible to use your component `Config` annotation test methods and classes, or use the provided `@SetConfig` and `@ConfigType` annotations to construct them for use as first-class values in unit tests. 

### `@SetConfig` 

`@SetConfig` is used to declare a ConfigurationAdmin configuration update prior to execution of a test using a `@Component`-style property declaration. 

Either the `pid` or `component` Class attribute must be specified for it to have any effect. If both are specified, the `pid` attribute takes precedence. 

Multiple `@SetConfig` annotations may be specified on the test class and the test method. They will be applied in the order they are declared, **starting with the class annotations, then the method annotations**.

### `@ConfigType` 

`@ConfigType` is used to map a service component's `Config` annotation type to an optional `@Component`-style property declaration, or to a pid to get a configuration from `ConfigurationAdmin` when the type is injected as a test parameter or collected by a `ConfigCollector`.

### `@AutoConfig`

`@AutoConfig(MyService.class)` is used to automatically convert a component property type annotation to a property map and install it using ConfigurationAdmin for the designated component class, so that a matching `context.registerInjectActivateService(MyService.class)` call will reflect the values of config annotation, without having to explicitly pass them as a `Map<String, Object>` in the method arguments.

An `@AutoConfig` annotation may be specified on the test class or the test method. If both are specified, the method annotation takes precedence.

All `@SetConfig` annotations in scope will be applied before `@AutoConfig`, if present, and `@ConfigType` annotations will be constructed after that.

Multiple `@ConfigType` annotations may be specified on the test class and the test method. They will be injected into matching parameters in the order they are declared, **starting with the method annotations, then the class annotations**.

Both osgi-mock.junit4 and osgi-mock.junit5 provide different approaches for convenient reflection and injection of these annotations.

### JUnit 5: `OsgiConfigParametersExtension` JUnit Extension

Given an OSGi component class that looks like this:

    #!java
    import org.osgi.service.component.annotations.Activate;
    import org.osgi.service.component.annotations.Component;
    import java.lang.annotation.Retention;
    import java.lang.annotation.RetentionPolicy;

    @Component(service = MyService.class)
    public class MyService {

        // specify runtime retention to allow for direct usage in unit tests 
        @Retention(RetentionPolicy.RUNTIME)
        public @interface Config {
            String path() default "/";
        }

        private final String path;

        @Activate
        public MyService(Config config) {
            this.path = config.path();
        }

        public String getPath() {
            return path;
        }
    }

A companion unit test in JUnit 5 might look like this:

    #!java
    import org.apache.sling.testing.mock.osgi.config.annotations.ConfigType;
    import org.apache.sling.testing.mock.osgi.config.annotations.SetConfig;
    import org.apache.sling.testing.mock.osgi.junit5.OsgiConfigParametersExtension;
    import org.junit.jupiter.api.Test;
    import org.junit.jupiter.api.extension.ExtendWith;

    import static org.junit.jupiter.api.Assertions.assertEquals;

    @ExtendWith(OsgiConfigParametersExtension.class)
    class MyServiceTest {

        @Test
        @MyService.Config(path = "/apps") // requires @Retention(RetentionPolicy.RUNTIME)
        void getPath(MyService.Config config) {
            MyService myService = new MyService(config);
            assertEquals("/apps", myService.getPath());
        }

        @Test
        @ConfigType(type = MyService.Config.class, property = "path=/libs")
        void getPath_ConfigType(MyService.Config config) {
            MyService myService = new MyService(config);
            assertEquals("/libs", myService.getPath());
        }

        @Test
        @SetConfig(pid = "new-pid", property = "path=/content")
        @ConfigType(pid = "new-pid", type = MyService.Config.class)
        void getPath_SetConfig(MyService.Config config) {
            MyService myService = new MyService(config);
            assertEquals("/content", myService.getPath());
        }
    }

There are multiple ways to declare a `Config` annotation and then use it as a test parameter.

Directly use the annotation on the test method and declare it as a test parameter:

    #!java
    @Test
    @MyService.Config(path = "/apps")
    void getPath(MyService.Config config) {
        MyService myService = new MyService(config);
        assertEquals("/apps", myService.getPath());
    }

Directly use the annotation on the test method, but use the `@AutoConfig(MyService.class)` annotation to install your component configuration behind the scenes, so that `registerInjectActivateService` will load it from ConfigurationAdmin:

    #!java
    @Test
    @AutoConfig(MyService.class)
    @MyService.Config(path = "/apps")
    void getPath() {
        MyService myService = context.registerInjectActivateService(MyService.class);
        assertEquals("/apps", myService.getPath());
    }

To create more than one configurable service in your test, use the `@ConfigMapParameter` annotation on a `Map<String, Object>` parameters to have the typed config annotations converted for use as Map arguments to `registerInjectActivateService`:

    #!java

    @Test
    @MyServiceDependency.Config(allowedPaths = "/apps")
    @MyService.Config(path = "/apps")
    void getPath(@ConfigMapParameter(MyServiceDependency.Config.class) 
                 Map<String, Object> myDependencyConfig,
                 @ConfigMapParameter(MyService.Config.class) 
                 Map<String, Object> myServiceConfig) {
        MyServiceDependency myDependency = 
            context.registerInjectActivateService(MyServiceDependency.class, myDependencyConfig);
        MyService myService = 
            context.registerInjectActivateService(MyService.class, myServiceConfig);
        assertEquals("/apps", myService.getPath());
    }


### JUnit 4: `ConfigCollector` JUnit Rule

Given the same example OSGi component from before:

    #!java
    import org.osgi.service.component.annotations.Activate;
    import org.osgi.service.component.annotations.Component;
    import java.lang.annotation.Retention;
    import java.lang.annotation.RetentionPolicy;

    @Component(service = MyService.class)
    public class MyService {

        // specify runtime retention to allow for direct usage in unit tests 
        @Retention(RetentionPolicy.RUNTIME)
        public @interface Config {
            String path() default "/";
        }

        private final String path;

        @Activate
        public MyService(Config config) {
            this.path = config.path();
        }

        public String getPath() {
            return path;
        }
    }


A companion unit test in JUnit 4 might look like this:

    #!java
    import org.apache.sling.testing.mock.osgi.config.annotations.ConfigType;
    import org.apache.sling.testing.mock.osgi.config.annotations.SetConfig;
    import org.apache.sling.testing.mock.osgi.junit.ConfigCollector;
    import org.apache.sling.testing.mock.osgi.junit.OsgiContext;
    import org.apache.sling.testing.mock.osgi.junit.OsgiContextBuilder;
    import org.junit.Rule;

    import static org.junit.Assert.assertEquals;

    public class MyServiceTest {

        @Rule
        public OsgiContext context = new OsgiContextBuilder().build();

        @Rule
        public ConfigCollector configs = new ConfigCollector(context);

        @Test
        @MyService.Config(path = "/apps") // requires @Retention(RetentionPolicy.RUNTIME)
        public void myServiceMethod() {
            MyService.Config config = configs.firstConfig(MyService.Config.class);
            MyService myService = new MyService(config);
            assertEquals("/apps", myService.getPath());
        }

        @Test
        @ConfigType(type = MyService.Config.class, property = "path=/libs")
        public void myServiceMethod() {
            MyService.Config config = configs.firstConfig(MyService.Config.class);
            MyService myService = new MyService(config);
            assertEquals("/libs", myService.getPath());
        }

        @Test
        @SetConfig(pid = "new-pid", property = "path=/content")
        @ConfigType(pid = "new-pid", type = MyService.Config.class)
        public void myServiceMethod() {
            MyService.Config config = configs.firstConfig(MyService.Config.class);
            MyService myService = new MyService(config);
            assertEquals("/content", myService.getPath());
        }
    }

In JUnit4 are multiple ways to declare a `Config` annotation and then use it as a test parameter.

Directly use the annotation on the test method and retrieve it from the `ConfigCollector` using the `firstConfig(Config.class)` method to pass to your component's `@Activate` constructor:

    #!java
    @Rule
    public ConfigCollector configs = new ConfigCollector(context);

    @Test
    @MyService.Config(path = "/apps")
    public void testGetPath() {
        MyService.Config config = configs.firstConfig(MyService.Config.class);
        MyService myService = new MyService(config);
        assertEquals("/apps", myService.getPath());
    }

Directly use the annotation on the test method, but use the `@AutoConfig(MyService.class)` annotation to install your component configuration behind the scenes, so that `registerInjectActivateService` will load it from ConfigurationAdmin:

    #!java
    @Rule
    public ConfigCollector configs = new ConfigCollector(context);

    @Test
    @AutoConfig(MyService.class)
    @MyService.Config(path = "/apps")
    public void testGetPath() {
        MyService myService = context.registerInjectActivateService(MyService.class);
        assertEquals("/apps", myService.getPath());
    }

To create more than one configurable service in your test, use the `ConfigCollector.firstConfigMap(Config.class)` method to return a `Map<String, Object>` converted from each `@Config` annotation for use as Map arguments to `registerInjectActivateService`:

    #!java
    @Rule
    public ConfigCollector configs = new ConfigCollector(context);

    @Test
    @MyServiceDependency.Config(allowedPaths = "/apps")
    @MyService.Config(path = "/apps")
    public void testGetPath() {
        Map<String, Object> myDependencyConfig = configs.firstConfigMap(MyServiceDependency.Config.class);
        Map<String, Object> myServiceConfig = configs.firstConfigMap(MyService.Config.class);
        MyServiceDependency myDependency = context.registerInjectActivateService(MyServiceDependency.class, myDependencyConfig);
        MyService myService = context.registerInjectActivateService(MyService.class, myServiceConfig);
        assertEquals("/apps", myService.getPath());
    }


### Config Annotations: SlingContext Compatibility

The OSGi Mock Config Annotations and JUnit4/JUnit5 extensions are compatible with the `SlingContext` from Sling Mocks and other libraries that provide extensions of `OsgiContextImpl`. The JUnit4 Rule or JUnit5 Extension will be available in test code as long as the osgi context provider's junit4 or junit5 library is explicitly or transitively dependent on the respective osgi-mock.junit4 or osgi-mock.junit5 dependency.
