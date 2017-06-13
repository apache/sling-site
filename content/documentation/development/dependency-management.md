Title: Dependency Management
Excerpt: This page is about how we do and don't do dependency management in the Sling project.

This page is about how we do and don't do dependency management in the Sling project.

[TOC]

## Introduction

Maven provides projects with a nice feature called dependency management. In Sling we currently use this feature to declare the non-Sling dependencies of modules in the parent POM.

After working with this some time and trying to upgrade various dependencies we came to the conclusion, that using Maven dependency management is not going to work out in the Sling scenario.

Why ? Maven's dependency management is aimed at traditional applicaitons, which are glued together statically during the build process. For this environment, dependency management is a great thing, since it guarantees a consistent application setup.

In a dynamic application setup as provided by an OSGi framework the static dependency management of Maven does not help. Actually it even causes problematic results with respect to backwards compatibility when using the Maven Bundle Plugin.

Why's that ? The Maven Bundle Plugin constructs the bundle manifest and will generally automatically create the Import-Package header. If the providing library (from Maven's dependency list) has `Export-Package` headers with version numbers, the Maven Bundle Plugin will insert the respective version numbers for the `Import-Package` header. This makes perfect sense, because it is expected, that the artifact required at least the given package version.

When using Maven dependency management, upgrading any dependencies in the parent POM may automatically increase the version numbers in the `Import-Package` headers and hence may cause any such bundle to fail resolution if deployed - even though the bundle did not change and does not really require a new version of the dependency.

So, in the case of OSGi deployment, Maven's dependency management actually interferes with the OSGi framework dependency management.

As a consequence, I suggest we drop dependency management in the parent POM (almost) completely and state the following.


## Dependency Management


The parent POM only does dependency management for build time dependencies and a very limited number of API dependencies used Sling wide. These dependencies are:

   * All plugin dependencies. That is `pluginManagement` is still used. Maven plugins are actually build time dependencies and therefore have no influence on the actual deployment.
   * Dependencies on commonly used testing environment helpers. Test helper classes are also build time dependencies used to run the unit and integration tests. As such, they may well be managed.
   * Sling makes a small number of assumptions about the environment, which we codify in the dependency management: The minimum version number of the OSGi specificaiton used, the Servlet API version and the JCR API version.

The `<dependencyManagement>` element currently contains the following managed dependencies:

| Group ID | Artifact ID | Version | Scope |
|--|--|--|--|
| org.osgi | org.osgi.core | 4.1.0 | provided |
| org.osgi | org.osgi.compendium | 4.1.0 | provided |
| javax.servlet | servlet-api | 2.4 | provided |
| javax.jcr | jcr | 1.0 | provided |
| org.slf4j | slf4j-api | 1.5.2 | provided |
| org.apache.felix | org.apache.felix.scr.annotations | 1.9.8 | provided |
| biz.aQute | bndlib | 1.50.0 | provided |
| junit | junit | 4.11 | test |
| org.jmock | jmock-junit4 | 2.5.1 | test |
| org.slf4j | slf4j-simple | 1.5.2 | test |


All dependencies per module are fully described in terms of version, scope, and classifier by the respective project.

The version of the module dependency should be selected according to the following rule: The lowest version providing the functionality required by the module (or bundle). By required functionality we bascially mean provided API.

Generally there is a constant flow of releases of dependent libraries. In general this should not cause the dependency version number of a using module to be increased. There is one exception though: If the fixed library version contains a bug fix, which has an influence on the operation of the module, an increase in the version number is indicated and should also be applied.


## References

* [Dependency Management](http://markmail.org/message/5qpmsukdk4mdacdy) -- Discussion thread about reducing Maven Dependency Management
* [SLING-811](https://issues.apache.org/jira/browse/SLING-811) -- The actual issue governing the changes to the project descriptors