title=How to Start Sling with the Kickstarter
type=page
status=published
tags=feature model,sling,kickstarter
~~~~~~

### About this How-To

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00;">

#### What we'll explore: 

* We'll start Sling with the Kickstart Launcher (a.k.a the kickstarter) and explore the Feature Model

#### What you should know: 

* Skill Level: Beginner
* Environment: Windows/Unix
* Time: 20 minutes

</div>

Back To: [Feature Model Home](/documentation/feature-model/feature-model-overview.html)

### Prerequisites

In order to follow this how-to you'll need the following on your computer:

* Java 8
* Bash shell

### What's the Kickstarter

Prior to the Kickstarter, the Sling application was assembled into an uber JAR using the Provisioning Model. 
The JAR file was fairly large in size and weighed in at ~70MB. If the Sling application required a new bundle,
the uber JAR would have to be rebuilt. The Kickstarter was designed to solve this problem as well as streamline
the application packaging process.

The Kickstarter provides a method to start Sling using a new application packaging/assembly approach known as
the _Feature Model_.  By default, the Kickstarter is configured with a minimum set of feature definitions to 
produce a lightweight Sling application.  If additional customization is required, simply 
define additional features based on your requirements. Any additional features will then be pulled from a Maven repository.

### How does the Kickstarter work

The [Kickstarter](https://github.com/apache/sling-org-apache-sling-kickstart) uses the Feature Model Launcher to 
start a Sling instance. It sets up a control port to manage the instance and provides default values to start Sling.
The Feature Launcher then downloads the necessary dependencies and installs them into the OSGi container. 

Let's try this out!

### Step 1: Download the Kickstarter 

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00;">

At the time of this writing, the latest Kickstarter version was `0.0.2`. Adjust the commands below to reflect the 
version you downloaded.

</div>

Visit the [Apache Sling Downloads](https://sling.apache.org/downloads.cgi) page and download the _Kickstart Project_
bundle. 

Then, create a working directory for the Kickstarter and copy the bundle to this location. You can name this 
directory anything you like.

    $ mkdir kickstarter
    $ cd kickstarter
    $ cp /some/download/path/org.apache.sling.kickstart-0.0.2.jar .

### Step 2: Start Sling with the Kickstarter

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00;">

 Make sure nothing is listening on port 8080 as this port will be used by Sling.

</div> 

Run the Kickstarter to start Sling.

    $ java -jar org.apache.sling.kickstart-0.0.2.jar

Next, open a browser and visit [http://localhost:8080/](http://localhost:8080/).

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00; margin-bottom: 1em;">

* The Kickstarter will take some time to start the first time since the Feature Model needs to populate your local
  Maven repository with any missing artifacts. 
* If you run into any issues, try re-running the Kickstarter with the `-v` option.

</div>

### Step 3: Start using Sling

Click the **Login** link and log in with **admin/admin**. 


### Step 4: Check the status of Sling

Open a new terminal window and navigate to the same Kickstarter working directory that
was used to start Sling.

Now, run the Kickstarter JAR again with the `status` command to view the current
status of your Sling instance.

    $ java -jar org.apache.sling.kickstart-0.0.2.jar status


If your Sling instance is running, you should see output similar to this:

    /127.0.0.1:52516>status
    /127.0.0.1:52516<OK
    Sent 'status' to /127.0.0.1:52481: OK
    Terminate VM, status: 0

If your sling instance is not running, you should see:

    No Apache Sling running at /127.0.0.1:52244
    Terminate VM, status: 3

### Step 5: Stop Sling with the Kickstater

Run the Kickstarter JAR again and specify the `stop` command.

    $ java -jar org.apache.sling.kickstart-0.0.2.jar stop

Alternatively, you can stop Sling by hitting `<CTRL+C>`.

## Mission Accomplished


<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00; margin-bottom: 1em;">

#### What we learned: 

* We successfully started Sling with the Kickstarter and had our first
  glimpse of the Feature Model.

</div>

Did we succeed in making you more curious about the world of Feature Models? 
If you stay with us, you'll learn how to customize Sling by creating your own
Feature Models.

If you still want to learn a bit more about the Kickstarter, stay on this page
and keep reading.

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00; margin-bottom: 1em;">

* Next Up: [How to Create a Custom Feature Model Project](/documentation/feature-model/howtos/sling-with-custom-project.html)
* Back To: [Feature Model Home](/documentation/feature-model/feature-model-overview.html)

</div>

## A couple additional things to explore

### Kickstarter commands and options

The generalized command for the Kickstarter is as follows:

    $ java -jar <jarfile> [options] [command]

It supports three commands: `stop`, `start` and `status` as well as a number of options. For 
a full list of available options, run the Kickstarter with the `-h` option.


| Short Option  | Long Option                                   | Description                                                                  |
| ------------- | --------------------------------------------- | ---------------------------------------------------------------------------- |
| -a            | --address=&lt;address&gt;                     | Address to bind to (default `0.0.0.0`).                                      |
| -af           | --additionalFeature=&lt;additionalFeature&gt; | Define additional feature files. Use multiple options for multiple features. |
| -c            | --slingHome=&lt;slingHome&gt;                 | Sling context directory (default `sling`).                                   |
| -D            | --define=&lt;key=value&gt;                    | Sets property key to value. This is different than the `-D` JVM option. This must come after the jar filename. |
| -f            | --logFile=&lt;logFile&gt;                     | Log file or "-" for stdout (default `logs/error.log`).                       |
| -h            | --help                                        | Display usage.                                                               |
| -i            | --launcherHome=&lt;launcherHome&gt;           | Launcher home directory (default `launcher`).                                |
| -j            | --control=&lt;controlAddress&gt;              | Host and port to use for control connection. Format `[host:]port`.            
| -l            | --logLevel=&lt;logLevel&gt;                   | Initial log level (0..4, FATAL, ERROR, WARN, INFO, DEBUG).                    |
| -n            | --noShutdownHook                              | Don't install the shutdown hook.                                             |
| -p            | --port=&lt;port&gt;                           | Port to listen to (default `8080`).                                          |
| -r            | --context=&lt;contextPath&gt;                 | Root servlet context path for the HTTP service (default `/`).                |
| -s            | --mainFeature=&lt;mainFeatureFile&gt;         | Main feature file (file path or URL). This will replace the default file used by Sling. |
| -v            | --verbose                                     | Start the launcher with additional information.                              |


<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00; margin-bottom: 1em;">

For compatibility, most of the options are the same as the 
[Sling Starter](https://github.com/apache/sling-org-apache-sling-starter)  project. The
options below are specific to the Kickstarter. 

* `-s`: Replaces the main default Sling feature with your own Feature Model. 
* `-af`: Defines additional Feature Models (use multiple `-af` options for multiple features).

</div>

### Start Sling using --mainFeature

The real power of the Kickstarter can be seen when you specify your own Feature Model. As an example,
let's re-run the Kickstarter and specify an external Feature Model.

We'll start by moving into our `kickstarter` workspace. Then, we'll Stop Sling if it's still running. 
Next, remove the old `conf` and `launcher` directories so that we can start a clean Sling instance.
Extract the Sling 12 Feature Model file from the Kickstarter JAR. Lastly, start Sling using the Feature Model 
JSON file.

    $ cd kickstarter
    $ java -jar org.apache.sling.kickstart-0.0.2.jar stop
    $ rm -rf conf launcher
    $ jar -xf org.apache.sling.kickstart-0.0.2.jar feature-sling12.json
    $ java -jar org.apache.sling.kickstart-0.0.2.jar --mainFeature=feature-sling12.json

If you're curious, take a peak at the Feature Model for Sling 12 by opening `feature-sling12.json` in
your favorite editor.

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00; margin-bottom: 1em;">

* Next Up: [How to Create a Custom Feature Model Project](/documentation/feature-model/howtos/sling-with-custom-project.html)
* Back To: [Feature Model Home](/documentation/feature-model/feature-model-overview.html)

</div>
