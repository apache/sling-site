title=JUnit server-side testing support bundles		
type=page
status=published
tags=testing
~~~~~~

This is an overview of the Sling bundles that provide support for server-side JUnit tests. 

The Maven modules below [`sling-samples/testing`](https://github.com/apache/sling-samples/tree/master/testing)
provide different examples including HTTP-based and server-side teleported tests in a 
bundle module, running against a full Sling instance setup in the same Maven module.

## org.apache.sling.junit.core: server-side JUnit tests support
This bundle provides a `JUnitServlet` that runs JUnit tests found in bundles. 

<div class="warning">
Note that the JUnitServlet does not require authentication, so it would allow any client to run tests. The servlet can be disabled by configuration if needed, but in general the `/system` path should not be accessible to website visitors anyway.
</div>

<div class="note">
For tighter integration with Sling, the alternate `SlingJUnitServlet` is registered with the `sling/junit/testing` resource type and `.junit` selector, if the bundle is running in a Sling system. Using this servlet instead of the plain JUnitServlet also allows Sling authentication to be used for running the tests, and the standard Sling request processing is used, including servlet filters for example.
</div>

To make tests available to that servlet, the bundle that contains them must point to them
with a `Sling-Test-Regexp` bundle header that defines a regular expression that matches
the test class names, like for example:

    Sling-Test-Regexp=com.example.*ServerSideTest

### The TeleporterRule

The `TeleporterRule` supplied by this bundle (since V1.0.12) makes it easy to write such tests, as it takes care of
all the mechanics of 

1. creating the test bundle including all necessary classes for execution
1. adding the `Sling-Test-Regexp` header to the bundles manifest
1. deploy the bundle on an Sling server (with the help of the customizer)
1. calling the `JUnitServlet` from the client-side and report back the results
1. uninstalling the test bundle

Most of these steps are done on the client-side by the org.apache.sling.junit.teleporter module (see below).

Using this rule the server-side tests can be mixed with other tests in the source code if that's convenient, it just
requires the `junit.core` and `junit.teleporter` modules described on this page to create such tests. 

Here's a basic example of a server-side test that accesses OSGi services:

    public class BasicTeleporterTest {
    
        @Rule
        public final TeleporterRule teleporter = TeleporterRule.forClass(getClass(), "Launchpad");
        
        @Test
        public void testConfigAdmin() throws IOException {
            final String pid = "TEST_" + getClass().getName() + UUID.randomUUID();
            
            final ConfigurationAdmin ca = teleporter.getService(ConfigurationAdmin.class);
            assertNotNull("Teleporter should provide a ConfigurationAdmin", ca);
            
            final Configuration cfg = ca.getConfiguration(pid);
            assertNotNull("Expecting to get a Configuration", cfg);
            assertEquals("Expecting the correct pid", pid, cfg.getPid());
        }
    }
    
That's all there is to it, the `TeleporterRule` takes care of the rest.     

The test bundle being build and deployed through this rule usually happens quickly as the temporary bundle is
very small. Both the client-side and server-side parts of the test can be debugged easily
with the appropriate IDE settings.

The `Teleporter.getService` method takes an optional OSGi LDAP filter for service
selection, like for example:

    final StringTransformer t = teleporter.getService(StringTransformer.class, "(mode=uppercase)");

The method waits for the service to be available or until the timeout elapsed ([SLING-6031](https://issues.apache.org/jira/browse/SLING-6031)).

And starting with version 1.0.4 of the `org.apache.sling.junit.teleporter` bundle, you can specify
resources to embed in the test bundle, as in this example:

    @Rule
    public final TeleporterRule teleporter = 
      TeleporterRule.forClass(getClass(), "Launchpad")
      .withResources("/foo/", "/some/other/resource.txt");

which will embed all resources found under `/foo` as well as the `resource.txt` in the test
bundle, making them available to the server-side tests.

This teleporter mechanism is used in our integration tests, search for `TeleporterRule` in there
for examples or look at the 
[`integrationtest.teleporter`](https://github.com/apache/sling-org-apache-sling-launchpad-integration-tests/tree/master/src/main/java/org/apache/sling/launchpad/webapp/integrationtest/teleporter)
package. 

As I write this the teleporter mechanism is quite new, I suspect there might be some weird interactions 
between things like `@AfterClass`, custom test runners and this mechanism but it works well to a growing
number of tests in our `launchpad/integration-tests` module. Moving to JUnit `Rules` as much as possible, 
and combining them using JUnit's `RuleChain`, should help work around such limitations if they arise.

### More details on the JUnitServlet
To try the JUnitServlet interactively, you can install a
bundle that contains tests and a `Sling-Test-Regexp` bundle header that points to them, as
described above. Or use the `TeleporterRule` and set a breakpoint in the tests execution, when the test bundle in
installed and listed by the test servlet.

To list the available tests, open `/system/sling/junit/` in your browser. The servlet shows available tests and allows 
you to execute them via a POST request.

Adding a path allows you to select a specific subset of tests, as in 
`/system/sling/junit/org.apache.sling.junit.remote.html`
 
 The JUnitServlet provides various output formats, including in particular JSON, see 
 `/system/sling/junit/.json` for example.

## org.apache.sling.junit.teleporter: client-side TeleporterRule support
This module provides the `ClientSideTeleporter` which the `TeleporterRule` uses to package the server-side tests
in bundles that's installed temporarily on the test server. Almost all steps described above in [The TeleporterRule](#the-teleporterrule) are being performed by this module.

This module is not a bundle, as it's used on the client only, as a dependency when running the tests.

### TeleporterRule.Customizer ###
A `TeleporterRule.Customizer` is used to setup the `ClientSideTeleporter`. That customizer is instantiated dynamically
based on a String passed to the `TeleporterRule.forClass` method as 2nd parameter. As an example from our `launchpad/integration-tests` module, this call

    TeleporterRule.forClass(getClass(), "Launchpad:author");
    
causes the `TeleporterRule` to use the `org.apache.sling.junit.teleporter.customizers.LaunchpadCustomizer` class
to setup the `ClientSideTeleporter`, and passes the "author" string to it as an option. Although our current `LaunchpadCustomizer`
does not use this options string, it is meant to select a specific server (of family of servers) to run the tests on.

The options string can also use a full class name instead of the `Launchpad` short form used here, if needed. The part
of that string that follows the first colon is passed to the customizer as is.

Using Strings for customization reduces the coupling with the `junit.core` bundle, as it does not need to know those
classes which are used only on the client side when running tests. 

If `TeleporterRule.forClass(getClass())` is used (the method without an additional 2nd parameter) the default customizer is used ([SLING-5677](https://issues.apache.org/jira/browse/SLING-5677), since version 1.0.8). 

The following customizers are currently used in Sling

### Default Customizer ###

<!-- GIT-TODO - not yet migrated -->
*[DefaultPropertyBasedCustomizer.java](https://svn.apache.org/repos/asf/sling/trunk/testing/junit/teleporter/src/main/java/org/apache/sling/testing/teleporter/client/DefaultPropertyBasedCustomizer.java)* is used by default when no other customizer is referenced in `TeleporterRule.forClass(getClass())`. It relies on the following system properties:

| Property Name                | Description                                     | Mandatory to set | Default value | Since version | Related JIRA |
|------------------------------|-------------------------------------------------|------------------| ----- | ---| --- |
| `ClientSideTeleporter.baseUrl` | base url of the Sling Server to which to deploy. | yes | (-) | 1.0.8 | [SLING-5677](https://issues.apache.org/jira/browse/SLING-5677) |
| `ClientSideTeleporter.includeDependencyPrefixes` | comma-separated list of package prefixes for classes referenced from the IT. Only the classes having one of the given package prefix are included in the bundle being deployed to the given Sling instance together with the IT class itself.  They are only included though in case they are referenced! If this is not set, no referenced classes will be included. | no | (-) | 1.0.8 | [SLING-5677](https://issues.apache.org/jira/browse/SLING-5677) |
| `ClientSideTeleporter.excludeDependencyPrefixes` | comma-separated list of package prefixes for classes referenced from the IT. Classes having one of the given package prefix will not be included in the bundle being deployed to the given Sling instance together with the IT class itself. This takes precedence over the `ClientSideTeleporter.includeDependencyPrefixes`. | no | (-) | 1.0.8 | [SLING-5677](https://issues.apache.org/jira/browse/SLING-5677) |
| `ClientSideTeleporter.embedClasses` | comma-separated list of fully qualified class names which should be embedded in the test bundle. Use this only for classes which are not detected automatically by the Maven Dependency Analyzer but still should be embedded in the test bundle | no | (-) | 1.0.8 | [SLING-5677](https://issues.apache.org/jira/browse/SLING-5677) |
| `ClientSideTeleporter.embedClassesDirectories` | comma-separated list directories containing class files which should be embedded in the test bundle. Use this only for classes which are not detected automatically by the Maven Dependency Analyzer but still should be embedded in the test bundle | no | (-) | 1.0.12 | [SLING-6551](https://issues.apache.org/jira/browse/SLING-6551) |
| `ClientSideTeleporter.additionalBundleHeaders` | comma-separated list of entries in the format `<name>:<value>` which should be added to the test bundle as additional headers | no | (-) | 1.0.12 | [SLING-6558](https://issues.apache.org/jira/browse/SLING-6558) |
| `ClientSideTeleporter.testReadyTimeoutSeconds` | how long to wait for our test to be ready on the server-side in seconds, after installing the test bundle. | no | `12` | 1.0.8 | [SLING-5677](https://issues.apache.org/jira/browse/SLING-5677) |
| `ClientSideTeleporter.serverUsername` | the username with which to send requests to the Sling server. | no | `admin` | 1.0.8 | [SLING-5677](https://issues.apache.org/jira/browse/SLING-5677) |
| `ClientSideTeleporter.serverPassword` | the password with which to send requests to the Sling server. | no | `admin` | 1.0.8 | [SLING-5677](https://issues.apache.org/jira/browse/SLING-5677) |
| `ClientSideTeleporter.enableLogging` | set to `true` to log the tasks being performed by the teleporter. Useful for debugging. | no | `false` | 1.0.12 | [SLING-6546](https://issues.apache.org/jira/browse/SLING-6546) |
| `ClientSideTeleporter.preventToUninstallBundle` | set to `true` to not automatically uninstall the test bundle after test execution. Useful for debugging. | no | `false` | 1.0.12 | [SLING-6546](https://issues.apache.org/jira/browse/SLING-6546) |
| `ClientSideTeleporter.testBundleDirectory` | if set the test bundles are being persisted (before being installed) within the given directory name. If the directory does not exist, it will be automatically created. Useful for debugging. Recommended value `${project.build.directory}/test-bundles`. | no | (-) | 1.0.12 | [SLING-6546](https://issues.apache.org/jira/browse/SLING-6546) |


The provisioning of an appropriate instance can be done with the [slingstart-maven-plugin](/documentation/development/slingstart.html). An example for that is given at [`sling-samples/testing/module-with-it`](https://github.com/apache/sling-samples/tree/master/testing/module-with-it). Since `slingstart-maven-plugin` 1.5.0 it is possible to bootstrap a Sling Server from a `model.txt` below `src/test/provisioning` independent of the packaging (see [SLING-6068](https://issues.apache.org/jira/browse/SLING-6068)).

#### LaunchpadCustomizer ####
The *[`LaunchpadCustomizer.java`](https://github.com/apache/sling-org-apache-sling-launchpad-integration-tests/blob/master/src/main/java/org/apache/sling/junit/teleporter/customizers/LaunchpadCustomizer.java)* only verifies that a Sling instance is ready at a given port and configures the `ClientSideTeleporter` to deploy to `http://localhost:8080` with the credentials `admin`:`admin`. `LaunchpadCustomizer` uses the `HttpTestBase` therefore some parameters are customizable through system properties. There is no bootstrapping of an instance done here, so this must be done separately!

#### BWIT_TeleporterCustomizer ####
The *[`BWIT_TeleporterCustomizer.java`](https://github.com/apache/sling-samples/tree/master/testing/bundle-with-it/src/test/java/org/apache/sling/junit/teleporter/customizers/BWIT_TeleporterCustomizer.java)* relies on `SlingTestBase` to set the server's base url and credentials. Additionally the test bundle is adjusted so that the API is not included in it (but rather referenced from another bundle). The bootstrapping of the Sling instance is tweaked through system properties which are desribed [here](http://labs.6dglobal.com/blog/2013-06-05/creating-integration-tests-apache-sling/) and implicitly done by the customizer itself.

Those should give you an overview on what can be done with a customizer and decide whether you need to write your own one or using the default customizer is just enough.

## org.apache.sling.junit.healthcheck: run JUnit tests as Sling Health Checks
This bundle allows JUnit tests to run as [Sling Health Checks](/documentation/bundles/sling-health-check-tool.html),
which can be useful when defining smoke tests for example, allowing them to be used both at build time and run time.

See the `JUnitHealthCheck` class for details. 

## org.apache.sling.junit.scriptable: scriptable server-side tests
This bundle allows Sling scripts to be executed from the `JUnitServlet` as JUnit tests, as follows:

* A node that has the `sling:Test` mixin is a scriptable test node.
* For security reasons, scriptable test nodes are only executed as tests if they are found under `/libs` or `/apps`, or more precisely under a path that's part of Sling's `ResourceResolver` search path.
* To execute a test, the scriptable tests provider makes an HTTP request to the test node's path, with a `.test.txt` selector and extension, and expects the output to contain only the string `TEST_PASSED`. Empty lines and comment lines starting with a hash sign (#) are ignored in the output, and other lines are reported as failures.

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

## org.apache.sling.junit.remote: obsolete

The `org.apache.sling.junit.remote` bundle provides utilities to run server-side JUnit tests,
but using the newer `TeleporterRule` described above is much simpler. As a result, this bundle
should only be needed for existing tests that were written using its mechanisms.   
