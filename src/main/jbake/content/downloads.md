title=Downloads
type=downloads
status=published
tags=downloads,community,pmc
~~~~~~

[TOC]

# Overview

To get the latest development release of Apache Sling, you can [check out the source code and build Sling yourself](documentation/development/getting-and-building-sling.html). Otherwise, the releases below are available for download. To install, just download and extract.

All Apache Sling products are distributed under the terms of the [Apache Software License](https://apache.org/licenses/) (version 2.0). See our license, or the LICENSE file included in each distribution.

For each module the following artifact types are provided

1. Main binary
1. Zip archive with complete project source code according to [ASF rules](https://www.apache.org/legal/release-policy.html) (classifier `source-release`), including LICENSE and NOTICE file.
1. Jar archive with source files of classes contained in 1., necessary for automatic downloads from IDEs (classifier `sources`), requirement of [Maven Central](https://central.sonatype.org/publish/requirements/#supply-javadoc-and-sources)
1. Jar archive containing [javadoc](https://docs.oracle.com/javase/7/docs/technotes/guides/javadoc/)(classifier `javadoc`), requirement of [Maven Central](https://central.sonatype.org/publish/requirements/#supply-javadoc-and-sources)

All those artifacts are accompanied by an according `*.asc` file containing the PGP signature.

# How to validate downloaded files

The PGP keys at [https://downloads.apache.org/sling/KEYS](https://downloads.apache.org/sling/KEYS) can be used to verify the integrity of the release archives. See [https://www.apache.org/info/verification](https://www.apache.org/info/verification) for how that works.

# Download servers

## Maven Central

All Sling modules are provided from [Maven Central with groupId `org.apache.sling`](https://central.sonatype.com/search?q=g%3Aorg.apache.sling).

## Apache

The links on this page point to the latest Apache Sling releases, provided
by the ASF's [CDN distribution services](https://blogs.apache.org/foundation/entry/apache-software-foundation-moves-to).

Older releases are available at [https://archive.apache.org/dist/sling/](https://archive.apache.org/dist/sling/).