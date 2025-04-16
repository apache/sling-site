title=Hamcrest Integration
type=page
status=published
tags=development
~~~~~~

Deeper integration with the [Hamcrest matcher library](https://hamcrest.org/).

## Maven Dependency

    #!xml
    <dependency>
      <groupId>org.apache.sling</groupId>
      <artifactId>org.apache.sling.testing.hamcrest</artifactId>
    </dependency>

Note that to keep the classpath consistent this module has all its dependencies marked as `provided` (except hamcrest). It relies on your own project to define the needed dependencies, such as `org.apache.sling:org.apache.sling.api`.

See latest version on the [downloads page](/downloads.cgi).

## Usage

The class [`org.apache.sling.testing.hamcrest.ResourceMatchers`](https://github.com/apache/sling-org-apache-sling-testing-hamcrest/blob/master/src/main/java/org/apache/sling/hamcrest/ResourceMatchers.java) is the main entry point. It contains static methods that can be used to create assertions.

    #!java
    import static org.apache.sling.hamcrest.ResourceMatchers.resourceOfType;

    public void MyServiceTest {

      @Test
      public void loadResources() {
        Map<String, Object> expectedProperties = /* define properties */;
        Resource resource = /* load resource */ null;

        assertThat(resource, resourceOfType("my/app"));
        assertThat(resource, hasChildren("header", "body"));
        assertThat(resource, resourceWithProps(expectedProperties));
      }

    }

The Slingshot sample application uses these matchers, see [SetupServiceTest.java](https://github.com/apache/sling-samples/blob/master/slingshot/src/test/java/org/apache/sling/sample/slingshot/impl/SetupServiceTest.java) for an example.
