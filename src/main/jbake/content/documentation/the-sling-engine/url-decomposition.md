title=URL decomposition		
type=page
status=published
tags=core,urls
~~~~~~

[TOC]

# Overview #
During the *Resource Resolution* step, the client request URI (as being returned by [HttpServletRequest.getRequestURI()](http://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#getRequestURI())) is decomposed into the following parts (in exactly this order):

1. **Resource Path** - For existing resources the resource path is the longest match (also considering its [mappings](/documentation/the-sling-engine/mappings-for-resource-resolution.html)) pointing to a resource where the next character is either a dot (`.`) or it is the full request URI.
Otherwise (for a path not matching any existing resource) the resource path ends at the *first dot (`.`)* in the request url. The exact logic for retrieving the resource path is implemented at [ResourceResolver.resolve(HttpServletRequest)](https://sling.apache.org/apidocs/sling11/org/apache/sling/api/resource/ResourceResolver.html#resolve-javax.servlet.http.HttpServletRequest-java.lang.String-)  called from `org.apache.sling.engine.impl.request.RequestData.initResource()` with the 2nd argument being the request path. *It is impossible to tell from just looking at the request URI where the resource path part ends. You have to know the underlying resource structure to know how a URL is decomposed. You cannot safely assume that the resource path will always end at the first dot!*.
1. **Selectors** - If the first character in the request URL after the resource path is a dot  (`.`), the string after the dot up to but not including the last dot before the next slash character or the end of the request URL comprises the selectors. If the resource path spans the complete request URL no selectors exist. If only one dot follows the resource path before the end of the request URL or the next slash, also no selectors exist.
1. **Extension** - The string after the last dot after the resource path in the request URL but before the end of the request URL or the next slash after the resource path in the request URL is the extension. 
1. **Suffix** - If the request URL contains a slash character after the resource path and optional selectors and extension, the path starting with the slash up to the end of the request URL is the suffix path. Otherwise, the suffix path is empty. Note, that after the resource path at least a dot must be in the URL to let Sling detect the suffix.

In addition since [SLING-848](https://issues.apache.org/jira/browse/SLING-848) there may be one or multiple **request path parameters**  passed in the form `;<key>=<value>`. Those request path parameters are only supported directly after the *Resource Path* or after the *Extension*. The value needs to be enclosed in `'` if it contains a `.` and is not located after the extension.
It is up to the [Resource Provider](resources.html#providing-resources-1) to decide for what purpose those parameters are being used and which ones are supported at all.

The decomposed parts can be accessed through the `RequestPathInfo` object, which is retrieved via [SlingHttpServletRequest.getPathInfo()](https://sling.apache.org/apidocs/sling7/org/apache/sling/api/SlingHttpServletRequest.html#getRequestPathInfo--).

There's a cheat sheet in Adobe's AEM documentation at [https://docs.adobe.com/docs/en/aem/6-2/develop/platform/sling-cheatsheet.html](https://docs.adobe.com/docs/en/aem/6-2/develop/platform/sling-cheatsheet.html) available to get you familiar with the URL decomposition of Sling.

# Examples #
Assume there is a Resource at `/a/b`, which has no children.

| URI | Resource Path | Selectors | Extension | Suffix | Resource Found |
|---|---|---|---|---|---|
| /a/b                      | /a/b | null  | null | null       | yes |
| /a/b.html                 | /a/b | null  | html | null       | yes |
| /a/b.s1.html              | /a/b | s1    | html | null       | yes |
| /a/b.s1.s2.html           | /a/b | s1.s2 | html | null       | yes |
| /a/b/c/d                  | /a/b/c/d | null  | null | null       | no! |
| /a/c.html/s.txt           | /a/c | null  | html | /s.txt     | no! |
| /a/b./c/d                  | /a/b | null  | null | /c/d       | yes |
| /a/b.html/c/d             | /a/b | null  | html | /c/d       | yes |
| /a/b.s1.html/c/d          | /a/b | s1    | html | /c/d       | yes |
| /a/b.s1.s2.html/c/d       | /a/b | s1.s2 | html | /c/d       | yes |
| /a/b/c/d.s.txt            | /a/b/c/d | s  | txt | null | no! |
| /a/b.html/c/d.s.txt       | /a/b | null  | html | /c/d.s.txt | yes |
| /a/b.s1.html/c/d.s.txt    | /a/b | s1    | html | /c/d.s.txt | yes |
| /a/b.s1.s2.html/c/d.s.txt | /a/b | s1.s2 | html | /c/d.s.txt | yes |


# Automated Tests #

The tests at

* [ResourceResolverImplTest](https://github.com/apache/sling-org-apache-sling-resourceresolver/blob/master/src/test/java/org/apache/sling/resourceresolver/impl/ResourceResolverImplTest.java) shows the split between resource path and the rest. Mostly in the method `testBasicAPIAssumptions`.
* [SlingRequestPathInfoTest](https://github.com/apache/sling-org-apache-sling-engine/blob/master/src/test/java/org/apache/sling/engine/impl/request/SlingRequestPathInfoTest.java) demonstrates the decomposition after the resource path part.

Feel free to suggest additional tests that help clarify how this works!
