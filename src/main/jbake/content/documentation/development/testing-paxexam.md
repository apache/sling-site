title=Apache Sling Testing PaxExam		
type=page
status=published
tags=testing,development,maven,junit,exam
~~~~~~

## Overview

Sling Testing PaxExam provides test support for use with [Pax Exam](https://github.com/ops4j/org.ops4j.pax.exam2).

[Sling's Karaf Features](https://sling.apache.org/documentation/karaf.html#sling-karaf-features) are available as `Option`s for Pax Exam to set up a tailored Sling instance easily.

The `TestSupport` class comes with common helper methods and `Option`s.

## Features

* run integration tests in a *tailored* Sling instance in the *same module* (with the build artifact under test)
* use different versions in build (e.g. *minimal*) and tests (e.g. *latest*)
* overriding of versions

## Getting Started

### 1. Add required dependencies

Add the required dependencies for testing with JUnit and Pax Exam in Sling:

    <!-- Sling Testing PaxExam -->
    <dependency>
      <groupId>org.apache.sling</groupId>
      <artifactId>org.apache.sling.testing.paxexam</artifactId>
      <version>0.0.5-SNAPSHOT</version>
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
        <version>2.18.1</version>
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

### 3. Create a test class and provide a *Configuration*

Create a test class (extend `TestSupport` to use helper methods and `Option`s) and provide a *Configuration* (`Option[]`) for Pax Exam:

    @Configuration
    public Option[] configuration() {
        return new Option[]{
            baseConfiguration(), // from TestSupport
            quickstart(),
            // build artifact
            testBundle("bundle.filename"), // from TestSupport
            // testing
            junitBundles()
        };
    }

    protected Option quickstart() {
        final String workingDirectory = workingDirectory(); // from TestSupport
        final int httpPort = findFreePort(); // from TestSupport
        return composite(
            slingQuickstartOakTar(workingDirectory, httpPort), // from SlingOptions
            slingModels(), // from SlingOptions (for illustration)
            slingScriptingThymeleaf() // from SlingOptions (for illustration)
        );
    }

The above configuration provides all bundles and OSGi configurations to run a Sling Quickstart setup with Sling Models and Sling Scripting Thymeleaf.

**NOTE:** When using `slingQuickstartOakTar()` or `slingQuickstartOakMongo()` without _working directory_, _HTTP port_ and _Mongo URI_ make sure to clean up file system and database after each test and do not run tests in parallel to prevent interferences between tests.

## Overriding or adding versions

To use different versions of bundles in tests than the ones in `SlingVersionResolver` create a custom `SlingVersionResolver` (extending `SlingVersionResolver`) and set it in `SlingOptions`:

    SlingOptions.versionResolver = new CustomSlingVersionResolver();

or simply (re)set versions in `SlingVersionResolver`:

    SlingOptions.versionResolver.setVersion(SLING_GROUP_ID, "org.apache.sling.jcr.oak.server", "1.1.0");

To use a version from project (`pom.xml`) use `setVersionFromProject(String, String)` with `groupId` and `artifactId`:

    SlingOptions.versionResolver.setVersionFromProject(SLING_GROUP_ID, "org.apache.sling.jcr.oak.server");

## Examples

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


