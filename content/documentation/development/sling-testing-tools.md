Title: Sling Testing Tools

<div class="warning">
While this information is still valid, we recommend using the tools and techniques described
in the newer "Junit Server-Side Tests Support" page instead, see link below. 
</div>

As mentioned above, this is now replaced by the [Junit Server-Side Tests Support]({{ refs.org-apache-sling-junit-bundles.path }}) page. 

Sling provides a number of testing tools to support the following use cases:

* Run JUnit tests contributed by OSGi bundles in an OSGi system. This does not require Sling and should work in other OSGi  environments.
* Run scriptable tests in a Sling instance, using any supported scripting language.
* Run integration tests via HTTP against a Sling instance that is started during the Maven build cycle, or independently.

This page describes those tools, and points to the bundles that implement them.

The [testing/samples/integration-tests](http://svn.apache.org/repos/asf/sling/trunk/testing/samples/integration-tests) module demonstrates these tools, and is also meant as a sample project to show how to run integration tests for Sling-based applications.

The main Sling integration tests at [launchpad/integration-tests](https://svn.apache.org/repos/asf/sling/trunk/launchpad/integration-tests) were created before this testing framework, and do not use it yet (as of March 2011). The new testing tools are simpler to use, but the "old" tests (all 400 of them as I write this) fulfill their validation role for testing Sling itself, there's no real need to modify them to use the new tools.

See also [Testing Sling-based applications]({{ refs.testing-sling-based-applications.path }}) which discusses testing in general.

## Required bundles
These tools require a number of bundles on top of the standard Sling launchpad. See the [sample tests pom.xml](http://svn.apache.org/repos/asf/sling/trunk/testing/samples/integration-tests/pom.xml)
for an up-to-date list. Look for `sling.additional.bundle.*` entries in that pom for the bundle artifact IDs, and see the `dependencies` section for their version numbers.

# Server-side JUnit tests contributed by bundles
The services provided by the [org.apache.sling.junit.core](http://svn.apache.org/repos/asf/sling/trunk/testing/junit/core) bundle allow bundles to register JUnit tests, which are executed server-side by the JUnitServlet registered by default at `/system/sling/junit`. This bundle is not dependent on Sling, it should work in other OSGi environments.

<div class="warning">
Note that the JUnitServlet does not require authentication, so it would allow any client to run tests. The servlet can be disabled by configuration if needed, but in general the `/system` path should not be accessible to website visitors anyway.
</div>

<div class="note">
For tighter integration with Sling, the alternate `SlingJUnitServlet` is registered with the `sling/junit/testing` resource type and `.junit` selector, if the bundle is running in a Sling system. Using this servlet instead of the plain JUnitServlet also allows Sling authentication to be used for running the tests, and the standard Sling request processing is used, including servlet filters for example.
</div>

To try the JUnitServlet interactively, install a bundle that contains tests registered via the `Sling-Test-Regexp=.*Test` bundle header. 

The JUnit core services use this regular expression to select which classes of the test bundle should be executed as JUnit tests.

To list the available tests, open http://localhost:8080/system/sling/junit/ . The servlet shows available tests, and allows you to execute them via a POST request.

Adding a path allows you to select a specific subset of tests, as in http://localhost:8080/system/sling/junit/org.apache.sling.junit.remote.html - the example integration tests described below use this to selectively execute server-side tests. The JUnitServlet provides various output formats, including in particular JSON, see http://localhost:8080/system/sling/junit/.json for example.

To supply tests from your own bundles, simply export the tests classes and add the `Sling-Test-Regexp` header to the bundle so that the Sling JUnit core services register them as tests.

### Injection of OSGi services
The `@TestReference` annotation is used to inject OSGi services in tests that are executed server side.The `BundleContext` can also be injected in this way.

## Curl examples
Here's an example executing a few tests using curl:

    $ curl -X POST http://localhost:8080/system/sling/junit/org.apache.sling.testing.samples.sampletests.JUnit.json
    [{
        "INFO_TYPE": "test",
        "description": "testPasses(org.apache.sling.testing.samples.sampletests.JUnit3Test)"
      },{
        "INFO_TYPE": "test",
        "description": "testPasses(org.apache.sling.testing.samples.sampletests.JUnit4Test)"
      },{
        "INFO_TYPE": "test",
        "description": "testRequiresBefore(org.apache.sling.testing.samples.sampletests.JUnit4Test)"
      }
    ]


And another example with a test that fails:

    $ curl -X POST http://localhost:8080/system/sling/junit/org.apache.sling.testing.samples.failingtests.JUnit4FailingTest.json

# Scriptable server-side tests
If the [org.apache.sling.junit.scriptable](http://svn.apache.org/repos/asf/sling/trunk/testing/junit/scriptable) bundle is active in a Sling system, (in addition to the `org.apache.sling.junit.core` bundle), scriptable tests can be executed by the `JUnitServlet` according to the following rules:

* A node that has the `sling:Test` mixin is a scriptable test node.
* For security reasons, scriptable test nodes are only executed as tests if they are found under `/libs` or `/apps`, or more precisely under a path that's part of Sling's `ResourceResolver` search path.
* To execute a test, the scriptable tests provider makes an HTTP request to the test node's path, with a `.test.txt` selector and extension, and expects the output to contain only the string `TEST_PASSED`. Empty lines and comment lines starting with a hash sign (#) are ignored in the output, and other lines are reported as failures.

The [ScriptableTestsTest](http://svn.apache.org/repos/asf/sling/trunk/testing/samples/integration-tests/src/test/java/org/apache/sling/testing/samples/integrationtests/serverside/scriptable/ScriptableTestsTest.java) class, from the integration test samples module described below, sets up such a test node and its accompanying script, and calls the JUnitServlet to execute the test. It can be used as a detailed example of how this works.

Here's a minimal example that sets up and executes a scriptable test:

    $ curl -u admin:admin -Fjcr:primaryNodeType=sling:Folder -Fsling:resourceType=foo -Fjcr:mixinTypes=sling:Test http://localhost:8080/apps/foo
    ...
    $ echo TEST_PASSED > /tmp/test.txt.esp ; curl -u admin:admin -T/tmp/test.txt.esp http://localhost:8080/apps/foo/test.txt.esp
    
At this point, foo.test.txt is what the scriptable test framework will request, and that outputs just TEST_PASSED:
    
    $ curl -u admin:admin http://localhost:8080/apps/foo.test.txt
    TEST_PASSED
    
And a POST to the JUnit servlet returns information on the test's execution:

    curl -u admin:admin -XPOST http://localhost:8080/system/sling/junit/org.apache.sling.junit.scriptable.ScriptableTestsProvider.json
    [{
        "INFO_TYPE": "test",
        "description": "verifyContent[0](org.apache.sling.junit.scriptable.TestAllPaths)",
        "test_metadata": {
          "test_execution_time_msec": 2
        }
      }
    ]

Test failures would be included in this JSON representation - you can test that by modifying the script to fail and making the
same request again.      

# Integration tests example
The [testing/samples/integration-tests](http://svn.apache.org/repos/asf/sling/trunk/testing/samples/integration-tests) module runs some simple integration tests against a Sling Launchpad instance that's setup from scratch before running the tests.

This module's pom and Java code can be used as examples to setup your own integration testing modules for Sling-based apps - or for any other runnable jar that provides an http service.

Besides serving as examples, some of the tests in this module are used to validate the testing tools. They run as part of the full Sling [continuous integration]({{ refs.project-information.path }}) build, so they're guaranteed to be correct examples if that build is successful.

The sample uses the [testing/tools](http://svn.apache.org/repos/asf/sling/trunk/testing/tools) to make the test code simpler. See the [OsgiConsoleTest|https://svn.apache.org/repos/asf/sling/trunk/testing/samples/integration-tests/src/test/java/org/apache/sling/testing/samples/integrationtests/http/OsgiConsoleTest.java] class for an example of a test that's very readable and requires no test setup or boilerplate code.

The following steps are executed in the `integration-test` phase of this module's Maven  build:

1. A random port number for the Sling server is selected by the Maven build helper plugin, unless explicitely set (see pom.xml for such options).
1. Additional bundles, defined in the module's pom, are downloaded from the Maven repository in the `target/sling/additional-bundles` folder.
1. The first test that inherits from the [SlingTestBase](https://svn.apache.org/repos/asf/sling/trunk/testing/tools/src/main/java/org/apache/sling/testing/tools/sling/SlingTestBase.java) class causes the Sling runnable jar (defined as a dependency in the module's pom) to be started. 
1. The `SlingTestBase` class waits for the Sling server to be ready, based on URLs and expected responses defined in the pom.
1. The `SlingTestBase` class installs and starts the bundles found in the `target/sling/additional-bundles` folder.
1. The test can now either test Sling directly via its http interface, or use the JUnitServlet to execute server-side tests contributed by bundles or scripts, as described above.
1. The Sling runnable jar is stopped when the test VM exits.
1. The test results are reported via the usual Maven mechanisms.

If `-DkeepJarRunning` is used on the Maven command line, the Sling runnable jar does not exit, to allow for running individual tests against this instance, for example when debugging the tests or the server code. See the pom for details.

## Running tests against existing server

Instead of provisioning a completely new Sling server, the ITs can also be executed on an already existing server instance. For that the 
`test-server-url` system property has to point to the existing server url. 
Additional bundles can still be deployed by using the `sling.additional.bundle.<num>` system property.

Optionally, the additional bundles can be undeployed after the execution of the IT by setting `additional.bundles.uninstall` to `true`. (since Sling Testing Tools 1.0.12, [SLING-4819](https://issues.apache.org/jira/browse/SLING-4819))

# Remote test execution
The testing tools support two types of remote test execution.

## SlingRemoteTestRunner
The [SlingRemoteTestRunner](http://svn.apache.org/repos/asf/sling/trunk/testing/junit/remote/src/main/java/org/apache/sling/junit/remote/testrunner/SlingRemoteTestRunner.java) is used to run tests using the `JUnitServlet` described above. In this case, the client-side JUnit test only defines which tests to run and some optional assertions. Checking the number of tests executed, for example, can be useful to make sure all test bundles have been activated as expected, to avoid ignoring missing test bundles.

See the [ServerSideSampleTest](https://svn.apache.org/repos/asf/sling/trunk/testing/samples/integration-tests/src/test/java/org/apache/sling/testing/samples/integrationtests/serverside/ServerSideSampleTest.java) class for an example.

It's a good idea to check that the JUnit servlet is ready before running those tests, see the
[ServerSideTestsBase]( https://svn.apache.org/repos/asf/sling/trunk/testing/samples/integration-tests/src/test/java/org/apache/sling/testing/samples/integrationtests/serverside/sling/SlingServerSideTestsBase.java)
for an example of how to do that.

## SlingRemoteExecutionRule
The [SlingRemoteExecutionRule](http://svn.apache.org/repos/asf/sling/trunk/testing/junit/remote/src/main/java/org/apache/sling/junit/remote/ide/SlingRemoteExecutionRule.java) is a JUnit Rule that allows tests to be executed remotely in a Sling instance from an IDE, assuming the test is available on both sides.

The [ExampleRemoteTest](https://svn.apache.org/repos/asf/sling/trunk/testing/junit/remote/src/main/java/org/apache/sling/junit/remote/exported/ExampleRemoteTest.java) class demonstrates this. To run it from your IDE, set the `sling.remote.test.url` in the IDE to the URL of the JUnitServlet, like http://localhost:8080/system/sling/junit for example.

# Debugging ITs
The JVM is usually forked twice during the execution of integration tests. The first time by the `maven-surefire-plugin` which executes the client-side (i.e. Maven-side) part of the tests. To debug this side the option `-Dmaven.surefire.debug` can be used which waits for a debugger to be attached on port 5005 before the (client-side) test is executed. More information is available in the [documentation of the maven-surefire-plugin](http://maven.apache.org/surefire/maven-surefire-plugin/examples/debugging.html).

Then the `JarExecutor` is forking the VM a second time to start the server (this does not happen if connecting to an already running instance). The system environment variable `jar.executor.vm.options` can be used to start that VM with debug options. All debug options are described at the [JPDA documentation](http://docs.oracle.com/javase/7/docs/technotes/guides/jpda/conninv.html#Invocation). If running 

    mvn test -Djar.executor.vm.options="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=8000"

the server start is interrupted until a debugger is connected on port 8000.
