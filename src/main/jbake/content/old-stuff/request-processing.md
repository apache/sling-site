title=Request Processing
type=page
status=published
tags=core,requests
~~~~~~

<div class="note">
2008-02-13: this page is *out of sync* with the current codebase, needs to be reviewed and updated.
</div>

One of the core problems towards understanding how Sling works is knowing how a Client Request is processed by Sling. This page describes the flow of processing requests inside Sling.


## Core Request Processing


The HTTP request enters Sling in the `org.apache.sling.core.ComponentRequestHandlerImpl.service(ServletRequest req, ServletResponse res)` method as the `ComponentRequestHandlerImpl` is registered as the Servlet handling HTTP requests. This method sets up the initial `ComponentRequest` and `ComponentResponse` objects and hands the request over to the first `ComponentFilterChain`. This first filter chain calls all `ComponentFilter` instances registered as request level filters. After processing all filters in the request level filter chain, the request is handed over to the second `ComponentFilterChain` which calls all `ComponentFilter` instances registered as component level filters. At the end of the second filter chain the `service` method of the actual `Component` to which the request resolved is called.

As the component is now processing the request, it may decide to dispatch the request to some other content such as for example a paragraph system or navigation component. To do this, the component will call the `RequestDispatcher.include` method. If the request dispatcher dispatches to a `Content` object Sling will hand the dispatch request over to the component level filter chain, which at the end will call the `service` method for the `Content` object to dispatched to. This process may be repeated at the component's discretion only limited by processing resources such as available memory.


As can be seen Sling itself is absed on the Component API `ComponentFilter` mechanism. As such Sling provides and uses the following filters in the Sling Core bundle:

{table:class=confluenceTable}
{tr}{th:colspan=2|class=confluenceTh} Request Level Filters {th}{tr}
{tr}{td:class=confluenceTd} `ErrorHandlerFilter` {td}{td:class=confluenceTd} Handles exceptions thrown while processing the request as well implements the `ComponentResponse.sendError()` method {td}{tr}
{tr}{td:class=confluenceTd} `AuthenticationFilter` {td}{td:class=confluenceTd} Implements authentication for the request and provides the JCR Session of the request {td}{tr}
{tr}{td:class=confluenceTd} `BurstCacheFilter` {td}{td:class=confluenceTd} Checks whether the request may be handled by cached response data {td}{tr}
{tr}{td:class=confluenceTd} `LocaleResolverFilter` {td}{td:class=confluenceTd} Provides information on the `Locale` to be used for request processing. This filter implements the `ComponentRequest.getLocale()` method {td}{tr}
{tr}{td:class=confluenceTd} `ThemeResolverFilter` {td}{td:class=confluenceTd} Provides the `Theme` for the request. The theme is provided as a request attribute {td}{tr}
{tr}{td:class=confluenceTd} `URLMapperFilter` {td}{td:class=confluenceTd} Resolves the request URL to a JCR Node which may be mapped into a `Content` object {td}{tr}
{tr}{td:class=confluenceTd} `ZipFilter` {td}{td:class=confluenceTd} Sample filter showing how the request response might be compressed according to the *Accept-Encoding* request header. This filter is not enabled by default. {td}{tr}
{table}



Deducing from these lists of filters, the actual request processing can be refined into the following steps:

1. Extract user authentication information and acquire the JCR session to access content. If the request has no user authentication data the such data may be requested from the user (for example by sending a HTTP 401 status) or an anonymous repository session might be acquired.
1. Check whether the request may be handled by data stored in the cache. If the request is cacheable and a cache entry exists for the request URL, the request data is returned to the client and request processing may terminate. Otherwise request processing will continue and optionally ensure that any response data is entered into the cache. Of course, if the request is not cacheable, for example because there are request parameters, or if any of the `Component` instances called during request processing decide to signal non-cacheability for whatever reason, the response data will of course not cached.
1. Extract the `java.util.Locale` from the request such that further processing may use properly translated messages. By default, the locale of the underlying Servlet request is used as the request locale. Other possibilities would be to use special cookies or some locale encoding in the path.
1. Find the theme (or skin) to use to render the response. This step will add a `org.apache.sling.theme.Theme` object as a request parameter, which may be used by `Component`s to decide on specific rendering. For example, the theme may encapsulate information on the CSS to use for responses rendered as HTML.
1. Resolve the request URL into a `Content` object.


The default request level filter chain setup ends with finding the `Content` object requested by the request URL. After having found this object, the request is handed over to the component level filter chain, which is concerned with handling filtering on a single `Content` instance. As such, the component level filter chain is used for each `Content` object which is to be serviced either on behalf of the HTTP request or on behalf of request dispatcher. Thus the component level filter chain will generally called multiple times during a single request.


{table:class=confluenceTable}
{tr}{th:colspan=2|class=confluenceTh} Component Level Filters {th}{tr}
{tr}{td:class=confluenceTd} `CacheFilter` {td}{td:class=confluenceTd} Checks whether the request to the current `Content` object may be handled by cached response data {td}{tr}
{tr}{td:class=confluenceTd} `ComponentResolverFilter` {td}{td:class=confluenceTd} Resolves the component ID returned by the `Content.getComponentId()` method into a `Component` instances, which will be called to service the request {td}{tr}
{table}

Again, deducing from the list of filters, the following steps are taking to service a given `Content` object:

1. Check whether the `Content` object processing may be handled from the cache. Same as with request level cache handling, a cache entry may exist for a single `Content` instance depending on whether the request is cacheable at all and on whether a cache entry exists. If a cache entry exists and may be used, the response data is simply spooled into the response and component level processing terminates for the `Content` object. Otherwise processing continues and may optionally lead to a new cache entry for the `Content` object to be reused later.
1. Resolve the component ID returned by the `Content.getComponentId()` method into a `Component` object. Of course it is an error, if the component ID cannot be mapped into a `Component` object.

After resolving the `Component` object default component filter chain terminates and control is handed over to the `service` method of the `Component` object resolved in the last step. At the discretion of the component request dispatchers may now be acquired to render other `Content` objects. In this case the component level filter chain is simply kicked of again resulting in the `service` method of another `Component` being called. And so forth.



## Resolving Content

As we have seen, the last step in the request level filter chain is the resolution of the request URL into a `Content` object. The URL Mapper Filter implementing this resolution uses an instance of the `org.apache.sling.content.ContentMapper` interface which is acquired by calling the `org.apache.sling.content.jcr.JcrContentManagerFactory` with the repository session acquired by the authentication filter.

The URL Mapper filter then tries to apply fixed mappings from request URL to destination paths to support shortcut URLs. For example the root path `/` may be mapped into the default landing page at `/default/home`. The list of such mappings is configurable through the Configuration Admin Service.

Next the URL Mapper tries to apply prefix matching patterns. A list of patterns is iterated checking whether the prefix applies and, if so, replacing the prefix with another prefix and trying to resolve the result. This functionality enables relocation of a subtree of the repository. For example, all requests whose prefix is `/here` might be remapped with the new prefix `/content/there`. The result  of this remapping is then resolved.

Resolution (currently) takes place on the last path segment of the request URL containing at least one dot. Parts of that segment are cut off after dots until no more dots exist in the URL. For each resulting substring, the `ContentManager.load(String)` method is called. This processing terminates if a `Content` object is found or if there is nothing to cut off any more.

This resolution is very simple and straight forwards. Future development may add support for the following features:

* *Vanity URLs* - Map the request URL according to the `Host` request header.
* *Dynamic Mapping* - Add support for a set of variables in path and/or prefix mapping. For example, a prefix mapping  may contain the string `/content/$\{lang}/$\{user`} resulting in resolving a prefix according to the language of the current locale and the name of the authenticated used.



## Registering Components


The last step of the component level filter chain is resolving the `Component` from the component ID of the `Content` object. Sling implements this resolution by making use of the OSGi service registry. That is, each component is to be registered as a service with the name `org.apache.sling.component.Component`. The `ComponentResolverFilter` is listening for these components and registers them internally in a map indexed by the IDs of the component as returned by the `Component.getId()` method.

When a component has to be resolved, the component ID returned by the `Content` object is simply looked up in the component map. If found, that component is used. Otherwise a fall back algorithm is applied which is described on the [Default Content Mapping and Request Rendering]({{ refs.default-mapping-and-rendering.path }}) page.



## Reqistering Filters

Just as `Component` instances used by Sling are expected to be registered as OSGi services, the `ComponentFilter`s to be 
used have to be registered as services under the name `org.apache.sling.component.ComponentFilter`. Sling picks up all registered component filters and adds them to the respective filter chains.

Service properties set upon registration of the filter define the chain to which the filter belongs and the order in which the filters should be processed:

| Property | Description |
|---|---|
| `filter.scope` | Defines the chain to which the filter is added. Supported values are `component` for component level filters and `request` for request level filters. If this property is missing or set to an unknown value the filter is added to the request level filter chain. |
| `filter.order` | Defines the weight of the filter to resolve the processing order. This property must be an `java.lang.Integer`. If not set or not an `Integer` the order defaults to `Integer.MAX_VALUE`. The lower the order number the earlier in the filter chain will the filter be inserted. If two filters are registered with the same order value, the filter with the lower `service.id` value is called first. |



## Content is a Java Object

It is crucial to understand that `Content` is an interface and the request processor of Sling does not actually care, how the `Content` instance comes to live as long as the is such an object and there is a `Component` instance capable of servicing the `Content` object.

By default Sling uses the *URL Mapper* to resolve the request URL into a `Content` object. When a `Component` is tasked with servicing a `Content` object it usually uses the `ComponentRequestDispatcher` to ask Sling to service another content object generally identified by a (relative or absolute) path to a JCR Repository Node from which the `Content` object is loaded.

But instead of having Sling resolve a path into a `Content` object the component may just as well create a `Content` object and hand it over to the `ComponentRequestDispatcher` for service. Consider a request which is handled by a `PageComponent`. This component has to draw a navigation tree somewhere in the response. So the component could of course insist on having a `navigation` child node to dispatch rendering to as follows:



    RequestDispatcher rd = request.getRequestDispatcher("navigation");
    rd.include(request, response);



What happens, though, if there is no `navigation` child node ? Probably, the request will fail with some error status. Of course the component could be more clever and do:



    Content navigation = request.getContent("navigation");
    if (navigation != null) {
        RequestDispatcher rd = request.getRequestDispatcher(navigation);
        rd.include(request, response);
    }



Still, if the `navigation` child node does not exist, there is no navigation drawn; at least there will be now error. Since Sling does not actually care, how a `Content` object comes to live, the component could do the following:



    Content navigation = new Content() {
        public String getPath() {
            return request.getContent().getPath() + "/navigation";
        }
        public String getComponentId() {
            return NavigationComponent.getClass().getName();
        }
    }
    
    RequestDispatcher rd = request.getRequestDispatcher(navigation);
    rd.include(request, response);



Of course, the page component now has to have knowledge about the actual `Component` to use.


Finally, as a further enhancement, the Component might even decide to first check for a `navigation` child node. If such a node does not exist the navigation `Content` object is just created:



    Content navigation = request.getContent("navigation");
    if (navigation == null) {
        navigation = new Content() {
            public String getPath() {
                return request.getContent().getPath() + "/navigation";
            }
            public String getComponentId() {
                return NavigationComponent.getClass().getName();
            }
        }
    }
    
    RequestDispatcher rd = request.getRequestDispatcher(navigation);
    rd.include(request, response);



This could for example be used to fall back to a default navigation setup while providing for specialized navigation configuration in an optional `navigation` child node.
