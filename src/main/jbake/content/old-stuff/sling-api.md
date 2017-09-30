title=Sling API
type=page
status=published
tags=api,core
~~~~~~

<div class="note">
The contents of this page is being created at the moment. It contains incomplete and partially wrong information as the text is adapted from the contents of the [Component API]({{ refs.component-api.path }}) documentation page.
</div>


## Introduction

The *Sling API* defines a presentation framework to build Web Applications. As such the Sling API builds upon the Servlet API but extends the latter with new functionality:

* A web page may be built from many different pieces. This aggregation of different pieces is comparable to the functionality provided by the Portlet API. In contrast to the latter, though, the pieces may themselves be aggregates of yet more pieces. So a single web page response may consist of a tree of pieces.
* Just like the Servlet API and the Portlet API the Sling API mainly defines a Java based framework. Yet the Sling API comes with the intention of supporting scripting built.
* In contrast to the Servlet API and the Portlet API, the Sling API is resource centric. That is, the request URL does not address a servlet or a portlet but a resource represented by an instance of the `org.apache.sling.api.resource.Resource` interface. From this resource the implementation of the Sling API will derive a `javax.servlet.Servlet` or `org.apache.sling.api.scripting.SlingScript` instance, which is used to handle the request.

An implementation of the presentation framework defined by the Sling API is called a *Sling Framework*. The Apache Sling project actually contains two implementations of this API: *microsling* and *Sling*. microsling (note the lowercase *m*) implements the same request processing mechanisms as *Sling* but is very hardcoded. It serves well as a rapid development environment as it is quickly set up, easy to handle and shows results very easily. Sling on the other hand is based on an OSGi framework and very flexible, allowing the extension of the system in various ways.



## Going Resource Centric

Traditional web applications are built around the notion of a traditional application which is converted into an application which may be used using a Web Browser. Web applications consist of a series of servlets and JSP scripts, which are called based on configuration in the web application deployment descriptor. Such applications are generally based on some internal database or some static filesystem content.

The Sling API on the other hand looks more like a traditional web server from the outside, which delivers more or less static content. Thus, while the traditional web application uses the request URL to select a piece of code to execute, the Sling API uses the URL to select a resource to be delivered.



### Comparsion to the Servlet API

The Sling API builds upon the Servlet API. Generally a Sling Framework will run inside a Servlet Container and be manifested towards the Servlet Container as a single Servlet, which dispatches requests to the Servlets and Scripts depending on the request URLs.

Response rendering may itself be a multi-step operation. Depending on the Servlets and Scripts, the rendering may include dispatching for child (or even foreign) Resources.



### Comparision to the Portlet API

Unlike the Portlet API, which defines one single level of portlet hierarchy - portlets are just pieces residing besides each other - the Sling API allows for hierarchic structuring of Resources and hence Servlet and Script renderings. To support this structuring, the Sling Framework does not control the rendering process of all elements on the page like the Portlet Container does for the portlets. Instead only the Resource addressed by the request URL is processed and it is left to the Servlet or Script rendering that Resource to dispatch other Resource/Servlet/Script tupels to add more data to the response.


### To Iterator or To Enumeration

With the advent of the Java Collection framework in Java 2, the `Enumeration` has been superceded by the `Iterator`. So the natural choice for the Sling API for methods to return enumeratable collection of objects would have be to declare the use of `Iterator` instances. But because the Servlet API defines to use `Enumeration` instances, the Sling API will also declare the use of `Enumeration` instances for consistency with the Servlet API extended by the Sling API.




## Request Processing

Unlike traditional Servlet API request processing, a Sling API request is processed by the Sling Framework in three basic steps:

1. *Resource Resolution* - The Sling Framework derives a Resource instance from the client request URL. The details of how to resolve the Resource. One possible solution would be to map the request URL to a [Java Content Repository]({{ refs.http://www.jcp.org/en/jsr/detail?id=170.path }}) Node and return a Resource representing that Node.
1. *Servlet and Script Resolution* - From the Resource created in the first step, the Servlet or Script is resolved based on the type of the Resource. The resource type is a simple string, whose semantics is defined by the Sling Framework. One possible definition could be for the resource type to be the primary node type of the Node underlying the Resource.
1. *Input Processing and Response Generation* -  After getting the Resource and the Servlet or Script, the `service()` method is called or the script is evaluated to process any user supplied input and send the response to the client. To structure the rendered response page, this method is responsible to include other resources. See *Dispatching Requests* below for details. See *Error Handling* below for a discussion on how exceptions and HTTP stati are handled.



### URL decomposition

During the *Resource Resolution* step, the client request URL is decomposed into the following parts:

1. *Resource Path* -  The longest substring of the request URL resolving to a Resource such that the resource path is either the complete request URL or the next character in the request URL after the resource path is either a dot (`.`) or a slash (`/`).
1. *Selectors* -  If the first character in the request URL after the resource path is a dot, the string after the dot upto but not including the last dot before the next slash character or the end of the request URL. If the resource path spans the complete request URL or if a slash follows the resource path in the request URL, no seletors exist. If only one dot follows the resource path before the end of the request URL or the next slash, no selectors exist.
1. *Extension* -  The string after the last dot after the resource path in the request URL but before the end of the request URL or the next slash after the resource path in the request URL. If a slash follows the resource path in the request URL, the extension is empty.
1. *Suffix Path* -  If the request URL contains a slash character after the resource path and optional selectors and extension, the path starting with the slash upto the end of the request URL is the suffix path. Otherwise, the suffix path is empty.

*Examples*: Assume there is a Resource at `/a/b`, which has no children.

| URI | Resource Path | Selectors | Extension | Suffix |
|--|--|--|--|--|
| /a/b                      | /a/b | null  | null | null       |
| /a/b.html                 | /a/b | null  | html | null       |
| /a/b.s1.html              | /a/b | s1    | html | null       |
| /a/b.s1.s2.html           | /a/b | s1.s2 | html | null       |
| /a/b/c/d                  | /a/b | null  | null | /c/d       |
| /a/b.html/c/d             | /a/b | null  | html | /c/d       |
| /a/b.s1.html/c/d          | /a/b | s1    | html | /c/d       |
| /a/b.s1.s2.html/c/d       | /a/b | s1.s2 | html | /c/d       |
| /a/b/c/d.s.txt            | /a/b | null  | null | /c/d.s.txt |
| /a/b.html/c/d.s.txt       | /a/b | null  | html | /c/d.s.txt |
| /a/b.s1.html/c/d.s.txt    | /a/b | s1    | html | /c/d.s.txt |
| /a/b.s1.s2.html/c/d.s.txt | /a/b | s1.s2 | html | /c/d.s.txt |

<div class="info">
The [SlingRequestPathInfoTest]({{ refs.http://svn.apache.org/repos/asf/sling/trunk/bundles/engine/src/test/java/org/apache/sling/engine/impl/request/SlingRequestPathInfoTest.java.path }}) demonstrates and tests this decomposition. Feel free to suggest additional tests that help clarify how this works!
</div>

## The SlingHttpServletRequest

The `org.apache.sling.api.SlingHttpServletRequest` interface defines the basic data available from the client request to both action processing and response rendering. The `SlingHttpServletRequest` extends the `javax.servlet.http.HTTPServletRequest`.

This section describes the data available from the `SlingHttpServletRequest`. For a complete and normative description of the methods, refer to the Sling API JavaDoc. The following information is represented for reference. In the case of differences between the following descriptions and the Sling API JavaDoc, the latter takes precedence.

1. *Resource access* - Resources may be accessed from the `SlingHttpServletRequest` object through the following methods: `getResource()`, `getResourceResolver()`.
1. *Request URL information* - In addition to the standard `HttpServletRequest` information the `SlingHttpServletRequest` provides access to the selectors, extension and suffix through the `getRequestPathInfo()` method. Note that the Resource path is not directly available form the `SlingHttpServletRequest` object. Instead it is available through the `Resource.getPath()` method of the Resource object retrieved through `SlingHttpServletRequest.getResource()`.
1. *Request Parameters* - To support user input submitted as `multipart/form-data` encoded POST parameters, the Sling API intrduces the `RequestParameter` interface allowing file uploads. Request parameters represented as `RequestParameter` objects are returned by the following methods: `getRequestParameter(String name)`, `getRequestParameterMap()`, `getRequestParameters(String name)`.
1. *Request Dispatching* - In addition to standard Serlvet API request dispatching, the Sling API supports dispatching requests to render different Resources using `RequestDispatcher` objects returned by the methods: `getRequestDispatcher(Resource resource)` and `getRequestDispatcher(Resource resource, RequestDispatcherOptions options)`.
1. *Miscellaneous* - Finally the ComponentRequest interface provides the following methods: `getCookie(String name)`, `getRequestProgressTracker()`, `getResponseContentType()`, `getResponseContentTypes()`, `getResourceBundle(Locale locale)`, `getServiceLocator()`.

The `SlingHttpServletRequest` objects are only valid during the time of request processing. Servlets and Scripts must not keep references for later use. As such, the `SlingHttpServletRequest` interface and its extensions are defined to not be thread safe.

*A note on HTTP Sessions*: The `SlingHttpServletRequest` extends the `HttpSerlvetRequest` and thus supports standard HTTP sessions. Be aware, though that Sessions are server side sessions and hence violate the sessionless principle of REST and therefore should be used with care. It is almost always possible to not use sessions.


## The SlingHttpServletResponse

The `org.apache.sling.api.SlingHttpServletResponse` interface extends the `javax.servet.http.HttpServletResponse` interface and is currently empty. It merely exists for symmetry with the `SlingHttpServletRequest`.




## The Resource

The `org.apache.sling.resource.Resource` represents the data addressed by the request URL. Resources may also be retrieved through the `org.apache.sling.api.resource.ResourceResolver`. Usually this interface is not implemented by clients. In certain use cases we call *synthetic Resource* if may be usefull to define a simple object implementing the `Resource` interface. The Sling Framework does not care about the concrete implementation of the `Resource` interface and rather uses the defined methods to access required information. The interface defines the following methods:

1. *getResourceType()* - Returns the type of the resource. This resource type is used to resolve the Servlet or Script used to handle the request for the resource.
1. *getPath()* - Returns the path derived from the client request URL which led to the creation of the Resource instance. See the [#URL_decomposition URL decomposition]({{ refs.-url_decomposition-url-decomposition.path }}) section above for more information. It is not required, that the Resource path be a part of the original client request URL. The request URL may also have been mapped to some internal path.
1. *getResourceMetadata()* - Returns meta data information about the resource in a `ResourceMetadata` object.
1. *adaptTo(Class<AdapterType> type)* - Returns alternative representations of the Resource. The concrete supported classes to which the Resource may be adapted depends on the implementation. For example a Resource based on a JCR Node may support being adapted to the underlying Node, an `InputStream`, an `URL` or even to a mapped object through JCR Object Content Mapping.

----



## The Component

The `org.apache.sling.component.Component` interface defines the API implemented to actually handle requests. As such the Component interface is comparable to the =javax.servlet.Servlet= interface. Like those other interfaces, the Component interface provides methods for life cycle management: `init(ComponentContext context)`, `destroy()`.



### Processing the Request

The Component Framework calls the `service(ComponentRequest request, ComponentResponse response)` method of the Component to have the component process the request optionally processing user input, rendering the response and optionally dispatch to other Content/Component tuples to provide more response data.



### Content and its Component

The Content object and a Component form a pair, in which the Content object takes the passive part of providing data to the Component and the Component takes the active part of acting upon the Content object. As a consequence, there always exists a link between a given implementation of the Content interface and a given implementation of the Component interface.

This link is manifested by the Component identifier available from the Content object through the `Content.getComponentId()` method on the one hand. On the other hand, the link is manifested by the `getContentClassName()` and `createContentInstance()` methods of the Component interface.



### Component Lifecylce

When a Component instance is created and added to the Component framework, the `init(ComponentContext)` method is called to prepare and initialize the Component. If this method terminates abnormally by throwing an exception, the Component is not used. The Component Framework implementation may try at a later time to recreate the Component, intialize it and use it. If the Component Framework tries to recreate the Component a new instance of the Component must be created to be initialized and used.

When the Component has successfully been initialized, it may be referred to by Content objects. When a client request is to be processed, the Content object is resolved and the `service` method on the Component to which the Content object refers is called. The `service` method may - and generally will - be called simultaneously to handle different requests in different threads. As such, implementations of these methods must be thread safe.

When the Component Framework decides to take a Component out of service, the `destroy()` method is called to give the Component a chance to cleanup any held resources. The destroy method must only be called by the Component Framework when no more request processing is using the Component, that is no thread may be in the `service` method of a Component to be destroyed. Irrespective of whether the destroy method terminated normally or abnormally, the Component will not be used again.

The addition and removal of Components is at the discretion of the Component Framework. A Component may be loaded at framework start time or on demand and my be removed at any time. But only one single Component instance with the same Component identifier may be active at the same time within a single Component Framework instance.



### The ComponentExtension

To enhance the core functionality of Components, each Component may have zero, one ore more Component Extensions attached. A Component Extensions is a Java object implementing the `org.apache.sling.component.ComponentExtension` interface. This interface just defines a `getName()` method to identify extensions.

The concrete implementation as well as instantiation and management of Component Extensions is left to the Component Framework implementation with one restriction though: The extensions must be available to the Component at the time the `init(ComponentContext)` method is called may only be dropped after the `destroy()` method terminates.

The Component interface defines two methods to access Extensions: The `getExtensions()` method returns a `java.util.Enumeration` of all ComponentExtension objects attached to the component. If no Component Extension are attached to the Component, an empty enumeration is returned. The `getExtension(String name)` returns the named Component Extension attached to the Component or `null` if no such Component Extension is attached to the Component.

Component Frameworks are allowed to share Component Extension instances of the same name between different Component instances. Regardless of whether Component Extensions are shared or not, they must be thread safe, as any Component Extension may be used within the `service` method, which themselves may be called concurrently.




## Request Processing Filters

Similar to the Servlet API providing filters for filtering requests and/or responses the Component API provides the `org.apache.sling.component.ComponentFilter` interface. The filters are called by a `ComponentFilterChain` and either handle the request, manipulate the request and/or response object and finally forward the request and response optionally wrapped to the `ComponentFilterChain.doFilter(ComponentRequest, ComponentResponse)` method.

Like the `Component`s  filters have a defined lifecycle manifested by `init` and `destroy` methods. When the filter enters the system, the Component Framework calls the `ComponentFilter.init(ComponentContext)` method. Only when this method completes successfully will the filter be put into action and be used during request processing. When the filter leaves the system, the Component Framework removes the filter from being used in filter chains and calls the `ComponentFilter.destroy()` method. This method is not expected to throw any exceptions. The filter may be removed from the Component Framework at the discretion of the Component Framework or because the filter is being unregistered from the Component Framework by some means outside this specification.

This specification does not define how `ComponentFilter` objects are registered with the Component Framework nor is it specified how the order in which the filters are called is defined. Likewise it is outside this specification how the filter instances registered with the Component Framework are configured.



## Sessions


The `org.apache.sling.component.ComponentSession` interface provides a way to identify a user across more than one request and to store transient information about that user.

A component can bind an object attribute into a `ComponentSession` by name. The `ComponentSession` interface defines two scopes for storing objects: `APPLICATION*SCOPE`, `COMPONENT*SCOPE`. All objects stored in the session using the `APPLICATION*SCOPE` must be available to all the components, servlets and JSPs that belong to the same component application and that handle a request identified as being a part of the same session. Objects stored in the session using the `COMPONENT*SCOPE` must be available to the component during requests for the same content that the objects where stored from. Attributes stored in the `COMPONENT_SCOPE` are not protected from other web components of the component application. They are just conveniently namespaced.

The component session extends the Servlet API `HttpSession`. Therefore all `HttpSession` listeners do apply to the component session and attributes set in the component session are visible in the `HttpSession` and vice versa.

The attribute accessor methods without the *scope* parameter always refer to `COMPONENT*SCOPE` attributes. To access `APPLICATION*SCOPE` attributes use the accessors taking an explicit `scope` parameter.

*A final note on Sessions*: Sessions are server side sessions and hence violate the sessionless principle of REST and therefore should be used with care. It is almost always possible to not use sessions.



## Dispatching Requests

To include renderings of child Content objects, a `org.apache.sling.component.ComponentRequestDispatcher` object may be retrieved from the ComponentContext with which the Component has been initialized or from the ComponentRequest provided to the service method. Using this dispatcher the reponse of rendering the Content may be included by calling the `ComponentRequestDispatcher.include(ComponentRequest, ComponentResponse)` method.

This method is comparable to the `RequestDispatcher.include(ServletRequest, ServletResponse` method of the Servlet API but dispatching by the `ComponentRequestDispatcher` does not go through the servlet container and stays within the Component Framework.

The `service` method of included Components are called with an instance of the `ComponentRequest` interface whose `getContent()` returns the Content object for the included Content.

When a Component is included by another component the following request attributes are set:

| *Request Attributes* | *Type* | *Description* |
|--|--|--|
| `org.apache.sling.component.request.content` | String | The `Content` instance to which the client URL resolved. This attribute is set when included Components are being rendered and it is not set for the Component directly addressed by the client request. |
| `org.apache.sling.component.request.component` | String | The `Component` instance for the `Content` object to which the client URL resolved. This attribute is set when included Components are being rendered and it is not set for the Component directly addressed by the client request. |


### Error Handling

While processing requests, the `service` methods called may have problems. Components have multiple options of reporting issues during processing to the client:

* Set the status of the HTTP response calling the `ComponentResponse.setStatus` method
* Send an error page calling the `ComponentResponse.sendError` method
* Throw an exception


If such an exception is thrown, the Component Framework must act upon the exception in one of the following ways:

* If the request is processed through Servlet API request inclusion, the exception must be given back to the servlet container. A `ComponentException` is just forwarded as a `ServletException`. This is a requirement of the Servlet API specification which states for included requests:

{quote}
  
  
{quote}

* Otherwise, the Component Framework may handle the error itself in a manner similar to the error handling approach defined the Servlet API specification (Section SRV 9.9 Error Handling of the Java Servlet Specification 2.4). Specifically the request attributes defined by the Servlet API specification must be set for the error handler:

| *Request Attributes* | *Type* | *Description* |
|--|--|--|
| `javax.servlet.error.status_code` | `java.lang.Integer` | The status code of the response. In the case of an exception thrown from the `service`, the code is defined by the Component Framework. |
| `javax.servlet.error.exception_type` | `java.lang.Class` | The fully qualified name of the exception class thrown. This attribute does not exist, if error handling does not result from an exception. This attribute is maintained for backwards compatibility according to the Servlet API Specification. |
| `javax.servlet.error.message` | `java.lang.String` | The message of the exception thrown. This attribute does not exist, if error handling does not result from an exception. This attribute is maintained for backwards compatibility according to the Servlet API Specification. |
| `javax.servlet.error.exception` | `java.lang.Throwable` | The exception thrown. This attribute does not exist, if error handling does not result from an exception. |
| `javax.servlet.error.request_uri` | `java.lang.String` | The request URL whose processing resulted in the error. |
| `javax.servlet.error.servlet_name` | `java.lang.String` | The name of the servlet which yielded the error. The servlet name will generally not have any significance inside the Component Framework. |
| `org.apache.sling.component.error.componentId` | `java.lang.String` | The identifier of the Component whose `service` method has caused the error. This attribute does not exist, if the Component Framework itself caused the error processing. |
* If the Component Framework decides to not handle the error itself, the exception must be forwarded to the servlet container as a `ComponentException` wrapping the original exception as its root cause.

This specification does not define, how error handlers are configured and used if the Component Framework provides error handling support. Likewise the Component Framework may or may not implement support to handle calls to the `ComponentResponse.sendError` method. The Component Framework may also use its own error handling also for errors resulting from request processing failures, for example if authentication is required or if the request URL cannot be resolved to a Content object.
