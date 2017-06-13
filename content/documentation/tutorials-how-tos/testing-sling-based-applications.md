Title: Testing Sling-based applications

Automated testing of OSGi components and services can be challenging, as many of them depend on other services that must be present or simulated for testing.

This page describes the various approaches that we use to test Sling itself, and introduces a number of tools that can help testing OSGi and HTTP-based applications.

[TOC]

## Unit tests

When possible, unit tests are obviously the fastest executing ones, and it's easy to keep them close to the code that they're testing. 

We have quite a lot of those in Sling, the older use the JUnit3 TestCase base class, and later ones use JUnit4 annotations. Mixing both approaches is possible, there's no need to rewrite existing tests.

## Tests that use a JCR repository

Utility classes from our [commons/testing](https://svn.apache.org/repos/asf/sling/trunk/bundles/commons/testing) module make it easy to get a real JCR repository for testing. That's a bit slower than pure unit tests, of course, but this only adds 1-2 seconds to the execution of a test suite.

The `RepositoryProviderTest` in that module uses this technique to get a JCR repository.

Note that our utilities do not cleanup the repository between tests, so you must be careful about test isolation, for example by using unique paths for each test.

## Mock classes and services

The next step is to use mock classes and services to simulate components that are needed for testing. This makes it possible to test OSGi service classes without an OSGi framework, or classes accessing the Sling or JCR API without a running Sling instance or JCR repository.

The [Development]({{ refs.development.path }}) documentation page contains a section "Testing Sling-based Applications" lising all mock implementations available as part of the Apache Sling project.

In other cases we use [jmock](http://www.jmock.org/) or [Mockito][1] to help create mock objects without having to write much code - such mocking libraries take care of the plumbing and allow you to write just the bits of code that matter (often with funny syntaxes). The tests of the [org.apache.sling.event](https://svn.apache.org/repos/asf/sling/trunk/bundles/extensions/event/) bundle, for example, make extensive use of such mock services.

The problem with mocks is that it can become hard to make sure you're actually testing something, and not just "mocking mocks". At a certain level of complexity, it becomes quicker and clearer to actually start an OSGi framework for automated tests.

### Side note: injecting services in private fields

To inject (real or fake) services in others for testing, without having to create getters and setters just for this, you could use a reflection-based trick, as in the below example. Utilities
such as the [PrivateAccessor](http://junit-addons.sourceforge.net/junitx/util/PrivateAccessor.html) from [junit-addons](http://junit-addons.sourceforge.net/) make that simpler.

    #!java
    // set resource resolver factory
    // in a ServletResolver object which has a private resourceResolverFactory field
    
    ServletResolver servletResolver = ....
    Class<?> resolverClass = servletResolver.getClass().getSuperclass();
    final java.lang.reflect.Field resolverField = resolverClass.getDeclaredField("resourceResolverFactory");
    resolverField.setAccessible(true);
    resolverField.set(servletResolver, factory);


## Pax Exam

[Pax Exam](http://team.ops4j.org/wiki/display/paxexam/Pax+Exam) allows you to easily start an OSGi framework during execution of a JUnit test suite.

We currently use it for our [Sling installer integration tests](https://svn.apache.org/repos/asf/sling/trunk/installer/it) for example. As parts of the installer interact directly with the OSGi framework, it felt safer to test it in a realistic situation rather than mock everything.

Such tests are obviously slower than plain unit tests and tests that use mocks. Our installer integration tests, using Pax Exam, take about a minute to execute on a 2010 macbook pro.

## Server-side JUnit tests

The tools described on the [JUnit server-side testing support]({{ refs.org-apache-sling-junit-bundles.path }}) page allow for
running JUnit tests on an live Sling instance, as part of the normal integration testing cycle. 

## HTTP-based integration tests
The [Sling HTTP Testing Rules](https://svn.apache.org/repos/asf/sling/trunk/testing/junit/rules) allow writing integration tests easily. They are primarily meant to be used for tests that use http against 
a Sling instance and make use of the [org.apache.sling.testing.clients](https://svn.apache.org/repos/asf/sling/trunk/testing/http/clients) which offer a simple, immutable and extendable way of working 
with specialized testing clients.

The JUnit rules incorporate boiler-plate logic that is shared in tests and take the modern approach of using rules rather than 
inheritance. The `SlingRule` (for methods) or `SlingClassRule` (for test classes) are base rules, chaining other rules like `TestTimeoutRule`, 
`TestDescriptionRule`, `FilterRule`. The `SlingInstanceRule` extends that and starts a Sling instance if needed and also allows 
instantiating a `SlingClient` pointing to the instance and automatically configure the base url, credentials, etc.
    

### <a name="starting"></a> Starting an Integration Test
Starting an integration is very simple out of the box, but is very extendable, both by combining or configuring the junit rules and by 
using the versatile `SlingClient` (which can be extended or adapted by calling `adaptTo(MyClient.class)` without losing the client 
configuration)

The [README](https://svn.apache.org/repos/asf/sling/trunk/testing/junit/rules/README.md) provides more detail, as do [the tests](https://svn.apache.org/repos/asf/sling/trunk/testing/junit/rules/src/test/java).
The [Sling HTTP Testing Clients](https://svn.apache.org/repos/asf/sling/trunk/testing/http/clients) provide simple explanations, and unit tests.

#### Maven Dependency
    #!xml 
    <dependency>
        <groupId>org.apache.sling</groupId>
        <artifactId>org.apache.sling.testing.rules</artifactId>
        <version>0.1.0-SNAPSHOT</version>        
    </dependency>

#### Simple Example using SlingInstanceRule


    #!java   
    public class MySimpleIT {
    
        @ClassRule
        public static SlingInstanceRule instanceRule = new SlingInstanceRule();
    
        @Rule
        public SlingRule methodRule = new SlingRule(); // will configure test timeout, description, etc.
    
        @Test
        public void testCreateNode() {
           SlingClient client = instanceRule.getAdminClient();
           client.createNode("/content/myNode", "nt:unstructured");
           Assert.assertTrue("Node should be there", client.exists("/content/myNode"));
           //client.adaptTo(OsgiConsoleClient.class).editConfigurationWithWait(10, "MYPID", null, myMap);
        }            
    } 
 

## Summary

Combining the above testing techniques has worked well for us in creating and testing Sling. Being able to test things at different levels of integration has proved an efficient way to get good test coverage without having to write too much boring test code.


  [1]: https://code.google.com/p/mockito/
