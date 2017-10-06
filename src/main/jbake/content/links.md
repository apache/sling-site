title=Links		
type=page
status=published
tags=community,pmc
~~~~~~

Here are some links to other resources

## Articles
   * [Java Content Repository: The Best Of Both Worlds](http://java.dzone.com/articles/java-content-repository-best) - by Bertrand Delacretaz on Javalobby - uses the Sling HTTP interface to demonstrate JCR features.
   * [Accessing Relational Data as SLING RESTful URLs](http://www.lucamasini.net/Home/sling-and-cq5/accessing-relational-data-as-sling-restful-urls) - by Luca Masini
   * [Your First Day With Sakai Nakamura](http://confluence.sakaiproject.org/display/KERNDOC/Your+First+Day+With+Sakai+Nakamura) - Sakai Nakamura is based on Sling, that introductory article has very good explanations of REST and Sling basics, and on why hierarchies are useful on the Web.

## About Sling

   * [Sling on dev.day.com](http://dev.day.com/microsling/content/blogs/main.html?category=sling) - Day's developers blog, regularly includes articles on Sling and JCR. Powered by Sling, of course.
   * [Sling on Lars Trieloff's Blog](http://weblogs.goshaky.com/weblogs/lars/tags/sling) - Lars regularly writes on his experiences with Sling. Most notably the mini series of three entries introducing Sling and microsling.
   * [Sling links at del.icio.us](http://del.icio.us/tag/sling+jcr) - If you're a del.icio.us user, please tag Sling-related posts with both *sling* and *jcr* tags, so that they appear in that list.
   * [Sling on Fisheye](http://fisheye6.atlassian.com/browse/sling) - code repository viewer, activity statistics, etc.
   * [Sling on ohloh](https://www.ohloh.net/p/sling) - activity and community statistics.
   * [Sling on MarkMail](http://sling.markmail.org/) - searchable mailing list archives.


## Projects using Sling

   * Gert Vanthienen succeeded in installing Sling into the new Apache ServiceMix kernel and documented his experience [Sling On ServiceMix Kernel](http://servicemix.apache.org/SMX4KNL/running-apache-sling-on-servicemix-kernel.html)

## Sling Presentations and Screencasts

   * [Presentations tagged with "sling" at slideshare](http://www.slideshare.net/tag/sling) 

The following screencasts demonstrate Day Software's CRX quickstart product, powered by Sling:

   * [First Steps with CRX Quickstart](http://dev.day.com/microsling/content/blogs/main/firststeps1.html)
   * [TheServerSide.com in 15 minutes](http://dev.day.com/microsling/content/blogs/main/firststeps2.html)

## From ApacheCon EU 08

   * [ApacheCon EU 08 Fast Feather Track Presentation on Sling](/docs/ApacheConEU08_FFT_Sling.pdf)
   * [JCR Meetup Presentation on Sling Architecture](/docs/ApacheConEU08_JCR_Meetup_Sling_Architecture.pdf)

## From ApacheCon US 07

   * [ApacheCon US 07 Fast Feather Track Presentation on Sling](/docs/ApacheConUS07_FFT_Sling.pdf)
   * [Feathercast On Day 4 with an interview on Sling with Felix](http://feathercast.org/?p=59)

## Technology used by Sling

### JSR 170 - Content Repository for Java{tm} technology API

The specification of the repository API: [JSR 170: Content Repository for Java{tm} technology API](http://www.jcp.org/en/jsr/detail?id=170).

### Apache Jackrabbit

The main purpose of Sling is to develop a content-centric Web Application
 framework for Java Content Repository (JCR) based data stores. Sling is
 implemented - with the notable exception of JCR Node Type management -
 purely in terms of the JCR API and as such may use any JCR compliant
 repository. The default implementation for [Apache Jackrabbit](http://jackrabbit.apache.org)
 is provided out of the box. This is also the reference implementation
 of the Content Repository for Java (JCR) Specification.
 
### The OSGi Alliance

[The OSGi Alliance](http://www.osgi.org) is the specification body defining the OSGi specifications,
 namely the Core, Compendium, Enterprise and IoT specifications. These specifications are at the
 center of making Sling possible. Sling is implemented as a series of OSGi modules (called bundles)
 and makes extensive use of the OSGi functionality, such as lifecycle management and the service 
 layer. In addition, Sling requires several OSGi compendium services to be available, such as the 
 Log Service, Http Service, Configuration Admin Service, Metatype Service, and
 Declarative Services.

### Apache Felix

While Sling does not require a specific OSGi framework implementation to
 run in, Sling is being developed using [Apache Felix](http://felix.apache.org)
 as the OSGi framework implementation. It has not been tested yet, but it
 is expected that Sling also operates perfectly inside other OSGi frameworks
 such as [Equinox](http://www.eclipse.org/equinox) and [Knopflerfish](http://www.knopflerfish.org).
