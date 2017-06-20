title=TODO title for getting-resources-and-properties-in-sling.md 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: Getting Resources and Properties in Sling


The Resource is one of the central parts of Sling. Extending from JCR's Everything is Content, Sling assumes Everthing is a Resource. Thus Sling is maintaining a virtual tree of resources, which is a merger of the actual contents in the JCR Repository and resources provided by so called resource providers. By doing this Sling fits very well in the paradigm of the REST architecture.

In this article we will explore a few ways to programmatically map a resource path (String) to a resource object (Resource) and its properties in Sling, from within an OSGI service, a servlet and a JSP.

The whole game consists in first getting a `ResourceResolver` and then getting the `Resource` itself.

## Within an OSGI Service/Compoment 

You can access a resource through the `ResourceResolverFactory` service:

    #!java
    @Reference
    private ResourceResolverFactory resolverFactory;
    
    public void myMethod() {
        try {
            String resourcePath = "path/to/resource";
            ResourceResolver resourceResolver = resolverFactory.getAdministrativeResourceResolver(null);
            Resource res = resourceResolver.getResource(resourcePath);
            // do something with the resource
            // when done, close the ResourceResolver
            resourceResolver.close();
        } catch (LoginException e) {
            // log the error
        }
    }



## Within a Servlet 

You can access the resource defined by the request URL through the `SlingHttpServletRequest`:

    #!java
    // req is the SlingHttpServletRequest
    Resource res = req.getResource();


You can access any resource by first accessing the `ResourceResolver`:

    #!java
    String resourcePath = "path/to/resource";
    // req is the SlingHttpServletRequest
    ResourceResolver resourceResolver = req.getResourceResolver();
    Resource res = resourceResolver.getResource(resourcePath);


## Within a JSP file 

When you use the `<sling:defineObjects>` tag in a JSP file, you have access to a few handy objects, one of them is `resource`, the resource that is resolved from the URL. Another one is `resourceResolver`, the `ResourceResolver` defined through the `SlingHttpServletRequest`. 

To access a resource:

    #!jsp
    <sling:defineObjects>
    <%
        String resourcePath = "path/to/resource";
        Resource res = resourceResolver.getResource(resourcePath);
    %>


If needed you can adapt a Sling Resource to a JCR Node:

    #!java
    Node node = resource.adaptTo(Node.class);


Note: `resource.adaptTo(Node.class)` may return null if the resource is not backed by a JCR node. This is particularly the case for `NonExistingResource` resources or resource provided by a non-JCR resource provider.

## Accessing a Property 

The `ValueMap` is an easy way to access properties of a resource. With most resources you can use `Adaptable.adaptTo(Class)` to adapt the resource to a value map:

    #!java
    // res is the Resource
    ValueMap properties = res.adaptTo(ValueMap.class);


You can also access the properties through the `ResourceUtil` utility class:

    #!java
    // res is the Resource
    ValueMap properties = ResourceUtil.getValueMap(res);


Then, to access a specific String property called `propName`:

    #!java
    String rule = properties.get(propName, (String) null);


For more details about resources and how to access them in Sling, you can refer to the [Sling documentation about Resources](/documentation/the-sling-engine/resources.html).
