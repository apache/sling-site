title=Documentation		
type=page
status=published
tags=documentation,community,pmc
~~~~~~

[TOC]

#Overview

The documentation is split into different parts:

   * [Getting Started](/documentation/getting-started.html), the right place to start!
   * [The Sling Engine](/documentation/the-sling-engine.html), all about the heart of Sling
   * [Development](/documentation/development.html), how do I get and develop with Sling
   * [Bundles](/documentation/bundles.html), which bundle delivers which features to Sling
   * [Tutorials & How-Tos](/documentation/tutorials-how-tos.html)
   * [Wiki](http://cwiki.apache.org/SLING/)
   * [Configuration](/documentation/configuration.html)
   * [API Doc](http://sling.apache.org/apidocs/sling8/index.html)


# How you can contribute

We're on the way to improve the documentation, but it's a long way. If you would like to contribute to the documentation you are very welcome. Please directly post your proposals to the [public wiki](http://cwiki.apache.org/SLING/) or post your suggestions to the [mailing list](/project-information.html).


# How the documentation is generated

The basic documentation of Sling is made up of four parts:

1. The Sling Site at http://sling.apache.org/ (you are here)
1. The Public Wiki at http://cwiki.apache.org/SLING
1. The JavaDoc
1. The Maven plugin documentation

This page is about how this documentation is maintained and who is allowed to do what.


## The Sling Website
TODO this page needs to be adapted to the JBake site generation mechanisms.


## The Public Wiki

The public wiki of Sling is available at [http://cwiki.apache.org/SLING](http://cwiki.apache.org/SLING) and is maintained in the Confluence space *SLING*. Everyone can create an account there. To gain edit rights please ask via the [mailing list](/project-information.html). Any of the administrators listed in the [Space Overview](https://cwiki.apache.org/confluence/spaces/viewspacesummary.action?key=SLING&showAllAdmins=true) can give you access.


## The JavaDoc

With every major release of Sling the JavaDoc of all containing bundles are published below [http://sling.apache.org/apidocs/](http://sling.apache.org/apidocs/).
The script for generating this aggregation JavaDoc is at [http://svn.apache.org/repos/asf/sling/trunk/tooling/release/](http://svn.apache.org/repos/asf/sling/trunk/tooling/release/) in `generate_javadoc_for_release.sh`

In addition every released bundle is released together with its JavaDoc (which is also pushed to Maven Central).

## The Maven Plugin Documentation

For the most important Maven Plugins the according Maven Sites (generated with the `maven-site-plugin`) are published at [http://sling.apache.org/components/](http://sling.apache.org/components/). The description on how to publish can be found at [Release Management](/documentation/development/release-management.html).
