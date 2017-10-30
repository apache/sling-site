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

Rather than performing a full build of Sling, which can take 5-10 minutes on a recent computer once your local Maven
repository is up to date, it's recommended to build only the launchpad and the modules you're interested in.

## tl:dr - Short form build + run instructions 

**TODO This needs to be updated due to our move to Git, please ask on our dev list if unsure**

If you already have the required svn (or Git, see below) client, JDK and Maven installed, here's the short form recipe:

    $ svn co http://svn.apache.org/repos/asf/sling/trunk sling 
    $ cd sling  # you are now in the Sling SVN checkout
    $ cd launchpad/builder
    $ mvn --update-snapshots clean install
    $ export DBG="-Xmx384M -agentlib:jdwp..." # (see below)
    $ java $DBG -jar target/org.apache.sling.launchpad... # (see below)
    
With this, Sling should be running at http://localhost:8080 with remote debugging active as per the $DBG variable.

## Prerequisites

Before you begin, you need to have the following tools installed on your system:

* Java 8 or higher
* [Maven](http://maven.apache.org) 3.3.9 or later; enforced by the Sling parent pom

If you want to set up Eclipse (not required to build Sling) you'll also need the following installed:

* Eclipse (tested with 3.4.2 and 3.5.x on Win XP, SP3, 3.6.x on Win7, 3.7 on MacOS X 10.6); just a plain installation of the platform runtime binary and the JDT will be adequate (you can install the IDE for Java Developers for convenience) 
* M2Eclipse plugin for Eclipse (sonatype) \-> [instructions](http://m2eclipse.sonatype.org/installing-m2eclipse.html)
* [Subversive plugin](http://www.polarion.com/products/svn/subversive.php) or [Subclipse-plugin](http://subclipse.tigris.org) for Eclipse

## Environment Setup

The full build process requires quite a lot of resources, so you may run into limits. The following hints should show you what to setup before building Sling.

### Environment Variable Space

* *Problem* \- Build aborts when trying to launch the integration tests with the message

    [INFO] Error while executing forked tests.; nested exception is org.apache.maven.surefire.booter.shade.org.codehaus.plexus.util.cli.CommandLineException: Error setting up environmental variables
    
    error=12, Not enough space

This problem is caused by insufficient swap space. When running the integration tests in the `launchpad/testing` modules, a process is launched by calling the `exec` system call. This copies the process (copy-on-write, though) and thus allocates as much virtual memory as is owned by the parent process. This may fail if swap space is exhausted.

* *Platform* \- OpenSolaris
* *Fix* \- If this issue persists you will need to check your system requirements and configuration with regard to swap, before taking action - if necessary.

## Configuring Maven

See [MavenTipsAndTricks](/documentation/development/maventipsandtricks.html).

## Getting the Sling Source

### From the Apache Sling Subversion repository

0. Install an svn client if needed.

1. Checkout Sling from the Subversion repository

    $ svn checkout http://svn.apache.org/repos/asf/sling/trunk sling

### From the Sling GitHub mirror

0. Install a Git client if needed

1. Checkout Sling from the GitHub mirror

    $ git clone https://github.com/apache/sling.git

### With Eclipse Subversive or Subclipse
First note how simple the above SVN instructions are...but if you *really* want to do this, read on.

If you use the Subversive plugin make sure you have installed the "Subversive Integration for M2Eclipse Project" which can be found under the following Eclipse update site: [http://community.polarion.com/projects/subversive/download/integrations/update-site/](http://community.polarion.com/projects/subversive/download/integrations/update-site/).

Also, make sure that you have installed either the "Maven SCM handler for Subclipse" or the "Maven SCM handler for Subversive".

#### Create a new workspace

It's best to create a new workspace for the sling project:

 1. List item
 1. Menu: File->Switch Workspace->Other...
 1. Enter a path for the new workspace and click OK
 1. When Eclipse has restarted it's time to adjust some configs
 1. Turn off automatic build (Menu: Project->Build Automatically)
 1. Go to menu: Eclipse->Preferences, in the preferences dialog select Java \-> Compiler \-> Errors/Warnings
 1. Expand the "Deprecated and restricted API" and change "Forbidden references (access rules)" from "Error" to "Warning"
 1. Click OK

#### Checkout the Sling source

1. Menu: File->Import
1. In the Import wizard select Maven->"Check out Maven Projects from SCM"
1. Click next
1. In the "SCM URL" field pick "SVN" and enter the url "http://svn.apache.org/repos/asf/sling/trunk"
1. Click Finish

Eclipse will now start to download the source and import the Maven projects. You might encounter some "Problem Occured" dialogs about "An internal error...", but just click OK on those and let Eclipse continue with the import. Be warned: This could take some time (it was 30 minutes on my laptop)\!

Possibly something in sling-builder might get a bit messed up (I didn't experience that problem, but Pontus reported it) then you can simply fix it with revert:

1. In the Project Explorer right-click on the "sling-builder" project and select the Team->Revert... menu
1. A couple of changes will be displayed
1. Click OK

## Building Sling

Note that while it's possible to build the full Sling reactor, using the pom.xml file in the root of the SVN checkout, this should
rarely be needed and it's almost always too slow to consider. Instead, it's recommended to build the Sling launchpad and the module
you're working on at the moment.

### With the Maven command line tool

1. Enter the directory, then do a build and local install of the launchpad (below are unix/linux commands, slightly different under windows)

        $ cd sling
        $ cd launchpad/builder # you are now in the Sling SVN checkout
        $ mvn --update-snapshots clean install
        $ java -jar target/org.apache.sling.launchpad-*.jar -c test -f -

<div class="note">
When starting Sling inside the `launchpad/builder` folder you should not use the default Sling Home folder name `sling` because this folder is removed when running `mvn clean`.
</div>

Messages should now be printed to the console which is being used as the "log file";
 
* the `-f` command line option is set to `-`, indicating the use of standard output as the log file. 
* the `-c sling` command line option instructs Sling to use the `sling` directory in the current directory for its data store, which is the Apache Felix bundle archive, the Jackrabbit repository data and configuration. You may also specify another directory here, either a relative or absolute path name (See also [Configuration](/documentation/configuration.html) for more information). 
* Use the `-h` option to see the list of flags and options.

After all messages have been printed you should be able to open the Sling Management Console by pointing your web browser at [http://localhost:8080/system/console](http://localhost:8080/system/console). You will be prompted for a user name and password. Enter `admin` for both the user name and the password (this may be set on the *Configuration* page later). From this console, you can manage the installed bundles, modify configuration objects, dump a configuration status and see some system information.

To stop Sling, just hit `Ctrl-C` in the console or click the *Stop* button on the *System Information* page of the Sling Management Console.

2. Enter the directory of the bundle you're working on, then do a build and deploy the bundle to the running launchpad instance

        $ cd sling
        $ cd bundles/servlets/get
        $ mvn clean install sling:install

The Maven build command ensure that:

* the bundle is installed in the local repository so future builds of the launchpad module will pick it up ( `install` goal )
* the bundle is deployed in the running launchpad instance ( `sling:install` goal )

### With M2Eclipse

1. Make sure you're in the Java perspective (Menu: Window->Open Perspective)
1. Menu: Run->Run Configurations...
1. In the Run Configurationa dialog right-click on "Maven Build" and select "New"
1. Change Name to "Build Sling"
1. Click "Browse Workspace..." and select "sling-builder"
1. Enter "clean install" in Goals
1. Click on the JRE tab
1. Enter "-Xmx256m \-XX:MaxPermSize=128m" in "VM arguments"
1. Click Apply
1. Click Run

### Alternative setup in Eclipse without M2Eclipse plugin

In the case that you do not want to use the M2Eclipse plugin there's another setup that lets you have the automatic build turned on:

1. Checkout the whole sling trunk (with subversive or the subclipse plugin) from SVN to a single project
1. Then manually add all `src/main/java` and `src/test/java` of the bundles to the project as source folders
1. Add all required libraries to the build path
1. Now you can build either in Eclipse or even better use "mvn clean install" on the command line

If you use "mvn clean install" to build Sling be sure you have set MAVEN_OPTS to "-Xmx384m \-XX:PermSize=256m" otherwise you will probably get OutOfmemory errors.

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
