title=Sling API CRUD Support		
type=page
status=published
tags=api,core
~~~~~~

[TOC]

# Apache Sling API Support

As of version 2.3.0, the Sling API provides full Create Read Update Delete (CRUD) features.  CRUD support is provided by the addition of the following methods to the ResourceResolver:

 * [`void delete(Resource resource) throws PersistenceException`](https://sling.apache.org/apidocs/sling11/org/apache/sling/api/resource/ResourceResolver.html#delete-org.apache.sling.api.resource.Resource-)
 * [`Resource create(Resource parent, String name, Map<String, Object> properties) throws PersistenceException`](https://sling.apache.org/apidocs/sling11/org/apache/sling/api/resource/ResourceResolver.html#create-org.apache.sling.api.resource.Resource-java.lang.String-java.util.Map-)
 * [`void revert()`](https://sling.apache.org/apidocs/sling11/org/apache/sling/api/resource/ResourceResolver.html#revert--)
 * [`void commit() throws PersistenceException`](https://sling.apache.org/apidocs/sling11/org/apache/sling/api/resource/ResourceResolver.html#commit--)
 * [`boolean hasChanges()`](https://sling.apache.org/apidocs/sling7/org/apache/sling/api/resource/ResourceResolver.html#hasChanges--)
 * [`void refresh()`](https://sling.apache.org/apidocs/sling11/org/apache/sling/api/resource/ResourceResolver.html#refresh--)
 * `orderBefore(Resource parent, String name, String followingSiblingName) throws UnsupportedOperationException, PersistenceException, IllegalArgumentException` (since [API 2.24.0](https://issues.apache.org/jira/browse/SLING-7975))
 
Those methods provide the ability to create and delete resources as well. In addition you can adapt a `Resource` to a `ModifiableValueMap` interface which is similar to the `ValueMap` interface, but allows for updating properties on a resource.

# Examples

Here are some examples of common operations performed using the Sling Post Servlet and Sling API CRUD support.  Note, the examples are derived from the cheat sheet in Adobe's AEM documentation at [https://experienceleague.adobe.com/docs/experience-manager-cloud-service/implementing/developing/full-stack/sling-cheatsheet.html](https://experienceleague.adobe.com/docs/experience-manager-cloud-service/implementing/developing/full-stack/sling-cheatsheet.html).

## Updating a Property

Update `/myresource`, setting the title and body:

**Sling Post Servlet**

    <form action="/myresource" method="POST">
      <input type="text" name="title">
      <textarea name="body">
    </form>
    
**Sling API CRUD**

    Resource myResource = resourceResolver.getResource("/myresource");
    ModifiableValueMap properties = myResource.adaptTo(ModifiableValueMap.class);
    properties.put("title", {TITLE});
    properties.put("body", {BODY});
    resourceResolver.commit();
    
## Create New Resource

Create a new resource below `/myresource`

**Sling Post Servlet**

    <form action="/myresource/" method="POST">
      <input type="text" name="dummy">
    </form>

**Sling API CRUD**

    Resource myResource = resourceResolver.getResource("/myresource");
    Map<String,Object> properties = new HashMap<String,Object>();
    properties.put("jcr:primaryType", "nt:unstructured");
    properties.put("sling:resourceType", "myapp/components/mytype");
    Resource dummy = resourceResolver.create(myResource, "dummy", properties);
    resourceResolver.commit();

## Remove a Property

Remove the property title

**Sling Post Servlet**

    <form action="/myresource" method="POST">
      <input type="hidden" name="title@Delete">
    </form>

**Sling API CRUD**

    Resource myResource = resourceResolver.getResource("/myresource");
    ModifiableValueMap properties = myResource.adaptTo(ModifiableValueMap.class);
    properties.remove("title");
    resourceResolver.commit();

## Copy a Resource

Copy the resource `/myresource` to `/myresource2`

**Sling Post Servlet**

    <form action="/myresource" method="POST">
      <input type="hidden" name=":operation" value="copy">
      <input type="hidden" name=":dest" value="/myresource2">
      <input type="hidden" name=":replace" value="true">
    </form>

**Sling API CRUD**

    Map<String,Object> properties = myResource.adaptTo(ValueMap.class);
    Resource myResource2 = resourceResolver.create(null, "myresource2", properties);
    resourceResolver.commit();

## Move a Resource

Move the resource `/myresource2` to `/myresource3`

**Sling Post Servlet**

    <form action="/myresource2" method="POST">
      <input type="hidden" name=":operation" value="move">
      <input type="hidden" name=":dest" value="/myresource3">
    </form>

**Sling API CRUD**

    Resource myResource2 = resourceResolver.getResource("/myresource2");
    Map<String,Object> properties = myResource2.adaptTo(ValueMap.class);
    Resource myResource3 = resourceResolver.create(null, "myresource3", properties);
    resourceResolver.delete(myResource2);
    resourceResolver.commit();

## Setting non-String Value

Set the property date to a particular date

**Sling Post Servlet**

    <form action="/myresource3" method="POST">
      <input type="text" name="date" value="2008-06-13T18:55:00">
      <input type="hidden" name="date@TypeHint" value="Date">
    </form>

**Sling API CRUD**

    Resource myResource3 = resourceResolver.getResource("/myresource3");
    Calendar calendar = [SOME_DATE];
    ModifiableValueMap properties = myResource3.adaptTo(ModifiableValueMap.class);
    properties.put("date", calendar);
    resourceResolver.commit();

## Delete a Resource

Delete the resource `/myresource`

**Sling Post Servlet**

    <form action="/myresource" method="POST">
      <input type="hidden" name=":operation" value="delete">
    </form>
    
**Sling API CRUD**
    
    Resource myResource = resourceResolver.getResource("/myresource");
    resourceResolver.delete(myResource);
    resourceResolver.commit();

## Order a Resource

Reorder the resource `/myresource` before sibling node `child1`

**Sling Post Servlet**

    <form action="/myresource" method="POST">
      <input type="hidden" name=":order" value="before child1">
    </form>
    
**Sling API CRUD**
    
    Resource myResource = resourceResolver.getResource("/");
    resourceResolver.orderBefore(myResource, "myresource", "child1");
    resourceResolver.commit();


# Value Class Support


<div class="info">
	Please note, this information is specific to the Sling JCR Resource implementation provided by the Apache Sling project.  Other implementations may have different value class support.  
</div>

The classes implementing the following types are supported directly when setting properties:

 * [Calendar](http://docs.oracle.com/javase/8/docs/api/java/util/Calendar.html)
 * [InputStream](http://docs.oracle.com/javase/8/docs/api/java/io/InputStream.html)
 * [Node](https://s.apache.org/jcr-2.0-javadoc/javax/jcr/Node.html)
 * [BigDecimal](http://docs.oracle.com/javase/8/docs/api/java/math/BigDecimal.html)
 * [Long](http://docs.oracle.com/javase/8/docs/api/java/lang/Long.html)
 * [Short](http://docs.oracle.com/javase/8/docs/api/java/lang/Short.html)
 * [Integer](http://docs.oracle.com/javase/8/docs/api/java/lang/Integer.html)
 * [Number](http://docs.oracle.com/javase/8/docs/api/java/lang/Number.html)
 * [Boolean](http://docs.oracle.com/javase/8/docs/api/java/lang/Boolean.html)
 * [String](http://docs.oracle.com/javase/8/docs/api/java/lang/String.html)
 
As well as the corresponding primitive types.  Any object which implements the Serializable interface will be serialized and the result of the serialization will be saved as a binary value for the property.
