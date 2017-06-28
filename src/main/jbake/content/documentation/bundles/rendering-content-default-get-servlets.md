title=Rendering Content - Default GET Servlets		
type=page
status=published
~~~~~~

[TOC]

<div class="note">
Not all features of the <b>org.apache.sling.servlets.get</b> bundle are described below - this
page needs more work.
</div>

# Default GET and HEAD servlets

Sling provides a number of default GET and HEAD servlets, in the `org.apache.sling.servlets.get` bundle.

This provides useful functionality out of the box: JSON rendering of content for example, usually does
not require custom code.

This page provides an overview of these default servlets.

Currently, only the `DefaultGetServlet` has configuration parameters. Those are found at
`/system/console/configMgr/org.apache.sling.servlets.get.DefaultGetServlet` on a standard Sling setup,
and should be self-explaining. One common use is to disable some of the default renderings listed below,
as they might not be useful or desired on production systems. 

# Default renderings

## Default JSON rendering
Adding a .json extension to a request triggers the default Sling GET servlet in JSON mode, unless a 
more specific servlet or script is provided for the current resource.

This servlet currently supports the following selectors:

  * `.tidy` causes the JSON output to be formatted
  * `.harray` causes child nodes to be output as arrays instead of objects, to preserve their order (requires `org.apache.sling.servlets.get` V2.1.10)
  * A numeric value or `.infinity` as the last selector selects the desired recursion level 

Note that the number of elements is limited by a configurable value, see the `DefaultGetServlet` configuration for more info.

## Default HTML rendering

In a similar way, adding a `.html` extension to a request triggers the default Sling GET servlet in HTML
mode. That rendering just dumps the current node values in a readable way, but it's only really useful
for troubleshooting.

## Default text rendering

A basic text rendering is also provided if the request has a `.txt` extension, unless more specific servlets
or scripts are provided.

## Default XML rendering

Adding a `.xml` extension triggers the default XML rendering, once again unless a more specific script or
servlet is registered for the current resource.

That XML rendering currently uses the JCR "document view" export functionality directly, so it only supports
rendering resources that are backed by JCR nodes.

## StreamRendererServlet

Whenever the request carries the extension `.res` or no extension at all, the resource's input stream is spooled to the servlet response (leveraging `Resource.adaptTo(InputStream.class)`). This servlet supports conditional requests ([RFC 7232](https://tools.ietf.org/html/rfc7232)) evaluating the resource's modification date from `Resource.getResourceMetadata().getModificationTime()`  and range requests ([RFC 7233](https://tools.ietf.org/html/rfc7233)).

## RedirectServlet

The `RedirectServlet` handles the `sling:redirect` resource type, using the `sling:target` property of the
resource to define the redirect target, and the `sling:status` property to define the HTTP status to use (default is 302).

This is not to be confused with the `sling:redirect` property used under `/etc/map`, which is described in 
[Mappings for Resource Resolution](/documentation/the-sling-engine/mappings-for-resource-resolution.html)

## SlingInfoServlet

The `SlingInfoServlet` provides info on the current JCR session, for requests that map to JCR nodes.

It is available at `/system/sling/info.sessionInfo` by default, and supports `.json` and `.txt` extensions. 
