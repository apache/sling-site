title=How to Create a Custom Feature Model Project
type=page
status=published
tags=featuremodel,sling, kickstarter
~~~~~~

### About this How-To

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00;">

#### What we'll explore: 

* Create a sample Sling bundle project 
* Update the Maven POM to add Feature Model support to the project
* Launch our sample application with the Kickstarter

#### What you should know: 

* Skill Level: Intermediate
* Environment: Windows/Unix
* Time: 20 minutes

</div>

* Back To: [How to Start Sling with the Kickstarter](/documentation/feature-model/howtos/kickstart.html)
* Back Home: [Feature Model](/documentation/feature-model/feature-model-overview.html)


### Prerequisites

In order to follow this how-to you'll need the following on your computer:

* Java 8
* Maven 3
* Bash shell


### What's the Sling Feature Model

The Sling Feature Model provides a robust approach for configuring and assembling OSGi-based applications.
Here are some of its high-level capabilities:

* Declarative description of an entire application or part of an application
* Support for aggregating Feature Models into a single Feature Model for simpler packaging and distribution
* Easy application startup through the Feature Launcher or the Kickstarter


### What's a Feature Model project

A Feature Model project is a standard Maven project with the following additional features:

* Sling Feature Maven Plugin
* Kickstarter launch profile


### Step 1: Create a Sling bundle project


Let's start by creating a simple Sling project using the traditional Maven [Sling Bundle Archetype](/documentation/development/maven-archetypes.html#sling-jcrinstall-bundle-archetype-1).

    $  mvn -X archetype:generate -DarchetypeGroupId=org.apache.sling -DarchetypeArtifactId=sling-bundle-archetype \
      -DgroupId=org.apache.sling.example \
      -DartifactId=feature-model-sample \
      -Dversion=1.0.0-SNAPSHOT \
      -Dpackage=org.apache.sling.example
    $ cd feature-model-sample 

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00;">

**Note:** There are plans to introduce a Maven archetype that will create a Maven project with support for Feature Models.

</div>


### Step 2: Update the POM

Now, let's update the POM and add a few elements to layer on support for Feature Models.

**1.** Add the following to the `<properties>` element.

    <slingfeature-maven-plugin.version>1.3.4</slingfeature-maven-plugin.version>
    <sling-kickstart-maven-plugin.version>0.0.2</sling-kickstart-maven-plugin.version>
    <oak.version>1.26.0</oak.version>

**2.** Add the [Sling Feature Maven Plugin](https://sling.apache.org/components/slingfeature-maven-plugin/plugin-info.html)  under `<build>` -> `<plugins>`.

    <plugin>
        <groupId>org.apache.sling</groupId>
        <artifactId>slingfeature-maven-plugin</artifactId>
        <version>${slingfeature-maven-plugin.version}</version>
        <extensions>true</extensions>
        <executions>
            <execution>
                <id>create-fm</id>
                <phase>package</phase>
                <goals>
                    <goal>include-artifact</goal>
                </goals>
            </execution>
            <execution>
                <id>aggregate-configuration</id>
                <phase>package</phase>
                <goals>
                    <goal>aggregate-features</goal>
                </goals>
                <configuration>
                    <aggregates>
                        <aggregate>
                            <classifier>feature_model_sample</classifier>
                            <filesInclude>**/*.json</filesInclude>
                            <title>Sling Sample Feature Model</title>
                        </aggregate>
                    </aggregates>
                </configuration>
            </execution>
            <execution>
                <id>install-fm</id>
                <phase>package</phase>
                <goals>
                    <goal>attach-features</goal>
                </goals>
            </execution>
        </executions>
    </plugin>


The Sling Feature Maven Plugin is responsible for creating a Feature Model JSON file for your project.  The only pieces that change from 
project to project are the `<classifier>` and `<title>` element values. Set these values to something descriptive for your project. 
The classifier value will be used as part of the Feature Model JSON filename:
`target/slingfeature-tmp/feature-`_classifier_`.json`


<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00; margin-bottom: 1em;">

Make a note of `target/slingfeature-tmp/feature-feature_model_sample.json` as this path will be used in the next section.

</div>

**3.** Add a Maven profile called `launch`  under `<project>` -> `<profiles>`.

    <profile>
        <id>launch</id>
        <build>
            <plugins>
                <plugin>
                    <groupId>org.apache.sling</groupId>
                    <artifactId>sling-kickstart-maven-plugin</artifactId>
                    <version>${sling-kickstart-maven-plugin.version}</version>
                    <extensions>true</extensions>
                    <executions>
                        <execution>
                            <id>start-sling</id>
                            <phase>install</phase>
                            <goals>
                                <goal>start</goal>
                            </goals>
                        </execution>
                    </executions>
                    <configuration>
                        <launchpadDependency>
                            <groupId>org.apache.sling</groupId>
                            <artifactId>org.apache.sling.kickstart</artifactId>
                            <version>0.0.3-SNAPSHOT</version>
                        </launchpadDependency>
                        <parallelExecution>false</parallelExecution>
                        <keepLaunchpadRunning>true</keepLaunchpadRunning>
                        <servers>
                            <server>
                                <port>8080</port>
                                <controlPort>8081</controlPort>
                                <additionalFeatureFile>
                                    target/slingfeature-tmp/feature-feature_model_sample.json
                                </additionalFeatureFile>
                                <debug>true</debug>
                            </server>
                        </servers>
                    </configuration>
                </plugin>
            </plugins>
        </build>
    </profile>


This profile is responsible for starting your application using the Kickstarter. Simply, set the `<additionalFeatureFile>` to the file
in your target directory that contains your application's Feature Model JSON.

### Step 4: Launch your application


    $ mvn clean install -Plaunch 

Now, log into Sling and visit the System Console. You should see your bundle (`feature-model-sample`) listed.


## Mission Accomplished

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00; margin-bottom: 1em;">

#### What we learned: 

* How to update a traditional Sling bundle project to support Feature Models
* How to start your project with the Kickstarter

</div>

Well, that was fun. We'll revisit this sample project soon, But first, let's see how the Feature Model can help us handle
complex application configurations. In the next section, we'll take a look at the Composite NodeStore and how to configure
it with the Feature Model.

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00; margin-bottom: 1em;">

* Next Up: [How to Create a Sling Composite Node Store](/documentation/feature-model/howtos/create-sling-composite.html)
* Back To: [Feature Model Home](/documentation/feature-model/feature-model-overview.html)

</div>
