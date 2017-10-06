title=Apache Sling - Bringing Back the Fun!		
type=page
status=published
tags=community
expandVariables=true
~~~~~~

**Apache Sling&trade;** - ${sling_tagline}

# Apache Sling in four bullets points

* ReST based web framework
* Content-driven, using a hierarchical content tree
* Modular design
* Scripting inside

# Getting started

If you prefer doing rather than reading, please proceed to the [Getting Started](/documentation/getting-started.html)
 section, where you can quickly get started on your own instance of Sling.

Discussions about Sling happen on our mailing lists, see the [Project Information](/project-information.html)
 page for more info.

# Apache Sling in a hundred words

Apache Sling is a web framework that uses a resource oriented architecture. The content is
 stored in a hierarchical resource tree which is mapped to the URL space of the web 
 application.

Sling applications use either scripts or Java servlets, selected based on
simple name conventions, to process HTTP requests in a RESTful way.

The runtime environment is modular and dynamic allowing to select only the required modules
 to run your Sling application. This provides a flexible extension mechanism where modules
 easily can be loaded, unloaded and reconfigured

Sling makes it very simple to implement simple applications, while providing an 
 enterprise-level framework for more complex applications. 

## News

<ul id="newsExcerpt">
</ul>


Refer to the news [archive](/news.html) for all news.


## References


#### Apache Jackrabbit

The main purpose of Sling is to develop a content-centric Web Application
framework for Java Content Repository (JCR) based data stores. Sling is
implemented - with the notable exception of JCR Node Type management -
purely in terms of the JCR API and as such may use any JCR compliant
repository. The default implementation for [Apache Jackrabbit](http://jackrabbit.apache.org)
 is provided out of the box.

#### OSGi

Sling is implemented as a series of [OSGi](http://www.osgi.org)
 Bundles and makes extensive use of the OSGi functionality, such as
lifecycle management and the service layer. In addition, Sling requires
several OSGi compendium services to be available, such as the Log Service,
Http Service, Configuration Admin Service, Metatype Service, and
Declarative Services.

#### Apache Felix

While Sling does not require a specific OSGi framework implementation to
run in, Sling is being developed using [Apache Felix](http://felix.apache.org)
 as the OSGi framework implementation. It has not been tested yet, but it
is expected that Sling also operates perfectly inside other OSGi frameworks
such as [Equinox](http://www.eclipse.org/equinox) and [Knopflerfish](http://www.knopflerfish.org).


<script src="/res/jquery-3.2.1.min.js" type="text/javascript"></script>
<script type="text/javascript">
        $(document).ready(function() {
            $.get("/news.html", function(news) {
                var $newsExcerpt = $(news).find('li').slice(0,5);
                $('#newsExcerpt').append($newsExcerpt);
            });
        });
</script>
