title=Resources		
type=page
status=published
tags=core,resources
~~~~~~

[TOC]

## What is a Resource

The Resource is one of the central parts of Sling. Extending from JCR's *Everything is Content*, Sling assumes *Everthing is a Resource*. Thus Sling is maintaining a virtual tree of resources, which is a merger of the actual contents by so called resource providers (one of them usually the JCR Resource Provider). By doing this Sling fits very well in the paradigma of the REST architecture.

### Resource Properties

Resources have a number of essential properties:

| Property | Description |
|---|---|
| Path | Resources are part of a Resource Tree. As such each Resource has a path which is formed by concatenating the names of all Resources along the root to the Resource separated by a slash. Ok, really, this is much like a URL path or a file system path where the slash (`/`) is the separator character. |
| Name | The name of the Resource is the last element (or segment) in the path. |
| Resource Type | Each resource has a resource type which is used by the Servlet and Script resolver to find the appropriate Servlet or Script to handle the request for the Resource. |
| Resource Super Type | The (optional explicit) super type of the Resource. See the section _Resource Types_ below for more details. |
| Adapters | Resources are always `Adaptable` and therefore can be adapted to a different view. See the section _Resource Adapters_ below for more details. |
| Metadata | Resources in general support [`ResourceMetadata`][1] providing access to values such as the length of a binary resource (which can be streamed) or the Resource's content type. |

For a complete description of the `Resource` interface, please refer to the [`Resource`][2] JavaDoc.

The properties are either exposed via the `ValueMap` or `ModifiableValueMap` adaptable or by calling `Resource.getValueMap()`.

To get the *main* binary property from a given resource one can adapt it to an `InputStream`. Most resource providers return the underlying wrapper binary in that case. For arbitrary binary properties one must use the `ValueMap` which will return `InputStream` for such properties.

### Resource Types

The exact method of setting the resource type for a Resource depends on the actual Resource Provider. For the four main Resource Provider
implementations provided by Sling, the assignments are as follows:

| Provider | Resource Type | Resource Super Type |
|---|---|---|
| JCR | The value of the `sling:resourceType` property or the primary node type if the property is not set (a namespace separator colon is replaced by a slash, e.g. the `nt:file` primary node type is mapped to the `nt/file` resource type | The value of the `sling:resourceSuperType` of the Resource node or resource super type of the resource pointed to by the resource type (when accessed with `ResourceResolver.getResource(String)` |
| File System | File based resources are of type `nt/file`; folder based resources are of type `nt/folder` corresponding to the respective JCR primary node type | none |
| Bundle | File based resources are of type `nt/file`; folder based resources are of type `nt/folder` corresponding to the respective JCR primary node type | none |
| Servlet | The absolute path of the resource appended with the suffix `.servlet` | `sling/bundle/resource` |

Resource Types form a type hierarchy much like Java classes form a type hierarchy. Each resource type has a resource super type, either explicitly defined as for example for JCR or Servlet Resources or implicitly. The implicit Resource Super Type is at the same time the root Resource Type much like the `java.lang.Object` class is called `sling/servlet/default` (for historical reasons). The `sling/servlet/default` Resource Type is the only type without a super type.

### Adapters

The object types to which Resources may be adapted mostly depends on the Resource Provider providing the resource. For example all JCR node based resources always adapt to `javax.jcr.Node` objects.

If the actual Resource object class implementation extends from the `SlingAdaptable` class, then in addition all `AdapterFactory` services adapting `Resource` objects are considered when trying to adapt the Resource. In general Resource Providers are recommended to have their Resource implementation extend from [`AbstractResource`][3] which guarantees the Resource implementation to extend from `SlingAdaptable` and thus supporting Adapter Factories.

## How to get a Resource

To get at Resources, you need a `ResourceResolver`. This interface defines four kinds of methods to access resources:

* Absolute Path Mapping Resource Resolution: The `resolve(HttpServletRequest, String)` and `resolve(String)` methods are called to apply some implementation specific path matching algorithm to find a Resource. These methods are mainly used to map external paths - such as path components of request URLs - to Resources. To support creating external paths usable in an URL a third method `map(String)` is defined, which allows for round-tripping.
* Absolute or Relative Path Resolution (including search path): The `getResource(String path)` and `getResource(Resource base, String path)` methods may be used to access a resource with an absolute path directly. If it can't be found the path is assumed to be relative and the search path retrieved from `getSearchPath()` is used to retrieve the resource. This mechanism is similar to resolving a programm with the `PATH` environment variable in your favourite operating system.
* Resource Enumeration: To enumerate resources and thus iterate the resource tree, the `listChildren(Resource)` method may be used. This method returns an `Iterator<Resource>` listing all resources whose path prefix is the path of the given Resource. This method will of course also cross boundaries of registered `ResourceProvider` instances to enable iterating the complete resource tree.
* Resource Querying: Querying resources is currently only supported for JCR Resources through the `findResources(String query, String language)` and `queryResources(String query, String language)` methods. For more information see the section on [Querying Resources](#querying-resources) below.

### How to get a ResourceResolver

Usually you get the `ResourceResolver` via the OSGi service `ResourceResolverFactory`. This interface provides different methods to create a ResourceResolver:

1. [`ResourceResolverFactory.getResourceResolver(java.util.Map authenticationInfo)`](https://sling.apache.org/apidocs/sling11/org/apache/sling/api/resource/ResourceResolverFactory.html#getResourceResolver-java.util.Map-). You must provide some authentication info details for this to work. Those are highly dependent on the implementing `ResourceProvider`. See sections below for further details which keys are supported.
2. [`ResourceResolverFactory.getServiceResourceResolver(java.util.Map authenticationInfo)`](https://sling.apache.org/apidocs/sling11/org/apache/sling/api/resource/ResourceResolverFactory.html#getServiceResourceResolver-java.util.Map-). Can optionally be further parameterized via the authentication info key [`sling.service.subservice`](https://sling.apache.org/apidocs/sling11/org/apache/sling/api/resource/ResourceResolverFactory.html#SUBSERVICE). For further details refer to [ServiceAuthentication](service-authentication.html).
3. [`ResourceResolverFactory.getThreadResourceResolver()`](https://sling.apache.org/apidocs/sling11/org/apache/sling/api/resource/ResourceResolverFactory.html#getThreadResourceResolver--). Uses the resource resolver bound to the current thread.
4. The deprecated `ResourceResolverFactory.getAdministrativeResourceResolver(...)`. Instead rather use the method 2.

It is crucial that each `ResourceResolver` retrieved via one of those methods is closed via [`ResourceResolver.close()`](https://sling.apache.org/apidocs/sling11/org/apache/sling/api/resource/ResourceResolver.html#close--) once it is no longer used.

### Absolute Path Mapping

As has been said, the absolute path mapping methods `resolve(HttpServletRequest, String)` and `resolve(String)` apply some implementation specific path matching algorithm to find a Resource. The difference between the two methods is that the former may take more properties of the `HttpServletRequest` into account when resolving the Resoure, while the latter just has an absolute path to work on.

The general algorithm of the two methods is as follows:

1. Call `HttpServletRequest.getScheme(), .getServerName(), getServerPort` to get an absolute path out of the request URL: \[scheme\]/\[host\].\[port\]\[path\] (`resolve(HttpServletRequest, String)` method only, which)
1. Check whether any virtual path matches the absolute path. If such a match exists, the next step is entered with the match.
1. Apply a list of mappings in order to create a mapped path. The first mapped path resolving to a Resource is assumed success and the Resource found is returned.
1. If no mapping created a mapped path addressing an existing Resource, the method fails and returns a `NonExistingResource` (for the  
`resolve(String)` and `resolve(HttpServletRequest,String)`) or null (for the `getResource(String path)` 
and `getResource(Resource base, String path)` methods).

The virtual path mapping may be used to create shortcut URLs for otherwise long and complicated URLs. An example of such an URL might be the main administrative page of a CMS system. So, administrators may access the root of the web application and directed to the main administrative page.

The path mapping functionality may be used to hide internal resource organization from the request URL space. For example to better control the structure of your repository, you might decide to store all accessible data inside a `/content` subtree. To hide this fact from the users, a mapping may be defined to prefix all incoming paths with `/content` to get at the actual Resource.

The `map(String)` applies the path mapping algorithm in the reverse order. That is, first the path mappings are reversed and then any virtual mappings are checked. So, a path `/content/sample` might be mapped `/sample` to revers the `/content` prefixing. Or the main administrative page - say `/system/admin/main.html` \- may be mapped to the virtual URL `/`.

More details on mappings can be found at [Mappings for Resource Resolution](/documentation/the-sling-engine/mappings-for-resource-resolution.html).

### Relative Path Resolution

Sometimes it is required to resolve relative paths to Resources. An example of such a use case is Script and Servlet resolution which starts with a relative path consisting of the Resource type, optional selectors and the request extension or method name. By scanning a search path for these relative paths a system provided Resource may be overwritten with some user defined implementation.

Consider for example, the system would provide a Servlet to render Resources of type `nt:file`. This Servlet would be registered under the path `/libs/nt/file/html`. For a certain web application, this default HTML rendering might not be appropriate, so a Script is created as `/apps/nt/file/html.jsp` with a customized HTML rendering. By defining the search path to be `[/apps,/libs]` the Servlet resolver would call the `ResourceResolver.getResource(String)` method with the relative path `nt/file/html` and be provided with the first matching resource - `/apps/nt/file/html.jsp` in this example.

Of course the search path is not used for absolute path arguments.

### Querying Resources

For convenience the `ResourceResolver` provides two Resource querying methods `findResources` and `queryResources` both methods take as arguments a JCR query string and a query language name. These parameters match the parameter definition of the `QueryManager.createQuery(String statement, String language)` method of the JCR API.

The return value of these two methods differ in the use case:

* `findResources` returns an `Iteratory<Resource>` of all Resources matching the query. This method is comparable to calling `getNodes()` on the `QueryResult` returned from executing the JCR query.
* `queryResources` returns an `Iterator<Map<String, Object>>`. Each entry in the iterator is a `Map<String, Object` representing a JCR result `Row` in the `RowIterator` returned from executing the JCR query. The map is indexed by the column name and the value of each entry is the value of the named column as a Java Object.

These methods are convenience methods to more easily post queries to the repository and to handle results in very straight forward way using only standard Java functionality.

Please note, that Resource querying is currently only supported for repository based Resources. These query methods are not reflected in the `ResourceProvider` interface used to inject non-repository Resources into the Resource tree.

## Providing Resources

The virtual Resource tree to which the the Resource accessor methods `resolve` and `getResource` provide access is implemented by a collection of registered `ResourceProvider` instances. The main Resource provider is of course the repository based `JcrResourceProvider` which supports Node and Property based resources. This Resource provider is always available in Sling. Further Resource providers may or may not exist.

Each Resource provider is registered as an OSGi service with a required service registration property `provider.roots`. This is a multi-value String property listing the absolute paths Resource tree entries serving as roots to provided subtrees. For example, if a Resource provider is registered with the service registration property `provider.roots` set to */some/root*, all paths starting with `/some/root` are first looked up in the given Resource Provider.

When looking up a Resource in the registered Resource providers, the `ResourceResolver` applies a longest prefix matching algorithm to find the best match. For example consider three Resource provider registered as follows:

* JCR Resource provider as `/`
* Resource provider R1 as `/some`
* Resource provider R2 as `/some/path`

When accessing a Resource with path `/some/path/resource` the Resource provider *R2* is first asked. If that cannot provide the resource, Resource provider *R1* is asked and finally the JCR Resource provider is asked. The first Resource provider having a Resource with the requested path will be used.

### JCR-based Resources

JCR-based Resources are provided with the default `JcrResourceProvider`. This Resource provider is always available and is always asked last. That is Resources provided by other Resource providers may never be overruled by repository based Resources.

These are the authenticationInfo keys (which can be used with [`ResourceResolverFactory.getResourceResolver(java.util.Map authenticationInfo)`](https://sling.apache.org/apidocs/sling11/org/apache/sling/api/resource/ResourceResolverFactory.html#getResourceResolver-java.util.Map-)) which are supported by the `JcrResourceProvider`:

| AuthenticationInfo Key | Constant | Type | Description |
| --- | --- | --- | --- |
| `user.jcr.session` | [`JcrResourceConstants.AUTHENTICATION_INFO_SESSION`](https://sling.apache.org/apidocs/sling11/org/apache/sling/jcr/resource/api/JcrResourceConstants.html#AUTHENTICATION_INFO_SESSION) | `javax.jcr.Session` | The session which is used for the underlying repository access. When calling `close()` on the returned `ResourceResolver` the session will not(!) be closed. |
| `user.jcr.credentials` | [`JcrResourceConstants.AUTHENTICATION_INFO_CREDENTIALS`](https://sling.apache.org/apidocs/sling11/org/apache/sling/jcr/resource/api/JcrResourceConstants.html#AUTHENTICATION_INFO_CREDENTIALS) | `javax.jcr.Credentials` | The credentials object from which to create the new underlying JCR session
| `user.name` | [`ResourceResolverFcatory.AUTHENTICATION_INFO_CREDENTIALS`](https://sling.apache.org/apidocs/sling11/org/apache/sling/api/resource/ResourceResolverFactory.html#USER) | String | Optionally used with `user.password` to create simple credentials from which the Session is being created.
| `user.impersonation` | [`ResourceResolverFcatory.USER_IMPERSONATION`](https://sling.apache.org/apidocs/sling11/org/apache/sling/api/resource/ResourceResolverFactory.html#USER_IMPERSONATION) | String | User ID which should be used for impersonation via `javax.jcr.Session.impersonate(...)`. Must be combined with one of the other authentication info keys.

There is support for the following [path parameters](url-decomposition.html):

Path Parameter | Example Value | Description | Since 
 --- | --- | --- | ---
| `v` | `1.0` | Retrieves the underlying JCR node from the [version history](https://docs.adobe.com/docs/en/spec/jcr/2.0/15_Versioning.html) leveraging the version label given in the value. | [SLING-848](https://issues.apache.org/jira/browse/SLING-848)

#### Main Binary Property

The main binary property (i.e. the one being exposed by `Resource.adaptTo(InputStream.class)`) is determined like follows:

1. `jcr:data` is such a property exists, otherwise
2. the primary item of the underlying node (as defined by [Node.getPrimaryItem()](https://docs.adobe.com/docs/en/spec/jsr170/javadocs/jcr-2.0/javax/jcr/Node.html#getPrimaryItem())).

For node type `nt:file` the property is looked up in the child node `jcr:content` for both cases. For all other node types it is looked up in the underlying node of the current resource.

### Bundle-based Resources

Resources may by provided by OSGi bundles. Providing bundles have a Bundle manifest header `Sling-Bundle-Resources` containing a list of absolute paths provided by the bundle. The path are separated by comma or whitespace (SP, TAB, VTAB, CR, LF).

The `BundleResourceProvider` supporting bundle-based Resources provides directories as Resources of type `nt:folder` and files as Resources of type `nt:file`. This matches the default primary node types intended to be used for directories and files in JCR repositories. 

For details see [Bundle Resource.](/documentation/bundles/bundle-resources-extensions-bundleresource.html)

### Servlet Resources

Servlet Resources are registered by the Servlet Resolver bundle for Servlets registered as OSGi services. See [Servlet Resolution](/documentation/the-sling-engine/servlets.html) for information on how Servlet Resources are provided.

### File System Resources

The Filesystem Resource Provider provides access to the operating system's filesystem through the Sling ResourceResolver. Multiple locations may be mapped into the resource tree by configuring the filesystem location and the resource tree root path for each location to be mapped. 

For details see [File System Resources](/documentation/bundles/accessing-filesystem-resources-extensions-fsresource.html).

### Merged Resources

The merged resource provider exposes a view on merged resources from multiple locations.

For details see [Resource Merger](/documentation/bundles/resource-merger.html).

### Custom Resource providers
Custom ResourceProvider services can be used to integrate your own custom resources in the Sling resource tree.

For a simple example of that, see the [PlanetResourceProvider][4] used in our integration tests.

##  Writeable Resources
Sling now supports full CRUD functionality on Resources, without necessarily having to go through the JCR API.

The advantage is that this works for any ResourceProvider that supports the required operations.

See the testSimpleCRUD method in [WriteableResourcesTest][5] for a basic example of how that works.
More details can be found at [Sling API CRUD Support](/documentation/the-sling-engine/sling-api-crud-support.html).

## Resource Observation

To be notified whenever certain resources or their properties have been modified/added/removed there are different possibilities

### Resource Observation API (ResourceChangeListener)

*This API is only available since Sling API 2.11.0 ([SLING-4751](https://issues.apache.org/jira/browse/SLING-4751)).*

Register an OSGi service for [`org.apache.sling.api.resource.observation.ResourceChangeListener`][6] to be notified about local changes. To be also notified about external changes (i.e. changes triggered by another Sling instance leveraging a clustered repository  make sure that your service implementation also implements the marker interface [`org.apache.sling.api.resource.observation.ExternalResourceChangeListener`][7]. The interface `ExternalResourceChangeListener` is not supposed to be registered with OSGi though.
Certain properties can be used to restrict subscription to only a subset of events.

### OSGi Event Admin

Resource events are sent out via the OSGi Event Admin. You can subscribe to those event by registering an OSGi service for [`org.osgi.service.event.EventHandler`][8]. Several properties should be used to restrict the subscription to only the relevant event. The event topics which are used for resources are listed as constants in [`org.apache.sling.api.SlingConstants`][9] starting with the prefix `TOPIC_`. 

You receive events no matter whether they originate from the local repository or from a remote clustered repository. You can check though in your event listener for the [event attribute `event.application`](/apache-sling-eventing-and-job-handling.html#basic-principles), which is only set in case the event was triggered from an external resource modification (compare with [`DEAConstants`](https://sling.apache.org/apidocs/sling9/org/apache/sling/event/dea/DEAConstants.html) and try to reuse the constant from there).

The OSGi event handlers may be [blacklisted by Apache Felix](http://felix.apache.org/documentation/subprojects/apache-felix-event-admin.html#configuration) in case the processing takes too long. Therefore dispatch all long-lasting operations to a new thread or start a new Sling Job.

## Wrap/Decorate Resources

The Sling API provides an easy way to wrap or decorate a resource before returning. Details see [Wrap or Decorate Resources](/documentation/the-sling-engine/wrap-or-decorate-resources.html).


  [1]: http://sling.apache.org/apidocs/sling8/org/apache/sling/api/resource/ResourceMetadata.html
  [2]: http://sling.apache.org/apidocs/sling8/org/apache/sling/api/resource/Resource.html
  [3]: http://sling.apache.org/apidocs/sling8/org/apache/sling/api/resource/AbstractResource.html
  [4]: https://github.com/apache/sling-org-apache-sling-launchpad-test-services/tree/master/src/main/java/org/apache/sling/launchpad/testservices/resourceprovider
  [5]: https://github.com/apache/sling-org-apache-sling-launchpad-test-services/blob/master/src/main/java/org/apache/sling/launchpad/testservices/serversidetests/WriteableResourcesTest.java
  [6]: https://github.com/apache/sling-org-apache-sling-api/blob/master/src/main/java/org/apache/sling/api/resource/observation/ResourceChangeListener.java
  [7]: https://github.com/apache/sling-org-apache-sling-api/blob/master/src/main/java/org/apache/sling/api/resource/observation/ExternalResourceChangeListener.java
  [8]: https://osgi.org/javadoc/r6/cmpn/org/osgi/service/event/EventHandler.html
  [9]: http://sling.apache.org/apidocs/sling8/org/apache/sling/api/SlingConstants.html
