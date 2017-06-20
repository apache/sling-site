title=Adapters		
type=page
status=published
~~~~~~

[TOC]

The `Resource` and `ResourceResolver` interfaces are defined with a method `adaptTo`, which adapts the object to other classes. Using this mechanism the JCR session of the resource resolver calling the `adaptTo` method with the `javax.jcr.Session` class object. Likewise the JCR node on which a resource is based can be retrieved by calling the `Resource.adaptTo` method with the `javax.jcr.Node` class object.

To use resources as scripts, the `Resource.adaptTo` method must support being called with the `org.apache.sling.api.script.SlingScript` class object. But of course, we do not want to integrate the script manager with the resource resolver. To enable adapting objects to classes which are not foreseen by the original implementation, a factory mechanism is used. This way, the script manager can provide an adapter factory to adapt `Resource` to `SlingScript` objects.


# Adaptable

The `Adaptable` interface defines the API to be implemented by a class providing adaptability to another class. The single method defined by this interface is


    /**
     * Adapts the adaptable to another type.
     * <p>
     * Please not that it is explicitly left as an implementation detail whether
     * each call to this method with the same <code>type</code> yields the same
     * object or a new object on each call.
     * <p>
     * Implementations of this method should document their adapted types as
     * well as their behaviour with respect to returning newly created or not
     * instance on each call.
     *
     * @param <AdapterType> The generic type to which this resource is adapted
     *            to
     * @param type The Class object of the target type, such as
     *            <code>javax.jcr.Node.class</code> or
     *            <code>java.io.File.class</code>
     * @return The adapter target or <code>null</code> if the resource cannot
     *         adapt to the requested type
     */
    <AdapterType> AdapterType adaptTo(Class<AdapterType> type);


This method is called to get a view of the same object in terms of another class. Examples of implementations of this method are the Sling `ResourceResolver` implementation providing adapting to a JCR session and the Sling JCR based `Resource` implementation providing adapting to a JCR node.

# Listing Adaptation Possibilities

The Web Console Plugin at `/system/console/adapters` and at `/system/console/status-adapters` can be used to list all existing adaptables in the system with their according adapter classes.

The web console plugin evaluates metadata being provided by any `AdapterFactory` services as well as metadata being provided through the file `SLING-INF/adapters.json`

# Implementing Adaptable

Each adaptable should derive from `SlingAdaptable` to automatically profit from all according `AdapterFactories` registered in the system. 
In case the `adaptTo(...)` method is being overwritten an according `SLING-INF/adapters.json` should be included in the providing bundle 
listing all adaptation possibilities. While this file is not strictly necessary for the actual adaptation to work, it provides useful information to the Web Console plugin. 
Otherwise developers will not know which adaptations are supported. The format of this JSON file looks like this ([SLING-2295](https://issues.apache.org/jira/browse/SLING-2295)):

    { 
      <fully qualified class name of adaptable> : {
        <condition> :  <fully qualified class name of adapter, may be a JSON array>
      }
    }

For example

    {
      "org.apache.sling.api.resource.Resource" : {
        "If the adaptable is a AuthorizableResource." : [
          "java.util.Map",
          "org.apache.sling.api.resource.ValueMap",
          "org.apache.jackrabbit.api.security.user.Authorizable"
        ],
        "If the resource is an AuthorizableResource and represents a JCR User" : "org.apache.jackrabbit.api.security.user.User",
        "If the resource is an AuthorizableResource and represents a JCR Group" : "org.apache.jackrabbit.api.security.user.Group"
      }
    }

Instead of manually creating that JSON file, the annotations from the module [adapter-annotations](https://svn.apache.org/viewvc/sling/trunk/tooling/maven/adapter-annotations/)  can be used together with the goal `generate-adapter-metadata` from the [Maven Sling Plugin](http://sling.apache.org/components/maven-sling-plugin/generate-adapter-metadata-mojo.html) to generate it automatically ([SLING-2313](https://issues.apache.org/jira/browse/SLING-2313)).


# Extending Adapters

Sometimes an `Adaptable` implementation cannot foresee future uses and requirements. To cope with such extensibility requirements two interfaces and an abstract base class are defined:

  * `AdapterManager`
  * `AdapterFactory`
  * `SlingAdaptable`


## AdapterFactory

The `AdapterFactory` interface defines the service interface and API for factories supporting extensible adapters for `SlingAdaptable` objects. The interface has a single method:


    /**
     * Adapt the given object to the adaptable type. The adaptable object is
     * guaranteed to be an instance of one of the classes listed in the
     * {@link #ADAPTABLE_CLASSES} services registration property. The type
     * parameter is one of the classes listed in the {@link #ADAPTER_CLASSES}
     * service registration properties.
     * <p>
     * This method may return <code>null</code> if the adaptable object cannot
     * be adapted to the adapter (target) type for any reason. In this case, the
     * implementation should log a message to the log facility noting the cause
     * for not being able to adapt.
     * <p>
     * Note that the <code>adaptable</code> object is not required to implement
     * the <code>Adaptable</code> interface, though most of the time this method
     * is called by means of calling the {@link Adaptable#adaptTo(Class)}
     * method.
     *
     * @param <AdapterType> The generic type of the adapter (target) type.
     * @param adaptable The object to adapt to the adapter type.
     * @param type The type to which the object is to be adapted.
     * @return The adapted object or <code>null</code> if this factory instance
     *         cannot adapt the object.
     */
    <AdapterType> AdapterType getAdapter(Object adaptable,
            Class<AdapterType> type);


Implementations of this interface are registered as OSGi services providing two lists: The list of classes which may be adapted (property named `adaptables`) and the list of classes to which the adapted class may be adapted (property named `adapters`). A good example of an Class implementing `AdapterFactory` is the `SlingScriptAdapterFactory`. In addition a property named `adapter.condition` can be provided which is supposed to contain a string value explaining under which circumstances the adaption will work (if there are any restrictions). This is evaluated by the Web Console Plugin.

`AdapterFactory` services are gathered by a `AdapterManager` implementation for use by consumers. Consumers should not care for `AdapterFactory` services.


## AdapterManager

The `AdapterManager` is defines the service interface for the generalized and extensible use of `AdapterFactory` services. Thus the adapter manager may be retrieved from the service registry to try to adapt whatever object that needs to be adapted - provided appropriate adapters exist.

The `AdapterManager` interface is defined as follows:


    /**
     * Returns an adapter object of the requested <code>AdapterType</code> for
     * the given <code>adaptable</code> object.
     * <p>
     * The <code>adaptable</code> object may be any non-<code>null</code> object
     * and is not required to implement the <code>Adaptable</code> interface.
     *
     * @param <AdapterType> The generic type of the adapter (target) type.
     * @param adaptable The object to adapt to the adapter type.
     * @param type The type to which the object is to be adapted.
     * @return The adapted object or <code>null</code> if no factory exists to
     *         adapt the <code>adaptable</code> to the <code>AdapterType</code>
     *         or if the <code>adaptable</code> cannot be adapted for any other
     *         reason.
     */
    <AdapterType> AdapterType getAdapter(Object adaptable,
            Class<AdapterType> type);


Any object can theoretically be adapted to any class even if it does not implement the `Adaptable` interface, if an `AdapterFactory` service delivers a `getAdapter()` method which adapts an object to another one. To check if there's any existing `AdapterFactory` which can adapt a given object to another one the `AdapterManager` service with its `getAdapter()` method does the job. So the `Adaptable` interface merely is an indicator that the object provides built-in support for being adapted.


## SlingAdaptable

The `SlingAdaptable` class is an implementation of the `Adaptable` interface which provides built-in support to call the `AdapterManager` to provide an adapter from the `Adaptable` object to the requested class.

An example of extending the `SlingAdaptable` class will be the Sling JCR based `Resource` implementation. This way, such a resource may be adapted to a `SlingScript` by means of an appropriately programmed `AdapterFactory` (see below).
