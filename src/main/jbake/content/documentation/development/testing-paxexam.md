title=Apache Sling Testing PaxExam		
type=page
status=published
tags=testing,development,maven,junit,exam
~~~~~~

## Overview

[Sling Testing PaxExam](https://github.com/apache/sling-org-apache-sling-testing-paxexam) provides test support for use with [Pax Exam](https://github.com/ops4j/org.ops4j.pax.exam2) to test with *real* Sling instances – no limitations or issues due to incomplete and faulty mock implementations.

[Sling's Karaf Features](https://sling.apache.org/documentation/karaf.html#sling-karaf-features) are available as `Option`s for Pax Exam to set up tailored Sling instances easily.

The [`TestSupport`](https://github.com/apache/sling-org-apache-sling-testing-paxexam/blob/master/src/main/java/org/apache/sling/testing/paxexam/TestSupport.java) class comes with common helper methods and `Option`s.

The setups and examples on this page show how to run fully isolated tests in separate JVMs ([forked container](https://ops4j1.jira.com/wiki/spaces/PAXEXAM4/pages/54263862/OSGi+Containers#OSGiContainers-ForkedContainer)) to avoid classloader issues and boot a new Sling instance per test class to have always a fresh OSGi container and JCR repository.


## Features

* run integration tests in a *tailored* Sling instance in the *same module* (with the build artifact under test)
* use different versions in build (e.g. *minimal*) and tests (e.g. *latest*)
* overriding of versions
* build bundles with test content and OSGi DS services on-the-fly (no need for extra modules)


## Getting Started


### 1. Add required dependencies

Add the required dependencies for testing with JUnit and Pax Exam in Sling:

    <!-- Sling Testing PaxExam -->
    <dependency>
      <groupId>org.apache.sling</groupId>
      <artifactId>org.apache.sling.testing.paxexam</artifactId>
      <version>1.0.0</version>
      <scope>provided</scope>
    </dependency>

    <!-- an OSGi framework -->
    <dependency>
      <groupId>org.apache.felix</groupId>
      <artifactId>org.apache.felix.framework</artifactId>
      <version>5.6.10</version>
      <scope>test</scope>
    </dependency>

    <!-- JUnit -->
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <scope>test</scope>
    </dependency>

    <!-- Pax Exam -->
    <dependency>
      <groupId>org.ops4j.pax.exam</groupId>
      <artifactId>pax-exam</artifactId>
      <version>4.11</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.ops4j.pax.exam</groupId>
      <artifactId>pax-exam-cm</artifactId>
      <version>4.11</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.ops4j.pax.exam</groupId>
      <artifactId>pax-exam-container-forked</artifactId>
      <version>4.11</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.ops4j.pax.exam</groupId>
      <artifactId>pax-exam-junit4</artifactId>
      <version>4.11</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.ops4j.pax.exam</groupId>
      <artifactId>pax-exam-link-mvn</artifactId>
      <version>4.11</version>
      <scope>test</scope>
    </dependency>

### 2. Configure the build artifact to use in integration testing

Configure the build artifact (bundle) to use in integration testing in `pom.xml`:

      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-failsafe-plugin</artifactId>
        <executions>
          <execution>
            <goals>
              <goal>integration-test</goal>
              <goal>verify</goal>
            </goals>
          </execution>
        </executions>
        <configuration>
          <redirectTestOutputToFile>true</redirectTestOutputToFile>
          <systemProperties>
            <property>
              <name>bundle.filename</name>
              <value>${basedir}/target/${project.build.finalName}.jar</value>
            </property>
          </systemProperties>
        </configuration>
      </plugin>

Add `depends-maven-plugin` when using `TestSupport#baseConfiguration()` or `SlingVersionResolver#setVersionFromProject(…)`:

      <plugin>
        <groupId>org.apache.servicemix.tooling</groupId>
        <artifactId>depends-maven-plugin</artifactId>
        <version>1.4.0</version>
        <executions>
          <execution>
            <goals>
              <goal>generate-depends-file</goal>
            </goals>
          </execution>
        </executions>
      </plugin>

**NOTE:** `<version/>` and `<executions/>` are managed in Sling Parent and can be omitted when using version 33 or higher.


### 3. Create a test class and provide a *Configuration*

Create a test class (extend `TestSupport` to use helper methods and `Option`s) and provide a *Configuration* (`Option[]`) for Pax Exam:

    @Configuration
    public Option[] configuration() {
        return new Option[]{
            baseConfiguration(), // from TestSupport
            slingQuickstart(),
            // build artifact
            testBundle("bundle.filename"), // from TestSupport
            // testing
            junitBundles()
        };
    }

    protected Option slingQuickstart() {
        final String workingDirectory = workingDirectory(); // from TestSupport
        final int httpPort = findFreePort(); // from TestSupport
        return composite(
            slingQuickstartOakTar(workingDirectory, httpPort), // from SlingOptions
            slingModels(), // from SlingOptions (for illustration)
            slingScripting() // from SlingOptions (for illustration)
        );
    }

The above configuration provides all bundles and OSGi configurations to run a Sling Quickstart setup with Sling Models and Sling Scripting.

**NOTE:** When using `slingQuickstartOakTar()` or `slingQuickstartOakMongo()` without _working directory_, _HTTP port_ and _Mongo URI_ make sure to clean up file system and database after each test and do not run tests in parallel to prevent interferences between tests.


## Overriding or adding versions

To use different versions of bundles in tests than the ones in `SlingVersionResolver` create a custom `SlingVersionResolver` (extending `SlingVersionResolver`) and set it in `SlingOptions`:

    SlingOptions.versionResolver = new CustomSlingVersionResolver();

or simply (re)set versions in `SlingVersionResolver`:

    SlingOptions.versionResolver.setVersion(SLING_GROUP_ID, "org.apache.sling.jcr.oak.server", "1.1.0");

To use a version from project (`pom.xml`) use `setVersionFromProject(String, String)` with `groupId` and `artifactId`:

    SlingOptions.versionResolver.setVersionFromProject(SLING_GROUP_ID, "org.apache.sling.jcr.oak.server");


## Examples

### Set up a tailored Sling instance

The `FreemarkerTestSupport` below from [Scripting FreeMarker](https://github.com/apache/sling-org-apache-sling-scripting-freemarker) shows how to set up a tailored Sling instance to test Scripting FreeMarker itself. 

`@Inject`ing `ServletResolver`, `SlingRequestProcessor`, `AuthenticationSupport`, `HttpService` and `ScriptEngineFactory` ensures testing is delayed until those services are available.

The `@ProbeBuilder` annotated method modifies the [probe](https://ops4j1.jira.com/wiki/spaces/PAXEXAM4/pages/54263860/Concepts#Concepts-Probe) for Sling by adding `Export-Package`, `Sling-Model-Packages` and `Sling-Initial-Content` headers.

    public abstract class FreemarkerTestSupport extends TestSupport {

        @Inject
        protected ServletResolver servletResolver;

        @Inject
        protected SlingRequestProcessor slingRequestProcessor;

        @Inject
        protected AuthenticationSupport authenticationSupport;

        @Inject
        protected HttpService httpService;

        @Inject
        @Filter(value = "(names=freemarker)")
        protected ScriptEngineFactory scriptEngineFactory;

        public Option baseConfiguration() {
            return composite(
                super.baseConfiguration(),
                slingQuickstart(),
                // Sling Scripting FreeMarker
                testBundle("bundle.filename"),
                mavenBundle().groupId("org.freemarker").artifactId("freemarker").versionAsInProject(),
                mavenBundle().groupId("org.apache.servicemix.specs").artifactId("org.apache.servicemix.specs.jaxp-api-1.4").versionAsInProject(),
                // testing
                slingResourcePresence(),
                mavenBundle().groupId("org.jsoup").artifactId("jsoup").versionAsInProject(),
                mavenBundle().groupId("org.apache.servicemix.bundles").artifactId("org.apache.servicemix.bundles.hamcrest").versionAsInProject(),
                junitBundles()
            );
        }

        @ProbeBuilder
        public TestProbeBuilder probeConfiguration(final TestProbeBuilder testProbeBuilder) {
            testProbeBuilder.setHeader(Constants.EXPORT_PACKAGE, "org.apache.sling.scripting.freemarker.it.app");
            testProbeBuilder.setHeader("Sling-Model-Packages", "org.apache.sling.scripting.freemarker.it.app");
            testProbeBuilder.setHeader("Sling-Initial-Content", String.join(",",
                "apps/freemarker;path:=/apps/freemarker;overwrite:=true;uninstall:=true",
                "content;path:=/content;overwrite:=true;uninstall:=true"
            ));
            return testProbeBuilder;
        }

        protected Option slingQuickstart() {
            final int httpPort = findFreePort();
            final String workingDirectory = workingDirectory();
            return composite(
                slingQuickstartOakTar(workingDirectory, httpPort),
                slingModels(),
                slingScripting()
            );
        }

    }

### Provide additional OSGi services for testing

The `FreemarkerScriptEngineFactoryIT` and `Ranked2Configuration` below from [Scripting FreeMarker](https://github.com/apache/sling-org-apache-sling-scripting-freemarker) show how to build a bundle with [Tinybundles](https://github.com/ops4j/org.ops4j.pax.tinybundles) (and [bnd](https://github.com/bndtools/bnd)) on-the-fly (`buildBundleWithBnd()`) to provide additional OSGi DS services for testing.

    @RunWith(PaxExam.class)
    @ExamReactorStrategy(PerClass.class)
    public class FreemarkerScriptEngineFactoryIT extends FreemarkerTestSupport {

        @Inject
        @Filter("(name=bar)")
        private freemarker.template.Configuration configuration;

        @Configuration
        public Option[] configuration() {
            return new Option[]{
                baseConfiguration(),
                buildBundleWithBnd( // from TestSupport
                    Ranked1Configuration.class,
                    Ranked2Configuration.class
                )
            };
        }
    
        […]
    
        @Test
        public void testConfiguration() throws IllegalAccessException {
            final Object configuration = FieldUtils.readDeclaredField(scriptEngineFactory, "configuration", true);
            assertThat(configuration, sameInstance(this.configuration));
            assertThat(configuration.getClass().getName(), is("org.apache.sling.scripting.freemarker.it.app.Ranked2Configuration"));
        }

    }

Test service with [OSGi R6 DS annotation](https://osgi.org/javadoc/r6/cmpn/org/osgi/service/component/annotations/package-summary.html#package_description) (extending `freemarker.template.Configuration`):

    @Component(
        service = Configuration.class,
        property = {
            "name=bar",
            "service.ranking:Integer=2"
        }
    )
    public class Ranked2Configuration extends Configuration {

        public Ranked2Configuration() {
            super(Configuration.getVersion());
        }

    }

### Testing HTML over HTTP with jsoup

The `SimpleIT` below from [Scripting FreeMarker](https://github.com/apache/sling-org-apache-sling-scripting-freemarker) shows how to test HTML rendering with [jsoup](https://jsoup.org). The use of [ResourcePresence](https://github.com/apache/sling-org-apache-sling-resource-presence) ensures that tests are delayed until Sling's repository is ready to serve the `Resource` at given path.

    @RunWith(PaxExam.class)
    @ExamReactorStrategy(PerClass.class)
    public class SimpleIT extends FreemarkerTestSupport {
    
        private Document document;
    
        @Inject
        @Filter(value = "(path=/apps/freemarker/page/simple/html.ftl)")
        private ResourcePresence resourcePresence;
    
        @Configuration
        public Option[] configuration() {
            return new Option[]{
                baseConfiguration(),
                factoryConfiguration("org.apache.sling.resource.presence.internal.ResourcePresenter")
                    .put("path", "/apps/freemarker/page/simple/html.ftl")
                    .asOption(),
            };
        }
    
        @Before
        public void setup() throws IOException {
            final String url = String.format("http://localhost:%s/freemarker/simple.html", httpPort());
            document = Jsoup.connect(url).get();
        }
    
        @Test
        public void testTitle() {
            assertThat(document.title(), is("freemarker simple"));
        }
    
        @Test
        public void testPageName() {
            final Element name = document.getElementById("name");
            assertThat(name.text(), is("simple"));
        }
    
    }


## Logging

See Pax Exam's [Logging Configuration](https://ops4j1.jira.com/wiki/spaces/PAXEXAM4/pages/54263891/Logging+Configuration) if logging needs to be tweaked.

For [Logback](https://logback.qos.ch) use `SlingOptions#logback()` and add both `exam.properties` and `logback.xml` to `src/test/resources` as described in Pax Exam's [Logging Configuration](https://ops4j1.jira.com/wiki/spaces/PAXEXAM4/pages/54263891/Logging+Configuration).


