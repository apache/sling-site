title=Mappings for Resource Resolution		
type=page
status=published
tags=core,resources,resourcemappings
~~~~~~

[TOC]

## Configuration

The resource resolution (mapping a request path to a resource in Sling's resource tree) can be influenced in different ways:

- Root Level Mappings
- Alias Configurations
- Vanity Path Configurations
- Namespace Mangling

## Root Level Mappings

The mapping of request URLs to resources is mainly configured in a configuration tree which is (by default) located below `/etc/map`. While the actual location can be configured with the property `resource.resolver.map.location` of the OSGi configuration `org.apache.sling.jcr.resource.internal.JcrResourceResolverFactoryImpl`, it is suggested to leave the default value.

When dealing with the resource resolution we have a number of properties influencing the process:

* `sling:match` &ndash; This property when set on a resource in the `/etc/map` tree (see below) defines a partial regular expression which is used instead of the resource's name to match the incoming request. This property is only needed if the regular expression includes characters which are not valid JCR name characters. The list of invalid characters for JCR names is: `/, :, [, ], *, ', ", \, |` and any whitespace except blank space. In addition a name without a name space may not be `.` or `..` and a blank space is only allowed inside the name.
* `sling:redirect` &ndash; This property when set on a resource in the `/etc/map` tree (see below) causes a redirect response to be sent to the client, which causes the client to send in a new request with the modified location. The value of this property is applied to the actual request and sent back as the value of `Location` response header.
* `sling:status` &ndash; This property defines the HTTP status code sent to the client with the `sling:redirect` response. If this property is not set, it defaults to 302 (Found). Other status codes supported are 300 (Multiple Choices), 301 (Moved Permanently), 303 (See Other), and 307 (Temporary Redirect).
* `sling:internalRedirect` &ndash; This property when set on a resource in the `/etc/map` tree (see below) causes the current path to be modified internally to continue with resource resolution. This is a multi-value property, i.e. multiple paths can be given here, which are tried one after another until one resolved to a resource.

Root Level Mappings apply to the request at large including the scheme, host, port and uri path. To accomplish this a path is constructed from the request like this `{scheme}/{host}.{port}/{uri_path}`. This string is then matched against mapping entries below `/etc/map` which are structured in the content analogously. The longest matching entry string is used and the replacement, that is the redirection property, is applied.

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

**NOTE:** Since the entries in the `/etc/map` are also used to reverse map any resource paths to URLs, using regular expressions with wildcards in the Root Level Mappings prevent the respective entries from being used for reverse mappings. Therefore, it is strongly recommended to not use regular expression matching, unless you have a strong need.

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

## String Interpolation for /etc/map

Setting up `/etc/map` for different environments like _dev, stage, qa and production_ was time consuming and error prone due to copy-n-paste errors.

With [SLING-7768](https://issues.apache.org/jira/browse/SLING-7768) Sling now supports String Interpolation under `/etc/map`. Before you had to configure the location of the mapping and make it run mode aware by taking advantage of the Sling OSGi Installer's run mode awareness.

With the string interpolation feature it is possible to add placeholders to **sling:match** entries to adapt them to different environments.

The values are either provided by System, Bundle Context or String Interpolation Configuration values.

The placeholders have this format: **$['type':'name';default='default value']**.

The type can be:

 * **env**: taken from the [Environment Variables](https://docs.oracle.com/javase/8/docs/api/java/lang/System.html#getenv-java.lang.String-)
 * **prop**: taken from the [Bundle Context Properties](https://docs.osgi.org/javadoc/r6/core/org/osgi/framework/BundleContext.html#getProperty(java.lang.String)) (first evaluates OSGi Framework Properties, then System Properties) 
 * **config**: taken from the String Interpolation Configuration

With this it is possible to create a single set of `/etc/map` definitions and then adjust the actual values of an instance by an OSGi configuration.

**Note**: the placeholder **must be placed** into a **sling:match** entry and cannot be the JCR Node name, as some of the characters are not allowed.

### Setting up /etc/map interpolation

The Substitution Configuration can be found in the OSGi Configuration as **Apache Sling String Interpolation Provider**.

The property **Placeholder Values** takes a list of **key=value** entries where each of them map a variable with its actual value.

In our little introduction we add an entry of **phv.default.host.name=localhost**. Save the configuration for now. Before going on make sure that you know Mapping Location configuration in the OSGi configuration of **Apache Sling Resource Resolver Factory**.

Now go to **composum** and go to that node. If it does not exist then create one.

The mapping should look like this:

    * etc
        * map
            * http
                * my-mapping
                    * sling:match=$\[phv.fq.host.name\].8080

Opening the page **http://localhost:8080/starter/index.html** should work just fine.

This is a mapping from System Properties with a default:

    * etc
        * map
            * http
                * my-mapping
                    * sling:match=$\[env:phv.fq.host.name;default=localhost\].8080

### Testing /etc/map interpolation

Now got back to the String Interpolation configuration and change the value to **qa.author.acme.com** and save it.

For local testing open your **hosts** file (/etc/hosts on Unix) and add a line like this:
```
127.0.0.1 qa.author.acme.com
```
save it and test with `ping qa.author.acme.com` to make sure the name resolves. Now you should be able to open the same page with: **http://qa.author.acme.com/starter/index.html**.

Now do the same with **phv.fq.host.name=staging.author.acme.com**.

The String Interpolation works with any part of the etc-map tree.

## Alias Configurations

The property `sling:alias` may be set on any resource to indicate an alias name for the resource. For example the resource `/content/visitors` may have the `sling:alias` property set to `besucher` allowing the resource to be addressed in an URL as `/content/besucher` as well as the original path `/content/visitors`.

### Impact of Alias Handling

In general, the number of aliases have a direct impact on the performance of the resource resolution - as basically all possible permutations of paths for a resource have to be tested against the incoming request path. By default a cache is used to speed up handling aliases during resolving resources. It is highly recommended to have this cache enabled to avoid slowing down request performance. However, the cache might have an impact on startup time and on the alias update time if the number of aliases is huge (over 10000).

The cache can be disabled by setting the property `resource.resolver.optimize.alias.resolution` of the OSGi configuration `org.apache.sling.jcr.resource.internal.JcrResourceResolverFactoryImpl` to `false`.

### Limitation of `sling:alias` for Principal with a limited access

Assuming there is

* An User named `testuser`
* An ACE with deny `jcr:all` in `/` for `everyone`
* An ACE with allow `jcr:read` in `/content` for `testuser`

If the `sling:alias` property (e.g. `myalias`) is set directly in `/content`, the User `testuser` will not be able to address the resource `/content` in an URL as `/myalias`.
Instead if the `sling:alias` property is set in any resource under `/content` (e.g. `/content/visitors`) the `sling:alias` feature will work as usual.

## Vanity Path Configuration

While an alias can provide a variation for a resource name, a vanity path can provide an alternative path for a resource. The following properties can be set on a resource:

* `sling:vanityPath` &ndash; This property when set on any resource defines an alternative path to address the resource.
* `sling:redirect` &ndash; This boolean property when set to `true` on a resource with a vanity path causes a redirect response to be sent to the client, which causes the client to send in a new request with the modified location. The value of the `sling:vanitaPath` property is applied to the actual request and sent back as the value of the `Location` response header.
* `sling:redirectStatus` &ndash; This property defines the HTTP status code sent to the client with the `sling:redirect` response. If this property is not set, it defaults to 302 (Found). Other status codes supported are 300 (Multiple Choices), 301 (Moved Permanently), 303 (See Other), and 307 (Temporary Redirect).
* `sling:vanityOrder` &ndash; It might happen that several resources in the resource tree specify the same vanity path. In that case the one with the highest order is used. This property can be used to set such an order.

### Rebuilding The Vanity Bloom Filter

[SLING-4216](https://issues.apache.org/jira/browse/SLING-4216) introduced the usage of a bloom filter in order to resolve long startup time with many vanityPath entries.
The bloom filter is handled automatically by the Sling framework. In some cases though, as changing the maximum number of vanity bloom filter bytes, a rebuild of the vanity bloom filter is needed.

In order to rebuild vanity bloom filter:

* stop Apache Sling
* locate the org.apache.sling.resourceresolver bundle in the file system (e.g. $SLING_HOME/felix/bundleXX)
* locate the vanityBloomFilter.txt file in the file system (e.g. $SLING_HOME/felix/bundleXX/data/vanityBloomFilter.txt)
* delete the vanityBloomFilter.txt file
* start Apache Sling (this might take few minutes, depending on how many vanity path entries are present)

## Interactions between mappings and authentication requirements

The [Sling authentication](/documentation/the-sling-engine/authentication.html) mechanism works by registering authentication requirements for paths which are protected. Normally these authentication requirements transparently apply to child resources as well due to the hierarchical nature of the paths used.

Additional mappings complicate the situation, therefore additional authentication requirements are automatically registered by Sling. For instance, assuming the following repository structure:

    /content
        +-- parent
            +-- sling:alias = "secret"
            +-- child


and that `/content/parent` is a protected resource, authentication requirements will automatically be registered for both `/content/parent` and `/content/secret`.

<div class="note">Although the section below uses vanity paths, it applies equally to mappings set up in <code>/etc/map</code></div>

One scenario where authentication requirements will not be registered properly is when the child of a protected resource has an external vanity path ( or resource mapping ) that is not a descendant of an existing authentication requirement, such as:

    /content
        +-- parent
            +-- child
                +-- sling:vanityPath = "/vanity"

In this scenario no authentication requirement will be registered for `/vanity`, which lead to the resource being accessible without authentication. If registering mappings for children of protected resources is desired, the following precautions must be taken:

- use external redirects. These will instruct the client to generate a new HTTP request, which will be properly handled by the Sling authentication
- manually set up authentication reqiurements for internal mappings

For an in-depth discussion on the matter, see [SLING-9622 - Avoid registration of auth requirements for aliases and vanity paths](https://issues.apache.org/jira/browse/SLING-9622) and also [SLING-9689 - Handle authentication requirements for children of protected resources when internal mappings](https://issues.apache.org/jira/browse/SLING-9689) for plans of improving the situation.

## Namespace Mangling

There are systems accessing Sling, which have a hard time handling URLs containing colons (`:`) in the path part correctly. Since URLs produced and supported by Sling may contain colons as JCR based resources may be namespaced (e.g. `jcr:content`), a special namespace mangling feature is built into the `ResourceResolver.resolve(...)` and `ResourceResolver.map(...)` methods.

Namespace mangling operates such, that any namespace prefix identified in a resource path to be mapped as an URL in the `map` methods is modified such that the prefix is enclosed in underscores and the colon is removed.

*Example*: The path `/content/_a_sample/jcr:content/jcr:data.png` is modified by namespace mangling in the `map` method to `/content/_a_sample/_jcr_content/_jcr_data.png`.

Conversely, the `resolve` methods must undo such namespace mangling to get back at the resource path. This is simple done by modifying any path such that segments starting with an underscore enclosed prefix are changed by removing the underscores and adding a colon after the prefix. There is one catch: Due to the way the `SlingPostServlet` automatically generates names, there may be cases where the actual name would be matching this mechanism. Therefore only prefixes are modified which are actually namespace prefixes.

*Example*: The path `/content/_a_sample/_jcr_content/_jcr_data.png` is modified by namespace mangling in the `resolve` method to get `/content/_a_sample/jcr:content/jcr:data.png`. The prefix `_a_` is not modified because there is no registered namespace with prefix `a`. On the other hand the prefix `jcr` is modified because there is of course a registered namespace with prefix `jcr`.

## Debugging Issues

Use the Apache Felix Web Console Plugin provided at `/system/console/jcrresolver` to inspect both the mapping and the resolver map entries. Also you can check what either `ResourceResolver.map(...)` or `ResourceResolver.resolve(...)` would return for a given URL/path.

## JCR Node Types

To ease with the definition of redirects and aliases when using nodes in a JCR repository, the following node types are defined:

* `sling:ResourceAlias` &ndash; This mixin node type defines the `sling:alias` property and may be attached to any node, which does not otherwise allow setting a property named `sling:alias`
* `sling:MappingSpec` &ndash; This mixin node type defines the `sling:match`, `sling:redirect`, `sling:status`, and `sling:internaleRedirect` properties to define a matching and redirection inside the `/etc/map` hierarchy.
* `sling:Mapping` &ndash; Primary node type which may be used to easily construct entries in the `/etc/map` tree. The node type extends the `sling:MappingSpec` mixin node type to allow setting the required matching and redirection. In addition the `sling:Resource` mixin node type is extended to allow setting a resource type and the `nt:hierarchyNode` node type is extended to allow locating nodes of this node type below `nt:folder` nodes.

Note, that these node types only help setting the properties. The implementation itself only cares for the properties and their values and not for any of these node types.
