title=Servlet Resolution
type=page
status=published
tags=servlets,servletresolver
~~~~~~
<div class="warning">
Please note that the description on this page is out of sync with the most recent developments going on as part of implementing issue [SLING-387]({{ refs.https://issues.apache.org/jira/browse/SLING-387.path }}). See the links to integration tests at the end of this page for the Current Truth.

Please see the new [Servlets]({{ refs.servlets.path }}) page.
</div>

[TOC]


## Servlets are Resources

As explained on the [Resources]({{ refs.resources.path }}) page, the Resource is the central data abstraction of Sling. In this contexts, Servlets are of course also povided as Resources. As such Servlets may be enumerated by iterating the Resource tree and Servlets may be retrieved through the `ResourceResolver`.

To show a Servlet inside the Resource tree, the `sling/servlet-resolver` project provides a `ServletResourceProvider` implementing the `ResourceProvider` interface. For each Servlet registered as an OSGi service with one or more defined service reference properties a `ServletResourceProvider` instance is registered.

The following service reference properties are defined for Servlets defined as OSGi services of type `javax.servlet.Servlet`:

| Name | Description |
|---|---|
| `sling.servlet.paths` | A list of absolute paths under which the servlet is accessible as a Resource. The property value must either be a single String, an array of Strings or a Vector of Strings. |
| `sling.servlet.resourceTypes` | The resource type(s) supported by the servlet. The property value must either be a single String, an array of Strings or a Vector of Strings. This property is ignored if the `sling.servlet.paths` property is set. |
| `sling.servlet.selectors` |  The request URL selectors supported by the servlet. The selectors must be configured as they would be specified in the URL that is as a list of dot-separated strings such as <em>print.a4</em>. The property value must either be a single String, an array of Strings or a Vector of Strings. This property is ignored if the `sling.servlet.paths` property is set. |
| `sling.servlet.extensions` | The request URL extensions supported by the servlet for GET requests. The property value must either be a single String, an array of Strings or a Vector of Strings. This property is ignored if the `sling.servlet.paths` property is set. |
| `sling.servlet.methods` |  The request methods supported by the servlet. The property value must either be a single String, an array of Strings or a Vector of Strings. This property is ignored if the `sling.servlet.paths` property is set. |
| `sling.servlet.prefix` |  The absolute prefix to make relative paths absolute. This property is a String and is optional. If it is not set, the actual prefix used is derived from the search path of the `ResourceResolver` at the time of registration. |


For a Servlet registered as an OSGi service to be used by the Sling Servlet Resolver, the following restrictions apply:

1. Either the `sling.servlet.paths` or the `sling.servlet.resourceTypes` service reference property must be set. If neither is set, the Servlet service is ignored.
1. If the `sling.servlet.paths` property is set, all other `sling.servlet.*` properties are ignored.
1. Otherwise a Resource provider is registered for the Servlet for each permutation resource types, selectors, extensions and methods.


Each path to be used for registration -- either from the `sling.servlet.paths` property or constructed from the other `sling.servlet.*` properties -- must be absolute. Any relative path is made absolute by prefixing it with a root path. This prefix may be set with the `sling.servlet.prefix` service registration property. If this property is not set, the first entry in the `ResourceResolver` search path for the `ResourceResolver.getResource(String)` method is used as the prefix. If this entry cannot be derived, a simpe slash -- `/` -- is used as the prefix.


### Example: Registration by Path


    sling.servlet.paths = [ "/libs/sling/sample/html", "/libs/sling/sample/txt" ]
    sling.servlet.resourceTypes = [ "sling/unused" ]
    sling.servlet.selectors = [ "img" ]
    sling.servlet.extensions = [ "html", "txt", "json" ]


A Servlet service registered with these properties is registered under the following paths:

   * `/libs/sling/sample/html`
   * `/libs/sling/sample/txt`

The registration properties `sling.servlet.resourceTypes`, `sling.servlet.selectors` and `sling.servlet.extensions` are ignored because the `sling.servlet.paths` property is set.


### Example: Registration by Resource Type etc.


    sling.servlet.resourceTypes = [ "sling/unused" ]
    sling.servlet.selectors = [ "img", "tab" ]
    sling.servlet.extensions = [ "html", "txt", "json" ]


A Servlet service registered with these properties is registered under the following paths:

   * `*prefix*/sling/unused/img/html`
   * `*prefix*/sling/unused/img/txt`
   * `*prefix*/sling/unused/img/json`
   * `*prefix*/sling/unused/tab/html`
   * `*prefix*/sling/unused/tab/txt`
   * `*prefix*/sling/unused/tab/json`

As explained the script is registered for each permutation of the resource types, selectors and extension. See above For an explanation of how `*prefix*` is defined.


## Scripts are Servlets


The Sling API defines a `SlingScript` interface which is used to represent (executable) scripts inside of Sling. This interface is implemented in the `scripting/resolver` bundle in the `DefaultSlingScript` class which also implements the `javax.servlet.Servlet`.

To further simplify the access to scripts from the Resource tree, the `scripting/resolver` bundle registers an `AdapterFactory` to adapt Resources to Scripts and Servlets. In fact the adapter factory returns instances of the `DefaultSlingScript` class for both Scripts and Servlets.

This functionality is used by the `ServletResolver.resolveServlet` implementation in the `sling/servlet-resolver` bundle: This implementation just looks up any Resource in the resource tree according its lookup algorithm (see below). The first matching Resource adapting to a `javax.servlet.Servlet` is used for processing the resource.

So from the perspective of the Servlet resolver, scripts and servlets are handled exactly the same.


## Resolution Process

The Servlet Resolution Process four elements of a `SlingHttpServletRequest`:

1. The *resource type* as retrieved through `request.getResource().getResourceType()`. Because the resource type may be a node type such as *nt:file*, the resource type is mangled into a path by replacing any colons contained to forward slashs. Also, any backslashes contained are replaced to forward slashes. This should give a relative path. Of course a resource type may also be set to an absolute path. See below.
1. The *request selectors* as retrieved through `request.getRequestPathInfo().getSelectorString()`. The selector string is turned into a realtive path by replacing all separating dots by forward slashes. For example the selector string `print.a4` is  converted into the relative path `print/a4`.
1. The *request extension* as retrieved through `request.getRequestPathInfo().getExtension()` if the request method is *GET* or *HEAD* and the request extension is not empty.
1. The *request method name* for any request method except *GET* or *HEAD* or if the request extension is empty.

The *resource type* is used as a (relative) parent path to the Servlet while the *request extension* or *request method* is used as the Servlet (base) name. The Servlet is retrieved from the Resource tree by calling the `ResourceResolver.getResource(String)` method which handles absolute and relative paths correctly by searching realtive paths in the configured search path.

The pseudo-code for Servlet resolution is as follows:


    Servlet resolveServlet(SlingHttpServletRequest request) {

        String resourceType = request.getResource().getResourceType();
        resourceType = resourceType.replaceAll("\\:", "/");

        String baseName;
        if (("GET".equals(request.getMethod()) || "HEAD".equals(request.getMethod())
                && request.getRequestPathInfo().getExtension() != null) {
            baseName = request.getRequestPathInfo().getExtension();
        } else {
            baseName = request.getMethod();
        }

        if (request.getRequestPath().getSelectorString() != null) {
            String selectors = request.getRequestPath().getSelectorString();
            selectors = selectors.replace('.', '/');
            while (selectors != null) {
                String path = resourceType + "/" + selectors + "/" + baseName;
                Servlet servlet = findServletFor(path);
                if (servlet != null) {
                    return servlet;
                }

                int lastSlash = selectors.lastIndexOf('/');
                if (lastSlash > 0) {
                    selectors = selectors.substring(0, lastSlash);
                } else {
                    selectors = null;
                }
            }
        }

        String path = resourceType + "/" + baseName;
        return findScriptFor(path);
    }

    Servlet findScriptFor(path) {
        // Find a Servlet or Script with the given path in the search path
        // where the Script is allowed to have Script language specific
        // extension, such as .js, .jsp, etc.
    }



## Default Servlet(s)

As explained in the Resolution Process section above, a default Servlet is selected if no servlet for the current resource type can be found. To make the provisioning of a default Servlet as versatile as provisioning per resource type Servlets (or scripts), the default Servlet is selected with just a special resource type `sling/servlet/default`.

The actual Servlet or Script called as the default Servlet is resolved exactly the same way as for any resource type. That is, also for the default Servlet selection, the request selectors and extension or method are considered. Also, the Servlet may be a Servlet registered as an OSGi service and provided through a Servlet Resource provider or it may be a Script stored in the repository or provided by the bundle.

Finally, if not even a registered default Servlet may be resolved for the request, because none has been registered, the `sling/servlet-resolve` bundle provides a fall back `DefaultServlet` with the following functionality:

   * If the request has no extension and the Resource of the request adapts to an `InputStream`, the contents of the resoure is stream out as the response. The response content type is taken from the `sling.contentType` Resource meta data or derived from the Resource path. If the `sling.characterEncoding` Resource meta data property is set, that value is used as the response character encoding. Currently there is no ETag and modification time stamp support.
   * Otherwise if the object has an OCM mapping, the properties of the mapped object are printed.
   * Otherwise just the path of the Resource is printed.


## Error Handler Servlet(s)

The `sling/servlet-resolver` project also provides an implementation of the Sling Core `ErrorHandler` interface, which applies the same Servlet resolution process as used for normal request processing. Error handler Servlets and Scripts are looked up with the predefined resource `sling/servlet/errorhandler` and an error specific name:

   * *HTTP Status Code Handling*: To handle HTTP status code as used by the `HttpServletResponse.sendError` methods, status code is used as the Servlet name. For example to provide a handler for status code 404 (NOT*FOUND), you could create a script `prefix/sling/servlet/errorhandler/404.esp` or for a status code 500 (INTERNAL*SERVER_ERRROR), you might want to register a Servlet at `prefix/sling/servlet/errorhandler/500`.
   * *Throwable Handling*: To handle uncaught `Throwables` the simple name of the `Throwable` class is used as the Servlet name. Similarly to the Java `try-catch` clauses the class hierarchy is supported. That is to handle an uncaught `FileNotFoundException`, the names `FileNotFoundException`, `IOException`, `Exception`, `Throwable` are checked for a Servlet and the first one found is then used. Again, the Serlvet may be a Servlet registered as an OSGi service or may be a plain script stored in the JCR repository or provided through some custom Resource provider.

## Integration tests
A set of simple example servlets is available in the [launchpad/test-services module]({{ refs.https://svn.apache.org/repos/asf/incubator/sling/trunk/launchpad/test-services.path }}).

Integration tests in the [launchpad/testing module]({{ refs.https://svn.apache.org/repos/asf/incubator/sling/trunk/launchpad/testing/src/test/java/org/apache/sling/launchpad/webapp/integrationtest/servlets/resolution.path }}) verify that these examples are correct.

Contributions to these tests and examples are welcome, of course!
