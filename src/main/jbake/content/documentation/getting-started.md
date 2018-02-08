title=Getting Started		
type=page
status=published
tags=tutorials
expandVariables=true
~~~~~~

# Run the Sling Application

There are different ways to get Apache Sling running. You can either use Docker, download a
 distribution or build it from source.

## Sling Docker Image

The easiest way to get Apache Sling running is to use Docker. If you don't have Docker installed
 you can skip to the next section.

We maintain a docker image of our latest release at [Apache Sling Docker Image](https://hub.docker.com/r/apache/sling).
 
The simplest command to launch Sling is:


    docker run -p 8080:8080 -v /tmp/sling:/opt/sling/sling apache/sling

This will start the latest Apache Sling distribution and mount the Sling directory to */tmp/sling*
 on your machine. Make sure that your docker configuration allows this or change to a different
 directory.

## Sling Download

Another option is to download the latest released Apache Sling standalone application from our
 [Downloads](/downloads.cgi) section. Once you have downloaded the application make sure that you have
 Java ${sling_minJavaVersion} or later installed and run Sling with:
 
    
    java -jar org.apache.sling.starter-${sling_releaseVersion}.jar

Starting the Sling application creates the Sling directory name *sling* in the same directory
 from where you started the above command.

## Sling Karaf

You can run Sling on [Karaf](https://karaf.apache.org) as well by either starting a [Sling Karaf Distribution](karaf.html#sling-karaf-distribution) or installing [Sling's Karaf Features](karaf.html#sling-karaf-features) into a running Karaf Container.

# Explore Sling

Once Sling is started, you can access Sling at [http://localhost:8080](http://localhost:8080).
 Starting Sling might take some seconds, so if you get an error in your browser that some
 service is missing, simply reload the page a little bit later.

The Sling directory contains a directory *logs*. This directory contains all the log files
 created by Sling. The main log file is called *error.log*.

# Where to head from here

We're on the way to update the documentation to make it more easy to get in touch with Sling.
We recommend you read through following topics to get as fast as possible into Sling: 

* [Getting and building Sling](/documentation/development/getting-and-building-sling.html)
* [Discover Sling in 15 minutes](getting-started/discover-sling-in-15-minutes.html)
* [Architecture](/documentation/the-sling-engine/architecture.html)
* [Dispatching Requests](/documentation/the-sling-engine/dispatching-requests.html)
* [Resources](/documentation/the-sling-engine/resources.html)
* [Sling IDE Tooling](/documentation/development/ide-tooling.html)
* [Manipulating Content - The SlingPostServlet (servlets.post)](/documentation/bundles/manipulating-content-the-slingpostservlet-servlets-post.html)
* [Request Parameters](/documentation/the-sling-engine/request-parameters.html)
* [Authentication](/documentation/the-sling-engine/authentication.html)
* [Eventing and Jobs](/documentation/bundles/apache-sling-eventing-and-job-handling.html)
