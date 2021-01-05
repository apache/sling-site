title=Downloads
type=downloads
status=published
tags=downloads,community,pmc
~~~~~~

[TOC]

# Overview

To get the latest development release of Apache Sling, you can [check out the source code and build Sling yourself](documentation/development/getting-and-building-sling.html). Otherwise, the releases below are available for download. To install, just download and extract.

All Apache Sling products are distributed under the terms of the [Apache Software License](http://apache.org/licenses/) (version 2.0). See our license, or the LICENSE file included in each distribution.

For each module the following artifact types are provided

1. Main binary
1. Zip archive with complete project source code (classifier `source-release`)
1. Jar archive with source files of classes contained in 1. (classifier `sources`)
1. Jar archive containing [javadoc](https://docs.oracle.com/javase/7/docs/technotes/guides/javadoc/)( (classifier `javadoc`)

All those artifacts are accompanied by an according `*.asc` file containing the PGP signature.

# Downloads

## How to validate downloaded files

The PGP keys at [https://downloads.apache.org/sling/KEYS](https://downloads.apache.org/sling/KEYS) can be used to verify the integrity of the release archives. See [https://www.apache.org/info/verification](https://www.apache.org/info/verification) for how that works.

## Maven Central

All Sling modules are provided from [Maven Central with groupId `org.apache.sling`](https://search.maven.org/search?q=g:org.apache.sling).

## Apache Mirrors

Use the links below to download binary or source distributions of Apache Sling from one of our ASF mirrors.

You are currently using **[preferred]**. If you encounter a problem with
this mirror, please select another mirror. If all mirrors are failing,
there are backup mirrors (at the end of the mirrors list) that should be
available. If the mirror displayed above is labeled *preferred*, then
please reload this page by [downloads.cgi](clicking here)

<form action="[location]" method="get" id="SelectMirror">
<p>Other mirrors: </p>
<select name="Preferred">
[if-any http]
[for http]<option value="[http]">[http]</option>[end]
[end]
[if-any ftp]
[for ftp]<option value="[ftp]">[ftp]</option>[end]
[end]
[if-any backup]
[for backup]<option value="[backup]">[backup] (backup)</option>[end]
[end]
</select>
<input type="submit" value="Change"></input>

Older releases are available at [http://archive.apache.org/dist/sling/](http://archive.apache.org/dist/sling/).