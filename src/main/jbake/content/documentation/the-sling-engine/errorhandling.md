title=Errorhandling		
type=page
status=published
tags=core,errorhandling
~~~~~~

The Sling Engine includes support for handling uncaught `Throwable` as well as rendering custom HTTP status code pages. This is implemented by expecting a (single) `org.apache.sling.engine.servlets.ErrorHandler` service to which handling of uncaught `Throwable` and HTTP status responses are delegated.

The Sling Servlet Resolver bundle implements this interface by providing an elaborate mechanism to find the correct error handling script or servlet using the same algorithms as are used to select the scripts or servlets to handle regular requests.

This page provides more information on how error handler scripts are selected and what is provided out of the box.

The [ErrorHandlingTest][1] in our integration tests suite provides 
working examples of various error handling scenarios.

[TOC]

## Resetting the Response

Errorhandler scripts and servlets are script with the current response. Before setting
the status and writing to the response such handlers should do the following:

* Check whether the response has been committed or not
* If the response has not been committed:
    * Reset the response
    * Set the status code (use `HttpServletResponse.setStatus`)
    * Set the response content type and character encoding (provided text data is sent back)
* If the response has already been committed:
    * Do not try to reset since this would cause an `IllegalStateException`. Also the writer may not be available.
    * The best that might be done in this case is just log a message at warning or error level along with information about the failure.


## HTTP Status Codes

The Sling engine implements the `HttpServletResponse.sendError` methods by calling the `ErrorHandler.handleError(int status, String message, SlingHttpServletRequest request, SlingHttpServletResponse response)` method.

The Servlet Resolver bundle implementation looks up a script to handle the status code as follows:

  * The status code is converted to a string and used as the request extension. Any request extensions, selectors or suffixes from the actual request are ignored.
  * The same resource type hierarchy is followed to find the script as for regular script resolution. The difference is that for error handler scripts `sling/servlet/errorhandler` is used as the implied base resource type (as opposed to `sling/servlet/default` for regular script resolution.

**Examples:**

  * An application provider my provide a default handler for the 404/NOT FOUND status. This script might be located in `/libs/sling/servlet/errorhandler/404.jsp`.
  * An programmer might provide a handler for the 403/FORBIDDEN status in `/apps/sling/servlet/errorhandler/403.esp`.


## Uncaught Throwables

To handle uncaught Throwables the simple name (`Class.getSimpleName()`) of the `Throwable` class is used as request extension. Similarly to the Java try-catch clauses the class hierarchy is supported. That is to handle an uncaught `FileNotFoundException`, the names `FileNotFoundException`, `IOException`, `Exception`, `Throwable` are checked for a Servlet and the first one found is then used. Again, the Serlvet may be a Servlet registered as an OSGi service or may be a plain script stored in the JCR repository or provided through some custom Resource provider.

**Example:**
To register a catch-all handler for any uncaught Throwables you might create a script `/apps/sling/servlet/errorhandler/Throwable.esp`.

**Note:** If no script or servlet to handle an uncaught `Throwable` is registered, the default handler kicks in, which sends back a 500/INTERNAL SERVER ERROR response containing the `Throwable` and the stack trace. This response is **not** handled by the HTTP Status Code handling described above because the response status is sent using `HttpServletResponse.setStatus(int, String)`. To prevent this default response you have to implement a catch-all handler for the `Throwable` class as shown in the example.

## Default Handler

The Sling Servlet Resolver bundle provides a default error handler servlet which is used if the algorithms described above do not resolve to a handler script or servlet. The provided error handler servlet does the following:

  * Print a descriptive message, which is the `javax.servlet.error.message` request attribute by default
  * Print a stacktrace if the `javax.servlet.error.exception` is set
  * Dump the request progress tracker

Starting with Sling Servlet Resolver version 2.0.10 the default error handler servlet is looked up using the string `default` as the request extension and the provided default servlet is registered as `<prefix>/sling/servlet/errorhandler/default.servlet` where <prefix> is the last entry in the resource resolver search path, `/libs` by default.

Thus to overwrite the default error handler servlet provide a servlet or script for the `default` extension, for example `/apps/sling/servlet/errorhandler/default.groovy`.


  [1]: https://github.com/apache/sling-org-apache-sling-launchpad-integration-tests/blob/master/src/main/java/org/apache/sling/launchpad/webapp/integrationtest/servlets/resolver/errorhandler/ErrorHandlingTest.java
