title=TODO title for mime-type-support-commons-mime.md 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: MIME Type Support (commons.mime and commons.contentdetection)

Support for MIME type mappings is generally a problematic issue. On the one hand applications have to take care to stay up to date with their mappings on the other hands in web applications it is tedious to maintain the mappings. Apache Sling takes a very user and deployment friendly approadch to this problem which is described in detail on this page.

[TOC]

## Servlet API Support

The Servlet API specification provides a limited support for MIME type mappings :

* Mappings may be defined in the `mime-mapping` elements of the the web application descriptor `web.xml`. Managing these mappings is presumably tedious. So servlet containers may provide reasonable defaults (or not).
* The `ServletContext.getMimeType(String)` returns a MIME type for a given file name based on the extension of the filename. The mapping returned is based on the servlet container configuration as well as the web application descriptor's `mime-mapping` elements.


## The Sling MimeTypeService

Already at the start of the Sling project we realized, that just basing the MIME type mapping decisions on the servlet container will not yield acceptable results. For this reason the Apache Sling projects provides a spezialized and configurable service supporting such mappings: The [`MimeTypeService`](/apidocs/sling6/org/apache/sling/commons/mime/MimeTypeService.html) provided by the `org.apache.sling.commons.mime` bundle.

This service provides access to registered MIME types and their mappings with two methods:

* `getExtension(String)` -- given a MIME type this methods returns a primary extension. For example for the type `text/plain` this method will return `txt`
* `getMimeType(String)` -- given a file name or just the extension) returns the mapped MIME type. For example for the filename `sample.html` (or just the extension `html`) this method will return `text/html`


Two more methods allow to programmatically add MIME type mappings:

* `registerMimeType(InputStream)` registers additional mappings from the given input stream which is expected to be formated in traditional `mime.types` file format (see below).
* `registerMimeType(String, String...)` registers a single mapping for the give MIME type and the respective extensions.

## The Sling ContentAwareMimeTypeService

For content-based mime type detection (as opposed to filename-based detection), the `org.apache.sling.commons.contentdetection` bundle 
provides the `ContentAwareMimeTypeService`, which takes an `InputStream` that's analyzed to detect its mime type, using Apache Tika
by default:

* `getMimeType(String filename, InputStream content)` -- given a filename and an `InputStream` that points to the file contents, this method first tries content-based detection using the stream, and falls back to filename-based detection if needed.

## And More...

Besides the `MimeTypeService` provided by Apache Sling, there is actually more:

* The [`SlingHttpServletRequest`](/apidocs/sling6/org/apache/sling/api/SlingHttpServletRequest.html) provides the `getResponseContentType()` method, which returns the preferred *Content-Type* for the response based on the requests extension. This method is implemented by Apache Sling using the `MimeTypeService`. So servlets and scripts may just call this method to set the content type of the response to the desired value.
* Each Servlet (and JSP scripts) is initialized by Apache Sling with a `ServletContext` instance whose implementation of the `getMimeType(String)` effectively calls the `MimeTypeService.getMimeType(String)` method.
* The Scripting support infrastructure of Sling sets the response content type on behalf of the script to the default value as returned by the `SlingHttpServletRequest.getResponseContentType()` method. At the same time the response character set is also set to `UTF-8` for *text* content types.

## Configuring MIME Type Mappings

The implementation of the `MimeTypeService` in the Apache Sling MIME type mapping support (`org.apache.sling.commons.mime`) bundle supports a numnber of ways to configure and extend the set of MIME type mappings:

* Default configuration. The default configuration is based on the [`mime.types`](http://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types) file maintained by Roy Fielding for the Apache httpd project and some extensions by Apache Sling.
* Bundle provided mappings. Bundles registered in the OSGi framework may contain MIME type mappings files `META-INF/mime.types` which are loaded automatically by the Apache Sling MIME type mapping support bundle.
* Configuration. Mappings may be supplied by configuration of the `MimeTypeService` implementation as the multi-value string property `mime.types`. Each value of the property corresponds to a line in a MIME type configuration file (see below for the format).
* Registered Mappings. Mappings may be registered with the `MimeTypeService.registerMapping` methods.
* [`MimeTypeProvider`](/apidocs/sling6/org/apache/sling/commons/mime/MimeTypeProvider.html). Additional mappings may be provided by service implementing the `MimeTypeProvider` interface. The `MimeTypeService` implementation will call these services in turn until a service returns a mapping provided there is no static configuration to responde to the mapping request.

Please note, that existing mappings cannot be overwritten later. Thus mappings have an inherent priority:

1. Mappings provided by the Apache httpd project's `mime.types` file
1. Extensions by the Apache Sling MIME type mapping support bundle
1. Bundles providing a `META-INF/mime.types` file in the order of their bundle-id (or startup order if started after the MIME type mapping support bundle)
1. OSGi Configuration. Note that bundles started *after* the MIME type mapping support bundle may not overwrite mappings provided by the OSGi configuration. This may sounds like a problem, but in reality this should genrally not matter
1. Mappings registered calling the `MimeTypeService.registerMimeType` method
1. Mappings provided by `MimeTypeProvider` services

## MIME Type Mapping File Format

The file format for MIME type mapping files is rather simple:

* The files are assumed to be encoded with the *ISO-8859-1* (aka Latin 1) character encoding
* The files consist of lines defining mappings where each line is terminated with either or both of a carriage return (CR, 0x0c) and line feed character (LF, 0x0a). There is no line continuation support *-la shell scripts or Java properties files.
* Empty lines and lines starting with a hash sign (`#`) are ignored
* Data lines consist of space (any whitespace matching the `\s` regular expression) separated values. The first value is the MIME type name and the remaining values defining mappings to file name extensions. The first listed file name extension is considered the *default mapping* and is returned by the `MimeTypeService.getExtension(String)` method. Entry lines consisting of just a mime type but no extensions are also (currently) ignored.

THe data line format described here also applies to configuration provided by the values of the `mime.types` property of the MIME type service configuration. The file format description applies to all `META-INF/mime.types` files provided by the bundles as well as input streams supplied to the `MimeTypeService.registerMimeType(InputStream)` method.

## Web Console Plugin

The Apache Sling MIME type mapping support bundle implements a plugin for the Apache Felix Web Console which may be consulted to investigate the current contents of the MIME type mapping tables.

![Mime Types Web Console Plugin](/documentation/bundles/mimetypes.png)
