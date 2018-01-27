title=Request Processing Analyzer (reqanalyzer)		
type=page
status=published
tags=requests
~~~~~~

[TOC]


## Introduction

Sling provides a helpful functionality to track progress of requests
being processed: The [RequestProgressTracker](http://sling.apache.org/apidocs/sling6/org/apache/sling/api/request/RequestProgressTracker.html) which is available through the [SlingHttpServletRequest](http://sling.apache.org/apidocs/sling6/org/apache/sling/api/SlingHttpServletRequest.html#getRequestProgressTracker%28%29).

This tool provides mechanims to record states of request processing and a simple mechanism to time periods of processing. By default Sling itself uses this tool to track progress through Sling like script resolution and calling scripts.

Scripts and servlets called during Sling's request processing may themselves use the `RequestProgressTracker` to log their own processing.

Usually the data collected by the `RequestProgressTracker` is just dropped or it may be visible for a certain number of recent requests on the *Recent Requests* page of the Web Console. When doing load tests, though, this Web Console page is of limited use because a lot more requests are handled than can be displayed in the Web Console.

This is where the [Request Processing Analyzer](https://github.com/apache/sling-org-apache-sling-reqanalyzer) comes in handy. When deployed as a bundle it registers as a request level servlet Filter with the Sling Main Servlet. Each request is logged in a special file (currently fixed at `${sling.home}/logs/requesttracker.txt`) with a header line provding core information on the request:

* Start time stamp in ms since the Epoch
* Request processing time in ms
* Request Method
* Request URL
* Response content type (plus character encoding if available)
* Response Status

After that first line the complete data from the requests `RequestProgressTracker` is dumped.

## Web Console Integration

The Request Processing Analyzer is available through the Web Console in the _Sling_ category to

* Download the `requesttracker.txt` file as a plain text or ZIP-ed file
* Launch the Swing-based GUI to analyze the file

The option to launch the Swing-based GUI is only available if the Sling application
is not running in headless mode and if the Web Console is accessed on _localhost_,
that is on the same host as the Sling instance is running.


## Analyzing the `requesttracker.txt` file

To analyze the `requesttracker.txt` file the *Request Processing Analyzer* module can also be used as a standalone Java application. Just start the module using the `java` command:

    $ java -jar org.apache.sling.reqanalyzer-0.0.1-SNAPSHOT.jar requesttracker.txt

The command supports two command line arguments:

1. The tracker file (required)
2. The number of requests to load and display from the file. This second option is optional and may be used to limit the request information loaded to the first requests in the file

After starting and parsing the file, a window is opened showing the core request information in simple table. This table can be sorted by any of the columns by clicking on the column title.

![Recorded Requests](requesttracker.png)

Clicking on any row opens a second window displaying the detail request progress information as recorded before with the `RequestProgressTracker`.

![Details of a recorded Request](requesttracker-details.png)

The size, location, and the widths of the table columns are persisted with the Java Preferences API and thus when starting the application again, these settings are preserved.
