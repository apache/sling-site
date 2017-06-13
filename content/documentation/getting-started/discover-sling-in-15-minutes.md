Title=TODO add front matter 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: Discover Sling in 15 minutes

The Sling Launchpad is a ready-to-run Sling configuration, providing an embedded JCR content repository and web server, a selection of Sling components, documentation and examples. The Launchpad makes it easy to get started with Sling and to develop script-based applications.

This page will help you get started with the Launchpad. Fifteen minutes should be enough to get an overview of what Sling does.

While simple to run and understand, the Launchpad is a full-featured instance of Sling, an example configuration that we have created with the most common modules and configurations. The full functionality of Sling is available by loading additional Sling (or custom) OSGi bundles as needed, using the Launchpad's web-based OSGi management console.

[TOC]

## See Also


More Sling samples can be found under 
[http://svn.apache.org/repos/asf/sling/trunk/samples/](http://svn.apache.org/repos/asf/sling/trunk/samples/)

Once you grok the basic examples of this page, we recommend studying the 
*slingbucks* and *espblog* samples. Both have README files with more info.

## Prerequisites

We'll start with the self-runnable jar from the Sling distribution, you only need a Java 7 JDK. Download the latest release from the Sling [Downloads](/downloads.cgi) page or by clicking this link: [org.apache.sling.launchpad-8.jar](http://www.apache.org/dyn/closer.lua/sling/org.apache.sling.launchpad-8.jar). Alternatively you can deploy the [Sling Web application](http://www.apache.org/dyn/closer.lua/sling/org.apache.sling.launchpad-8-webapp.war) into any decent Servlet Container such as Jetty or Tomcat or you can [build the current source yourself]({{ refs.getting-and-building-sling.path }}).

To show the simplicity of the REST-style approach taken by Sling the examples below will be using [cURL](http://curl.haxx.se/). Any HTTP client would do, but cURL is the easiest to document in a reproducible way.

A WebDAV client makes editing server-side scripts much more convenient, but to make our examples easy to reproduce, we're using cURL below to create and update files in the JCR repository, via the Sling WebDAV server.


## Start the Launchpad

After downloading the Sling Launchpad self-runnable jar just start it as follows:


    $ java -jar org.apache.sling.launchpad-8.jar


This starts the Sling embedded Web Server on port 8080 and writes application files into the `sling` folder found in the current working directory.

Once started, look at [http://localhost:8080/system/console/bundles](http://localhost:8080/system/console/bundles) with your browser. Use *admin* with password *admin* if Sling asks you for a login. Sling then displays the *Felix Web Management Console* page.


On the bundles page, all bundles should be marked *Active*. They're all [OSGi](http://www.osgi.org/) bundles powered by [Apache Felix](http://felix.apache.org), but that doesn't really matter to us right now.

*Log files: If things go wrong, have a look at the `sling/logs/error.log` log file \- that's where Sling writes any error messages.*

## Create some content

Until we have ready-to-test forms, you can create content with cURL, or you can create an HTML form that posts to the specified URL.

To create a content node (nodes are a [JCR](http://jackrabbit.apache.org/) concept, a unit of storage) with cURL, use:


    curl -u admin:admin -F"sling:resourceType=foo/bar" -F"title=some title" http://localhost:8080/content/mynode


The resulting node can be seen at [http://localhost:8080/content/mynode.html](http://localhost:8080/content/mynode.html.path), or as json format under [http://localhost:8080/content/mynode.json](http://localhost:8080/content/mynode.json). Lets try with cURL:

    $ curl http://localhost:8080/content/mynode.json

This returns the properties of the `/content/mynode` in JSON format as we have created it above. 

    {"title":"some title","sling:resourceType":"foo/bar","jcr:primaryType":"nt:unstructured"}

The additional property `jcr:primaryType` is a special JCR property added by the content repository, indicating the JCR primary node type.

*Monitoring requests: Sling provides a simple tool (an OSGi console plugin) to monitor HTTP requests, which helps understand how things work internally. See the [Monitoring Requests]({{ refs.monitoring-requests.path }}) page for details.*

## Render your content using server-side javascript (ESP)

Sling uses scripts or servlets to render and process content.

Several scripting languages are available as additional Sling modules (packaged as OSGi *bundles* that can be installed via the Sling management console), but the launchpad currently includes the ESP (server-side ECMAscript), JSP (Java Server Pages), and Groovy language modules by default.

To select a script, Sling uses the node's *sling:resourceType* property, if it is set.

That is the case in our example, so the following script will be used by Sling to render the node in HTML, if the script is found at */apps/foo/bar/html.esp* in the repository.

    <html>
      <body>
        <h1><%= currentNode.title %></h1>
      </body>
    </html>


To select the script, Sling:

* looks under */apps*
* and appends the *sling:resourceType* value of our node ( which is *foo/bar* ) 
* and appends *html.esp*, as the extension of our URL is *html* and the language of our script is *esp*.

Store this script under */apps/foo/bar/html.esp*, either using a WebDAV client (connected to [http://admin:admin@localhost:8080/](http://admin:admin@localhost:8080/)), or using cURL as shown here, after creating the *html.esp* script in the current directory on your system:


    curl -X MKCOL -u admin:admin http://localhost:8080/apps/foo
    curl -X MKCOL -u admin:admin http://localhost:8080/apps/foo/bar


create a local file *html.esp* and copy above content.


    curl -u admin:admin -T html.esp http://localhost:8080/apps/foo/bar/html.esp


The HTML rendering of your node, at [http://localhost:8080/content/mynode.html](http://localhost:8080/content/mynode.html), is now created by this ESP script. You should see the node's title alone as an &lt;h1&gt; element in that page.

A script named *POST.esp* instead of *html.esp* would be called for a POST request, *DELETE.esp* for DELETE, *xml.esp* for a GET request with a *.xml* extension, etc. See [URL to Script Resolution]({{ refs.url-to-script-resolution.path }}) on the Sling wiki for more info.

Servlets can also be easily "wired" to handle specific resource types, extensions, etc., in the simplest case by using SCR annotations in the servlet source code. Servlets and scripts are interchangeable when it comes to processing Sling requests.


## What next?

These simple examples show how Sling uses scripts to work with JCR data, based 
on *sling:resourceType* or node types.

There's much more to Sling of course - you'll find some additional simple examples below, as
well as above in the *see also* section.

## Additional examples

### Let Sling generate the path of a newly created node.

To create a node with a unique path at a given location, end the URL of the POST request with */*.

In this case, the Sling response redirects to the URL of the created node.

Start by creating a new */blog* folder:


    curl -X POST -u admin:admin "http://localhost:8080/content/blog"


And create a node with a Sling-generated name under it:


    curl -D - -u admin:admin -F"title=Adventures with Sling" "http://localhost:8080/content/blog/"


Using cURL's *-D* option shows the full HTTP response, which includes a *Location* header to indicate where the new node was created:


    Location: /blog/adventures_with_slin


The actual node name might not be *adventures_with_slin* - depending on existing content in your repository, Sling will find a unique name for this new node, based on several well-know property values like title, description, etc. which are used for this if provided.

So, in our case, our new node can be displayed in HTML via the [http://localhost:8080/blog/adventures_with_slin.html](http://localhost:8080/blog/adventures*with*slin.html) URL.

Note that we didn't set a *sling:resourceType* property on our node, so if you want to render that node with a script, you'll have to store the script under */apps/nt/unstructured/html.esp*.


### Add a page header with sling.include

The *sling.include* function can be called from scripts to include the rendered result of another node.

In this example, we create a node at */content/header*, rendered with a logo using an *html.esp* script, then use that header at the top of the *html.esp* script that we created previously for the *foo/bar* resource type.

Start by checking that [http://localhost:8080/content/mynode.html](http://localhost:8080/content/mynode.html) is rendered using the *html.esp* script created above.

Create this script and name it *header.esp*:

    <div>
      <p style="color:blue;">
        <img src="/images/sling.jpg" align="right"/>
        <%= currentNode.headline %>
      </p>
    </div>


Upload it so that it is used to render resources having *sling:resourceType=foo/header*:


    curl -X MKCOL -u admin:admin http://localhost:8080/apps/foo/header/
    curl -u admin:admin -T header.esp http://localhost:8080/apps/foo/header/html.esp


Create the header node:


    curl -u admin:admin -F"sling:resourceType=foo/header" -F"headline=Hello, Sling world" http://localhost:8080/content/header


Upload the logo that the script uses (using sling.jpg or another logo in the current directory):


    curl -X MKCOL -u admin:admin http://localhost:8080/images/
    curl -u admin:admin -T sling.jpg http://localhost:8080/images/sling.jpg


And check that the header is rendered with the logo at [http://localhost:8080/content/header.html](http://localhost:8080/content/header.html).

Now, update the html.esp script that we created for our first example above, to include the header:

    <html>
      <body>
        <div id="header">
          <% sling.include("/content/header"); %>
        </div>
        <h1><%= currentNode.title %></h1>
      </body>
    </html>


And upload it again to replace the previous version:


    curl -u admin:admin -T html.esp http://localhost:8080/apps/foo/bar/html.esp


The [http://localhost:8080/content/mynode.html](http://localhost:8080/content/mynode.html), once refreshed, now shows the blue headline and logo, and this layout also applies to any node created with *sling:resourceType=foo/bar*.
