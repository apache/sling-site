title=Getting and Building Sling		
type=page
status=published
excerpt=A quick guide for getting the Sling source, then building and running the resulting Sling instance; either without or with Eclipse.
tags=development
~~~~~~

A quick guide for getting the Sling source, then building and running the resulting Sling instance; either without or with Eclipse.

Note that you don't *have* to build Sling yourself, if you don't need the bleeding-edge stuff you can get prebuilt 
binaries from the [Downloads](/downloads.cgi) page. But those, especially the launchpad runnable jar, are not released often
and can be outdated. In case of doubt, build it yourself as shown below or ask on the Sling users mailing list.

Note that building the Sling starter application does not rebuild all of the modules contained in it. If you want to
work on a certain module, you should rebuild it separately.

## tl:dr - Short form build + run instructions 
If you already have the required Git client, JDK and Maven installed, here's the short form recipe:

    $ git clone https://github.com/apache/sling-org-apache-sling-starter.git
    $ cd sling-org-apache-sling-starter
    $ mvn --update-snapshots clean install
    $ export DBG="-Xmx384M -agentlib:jdwp..." # (see below)
    $ java $DBG -jar target/org.apache.sling.launchpad... # (see below)
    
With this, Sling should be running at http://localhost:8080 with remote debugging active as per the $DBG variable.

## Prerequisites

Before you begin, you need to have the following tools installed on your system:

* Java 8 or higher
* [Maven](http://maven.apache.org) 3.3.9 or later; enforced by the Sling parent pom

If you want to set up an IDE any recent version of a Java IDE with Maven support
will do just fine. If you're using Eclipse, you can install the
[/documentation/development/ide-tooling.html](Sling IDE tooling) for some extra
niceties, but it's not required in any way.

## Configuring Maven

See [MavenTipsAndTricks](/documentation/development/maventipsandtricks.html).

## Getting the Sling Source

The Sling source code is managed in Git using the Apache Gitbox tools: Git repositories are mirrored from GitHub to the canonical
Apache Git repositories. In practice, one can work on GitHub and the replication to the Apache repositories is transparent.

The [complete list of modules](/repolist.html) can be used to clone individual modules, but we provide a more convenient
way of checking out all of the source modules that are used in Sling. Since that's over 2^<super>8</super> repositories,
it's based on additional tooling:

1. Install a git client if needed and the [Google Repo](https://android.googlesource.com/tools/repo) tool.

2. Check out a new repo workspace

        $ repo init --no-clone-bundle -u https://github.com/apache/sling-aggregator.git
        $ repo sync -j 16 --no-clone-bundle

3. In your IDE, import the projects you're interested in from the repo workspace.

## Building Sling

We don't yet offer a way of building all the Sling modules using a single
command, but that should not be usually needed. To build any Sling module, just
enter the local directory and execute

    $ mvn --update-snapshots clean install

Some modules may have specific build instructions, see the `README.md` file for
each module.

## Running Sling

The Sling project produces an executable jar with the `org-apache-sling-starter`
module. After building the module, you can execute

    $ java -jar target/org.apache.sling.starter-*.jar

to start it up.

<div class="note">
When starting Sling inside the org-apache-sling-starter module you should not use the default Sling Home folder name sling because this folder is removed when running mvn clean.
</div>

Messages should now be printed to the console which is being used as the "log file";
 
* the `-f` command line option is set to `-`, indicating the use of standard output as the log file. 
* the `-c sling` command line option instructs Sling to use the `sling` directory in the current directory for its data store, which is the Apache Felix bundle archive, the Jackrabbit repository data and configuration. You may also specify another directory here, either a relative or absolute path name (See also [Configuration](/documentation/configuration.html) for more information). 
* Use the `-h` option to see the list of flags and options.

After all messages have been printed you should be able to open the Sling Management Console by pointing your web browser at [http://localhost:8080/system/console](http://localhost:8080/system/console). You will be prompted for a user name and password. Enter `admin` for both the user name and the password (this may be set on the *Configuration* page later). From this console, you can manage the installed bundles, modify configuration objects, dump a configuration status and see some system information.

To stop Sling, just hit `Ctrl-C` in the console or click the *Stop* button on the *System Information* page of the Sling Management Console.

## Making and deploying changes

Enter the module of the bundle you're working on, then do a build and deploy the bundle to the running launchpad instance

        $ cd org-apache-sling-servlets-get
        $ mvn clean install sling:install

The Maven build command ensure that:

* the bundle is installed in the local repository so future builds of the launchpad module will pick it up ( `install` goal )
* the bundle is deployed in the running launchpad instance ( `sling:install` goal )

Congratulations \! You should now have a running Sling instance, that you can start playing around with.

## Further Tips and Tricks

### Debug Sling in Eclipse

You can use remote debugging to debug Sling in Eclipse, here's a little How-To

1. start Sling from the command line with (replace N with the actual version before running the command)
 
    java -Xmx384M -agentlib:jdwp=transport=dt_socket,address=30303,server=y,suspend=n -jar org.apache.sling.launchpad-N.jar

1. Open Menu Run-> Debug configurations
1. Right-click on "Remote Java Applications"
1. Choose "New"
1. In the "Connect" tab choose the Eclipse Sling Project for the field "Project" with the browse button
1. Let the Connection type be "Standard (Socket Attach)"
1. The host should be localhost
1. Set the Port to 30303
1. On the source tab click the "Add" button
1. Select "Java Project"
1. Select all Sling projects and click OK
1. Click "Debug"

Now you should be able to set breakpoints, evaluate properties, and so on as usual.

### Debug Maven Tests in Eclipse

In the same way as you can debug the sling app, you are also able to debug a maven test. Just run the maven tests like this

    mvn -Dmaven.surefire.debug test


The tests will automatically pause and await a remote debugger on port 5005. You can then attach to the running tests using Eclipse. You can setup a "Remote Java Application" launch configuration via the menu command "Run" > "Open Debug Dialog..." (see above).
For more information on this see the [Maven Surefire Docu](http://maven.apache.org/plugins/maven-surefire-plugin/examples/debugging.html).


### Simple way to develop new bundle in Eclipse for Sling

The easiest way that I found is to create a new folder in the existing Eclipse workspace. After that you can follow these steps:

* Start by copying and adapting an existing Sling pom.xml (eg. the pom.xml from the espblog sample)
* Generate the Eclipse project files using mvn eclipse:eclipse
* Choose File/Import in Eclipse and select "Existing projects into workspace"
* Now you can create, edit and compile the files in Eclipse
* To create the bundle jar and install it, just use the command line "mvn clean install" in the project directory
* If you have a running Sling app you can install the bundle from the command line with "mvn \-P autoInstallBundle clean install \-Dsling.url=http://localhost:8080/system/console"

If adding dependencies to the poms, run mvn eclipse:eclipse again and refresh the project in Eclipse. Debugging works as described above.
