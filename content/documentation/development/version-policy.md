title=Version Policy		
type=page
status=published
~~~~~~
Excerpt: This page is about how we assign versions to exported packages and bundles and defines when to increase which part of the version number.

This page is about how we assign versions to exported packages and bundles and defines when to increase which part of the version number.

<div class="info">
Please note that this page is currently in draft stage and still being discussed.
</div>

[TOC]

## Introduction

In comments to [SLING-1176](https://issues.apache.org/jira/browse/SLING-2944) Ian Boston wrote:

> The exports in bundle/api/pom.xml look like they might become problematic from a support point of view, although we probably can't avoid this. [...] [The problem is the] manual maintenance of the version numbers. (not a big problem but needs to be done)

I agree, that this is a problem. So let me reasonate on this a bit ;-)

As a reference you might want to read [my blog post on version numbers](http://blog.meschberger.ch/2009/10/on-version-numbers.html) and also what the [Eclipse guys have to say](http://wiki.eclipse.org/index.php/Version_Numbering) (great read, btw). The OSGi Alliance has come up with a good definition for [Semantic Versioning](http://www.osgi.org/wiki/uploads/Links/SemanticVersioning.pdf) to which the definitions described below perfectly match.

For Sling we have three kinds of version numbers:

1. Big Sling Releases
1. Sling Bundles
1. Package Exports

### Big Sling Releases

For *Big Sling Releases* we already have an ample solution in that we just use a single number increased from release to release. Just remember that a *Big Sling Release* is a convenience release of existing released Sling bundles.

### Sling Bundles

For *Sling Bundles* version numbers are just defined as the `<version>` element of the bundle's POM. The only restriction here is, that we decided to use even numbers for releases and odd numbers for SNAPSHOTs. Whether and when which version part is increased is not explicitly defined yet.

### Package Exports

For *Package Exports* the situation is more problematic since there are a number of places to set exported package version number:

* In a `packageinfo` file inside the package (picked up by the Maven Bundle Plugin to set the export version)
* Explicitly in the `<Export-Package>` element of the Maven Bundle Plugin configuration
* By reference to the bundle version number using the `${pom.version}` variable.

Up to now, we mostly used the `${pom.version}` notation linking the exported package version to the bundle version. Over time this mechanism leads to a number of problems:

* For bundles with more than one package exported, the exported packages will evolve independently. As a consequence their versioning should also evolve independently. An example of such a bundle is the Sling API bundle of course.
* Linking the package export version number to the bundle version number confuses the actual semantics of both version numbers. The package export version number only indicates the version of the actual package while the bundle version number indicates a development state of the overall bundle. This will generally not be the same.
* The version of the exported package is increased on each bundle release, even though nothing may have changed on the export. In such a situation the version of the export should stay the same.

That said, the reuse of the bundle version as the package export version still is probably the correct thing to do for legacy library wrappers.

Consider for example the Sling API bundle, which exports 9 packages. Each of which may evolve independently. Now the `resource` package is extended causing a minor version increase. Should the version numbers of the other exports also be increased ? Thus acting as if there was some API change ?

I would say, no. Particularly if some API implementation bundle is restricting the import version of the API implemented. Such an implementation would immediately stop working because the version has been increased. But since there has been no change, the implementation would still be correct.

So, I think, we should evolve the exported package versions independently from each other and even independently from the bundle version.

This places more burden on the developer when deciding on the exported package version - in fact this requires such a decision as compared to have Maven take the decision by just setting the bundle version.

The only problem is: Where shall this be noted ? In the POM or in the `packageinfo` file ? If we would place the `packageinfo` file just beneath the class source files, I would say, in the `packageinfo` file.

But this would require defining the class source locations as resource location in the POM (at least for `packageinfo`) files.

I am not sure ....

This has not been discussed at large, but I would assume, that the POM is still the correct place to take note of the version of the exported packages.

### Future

The newest versions of the bnd library also support an `@Export` annotation in the `package-info.java` pseudo class file. This pseudo class is supported starting with Java 5 to take package level annotations (like the `@Export` annotation) and as a replacement of the `package-info.html` file.

Using this syntax something like the following would be easily possible:


/**
* This is the Package Level JavaDoc
*/
@Export(version = "1.0")
package org.apache.sling.api.auth;
import aQute.bnd.annotation.Export;


See [bnd Versioning](http://bnd.bndtools.org/chapters/170-versioning.html) for details.


## Version Number Syntax

As a small reminder, this is how a version number is constructed:  In OSGi version numbers are composed of four (4) segments: three integers and one string named _major_._minor_._micro_._qualifier_.

Each segment captures a different intent:

* the major segment indicates breakage in the API
* the minor segment indicates *externally visible* changes
* the micro segment indicates bug fixes
* the qualifier segment is not generally used but may be used to convey more information about a particular build, such as a build time or a SVN revision number.


## Evolution of Exported Package Versions

Version numbers of exported packages evolve independently from each other. Depending on the changes applied, the micro, minor, or major segement is increased. Whenever the major segment is increased, the minor and micro segments are reset to zero. Whenever the minor segment is increased, the micro segment is reset to zero.

Segments are increased according to the above listing.

This requires committers to think well about changes they apply to exported packages:

* Removing interfaces, methods or constants is likely an API breakage and thus requires a major version increase. In Sling we try to prevent this from happening.
* Adding new methods to interfaces is likely just an *externally visible* change and thus requires a minor version increase
* Fixing a bug in an exported class just requires a minor version increase.

JavaDoc updates generally do not constitute a reason to evolve the version number. The exception is that if the JavaDoc update is caused by a API limitation, it might be conceivable to increase the version number of the exported package. A decision on this will have to be taken on a case-by-case basis.


## Evolution of Bundle Versions

Version numbers of bundles evolve depending on the evolution of the exported packages but also depending on the evolution of the private code, which is not exported.

As a rule of thumb, the following reasons apply for increasing the segments of bundle version numbers:

* Increasing the major version number of any of the exported packages or restructuring the bundle such that major parts are removed from the bundle (and either completely removed or moved to other bundle(s)).
* Increasing the minor version number of any of the exported packages or refactoring the internal code or implementing a package exported by another bundle whose minor (or even major) version number has increased. Also functional extensions of the internal bundle classes consitutes a reason to increase the minor version number.
* Increasing the micro version number of any of the exported packages or bug fixes.

Note, that this definition does not require the bundle and epxorted package version numbers to be synchronized in any way. While doing so might help in a first or second step, over time it will become close to impossible to keep the versions in sync. So rather than trying to keep the versions in sync, we should make sure, we increase the versions correctly.


## Examples


### Pure API Bundle

An example of an almost *Pure API Bundle* is the Sling API bundle. This bundle exports 9 packages. Some are really stable -- e.g. the `org.apache.sling.api` package or the `org.apache.sling.wrappers` package -- and some are being worked on at the moment -- e.g. the `org.apache.sling.resource` package.

To not break existing users of the unmodified packages, the exported versions of these packages must not be increased.

To signal to users of evolving packages, that there might be new and interesting functionality, the version number must be increased according to above definition. This also conveys to the implementor(s) of the API, that they have to take some action.


A hypothetical evolution of version numbers shown on two packages and the bundle version might be as follows

| Description | `api` package | `resource` package | bundle |
|-|-|-|-|
| Initial Release | 1.0.0 | 1.0.0 | 1.0.0 |
| Bug fix in a `resource` class | 1.0.0 | 1.0.2 | 1.0.2 |
| New API in the `resource` package | 1.0.0 | 1.1.0 | 1.1.0 |
| New API in the `api` package | 1.1.0 | 1.1.0 | 1.2.0 |
| API breakage in the `api` package | 2.0.0 | 1.1.0 | 2.0.0 |


### Implementation Bundle providing API

An example of such a hybrid bundle is the Sling Engine bundle. This bundle exports two packages themselves defining API and contains a number of internal packages which actually implement parts of the Sling API.

A hypothetical evolution of version numbers shown on one exported package and the bundle version might be as follows

| Description | `engine` package | bundle |
|-|-|-|
| Initial Release | 1.0.0 | 1.0.0 |
| Bug fix in a `engine` class | 1.0.2 | 1.0.2 |
| Bug fix in an internal calss | 1.0.2 | 1.0.4 |
| New API in the `engine` package | 1.1.0 | 1.1.0 |
| Implement new API from `api` 1.1.0 | 1.1.0 | 1.2.0 |
| Refactor internal classes | 1.1.0 | 1.3.0 |
| Implement API from `api` 2.0.0 | 1.1.0 | 2.0.0 |


### Pure Implementation Bundle

For Pure Implementation Bundles only the bundle version numbers are maintained because there is no exported package whose version number needs to be managed. This makes the decision process of version number evolution very simple.


## Importing Packages


When importing packages a version number will automatically be generated by the Maven Bundle Plugin as follows:

* If the providing package exports a package with an explicit version number, that exact version number will be used as the lower bound
* If such a lower bound exists, the upper bound is exclusive the next major version number.

For example if importing the `api` package exported at version 1.2.3, the `Import-Package` statement is generated as


Import-Package: api;version=[1.2.3,2.0.0)



This default works well for consumers of the API, since according to above definitions an API is guaranteed to not contain breakages if the major version number is not increased.

For bundles implementing the API, this default does not work well, since from their point of view an *externally visible* change in fact constitutes a breakage, because the implementation is not complete. So if a bundle implements a package a manually crafted import version should be defined which includes the export version of the defining bundle but excludes the next minor version.

For example implementing the `api` package exported at version 1.2.3, would require the following manually created `Import-Package` statement:


Import-Package: api;version=[1.2.3,1.3.0)


This allows for the implementation to work correctly with bug fixed package exports but as soon as there are any *externally visible* changes, the implementation bundle has to be adapted -- even if this just means increasing the upper version bound in the `Import-Package` statement thus guaranteeing compliance (again).

### Future

Recent versions of the bnd library support automatic differentiation between _use_ and _implementation_ of API and to set the import version ranges accordingly. See [bnd Versioning](http://bnd.bndtools.org/chapters/170-versioning.html) for details.

## References

* [Version Numbers](http://markmail.org/thread/zshobgjwtqrncajt) -- The mail thread discussing version numbering
* [On Version Numbers](http://blog.meschberger.ch/2009/10/on-version-numbers.html) -- Blog about version numbers
* [Version Numbering](http://wiki.eclipse.org/index.php/Version_Numbering) -- An Eclipse paper on assigning version numbers. Very good read.
* [Semantic Versioning](http://www.osgi.org/wiki/uploads/Links/SemanticVersioning.pdf) -- An OSGi Alliance paper on semantic versioning.
* [bnd Versioning](http://bnd.bndtools.org/chapters/170-versioning.html) -- Describes how the bnd library used by the Maven Bundle plugin supports package versioning
