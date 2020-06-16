title=Start Sling Feature Model with Feature Launcher
type=page
status=published
tags=feature model,sling,feature launcher
~~~~~~

### How-To Overview

<div style="background: lightblue;">

* What will you learn:
	* We are starting up Apache Sling with the Feature Launcher directly

* Time: 15 minutes
* Skill Level: Beginner
* Environment: Windows/Unix
</div>

* Back To: [Feature Model Home](/documentation/feature-model/feature-model-overview.html)

### Prerequisites

In order to follow through this HowTo you need the following on your computer:

* Java 8
* Command Line with Bash

### What is the Feature Launcher

The [Feature Launcher](https://github.com/apache/sling-org-apache-sling-feature-launcher) is
taking a Feature Model, resolves all the dependencies and launches the Feature Model ontop
of an OSGi container.
Some of the Feature Models are handled by extensions which have to be provided to the Feature
Launcher at startup time. 

### Explanation on what will happen

### Step 1: Obtain the Feature Launcher

First we create the project folder:

    $ cd <project root folder>
    $ mkdir sling-feature-launcher
    $ cd sling-feature-launcher
    $ curl https://repository.apache.org/content/groups/public/org/apache/sling/org.apache.sling.feature.launcher/1.1.4/org.apache.sling.feature.launcher-1.1.4.jar \
        org.apache.sling.feature.launcher-1.1.4.jar


### Step 2: Optional: Obtain Extensions

Extension are optional pieces that can added to the Feature Launcher to handle additional media like here
the Content Extension.

Going to the [Sling Folder](https://repository.apache.org/content/groups/public/org/apache/sling/)
you can select the desired extension.
In this Howto we are going to use the Content Extension:

    $ cd <project root folder>
    $ cd sling-feature-launcher
    $ curl https://repository.apache.org/content/groups/public/org/apache/sling/org.apache.sling.feature.extension.content/1.0.6//org.apache.sling.feature.extension.content-1.0.6.jar \
        org.apache.sling.feature.extension.content-1.0.6.jar


### Step 3: Obtain the Sling Feature Model

The Sling Feature Model can be taken from the [Sling Kickstart](https://github.com/apache/sling-org-apache-sling-kickstart#build)
project. Just got the folder /src/main/resources in the GitHub project page and then download the
[feature-sling12.json](https://github.com/apache/sling-org-apache-sling-kickstart/blob/master/src/main/resources/feature-sling12.json)
file.

### Step 5: Create Custom Log Settings

This step will create a Configuration Feature Model so that we can adjust the Log settings of Sling's
main log (error.log).
**Note**: this can be applied to any configuration inside the Sling12 Feature Model file.

Create a Configuration Feature Model file:
1. Create a file called **feature-config-sling12.json** (name does not matter)
2. Add the content from below
3. Save it

Feature Model Config file:

    {
        "id":"org.apache.sling:config.local:slingosgifeature:sling12-config:0.0.1-SNAPSHOT",
        "configurations":  {
            "org.apache.sling.commons.log.LogManager":    {
                "org.apache.sling.commons.log.level":"debug",
                "org.apache.sling.commons.log.file":"logs/test2.log"
            }
        }
    }

**Note**: this will only have the properties that we want to change. To remove a property from the
Sling Feature Model then add the entire configuration (copy it from the Sling Feature Model file)
and then use the option **USE_FIRST** instead of **MERGE_FIRST** in the **-CC** option.

### Step 4: Launch Sling

Execute 

    java \
        -Dorg.osgi.service.http.port=8170 \
        -Dorg.apache.felix.http.host=localhost \
        -cp org.apache.sling.feature.extension.content-1.0.6.jar
        -jar org.apache.sling.feature.launcher-1.1.4.jar \
        -f feature-config-sling12.json \
        -f feature-sling12.json \
        -CC "org.apache.sling.commons.log.LogManager=MERGE_FIRST" \
        -c artifacts


This will bring up Sling on port 8170 just fine with the adjusted Sling logging.

![Feature Launcher Sling Home](sling.home.feature.launcher.png)

Adjusted Logging:

![Adjusted Sling Feature Logging](sling-ajusted-logging.png)

## Mission Accomplished

* Next Up: [Custom Feature Project with Sling](/documentation/feature-model/howtos/sling-with-custom-project.html)
* Back To: [Feature Model Home](/documentation/feature-model/feature-model-overview.html)

## Addendum

### Configuration Class Overrides

The [Feature Launcher](https://github.com/apache/sling-org-apache-sling-feature-launcher) requires
the user to define Configuration Class Overrides if provided Feature Models' Configuration contain
conflicting configurations.
The caller must provide it with the **-CC** option with a key-value pair separted by an
equal sign. These are examples:

* Merge Log Manager and take the first configuration:
    * org.apache.sling.commons.log.LogManager=MERGE_FIRST
* Merge any configuration under 'org.apache.sling.commons.log' and take the last
    * org.apache.sling.commons.log.*=MERGE_LATEST
* Take the first configuration of any file
    * *=USE_FIRST

These are the available actions:

* PROPERTY_CLASH: if conflicting then fail
* USE_FIRST: use first provided configuration
* USE_LATEST: use the last configuration
* MERGE_FIRST: merge first provided configuration (whatever is not provided is taken from the later) 
* MERGE_LATEST: merge last provided configuration (whatever is not provided is taken from the former)

These are the available configuration pattern:

* fully qualified path: applies on to the configuration with that path
* prefix ending in a *: applies to all configurations with the given prefix
* *: all configurations
