title=JSP Scripting Engine		
type=page
status=published
tags=scripts,jsp
~~~~~~

The Apache Sling JSP Scripting Engine is implemented by the [`org.apache.sling.scripting.jsp`](https://github.com/apache/sling/tree/trunk/bundles/scripting/jsp)
 bundle, based on the Jasper 2 JSP engine.

On top of that Apache Sling also provides its own JSP Taglib, implemented by the
 [`org.apache.sling.scripting.jsp.taglib`](https://github.com/apache/sling/tree/trunk/bundles/scripting/jsp-taglib) bundle.

The Sling Scripting JSP Taglib supports the use of Sling as an application in JSP pages.  The Sling Taglib provides the
 ability to invoke JSP scripts, include Resources and interact with the Sling Repository, all with JSP tags and
 [Expression Language (EL)](http://docs.oracle.com/javaee/6/tutorial/doc/gjddd.html) functions.

## Use

Using the Sling Taglib in a JSP page is as simple as including the Taglib include in your JSP, with the correct URI for the
version of the Sling Taglib installed.

    <%@taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling" %>

Generally, the prefix to use is `sling`.  Often applications include a global JSP file which includes the Sling Taglib
and sets up all of the application variables and methods.

The Sling Taglib does not attempt to reproduce the functionality of other Tag Libraries, such as
[JSTL](http://www.oracle.com/technetwork/java/index-jsp-135995.html); additional Tag Libraries may be required to fully leverage
the Sling Taglib.

## Taglib Versions

There have been a number of releases of the Sling Taglibs, including versions with different URIs.

| Taglib Version | Bundle Version | URI |
|--|--|--|
| 1.0 | 2.0.6 | http://sling.apache.org/taglibs/sling/1.0 |
| 1.1 | 2.1.0 | http://sling.apache.org/taglibs/sling/1.1 |
| 1.2 | 2.1.8 | http://sling.apache.org/taglibs/sling/1.2 |
| 1.3 | 2.2.0 | http://sling.apache.org/taglibs/sling |

All releases from 1.3 onward are expected to use the URI `http://sling.apache.org/taglibs/sling` to ensure ease of
upgrading to newer versions of the Taglib.

## Expression Language Functions

The Sling Taglib includes a number of Expression Language Functions which can be used to access the repository.

### adaptTo

Adapts an Adaptable to another class.

* Returns: `java.lang.Object`
* Accepts:
    * `org.apache.sling.api.adapter.Adaptable` - The object to adapt
    * `java.lang.String` - The name of the class to which to adapt the adaptable
* Since: 1.3

*Example Usage*

    <c:set var="myProperties" value="${sling:adaptTo(resource,'org.apache.sling.api.resource.ValueMap')}" />

### encode

Writes properly Cross Site Scripting (XSS) encoded text to the response using the OWASP ESAPI.   Supports a number of encoding modes.

* Returns: `java.util.String` - An encoded text
* Accepts:
    * `java.lang.String` - The text to encode
    * `java.lang.String` - The encoding mode, one of HTML, HTML_ATTR, XML, XML_ATTR, JS
* Since: 1.4

*Example Usage*

    ${sling:encode('<script>alert("Bad Stuff!");</script>','HTML')}

### findResources

Searches for resources using the given query formulated in the given language.

* Returns: `java.util.Iterator` - An Iterator of Resource objects matching the query.
* Accepts:
    * `org.apache.sling.api.resource.ResourceResolver` - The Resource Resolver to use for the query.
    * `java.lang.String` - The query string to use to find the resources.
    * `java.lang.String` - The language in which the query is formulated.
* Since: 1.3

*Example Usage*

    <c:forEach var="found" items="${sling:findResources(resourceResolver,'/jcr:root//*[jcr:contains(., 'Sling')] order by @jcr:score','xpath')">
        <li>${found.path}</li>
    </c:forEach>

### getRelativeResource

Gets the resource at the relative path to the provided resource.

* Returns: `org.apache.sling.api.resource.Resource` - The resource at the relative path.
* Accepts:
    * `org.apache.sling.api.resource.Resource` - The resource relative to which to find the path.
    * `java.lang.String` - The relative path at which to find the resource.
* Since: 1.3

*Example Usage*

    <c:set var="content" value="${sling:getRelativeResource(resource,'jcr:content')}" />

### getResource

Method allow for the retrieval of resources.

* Returns: `org.apache.sling.api.resource.Resource` - The resource at the path.
* Accepts:
    * `org.apache.sling.api.resource.ResourceResolver` - The current resource resolver.
    * `java.lang.String` - The path at which to find the resource.
* Since: 1.3

*Example Usage*

    <c:set var="content" value="${sling:getResource(resourceResolver,'/content')}" />

### getValue

Gets the value of the specified key from the ValueMap and either coerses
the value into the specified type or uses the specified type as a default
depending on the parameter passed in.

If the third parameter is a class, the resulting value will be coersed into the class,
otherwise, the third parameter is used as the default when retrieving the value from the
`ValueMap`.

* Returns: `java.lang.Object` - The value.
* Accepts:
    * `org.apache.sling.api.resource.ValueMap` - The ValueMap from which to retrieve the value.
    * `java.lang.String` - The key for the value to retrieve
    * `java.lang.Object` - Either the default value or the class to which to coerce the value.
* Since: 1.3

*Example Usage*

    <c:set var="content" value="${sling:getValue(properties,'jcr:title',resource.name)}" />

### hasChildren

Return true if the specified resource has child resources.

* Returns: `java.lang.Boolean` - True if there are child resource of the specified resource
* Accepts:
    * `org.apache.sling.api.resource.Resource` - The resource of which to check for children.
* Since: 1.3

*Example Usage*

    <c:if test="${sling:hasChildren(resource)">
        <h1>Do Something</h1>
    </c:if>

### listChildren

Method for allowing the invocation of the Sling Resource listChildren method.

* Returns: `java.util.Iterator` - The children of the resource.
* Accepts:
    * `org.apache.sling.api.resource.Resource` - The resource of which to list the children.
* Since: 1.3

*Example Usage*

    <c:forEach var="child" items="${sling:listChildren(resource)">
        <li>${child.path}</li>
    </c:forEach>

## Tags

The Sling Taglib includes a number of Tags which can be used to access the repository, handle the inclusion of scripts and manage requests.

### adaptTo

Adapts adaptables to objects of other types.

* Attributes
    * adaptable - The adaptable object to adapt.
    * adaptTo - The class name to which to adapt the adaptable.
    * var - The name of the variable to which to save the adapted object.
* Since: 1.3

*Example Usage*

    <sling:adaptTo adaptable="${resource}" adaptTo="org.apache.sling.api.resource.ValueMap" var="myProps" />

### call

Execute a script.

* Attributes
    * flush - Whether to flush the output before including the target.
    * script - The script to include.
    * ignoreComponentHierarchy - Controls if the component hierarchy should be ignored for script resolution. If true, only the search paths are respected.
* Since: 1.2

*Example Usage*

    <sling:call script="myscript.jsp" />

### defineObjects

Defines regularly used scripting variables. By default the following scripting variables are defined through this tag:

* **slingRequest**, SlingHttpServletRequest object, providing access to the HTTP request header information - extends the standard HttpServletRequest - and provides access to Sling-specific things like resource, path info, selector, etc.
* **slingResponse**, SlingHttpServletResponse object, providing access for the HTTP response that is created by the server. This is currently the same as the HttpServletResponse from which it extends.
* **resourceResolver**, Current ResourceResolver. Same as slingRequest.getResourceResolver().
* **sling**, SlingScriptHelper, containing convenience methods for scripts, mainly sling.include('/some/other/resource') for including the responses of other resources inside this response (eg. embedding header html snippets) and sling.getService(foo.bar.Service.class) to retrieve OSGi services available in Sling (Class notation depending on scripting language).
* **resource**, current Resource to handle, depending on the URL of the request. Same as slingRequest.getResource().
* **log**, provides an SLF4J Logger for logging to the Sling log system from within scripts, eg. log.info("Executing my script").
* **currentNode**, the underlying JCR node (if there is one) of the current resource.
* **bindings**, provides access to the SlingBindings object for access to non-standard scripting variables.


See also [Scripting variables in CMS](https://cwiki.apache.org/confluence/display/SLING/Scripting+variables#Scriptingvariables-JSP)


* Attributes which allow to bind the according variables to other names than the default ones listed above.
    * requestName
    * responseName
    * resourceName
    * nodeName
    * logName
    * resourceResolverName
    * slingName
* Since: 1.0

*Example Usage*

    <sling:defineObjects />

### encode

Writes properly Cross Site Scripting (XSS) encoded text to the response using the OWASP ESAPI.   Supports a number of encoding modes.

* Attributes:
    * value - The text to encode
    * default - a default text to use if the value is null or empty
    * mode - The encoding mode, one of HTML, HTML_ATTR, XML, XML_ATTR, JS
* Since: 1.4

*Example Usage*

    <sling:encode value="<script>alert('Bad Stuff!');</script>" mode="HTML" />

### eval

Evaluates a script invocation and includes the result in the current page.

* Attributes
    * flush - Whether to flush the output before including the target.
    * script - The path to the script object to include in the current request processing. By default, the current resource is used for script resolving. This behaviour can be changed by specifying either resource, resourceType or ignoreResourceTypeHierarchy.
    * resource - The resource object to include in the current request processing. This attribute is optional. If it is specified, resourceType should not be used. If both are used, resource takes precedence.
    * resourceType - The resource type of a resource to include. This attribute is optional. If it is specified, resource should not be used. If both are used, resource takes precedence.
    * ignoreResourceTypeHierarchy - Prevents using the resource type hierarchy for searching a script.
* Since: 1.1

*Example Usage*

    <sling:eval script="myscript.jsp" />

### findResources

Tag for searching for resources using the given query formulated in the given language.

* Attributes
    * query - The query string to find the resources.
    * language - The query language to use.
    * var - The name of the variable to which to save the resources.
* Since: 1.3

*Example Usage*

    <sling:findResources query="/jcr:root//*[jcr:contains(., 'Sling')] order by @jcr:score" language="xpath" var="resources" />

### forward

Forwards a request to a resource rendering the current page

* Attributes
    * resource - The resource object to forward the request to. Either resource or path must be specified. If both are specified, the resource takes precedences.
    * path - The path to the resource object to forward the request to. If this path is relative it is appended to the path of the current resource whose script is forwarding the given resource. Either resource or path must be specified. If both are specified, the resource takes precedences.
    * resourceType - The resource type of a resource to forward. If the resource to be forwarded is specified with the path attribute, which cannot be resolved to a resource, the tag may create a synthetic resource object out of the path and this resource type. If the resource type is set the path must be the exact path to a resource object. That is, adding parameters, selectors and extensions to the path is not supported if the resource type is set.
    * replaceSelectors - When dispatching, replace selectors by the value provided by this option.
    * addSelectors - When dispatching, add the value provided by this option to the selectors.
    * replaceSuffix - When dispatching, replace the suffix by the value provided by this option.
* Since: 1.0

*Example Usage*

    <sling:forward path="/content/aresource" resourceType="myapp/components/display" />

### getProperty

Retrieves the value from the ValueMap, allowing for a default value or coercing the return value.

* Attributes
    * properties - The ValueMap from which to retrieve the value.
    * key - The key to retrieve the value from from the ValueMap.
    * defaultValue - The default value to return if no value exists for the key. If specified, this takes precedence over returnClass.
    * returnClass - The class into which to coerce the returned value.
    * var - The name of the variable to which to save the value.
* Since: 1.3

*Example Usage*

    <sling:getProperties properties="${properties}" key="jcr:title" defaultValue="${resource.name}" var="title" />

### getResource

Retrieves resources based on either an absolute path or a relative path and a base resource.

* Attributes
    * base - The base resource under which to retrieve the child resource, will only be considered if a relative path is specified.
    * path - The path of the resource to retrieve, if relative, the base resource must be specified.
    * var - The name of the variable to which to save the resource.
* Since: 1.3

*Example Usage*

    <sling:getResource base="${resource}" path="jcr:content" var="content" />

### include

Includes a resource rendering into the current page.

* Attributes
    * flush - Whether to flush the output before including the target.
    * resource - The resource object to include in the current request processing. Either resource or path must be specified. If both are specified, the resource takes precedences.
    * path - The path to the resource object to include in the current request processing. If this path is relative it is appended to the path of the current resource whose script is including the given resource. Either resource or path must be specified. If both are specified, the resource takes precedences.
    * resourceType - The resource type of a resource to include. If the resource to be included is specified with the path attribute, which cannot be resolved to a resource, the tag may create a synthetic resource object out of the path and this resource type. If the resource type is set the path must be the exact path to a resource object. That is, adding parameters, selectors and extensions to the path is not supported if the resource type is set.
    * replaceSelectors - When dispatching, replace selectors by the value provided by this option.
    * addSelectors - When dispatching, add the value provided by this option to the selectors.
    * replaceSuffix - When dispatching, replace the suffix by the value provided by this option.
    * scope - If var is specified, what scope to store the variable in. (Since 1.3)
    * var - variable name to store the resulting markup into (Since 1.3)
* Since: 1.0

*Example Usage*

    <sling:include path="/content/aresource" resourceType="myapp/components/display" />

### listChildren

Lists the children of a Sling Resource.

* Attributes
    * resource - The resource for which to retrieve the children.
    * var - The name of the variable to which to save the child resources.
* Since: 1.3

*Example Usage*

    <sling:listChildren resource="${resource}" var="children" />
