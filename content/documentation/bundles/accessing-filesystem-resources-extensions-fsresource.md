title=Accessing File System Resources (org.apache.sling.fsresource)		
type=page
status=published
~~~~~~
[TOC]


## Introduction

The Apache Sling File System Resource Provider provides access to the operating system's file system through the Sling `ResourceResolver`. Multiple locations may be mapped into the resource tree by configuring the file system location and the resource tree root path for each location to be mapped. The provider supports mapping folders and files as binaries, and content structures stored in JSON files or FileVault XML format.

To activate this feature, install the `org.apache.sling.fsresource` bundle. You can get it from the Sling downloads page or from [Maven Central][maven-central].

Currently two major versions are maintained - choose the correct version depending on your Sling environment:

* fsresource 2.x ([trunk][src-trunk]): compatible with Apache Sling API 2.11 and Apache Sling Resource Resolver 1.5.18 or above.
* fsresource 1.x ([branch][src-branch]): compatible with Apache Sling API 2.4 and Apache Sling Resource Resolver 1.1.0 or above.


## Resource Types

Files and directories are mapped into the resource tree as regular `Resource` instances whose resource type depends on the actual nature of the mapped file system resource:

   * Regular files are assigned the `nt:file` resource type
   * Directories are assigned the `nt:folder` resource type

Content stored in JSON or FileVault XML files are mapped with the resource type stored in the files. If a resource type is missing `nt:unstructured` is used as fallback.


## Adapters

File system resources extend from Sling's `AbstractResource` class and thus are adaptable to any type for which an `AdapterFactory` is registered supporting file system resources. In addition File system Resources support the following adapters natively:

   * `java.io.File` -- The Java file object providing access to the file system file
   * `java.net.URL` -- A valid `file://` URL to the file. This URL is derived from the `java.io.File` object by calling the `File.toURI().toURL()` sequence.
   * `java.io.InputStream` -- If the `java.io.File` can be read from (as per `File.canRead()` an `InputStream` to read from the file is returned.



## Configuration

The File System Resource Provider is configured with OSGi Configuration Admin factory configurtions whose factory PID is `org.apache.sling.fsprovider.internal.FsResourceProvider`. Configuration can be managed using the OSGi Configuration Admin API, through the Web Console or by any other means supporting Configuration Admin configurations. Each configuration "mounts" a specific file system path into the resource hierarchy.

Which files are mounted depends on the 'File system layout' configuration parameter:

* FILES_FOLDERS (default): Support only files and folders (classic mode).
* INITIAL_CONTENT: Sling-Initial-Content filesystem layout, supports file and folders ant content files in JSON and jcr.xml format.
* FILEVAULT_XML: FileVault XML format (expanded content package).

Configuration parameters for each mapping:

| Parameter | Name | Description |
|-|-|-|
| File System Root | `provider.file` | File system directory mapped to the virtual resource tree. This property must not be an empty string. If the path is relative it is resolved against sling.home or the current working directory. The path may be a file or folder. If the path does not address an existing file or folder, an empty folder is created. |
| Provider Root	| `provider.root` (2.x), `provider.roots` (1.x) | Location in the virtual resource tree where the file system resources are mapped in. This property must not be an empty string. Only one path is supported. |
| File system layout | `provider.fs.mode` | File system layout mode for files, folders and content. |
| Init. Content Options | `provider.initial.content.import.options` | Import options for Sling-Initial-Content file system layout. Supported options: overwrite, ignoreImportProviders. |
| FileVault Filter | `provider.filevault.filterxml.path` | Path to META-INF/vault/filter.xml when using FileVault XML file system layout. |
| Check Interval | `provider.checkinterval` | If the interval has a value higher than 100, the provider will check the file system for changes periodically. This interval defines the period in milliseconds (the default is 1000). If a change is detected, resource events are sent through the event admin. |
| Cache Size | `provider.cache.size` | Max. number of content files cached in memory.  |


### FILES_FOLDERS file system layout

The mode maps only files and folders. This was the only mode supported in fsresource versions before 1.3.

Notes:

* No caching is used for this mode.
* Resource events are sent when file oder folder changes are detected.


### INITIAL_CONTENT file system layout

The mode maps files and folders, and content files stored in JSON or jcr.xml files. The layout has to match the conventions of the [Apache Sling JCR Content Loader][jcr-contentloader]. The bundle header `Sling-Initial-Content` defines where and how the content should be loaded to.

This mode is best use together with the [Maven Sling Plugin][maven-sling-plugin], which automatically creates the appropriate File System Resource Provider configurations for a Maven bundle project containing content structures. For each path an individual configuration is created.

Usage - deploy OSGi bundle from current maven project and register the appropriate OSGi configuration mappings:

    $ mvn -Dsling.mountByFS=true sling:install

Only register the appropriate mappings:

    $ mvn sling:fsmount

Remove the mappings:

    $ mvn sling:fsunmount

Notes:

* The content of JSON or jcr.xml files is cached in-memory until it changes.
* Resource events are sent when file oder folder changes are detected. When a JSON or jcr.xml file is changed resource events are sent for each resource contained in this file.
* When 'overwrite:=true' is not set for a path in the `Sling-Initial-Content` header the resource provider falls back to the parent resource provider (e.g. JCR repository) if a requested resource is not find in the file system (version 2.x, with version 1.x this always happens).


### FILEVAULT_XML file system layout

The mode maps an maven project containing an expanded content package which uses the [Jackrabbit FileVault XML layout][vaultfs] in the running Sling instance. The existing of a filter file `META-INF/vault/filter.xml` is mandatory.

This mode is best use together with the [Maven Sling Plugin][maven-sling-plugin], which automatically creates the appropriate File System Resource Provider configurations. For each path defined in the filter.xml one mapping configuration is created. The include/exclude definitions are respected as well.

Usage - register the appropriate mappings:

    $ mvn sling:fsmount

Remove the mappings:

    $ mvn sling:fsunmount

Notes:

* The content of .content.xml files is cached in-memory until it changes.
* Resource events are sent when file oder folder changes are detected. When a JSON or jcr.xml file is changed resource events are sent for each resource contained in this file.
* Content excluded by the filter definition is not mounted by the resource provider, if a resource of the relevant path is requested the resource provider falls back to the parent resource provider (e.g. JCR repository).



[src-trunk]: https://svn.apache.org/repos/asf/sling/trunk/bundles/extensions/fsresource/
[src-branch]: https://svn.apache.org/repos/asf/sling/branches/fsresource-1.x/
[maven-central]: https://search.maven.org/#search%7Cga%7C1%7Cg%3A%22org.apache.sling%22%20AND%20a%3A%22org.apache.sling.fsresource%22
[jcr-contentloader]: content-loading-jcr-contentloader.html
[maven-sling-plugin]: http://sling.apache.org/components/maven-sling-plugin/
[vaultfs]: http://jackrabbit.apache.org/filevault/vaultfs.html
