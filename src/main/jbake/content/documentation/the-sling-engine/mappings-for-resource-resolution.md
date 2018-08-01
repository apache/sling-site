title=Mappings for Resource Resolution		
type=page
status=published
tags=core,resources,resourcemappings
~~~~~~

[TOC]

## Configuration


### Properties

The mapping of request URLs to resources is mainly configured in a configuration tree which is (by default) located below `/etc/map`. The actual location can be configured with the `resource.resolver.map.location` property of the `org.apache.sling.jcr.resource.internal.JcrResourceResolverFactoryImpl` configuration.
That way you can even make it run mode specific, by taking advantage of the Sling OSGi Installer's run mode awareness.


When dealing with the new resource resolution we have a number of properties influencing the process:

* `sling:match` &ndash; This property when set on a node in the `/etc/map` tree (see below) defines a partial regular expression which is used instead of the node's name to match the incoming request. This property is only needed if the regular expression includes characters which are not valid JCR name characters. The list of invalid characters for JCR names is: `/, :, [, ], *, ', ", \, |` and any whitespace except blank space. In addition a name without a name space may not be `.` or `..` and a blank space is only allowed inside the name.
* `sling:redirect` &ndash; This property when set on a node in the `/etc/map` tree (see below) causes a redirect response to be sent to the client, which causes the client to send in a new request with the modified location. The value of this property is applied to the actual request and sent back as the value of `Location` response header.
* `sling:status` &ndash; This property defines the HTTP status code sent to the client with the `sling:redirect` response. If this property is not set, it defaults to 302 (Found). Other status codes supported are 300 (Multiple Choices), 301 (Moved Permanently), 303 (See Other), and 307 (Temporary Redirect).
* `sling:internalRedirect` &ndash; This property when set on a node in the `/etc/map` tree (see below) causes the current path to be modified internally to continue with resource resolution. This is a multi-value property, i.e. multiple paths can be given here, which are tried one after another until one resolved to a resource.
* `sling:alias` &ndash; The property may be set on any resource to indicate an alias name for the resource. For example the resource `/content/visitors` may have the `sling:alias` property set to `besucher` allowing the resource to be addressed in an URL as `/content/besucher`.

#### Limitation of `sling:alias` for Principal with a limited access

Assuming there is

* An User named `testuser`
* An ACE with deny `jcr:all` in `/` for `everyone`
* An ACE with allow `jcr:read` in `/content` for `testuser`

If the `sling:alias` property (e.g. `myalias`) is set directly in `/content`, the User `testuser` will not be able to address the resource `/content` in an URL as `/myalias`.
Instead if the `sling:alias` property is set in any resource under `/content` (e.g. `/content/visitors`) the `sling:alias` feature will work as usual.

### Node Types

To ease with the definition of redirects and aliases, the following node types are defined:

* `sling:ResourceAlias` &ndash; This mixin node type defines the `sling:alias` property and may be attached to any node, which does not otherwise allow setting a property named `sling:alias`
* `sling:MappingSpec` &ndash; This mixin node type defines the `sling:match`, `sling:redirect`, `sling:status`, and `sling:internaleRedirect` properties to define a matching and redirection inside the `/etc/map` hierarchy.
* `sling:Mapping` &ndash; Primary node type which may be used to easily construct entries in the `/etc/map` tree. The node type extends the `sling:MappingSpec` mixin node type to allow setting the required matching and redirection. In addition the `sling:Resource` mixin node type is extended to allow setting a resource type and the `nt:hierarchyNode` node type is extended to allow locating nodes of this node type below `nt:folder` nodes.

Note, that these node types only help setting the properties. The implementation itself only cares for the properties and their values and not for any of these node types.

## Namespace Mangling

There are systems accessing Sling, which have a hard time handling URLs containing colons &ndash; `:` &ndash; in the path part correctly. Since URLs produced and supported by Sling may contain colons because JCR Item based resources may be namespaced (e.g. `jcr:content`), a special namespace mangling feature is built into the `ResourceResolver.resolve` and `ResourceResolver(map)` methods.

Namespace mangling operates such, that any namespace prefix identified in resource path to be mapped as an URL in the `map` methods is modified such that the prefix is enclosed in underscores and the colon removed.

*Example*: The path `/content/*a*sample/jcr:content/jcr:data.png` is modified by namespace mangling in the `map` method to get at `/content/*a*sample/*jcr*content/*jcr*data.png`.

Conversely the `resolve` methods must undo such namespace mangling to get back at the resource path. This is simple done by modifying any path such that segments starting with an underscore enclosed prefix are changed by removing the underscores and adding a colon after the prefix. There is one catch, tough: Due to the way the SlingPostServlets automatically generates names, there may be cases where the actual name would be matching this mechanism. Therefore only prefixes are modified which are actually namespace prefixes.

*Example*: The path `/content/*a*sample/*jcr*content/*jcr*data.png{*`} *is modified by namespace mangling in the* `{*}resolve{*`} *method to get* `*/content/*a*sample/jcr:content/jcr:data.png{*}{`}*. The prefix* `*\*a{*}{`}`{`} is not modified because there is no registered namespace with prefix `a`. On the other hand the prefix `{*}jcr{*`} is modified because there is of course a registered namespace with prefix `jcr`.

## Root Level Mappings

Root Level Mappings apply to the request at large including the scheme, host, port and uri path. To accomplish this a path is constructed from the request lik this `{scheme}/{host}.{port}/{uri_path}`. This string is then matched against mapping entries below `/etc/map` which are structured in the content analogously. The longest matching entry string is used and the replacement, that is the redirection property, is applied.

### Mapping Entry Specification

Each entry in the mapping table is a regular expression, which is constructed from the resource path below `/etc/map`. If any resource along the path has a `sling:match` property, the respective value is used in the corresponding segment instead of the resource name. Only resources either having a `sling:redirect` or `sling:internalRedirect` property are used as table entries. Other resources in the tree are just used to build the mapping structure.

*Example*

Consider the following content

    /etc/map
          +-- http
               +-- example.com.80
               |    +-- sling:redirect = "http://www.example.com/"
               +-- www.example.com.80
               |    +-- sling:internalRedirect = "/example"
               +-- any_example.com.80
               |    +-- sling:match = ".+\.example\.com\.80"
               |    +-- sling:redirect = "http://www.example.com/"
               +-- localhost_any
               |    +-- sling:match = "localhost\.\d*"
               |    +-- sling:internalRedirect = "/content"
               |    +-- cgi-bin
               |    |    +-- sling:internalRedirect = "/scripts"
               |    +-- gateway
               |    |    +-- sling:internalRedirect = "http://gbiv.com"
               |    +-- (stories)
               |         +-- sling:internalRedirect = "/anecdotes/$1"
               +-- regexmap
                    +-- sling:match = "$1.example.com/$2"
                    +-- sling:internalRedirect = "/content/([^/]+)/(.*)"

This would define the following mapping entries:

| Regular Expression | Redirect | Internal | Description |
|---|---|---|---|
| http/example.com.80 | http://www.example.com | no | Redirect all requests to the Second Level Domain to www |
| http/www.example.com.80 | /example | yes | Prefix the URI paths of the requests sent to this domain with the string `/example` |
| http/.+\.example\.com\.80 | http://www.example.com | no | Redirect all requests to sub domains to www. The actual regular expression for the host.port segment is taken from the `sling:match` property. |
| http/localhost\.\d\* | /content | yes | Prefix the URI paths with `/content` for requests to localhost, regardless of actual port the request was received on. This entry only applies if the URI path does not start with `/cgi-bin`, `gateway` or `stories` because there are longer match entries. The actual regular expression for the host.port segment is taken from the `sling:match` property. |
| http/localhost\.\d*/cgi-bin | /scripts | yes | Replace the `/cgi-bin` prefix in the URI path with `/scripts` for requests to localhost, regardless of actual port the request was received on. |
| http/localhost\.\d*/gateway | http://gbiv.com | yes | Replace the `/gateway` prefix in the URI path with `http://gbiv.com` for requests to localhost, regardless of actual port the request was received on. |
| http/localhost\.\d*/(stories) | /anecdotes/stories | yes | Prepend the URI paths starting with `/stories` with `/anecdotes` for requests to localhost, regardless of actual port the request was received on. |

### Regular Expression Matching

As said above the mapping entries are regular expressions which are matched against path. As such these regular expressions may also contain capturing groups as shown in the example above: `http/localhost\.\d*/(stories)`. After matching the path against the regular expression, the replacement pattern is applied which allows references back to the capturing groups.

To illustrate the matching and replacement is applied according to the following pseudo code:

    #!java
    String path = request.getScheme + "/" + request.getServerName()
            + "." + request.getServerPort() + "/" + request.getPathInfo();
    String result = null;
    for (MapEntry entry: mapEntries) {
        Matcher matcher = entry.pattern.matcher(path);
        if (matcher.find()) {
            StringBuffer buf = new StringBuffer();
            matcher.appendReplacement(buf, entry.getRedirect());
            matcher.appendTail(buf);
            result = buf.toString();
            break;
        }
    }

At the end of the loop, `result` contains the mapped path or `null` if no entry matches the request `path`.

**NOTE:** Since the entries in the `/etc/map` are also used to reverse map any resource paths to URLs, using regular expressions with wildcards in the Root Level Mappings prevent the respective entries from being used for reverse mappings. Therefor, it is strongly recommended to not use regular expression matching, unless you have a strong need.

#### Regular Expressions for Reverse Mappings

By default using regular expressions with wildcards will prevent to use the mapping entry for reverse mappings (see above). 

There is one exception though: If there is a `sling:internalRedirect` property containing a regular expression the map entry will be *exclusively used for reverse mappings* (i.e. used only for `ResourceResolver.map(...)`) (see also [SLING-2560](https://issues.apache.org/jira/browse/SLING-2560)). The same resource may carry a `sling:match` property with wildcards and groups referring to the groups being defined in the `sling:internalRedirect` property. 

This example 

    /etc/map
          +-- http
               +-- example.com.80
               |    +-- sling:internalRedirect = "/content/([^/]+)/home/(.*)"
               |    +-- sling:match = "$1/index/$2"
               
leads to the following entry being used in the reverse mapping table:

| Pattern | Replacement |
| ------- | ----------- |
| /content/([^/]+)/home/(.*) | http://example.com/$1/index/$2 |


### Redirection Values

The result of matching the request path and getting the redirection is either a path into the resource tree or another URL. If the result is an URL, it is converted into a path again and matched against the mapping entries. This may be taking place repeatedly until an absolute or relative path into the resource tree results.

The following pseudo code summarizes this behaviour:

    #!java
    String path = ....;
    String result = path;
    do {
        result = applyMapEntries(result);
    } while (isURL(result));

As soon as the result of applying the map entries is an absolute or relative path (or no more map entries match), Root Level Mapping terminates and the next step in resource resolution, resource tree access, takes place.

## Resource Tree Access

The result of Root Level Mapping is an absolute or relative path to a resource. If the path is relative &ndash; e.g. `myproject/docroot/sample.gif` &ndash; the resource resolver search path (`ResourceResolver.getSearchPath()` is used to build absolute paths and resolve the resource. In this case the first resource found is used. If the result of Root Level Mapping is an absolute path, the path is used as is.

Accessing the resource tree after applying the Root Level Mappings has four options:

* Check whether the path addresses a so called Star Resource. A Star Resource is a resource whose path ends with or contains `/\*`. Such resources are used by the `SlingPostServlet` to create new content below an existing resource. If the path after Root Level Mapping is absolute, it is made absolute by prepending the first search path entry.
* Check whether the path exists in the repository. if the path is absolute, it is tried directly. Otherwise the search path entries are prepended  to the path until a resource is found or the search path is exhausted without finding a resource.
* Drill down the resource tree starting from the root, optionally using the search path until a resource is found.
* If no resource can be resolved, a Missing Resource is returned.

### Drilling Down the Resource Tree

Drilling down the resource tree starts at the root and for each segment in the path checks whether a child resource of the given name exists or not. If not, a child resource is looked up, which has a `sling:alias` property whose value matches the given name. If neither exists, the search is terminated and the resource cannot be resolved.

The following pseudo code shows this algorithm assuming the path is absolute:

    #!java
    String path = ...; // the absolute path
    Resource current = getResource("/");
    String[] segments = path.split("/");
    for (String segment: segments) {
        Resource child = getResource(current, segment);
        if (child == null) {
            Iterator<Resource> children = listChildren(current);
            current = null;
            while (children.hasNext()) {
                child = children.next();
                if (segment.equals(getSlingAlias(child))) {
                    current = child;
                    break;
                }
            }
            if (current == null) {
                // fail
                break;
            }
        } else {
            current = child;
        }
    }

## Rebuild The Vanity Bloom Filter 

[SLING-4216](https://issues.apache.org/jira/browse/SLING-4216) introduced the usage of a bloom filter in order to resolve long startup time with many vanityPath entries.
The bloom filter is handled automatically by the Sling framework. In some cases though, as changing the maximum number of vanity bloom filter bytes, a rebuild of the vanity bloom filter is needed.

In order to rebuild vanity bloom filter:

* stop Apache Sling
* locate the org.apache.sling.resourceresolver bundle in the file system (e.g. $SLING_HOME/felix/bundleXX)
* locate the vanityBloomFilter.txt file in the file system (e.g. $SLING_HOME/felix/bundleXX/data/vanityBloomFilter.txt)
* delete the vanityBloomFilter.txt file
* start Apache Sling (this might take few minutes, depending on how many vanity path entries are present)

## Debugging Issues

Use the Felix Web Console Plugin provided at `/system/console/jcrresolver` to inspect both the mapping and the resolver map entries. Also you can check what either `ResourceResolver.map(...)` or `ResourceResolver.resolve(...)` would return for a given URL/path.

