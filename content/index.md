Title: Apache Sling - Bringing Back the Fun!

**Apache Sling&trade;** is an innovative web framework that is intended to
bring back the fun to web development.

Discussions about Sling happen on our mailing lists, see the [Project Information]({{refs.project-information.path}})
 page for more info.

# Apache Sling in five bullets points

* REST based web framework
* Content-driven, using a JCR content repository
* Powered by OSGi
* Scripting inside, multiple languages (JSP, server-side javascript, Scala,
etc.)
* Apache Open Source project

# Apache Sling in a hundred words

Apache Sling is a web framework that uses a [Java Content Repository](http://en.wikipedia.org/wiki/JSR-170), such as [Apache Jackrabbit](http://jackrabbit.apache.org/), to store and manage content.

Sling applications use either scripts or Java servlets, selected based on
simple name conventions, to process HTTP requests in a RESTful way.

The embedded [Apache Felix](http://felix.apache.org/)
 OSGi framework and console provide a dynamic runtime environment, where
code and content bundles can be loaded, unloaded and reconfigured at
runtime.

As the first web framework dedicated to [JSR-170](http://jcp.org/en/jsr/detail?id=170)
 Java Content Repositories, Sling makes it very simple to implement simple
applications, while providing an enterprise-level framework for more
complex applications. 

## News

<ul id="newsExcerpt">
</ul>


Refer to the news [archive]({{ refs.news.path }}) for all news.

## History

Sling started as an internal project at [Day Software](http://www.day.com)
, and entered the Apache Incubator in September 2007. As of June, 17th,
2009 Apache Sling is a top level project of the Apache Software Foundation.

The name "Sling" has been proposed by Roy Fielding who explained it like
this:

> \[The name is\] Biblical in nature.  The story of David: the weapon he
> uses to slay the giant Goliath is a sling.  Hence, our David's
> \[David Nuescheler, CTO of Day Software\] favorite weapon.

> It is also the simplest device for delivering content very fast.

## Getting started

If you prefer doing rather than reading, please proceed to [Discover Sling in 15 minutes]({{refs.discover-sling-in-15-minutes.path}})
 or read through the recommended links in the [Getting Started]({{refs.getting-started.path}})
 section, where you can quickly get started on your own instance of Sling.

## Use Cases for Sling

#### Wiki

Day built a Wiki system on Sling. Each Wiki page is a node (with optional
child nodes) in the repository. As a page is requested, the respective node
is accessed and through the applying Component is rendered.

Thanks to the JCR Mapping and the resolution of the Component from the
mapped Content, the system does not care for what actual node is addressed
as long as there is a Content mapping and a Component capable of handling
the Content.

Thus in the tradition of REST, the attachement of a Wiki page, which
happens to be in a node nested below the wiki page node is easily accessed
using the URL of the wiki page attaching the relative path of the
attachement  ode. The system resolves the URL to the attachement Content
and just calls the attachement's Component to spool the attachement.



#### Digital Asset Management

Day has implemented a Digital Asset Management (DAM) Application based on
Sling. Thanks to the flexibility of the Content/Component combo as well as
the service registration/access functionality offered by OSGi, extending
DAM for new content type is merely a matter of implementing one or two
interfaces and registering the respective service(s).

Again, the managed assets may be easily spooled by directly accessing them.


#### Web Content Management

Last but not least, Sling offers itself very well to implementing a Web
Content Management system. Thanks to the flexibility of rendering the
output - remember: the system does not care what to render, as long as the
URL resolves to a Content object for which a Component exists, which is
called to render the Content - providing support for Web Content authors
(not PHP programmers but users out in the field) to build pages to their
likings can easily be done.


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


<script src="/res/jquery.js" type="text/javascript"></script>
<script type="text/javascript">
        $(document).ready(function() {
            $.get("/news.html", function(news) {
                var $newsExcerpt = $(news).find('li').slice(0,5);
                $('#newsExcerpt').append($newsExcerpt);
            });
        });
</script>
