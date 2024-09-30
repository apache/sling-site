title=Rendering Content - GET Servlets
type=page
status=published
tags=servlets
~~~~~~

[TOC]

# Overview

Sling provides a number of servlets answering `GET` or `HEAD`, in the [`org.apache.sling.servlets.get` bundle](https://github.com/apache/sling-org-apache-sling-servlets-get).

Those provide useful functionality out of the box for example JSON rendering of content.

This page provides an overview of these servlets shipping with Sling.

# DefaultGetServlet

The `DefaultGetServlet` is registered on the special [resource type `sling/servlet/default`](../the-sling-engine/servlets.html#default-servlets) which acts as fallback whenever no more specifically registered servlet can be found.
It answers both `GET` and `HEAD` requests.

Its configuration can be found at `/system/console/configMgr/org.apache.sling.servlets.get.DefaultGetServlet` on a standard Sling setup,
and should be self-explaining. One common use case of adjusting the configuration is to disable some of the default renderings listed below,
as they might not be useful or desired on production systems. 

If not otherwise mentioned for specific renderings the servlet does not support conditional requests as specified by [RFC 7232](https://tools.ietf.org/html/rfc7232) (i.e. the `If-....` request headers are disregarded and the response will neither contain `ETag` nor `Last-Modified` headers).

## Default renderings

### JSON rendering

Adding a .json extension to a request triggers the default Sling GET servlet in JSON mode, unless a 
more specific servlet or script is provided for the current resource.

This servlet currently supports the following selectors:

  * `.tidy` causes the JSON output to be formatted
  * `.harray` causes child nodes to be output as arrays instead of objects, to preserve their order (requires `org.apache.sling.servlets.get` V2.1.10)
  * A numeric value or `.infinity` as the last selector selects the desired recursion level 

Note that the number of elements is limited by a configurable value, see the `DefaultGetServlet` configuration for more info.

### HTML rendering

In a similar way, adding a `.html` extension to a request triggers the default Sling GET servlet in HTML
mode. That rendering just dumps the current node values in a readable way, but it's only really useful
for troubleshooting.

### Text rendering

A basic text rendering is also provided if the request has a `.txt` extension, unless more specific servlets
or scripts are provided.

### XML rendering

Adding a `.xml` extension triggers the default XML rendering, once again unless a more specific script or
servlet is registered for the current resource.

That XML rendering currently uses the JCR "document view" export functionality directly, so it only supports
rendering resources that are backed by JCR nodes.

### Stream rendering

Whenever the request carries the extension `.res` or no extension at all, the [resource's input stream](../the-sling-engine/resources.html) is spooled to the servlet's response (leveraging `Resource.adaptTo(InputStream.class)`). This servlet supports [conditional requests (RFC 7232)](https://tools.ietf.org/html/rfc7232) based on the last-modified response header by evaluating the resource's modification date from `Resource.getResourceMetadata().getModificationTime()`  and [range requests (RFC 7233)](https://tools.ietf.org/html/rfc7233).

In case the underlying resource's InputStream is an [ExternalizableInputStream](https://github.com/apache/sling-org-apache-sling-api/blob/master/src/main/java/org/apache/sling/api/resource/external/ExternalizableInputStream.java) instead a redirect towards its URI is triggered ([SLING-7140](https://issues.apache.org/jira/browse/SLING-7140)).

## Programmatically reusing DefaultGetServlet

There are scenarios where it is useful to stream e.g. a binary resource using the default GET servlet with a different extension/resource type. However, there is
no API to select a specific servlet. We can still stream using the default GET servlet by taking advantage of the
fact that it is also registered for the _res_ extension. The code to do that from your custom servlet would be:

    Resource toRender = /* code to obtain resource here */ null;
    request
        .getRequestDispatcher(toRender.getPath() + ".res")
        .forward(request, response);  

See also [SLING-8742 - Allow overriding the extension when using the RequestDispatcher](https://issues.apache.org/jira/browse/SLING-8742)
for a discussion on providing an API for this use case.

The same approach is possible for all other rendering by retrieving a request dispatcher with the appropriate selector.

# RedirectServlet

The `RedirectServlet` handles the `sling:redirect` resource type, using the `sling:target` property of the
resource to define the redirect target, and the `sling:status` property to define the HTTP status to use (default is 302).

This is not to be confused with the `sling:redirect` property used under `/etc/map`, which is described in 
[Mappings for Resource Resolution](/documentation/the-sling-engine/mappings-for-resource-resolution.html)

# SlingInfoServlet

The `SlingInfoServlet` provides info on the current JCR session, for requests that map to JCR nodes.

It is available at `/system/sling/info.sessionInfo` by default, and supports `.json` and `.txt` extensions. 

# JCR Versions Support

The extensions created for [SLING-848](https://issues.apache.org/jira/browse/SLING-848) 
and [SLING-4318](https://issues.apache.org/jira/browse/SLING-4318) provide some access to JCR version 
management features, along with the [Sling POST Servlet](/documentation/bundles/manipulating-content-the-slingpostservlet-servlets-post.html) 
versioning-related features.

It obviously only works on top of Sling resources backed by the [JCR Resource Provider](https://sling.apache.org/documentation/the-sling-engine/resources.html#jcr-based-resources).

Here's an example that demonstrates this.

First, create a versionable node and check it in:

    curl -u admin:admin -Fjcr:mixinTypes=mix:versionable -Fmarker=A http://localhost:8080/vtest
    curl -u admin:admin -F :operation=checkin http://localhost:8080/vtest

via the [Sling POST servlet](manipulating-content-the-slingpostservlet-servlets-post.html#versionable-node-support).

## VersionInfoServlet

Use the [org.apache.sling.servlets.get.impl.version.VersionInfoServlet](http://localhost:8080/system/console/configMgr/org.apache.sling.servlets.get.impl.version.VersionInfoServlet) OSGi configuration to activate the `VersionInfoServlet` which supports
the `.V.json` selector shown below. That servlet is disabled by default to make sure the configurable V selector doesn't interfere with existing applications.

It is registered to the resource type `sling/servlet/default` for the configurable selector `V`.

To shows the initial versions state just request the relevant resource with the `V` selector:

    curl -s -u admin:admin http://localhost:8080/vtest.V.json
    {
      "versions": {
        "jcr:rootVersion": {
          "created": "Tue Jan 23 2018 14:08:09 GMT+0100",
          "successors": [
            "1.0"
          ],
          "predecessors": [],
          "labels": [],
          "baseVersion": "false"
        },
        "1.0": {
          "created": "Tue Jan 23 2018 14:08:35 GMT+0100",
          "successors": [],
          "predecessors": [
            "jcr:rootVersion"
          ],
          "labels": [],
          "baseVersion": "true"
        }
      }
    }    
    
Now, create two additional versions with a different `marker` value:

    curl -u admin:admin -F :autoCheckin=true -F :autoCheckout=true -Fmarker=B http://localhost:8080/vtest
    curl -u admin:admin -F :autoCheckin=true -F :autoCheckout=true -Fmarker=C http://localhost:8080/vtest
    
The `VersionInfoServlet` now shows all versions (output abbreviated):

    curl -s -u admin:admin http://localhost:8080/vtest.V.json
    {
      "versions": {
        "jcr:rootVersion": {
          "successors": [
            "1.0"
          ],
          "predecessors": []
        },
        "1.0": {
          "successors": [
            "1.1"
          ],
          "predecessors": [
            "jcr:rootVersion"
          ]
        },
        "1.1": {
          "successors": [
            "1.2"
          ],
          "predecessors": [
            "1.0"
          ]
        },
        "1.2": {
          "successors": [],
          "predecessors": [
            "1.1"
          ]
        }
      }
    }

## Version URI path parameter on DefaultGetServlet

And the [`;v=` URI path parameter](../the-sling-engine/url-decomposition.html) gives access to each version (output abbreviated):

    curl -s "http://localhost:8080/vtest.tidy.json;v=1.0"
    {
      "marker": "A",
      "jcr:frozenUuid": "a6fd966d-917d-49e2-ba32-e7f942ff3a0f",
      "jcr:uuid": "74291bc8-e7cb-4a71-ab3a-224ba234be0a"
    }
    
    curl -s "http://localhost:8080/vtest.tidy.json;v=1.1"
    {
      "marker": "B",
      "jcr:frozenUuid": "a6fd966d-917d-49e2-ba32-e7f942ff3a0f",
      "jcr:uuid": "18b38479-a3fc-4a21-9cd4-89c44daf917d"
    }
    
    curl -s "http://localhost:8080/vtest.tidy.json;v=1.2"
    {
      "marker": "C",
      "jcr:frozenUuid": "a6fd966d-917d-49e2-ba32-e7f942ff3a0f",
      "jcr:uuid": "3d55430b-2fa6-4562-b415-638fb6608c0e"
    }