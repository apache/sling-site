title=Getting Started		
type=page
status=published
tags=tutorials
~~~~~~

# Run the Sling Application

There are different ways to get Apache Sling running. You can either use Docker, download a
 distribution or build it from source.

## Sling Docker Image

The easiest way to get Apache Sling running is to use Docker. If you don't have Docker installed
 you can skip to the next section.

We maintain a docker image of our latest release at [Apache Sling Docker Image](https://hub.docker.com/r/apachesling/sling).
 
The simplest command to launch Sling is:


    docker run -p 8080:8080 apachesling/sling

This will start the latest Apache Sling distribution.

## Sling Download

The other option is to download the latest released Apache Sling standalone application from our
 [Downloads](/downloads.cgi) section. Once you have downloaded the application make sure that you have
 Java 8 or later installed and run Sling with (replace the N with the latest version number before
 executing the command):
 
    
    java -jar org.apache.sling.launchpad-N.jar
    
# Explore Sling

Once Sling is started, you can access Sling at [http://localhost:8080](http://localhost:8080).
 Starting Sling might take some seconds, so if you get an error in your browser that some
 service is missing, simply reload the page a little bit later.


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
