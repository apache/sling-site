title=Sling Models		
type=page
status=published
tags=models
~~~~~~

[TOC]

Many Sling projects want to be able to create model objects - POJOs which are automatically mapped from Sling objects, typically resources, but also request objects. Sometimes these POJOs need OSGi services as well.
Sling Models provide an easy way to achieve this, integrating into the already existing pattern and infrastructure provided by Sling.

# Basic Usage
## Model Classes

In the simplest case, the model class is annotated with `@Model` and the adaptable class. 

### Field Injection

Fields which need to be injected are annotated with `@ValueMapValue`:

    ::java
    import org.apache.sling.api.resource.Resource;
    import org.apache.sling.models.annotations.Model;
    import org.apache.sling.models.annotations.injectorspecific.ValueMapValue;

    @Model(adaptables=Resource.class)
    public class MyModel {
    
        @ValueMapValue
        private String propertyName;
    }

In this case, a property named `propertyName` will be looked up from the Resource (after first adapting it to a `ValueMap`) and it is injected. Fields can use any visibility modifier:

    ::java
    @Model(adaptables=Resource.class)
    public class PublicFieldModel {
    
        @ValueMapValue
        public String publicField;
    }

    @Model(adaptables=Resource.class)
    public class ProtectedFieldModel {
    
        @ValueMapValue
        protected String protectedField;
    }

    @Model(adaptables=Resource.class)
    public class PrivateFieldModel {
    
        @ValueMapValue
        private String privateField;
    }

    @Model(adaptables=Resource.class)
    public class PackagePrivateFieldModel {
    
        @ValueMapValue
        String packagePrivateField;
    }

### Method Injection (on interface only models)

For an interface, it is similar:

	::java
	@Model(adaptables=Resource.class)
	public interface MyModel {
	 
	    @ValueMapValue
	    String getPropertyName();
	}

Interface methods must be `public`. Even though private interface methods have been available since Java 9, Sling Models uses Dynamic Proxies to instantiate the interfaces, which does not work with private interface methods. Additionally, while default interface methods will work with interface injection, the default implementation (in the interface) is currently not used, and will not be executed.

### Constructor Injection

Constructor injection is also supported (as of [Sling Models 1.1.0](https://issues.apache.org/jira/browse/SLING-3716)):

    ::java
    @Model(adaptables=Resource.class)
    public class MyModel {    
        @Inject
        public MyModel(@ValueMapValue(name="propertyName") String propertyName) {
          // constructor code
        }
    }

Because the name of a constructor argument parameter cannot be detected via the Java Reflection API a `@Named` annotation (or a `name` element on injector specific annotations) is mandatory for injectors that require a name for resolving the injection. This restriction can be bypassed since [Sling Models 1.7.0](https://issues.apache.org/jira/browse/SLING-11917) when the compiler generates metadata for method names via [javac option `-parameters`](https://docs.oracle.com/en/java/javase/21/docs/specs/man/javac.html#option-parameters) or the according [maven-compiler-plugin parameter](https://maven.apache.org/plugins/maven-compiler-plugin/compile-mojo.html#parameters).
In order for a constructor to be used for injection *it has to be annotated on method level with `@Inject`*. In addition using injector-specific annotations on parameter level is supported.
You can also reference the adaptable itself via a constructor argument with the `@Self` annotation.

Constructors may use any visibility modifier (as of [Sling Models 1.5.0](https://issues.apache.org/jira/browse/SLING-8069)).

In addition to that constructors taking a single argument of the adaptable type are supported. Those don't need any annotations. So 

    ::java
    @Model(adaptables=Resource.class)
    public class MyModel {    
        @Inject
        public MyModel(@Self Resource resource) {
          // constructor code
        }
    }

and 

    ::java
    @Model(adaptables=Resource.class)
    public class MyModel {    
        public MyModel(Resource resource) {
          // constructor code
        }
    }

are functionally equivalent.

The implicit constructors of [record classes] are supported since [Sling Models 1.7.0](https://issues.apache.org/jira/browse/SLING-12359) as well.

## @Model and Adaptable Types

When defining a Sling Model class, the `adaptables` parameter to the `@Model` annotation is mostly determined by the injectors being used. The provided class must satisfy the needs of all injectors (for the details see [the table below](#available-injectors-1)). For example if the model class only uses the `ValueMap` injector, the adaptables parameter can be a `Resource`, a `SlingJakartaHttpServletRequest`, a `SlingHttpServletRequest` or both. But if the `Request Attribute` injector is used, only an adaptable of the type `SlingJakartaHttpServletRequest` or `SlingHttpServletRequest` will work.

In order to increase the reuse it's advised to stick to `Resource` as adaptables if possible, as such a model can be used in the context of request and outside of it. 

## Bundle Manifest Configuration

In order for these classes to be picked up, there is a header which must be added to the bundle's manifest:

	<Sling-Model-Packages>
	  org.apache.sling.models.it.models
	</Sling-Model-Packages>

This header must contain all packages which contain model classes or interfaces. However, subpackages need not be listed
individually, e.g. the header above will also pick up model classes in `org.apache.sling.models.it.models.sub`.
However, wildcard characters like `*` are not supported. 
Multiple packages can be listed in a comma-separated list (any whitespace will be removed):

    <Sling-Model-Packages>
      org.apache.sling.models.it.models,
      org.apache.sling.other.models
    </Sling-Model-Packages>

Alternatively it is possible to list all classes individually that are Sling Models classes via the `Sling-Model-Classes` header. Again, wildcard characters like `*` are not supported. 

If you use the Sling Models bnd plugin all required bundle headers are generated automatically at build time, see chapter [Registration of Sling Models classes via bnd plugin](#registration-of-sling-models-classes-via-bnd-plugin-1) below.

# Client Code

There are multiple ways to instantiate Sling Models.

## adaptTo()

Client code doesn't need to be aware that Sling Models is being used. It just uses the Sling Adapter framework:

    ::java
	MyModel model = resource.adaptTo(MyModel.class)
	
Or

	::jsp
	<sling:adaptTo adaptable="${resource}" adaptTo="org.apache.sling.models.it.models.MyModel" var="model"/>

Or

	::jsp
	${sling:adaptTo(resource, 'org.apache.sling.models.it.models.MyModel')}

As with other AdapterFactories, if the adaptation can't be made for any reason, `adaptTo()` returns null.

## ModelFactory
*See also  [SLING-3709](https://issues.apache.org/jira/browse/SLING-3709)*

Since Sling Models 1.2.0 there is another way of instantiating models. The OSGi service `ModelFactory` provides a method for instantiating a model that throws exceptions. This is not allowed by the Javadoc contract of the `adaptTo()` method. That way `null` checks are not necessary and it is easier to see why instantiation of the model failed.

    ::java
	try {
        MyModel model = modelFactory.createModel(object, MyModel.class);
    } catch (Exception e) {
        // give out error message that the model could not be instantiated. 
        // The exception contains further information. 
        // See the javadoc of the ModelFactory for which Exception can be expected here
    }

In addition `ModelFactory` provides methods for checking whether a given class is a model at all (having the model annotation) or whether a class can be adapted from a given adaptable. 

## Usage in HTL
Please see [Sling Models Use Provider](/documentation/bundles/scripting/scripting-htl.html#java-use-provider-1); internally it uses the `ModelFactory` from above.


# Available injectors

In the above cases just the `@ValueMapValue` annotation was used, but there other available injectors. For each injector there is a specialized annotation available. For the optional parameters see the next section.


Title | Injector Name  | Annotation          | Supported Optional Elements    | Description   | Applicable to (including  using `@Via`) | Array Support   | Parametrized Type Support
----- | -----------------   | ------------------------------ |------------------------- | --------------- | ---------------------------
Scripting Bindings|`script-bindings` | `@ScriptVariable`   | `injectionStrategy` and `name`          | Injects the script variable defined via [Sling Bindings](https://cwiki.apache.org/confluence/display/SLING/Scripting+variables). It requires the the adaptable is a `SlingJakartaHttpServletRequest` or `SlingHttpServletRequest`. If `name` is not set the name is derived from the method/field name.  | A ServletRequest object which has the `Sling Bindings` attribute defined | no conversion is done |  If a parameterized type is passed, the bindings value must be of a compatible type of the parameterized type.
ValueMap | `valuemap` | `@ValueMapValue`    | `injectionStrategy`, `name`   | Injects a `ValueMap` value taken from the adapted resource (either taking from the adapted resource or the resource of the adapted SlingJakartaHttpServletRequest or SlingHttpServletRequest). If `name` is not set the name is derived from the method/field name. |Any object which is or can be adapted to a `ValueMap` |  Primitive arrays wrapped/unwrapped as necessary. Wrapper object arrays are unwrapped/wrapped as necessary. | Parameterized `List` and `Collection` injection points are injected by getting an array of the component type and creating an unmodifiable `List` from the array.
Child Resource | `child-resources` | `@ChildResource`    | `injectionStrategy`, `name`   | Injects a child resource by name (taken from the adapted resource (either taking from the adapted resource or the resource of the adapted SlingJakartaHttpServletRequest or SlingHttpServletRequest). If `name` is not set the name is derived from the method/field name. | `Resource` objects  |  none  | if a parameterized type `List` or `Collection` is passed, a `List<Resource>` is returned (the contents of which may be adapted to the target type) filled with all child resources of the resource looked up by the given name.
Request Attribute | `request-attributes` | `@RequestAttribute` | `injectionStrategy`, `name`    | Injects a request attribute by name, it requires the the adaptable is a `SlingJakartaHttpServletRequest` or `SlingHttpServletRequest` . If `name` is not set the name is derived from the method/field name. | `ServletRequest` objects | no conversion is done | If a parameterized type is passed, the request attribute must be of a compatible type of the parameterized type.
Resource path | `resource-path` | `@ResourcePath`     | `injectionStrategy`, `path`, and `name` |Injects a resource either by path or by reading a property with the given name. | `Resource`, `SlingJakartaHttpServletRequest` or `SlingHttpServletRequest` objects | yes | none
OSGi service | `osgi-services` | `@OSGiService`      | `injectionStrategy`, `filter`           | Injects an OSGi service by type (and the optional filter) | Any object | yes | Parameterized `List` and `Collection` injection points are injected by getting an array of the services and creating an unmodifiable `List` from the array.
Context-Aware Configuration | `ca-config` | `@ContextAwareConfiguration` | `injectionStrategy`, `name`    |  Lookup context-aware configuration. See [Context-Aware Configuration](#context-aware-configuration) below. | Any object | yes | If a parameterized type `List` or `Collection` is used, a configuration collection is looked up.
Self | `self` | `@Self`             | `injectionStrategy`                     |  Injects the adaptable itself. If the field type does not match with the adaptable it is tried to adapt the adaptable to the requested type. | any object | none | none
Sling Object | `sling-object` | `@SlingObject`      | `injectionStrategy`                     | Injects commonly used sling objects if the field matches with the class: request, response, resource resolver, current resource, SlingScriptHelper | `Resource`, `ResourceResolver`, `SlingJakartaHttpServletRequest` or `SlingHttpServletRequest` objects (not all objects can be resolved by all adaptables).  | none | none

# Parameters to the Injectors

Injectors can support optional parameters as listed in the above table

## Optional and Required

Injected fields/methods are assumed to be required. To mark them as optional, there are 2 options:

* add the parameter `injectionStrategy=InjectionStrategy.OPTIONAL` to the annotation
* or wrap the type into an `Optional`

It is recommended to use the approach using the `Optional` type, because then this "optionality" is also expressed in the type system.

    ::java
    import java.util.Optional;

    @Model(adaptables=Resource.class)
    public class MyModel {

	    @ValueMapValue(injectionStrategy=InjectionStrategy.OPTIONAL)
	    private String optionalProperty;

        @ValueMapValue
        private Optional<String> anotherOptionalProperty;
    }
Please note, that even injections marked as optional are always tried. It is just that any failure to inject a value does not lead to the termination of the creation of the SlingModel, but instead it continues, leaving the field value/return value at the default value (as provided by the `@Default` annotation) or at the default value of the used type.

If a majority of injected fields/methods are optional, it is possible (since Sling Models API 1.0.2/Impl 1.0.6) to change the default injection strategy by using adding `defaultInjectionStrategy = DefaultInjectionStrategy.OPTIONAL` to the `@Model` annotation:

	::java
	@Model(adaptables=Resource.class, defaultInjectionStrategy=DefaultInjectionStrategy.OPTIONAL)
	public class MyModel {

        @ValueMapValue
        private String optionalProperty;
	}

To still mark some fields/methods as being mandatory while relying on `defaultInjectionStrategy = DefaultInjectionStrategy.OPTIONAL` for all other fields, the parameter `injectionStrategy=InjectionStrategy.REQUIRED` can be used.

`defaultInjectionStrategy = DefaultInjectionStrategy.OPTIONAL` parameters are only evaluated when using the `defaultInjectionStrategy = DefaultInjectionStrategy.REQUIRED` (which is the default), `injectionStrategy=InjectionStrategy.REQUIRED` parameters only if using `defaultInjectionStrategy = DefaultInjectionStrategy.OPTIONAL`.




## Names
If the field or method name doesn't exactly match the property name, the parameter `name` can be used:

	::java
	@Model(adaptables=Resource.class)
	public class MyModel {
	 
	    @ValueMapValue(name="secondPropertyName")
	    private String otherName;
	} 

In this case the value of the property named `secondPropertyName` would be taken from the ValueMap.


## Path
The `@ResourcePath` injector supports the parameter `path` to inject a resource with the given parameter:   

    ::java
    @Model(adaptables=Resource.class) {

        @ResourcePath(path="/libs")
        Resource libs;
    }

## OSGi Service Filters
OSGi injection can be filtered:

	::java
	@Model(adaptables=SlingJakartaHttpServletRequest.class)
	public class MyModel {
	 
	    @OSGiService
	    private PrintWriter out;
	 
	    @OSGiInjector(name="log")
	    private Logger logger;
	 
	    @OsgiInjector(filter="paths=/bin/something")
	    private List<Servlet> servlets;
	}

## Collection support
Lists and arrays are supported by some injectors. For the details look at the table given in [Available Injectors](#available-injectors-1):

	::java
	@Model(adaptables=Resource.class)
	public class MyModel {
	 
	    @OsgiService
	    private List<Servlet> servlets;
	}

List injection for *child resources* works by injecting grand child resources (since Sling Models Impl 1.0.6). For example, the class

	::java
	@Model(adaptables=Resource.class)
	public class MyModel {

	    @ChildResource
	    private List<Resource> addresses;
	}

Is suitable for a resource structure such as:

	+- resource (being adapted)
	 |
	 +- addresses
	    |
	    +- address1
	    |
	    +- address2

In this case, the `addresses` `List` will contain `address1` and `address2`.
 
# Defaults
A default value can provided (for String and primitives)

    ::java
    @Model(adaptables=Resource.class)
    public class MyModel {

        @ValueMapValue
        @Default(values="defaultValue")
        private String name;
    }

Defaults can also be arrays:

    ::java
    @Model(adaptables=Resource.class)
    public class MyModel {

        @ValueMapValue
        @Default(intValues={1,2,3,4})
        private int[] integers;
    }

# Via  

In some cases, a different object should be used as the adaptable instead of the original adaptable. This can be done
using the `via` parameter.

While this feature does also work with the injector-specfic annotations above, it's use is discouraged because it's barely used and just increases the complexity of the models.

 By default, this can be done using a JavaBean property of the adaptable:

	::java
	@Model(adaptables=SlingJakartaHttpServletRequest.class)
	public interface MyModel {
	 
	    // will return request.getResource().getValueMap().get("propertyName", String.class)
	    @Inject(via="resource")
	    String getPropertyName();
	} 


A different strategy can be used to define the adaptable by specifying a `type` attribute:

    ::java
    @Model(adaptables=Resource.class)
    public interface MyModel {

		// will return resource.getChild("jcr:content").getValueMap().get("propertyName", String.class)
        @Inject @Via(value = "jcr:content", type = ChildResource.class)
        String getPropertyName();

    }

## Via Types
 
The following standard types are provided (all types are in the package `org.apache.sling.models.annotations.via`, available since API 1.3.4, Implementation 1.4.0)

`@Via` type value             | Description
----------------------------- | ------------------------------ 
`BeanProperty`  (default)     | Uses a JavaBean property from the adaptable.
`ChildResource`               | Uses a child resource from the adaptable, assuming the adaptable is a `Resource`. In case the adaptable is a `SlingJakartaHttpServletRequest` or `SlingHttpServletRequest` uses a wrapper overwriting the `getResource()` to point to the given child resource ([SLING-7321](https://issues.apache.org/jira/browse/SLING-7321)).
`ForcedResourceType`          | Creates a wrapped resource with the provided resource type. If the adaptable is a `SlingJakartaHttpServletRequest` or `SlingHttpServletRequest`, a wrapped request is created as well to contain the wrapped resource.
`ResourceSuperType`           | Creates a wrapped resource with the resource type set to the adaptable's resource super type. If the adaptable is a `SlingJakartaHttpServletRequest` or `SlingHttpServletRequest`, a wrapped request is created as well to contain the wrapped resource.


Defining your own type for the `@Via` annotation is a two step process. The first step is to create a marker class implementing the `@ViaProviderType` annotation. This class can be entirely empty, e.g.

    ::java
    public class MyCustomProviderType implements ViaProviderType {}

The second step is to create an OSGi service implementing the `ViaProvider` interface. This interface defines two methods:

* `getType()` should return the marker class. 
* `getAdaptable()` should return the new adaptable or `ViaProvider.ORIGINAL` to indicate that the original adaptable should be used.



# PostConstruct Methods 
The `@PostConstruct` annotation can be used to add methods which are invoked upon completion of all injections:

	::java
	@Model(adaptables=SlingJakartaHttpServletRequest.class)
	public class MyModel {
	 
	    @SlingObject
	    private PrintWriter out;
	 
	    @OsgiInjector(name="log")
	    private Logger logger;
	 
	    @PostConstruct
	    protected void sayHello() {
	         logger.info("hello");
	    }
	}

`@PostConstruct` methods in a super class will be invoked first. If a `@PostConstruct` method exists in a subclass with the same name as in the parent class, only the subclass method will be invoked. This is the case regardless of the scope of either method.

Since Sling Models Implementation 1.4.6, `@PostConstruct` methods may return a `false` boolean value in which case the model creation will fail without logging any exception
(a message will be logged at the `DEBUG` level).


#  Adaptations and nesting Sling Models
If the injected object does not match the desired type and the object implements the `Adaptable` interface, Sling Models will try to adapt it. This provides the ability to create rich object graphs. For example:

	::java
	@Model(adaptables=Resource.class)
	public interface MyModel {
	 
	    @ChildResource
	    ImageModel getImage();
	}

    ::java
	@Model(adaptables=Resource.class)
	public interface ImageModel {
	 
	    @ValueMapvalue
	    String getPath();
	}

When a resource is adapted to `MyModel`, a child resource named `image` is automatically adapted to an instance of `ImageModel`.

Constructor injection is supported for the adaptable itself. For example:

    ::java
	@Model(adaptables=Resource.class)
    public class MyModel {

        public MyModel(Resource resource) {
            this.resource = resource;
        }

        private final Resource resource;

        @ValueMapValue
        private String propertyName;
    }

Note: storing the original adaptable (request/resource) in a field is discouraged. Please see the note about <a href="#caching-self-reference-note">caching and self references</a> below.

# Sling Validation
<a name="validation" />
*See also [SLING-4161](https://issues.apache.org/jira/browse/SLING-4161)*


Since API version 1.2.0 you can use the attribute `validation` on the Model annotation to call a validation service on the resource being used by the Sling model. That attribute supports three different values:

  Value |  Description |  Invalid validation model |  No validation model found |  Resource invalid according to validation model
  ----- | ------- | ------------- | -------------| ---------
 `DISABLED` (default) | don't validate the resource bound to the Model | Model instantiated | Model instantiated  | Model instantiated  
 `REQUIRED` | enforce validation of the resource bound to the Model | Model not instantiated | Model not instantiated | Model not instantiated
 `OPTIONAL` | validate the resource bound to the Model (if a validation model is found) | Model not instantiated | Model instantiated | Model not instantiated

In case the model is not instantiated an appropriate error message is logged (if `adaptTo()` is used) or an appropriate exception is thrown if `ModelFactory.createModel()` is used.

The only implementation for this Sling Models validation service is leveraging [Sling Validation](/documentation/bundles/validation.html) and is located in the bundle [org.apache.sling.models.validation-impl](https://github.com/apache/sling-org-apache-sling-models-validation-impl). Validation is only working on models which are adapted from either `Resource`, `SlingJakartaHttpServletRequest` or `SlingHttpServletRequest` and if the Sling Validation Bundle is deployed.

# Performance

## Caching adaptions

By default, Sling Models do not do any caching of the adaptation result and every request for a model class will result in a new instance of the model class. However, there are two notable cases when the adaptation result can be cached. The first case is when the adaptable extends the `SlingAdaptable` base class. Most significantly, this is the case for many `Resource` adaptables as `AbstractResource` extends `SlingAdaptable`.  `SlingAdaptable` implements a caching mechanism such that multiple invocations of `adaptTo()` will return the same object. For example:

    ::java
    // assume that resource is an instance of some subclass of AbstractResource
    ModelClass object1 = resource.adaptTo(ModelClass.class); // creates new instance of ModelClass
    ModelClass object2 = resource.adaptTo(ModelClass.class); // SlingAdaptable returns the cached instance
    assert object1 == object2;

While this is true for `AbstractResource` subclasses, it is notably **not** the case for `SlingJakartaHttpServletRequest` or `SlingHttpServletRequest` as this class does not extend `SlingAdaptable`. So:

    ::java
    // assume that request is some SlingJakartaHttpServletRequest or SlingHttpServletRequest object
    ModelClass object1 = request.adaptTo(ModelClass.class); // creates new instance of ModelClass
    ModelClass object2 = request.adaptTo(ModelClass.class); // creates another new instance of ModelClass
    assert object1 != object2;

Since API version 1.3.4, Sling Models *can* cache an adaptation result, regardless of the adaptable by specifying `cache = true` on the `@Model` annotation.


    ::java
    @Model(adaptable = SlingJakartaHttpServletRequest.class, cache = true)
    public class ModelClass {}

    ...

    // assume that request is some SlingJakartaHttpServletRequest or SlingHttpServletRequest object
    ModelClass object1 = request.adaptTo(ModelClass.class); // creates new instance of ModelClass
    ModelClass object2 = request.adaptTo(ModelClass.class); // Sling Models returns the cached instance
    assert object1 == object2;

When `cache = true` is specified, the adaptation result is cached regardless of how the adaptation is done:

    ::java
    @Model(adaptable = SlingJakartaHttpServletRequest.class, cache = true)
    public class ModelClass {}

    ...

    // assume that request is some SlingJakartaHttpServletRequest or SlingHttpServletRequest object
    ModelClass object1 = request.adaptTo(ModelClass.class); // creates new instance of ModelClass
    ModelClass object2 = modelFactory.createModel(request, ModelClass.class); // Sling Models returns the cached instance
    assert object1 == object2;

<a name="caching-self-reference-note"></a>
## A note about cache = true and using the self injector

In general, it is **strongly** discouraged to store a reference to the original adaptable using the `self` injector. Using implementation version 1.4.8 or below, storing the original adaptable in a Sling Model, can cause heap space exhaustion, crashing the JVM. Starting in version 1.4.10, storing the original adaptable will not crash the JVM, but it can cause unexpected behavior (e.g. a model being created twice, when it should be cached). The issue was first reported in [SLING-7586](https://issues.apache.org/jira/browse/SLING-7586).

The problem can be avoided by discarding the original adaptable when it is no longer needed. This can be done by setting affected field(s) to `null` at the end of the `@PostConstruct` annotated method:

    ::java
    @Model(adaptable = SlingJakartaHttpServletRequest.class, cache = true)
    public class CachableModelClass {
        @Self
        private SlingJakartaHttpServletRequest request;
        
        @PostConstruct
        private void init() {
          ... do something with request ...
          
          this.request = null;
        }
    }

Alternatively, the same effect can be achieved using constructor injection, by not storing the reference to the adaptable:

    ::java
    @Model(adaptable = SlingJakartaHttpServletRequest.class, cache = true)
    public class CachableModelClass {
        public CachableModelClass(SlingJakartaHttpServletRequest request) {
          ... do something with request ...
        }
    }

## Other performance aspects 

Given the ease of creating Sling Models and their features, performance can get a problem; the following aspects should be considered:

* When a Sling Model is created, all injections are at least tried, and depending on the injector the performance impact might vary. So model classes with many injections are always slower than smaller models with less injections. In such situations it can make sense to have specialized Sling Models which just cover a single aspect needed in a special situation.
* The support of adaptions can lead to situations, that the instantiation of a single Sling Model can lead to the creation of a whole graph of Sling Models ([see above](#adaptations-and-nesting-sling-models-1)); this is not always required and can lead to severe performance problems. Also in this situations the use of more specialized Sling Models can help which do not always trigger the instantation of this graph.


 
# Context-Aware Configuration

Since [SLING-7256](https://issues.apache.org/jira/browse/SLING-7256) it is possible to inject 
[Context-Aware Configuration](https://sling.apache.org/documentation/bundles/context-aware-configuration/context-aware-configuration.html) directly in Sling Models.

To use it, the following additional bundles are required (with given minimal version):

* Apache Sling Context-Aware Configuration Implementation 1.6.0 (`org.apache.sling.caconfig.impl`)
* Apache Sling Context-Aware Configuration SPI 1.4.0 (`org.apache.sling.caconfig.spi`)
* Apache Sling Context-Aware Configuration API 1.1.2 (`org.apache.sling.caconfig.api`)
* Apache Sling Models Context-Aware Configuration 1.0.0 (`org.apache.sling.models.caconfig`) - this bundle contains both the `@ContextAwareConfiguration` injector annotation and the injector implementation.

Usage example for injecting a single Context-Aware configuration looked up in context of the current resource (`SingleConfig` is an annotation class describing the context-aware configuration):

    ::java
    @Model(adaptables = { SlingJakartaHttpServletRequest.class, Resource.class })
    public class SingleConfigModel {

        @ContextAwareConfiguration
        private SingleConfig config;

    }

Example for injecting a configuration list (`ListConfig` is an annotation class configured as context-aware configuration list):

    ::java
    @Model(adaptables = { SlingJakartaHttpServletRequest.class, Resource.class })
    public class ListConfigModel {

        @ContextAwareConfiguration
        private List<ListConfig> configList;
    }

For more examples, see [example models from unit tests](https://github.com/apache/sling-org-apache-sling-models-caconfig/tree/master/src/test/java/org/apache/sling/models/caconfig/example/model).

# Custom Injectors

To create a custom injector, simply implement the `org.apache.sling.models.spi.Injector` interface and register your implementation with the OSGi service registry. Please refer to the [standard injectors in Git](https://github.com/apache/sling-org-apache-sling-models-impl/tree/master/src/main/java/org/apache/sling/models/impl/injectors) for examples.


# Custom Annotations

To create a custom annotation, implement the `org.apache.sling.models.spi.injectorspecific.StaticInjectAnnotationProcessorFactory` interface.
This interface may be implemented by the same class as implements an injector, but this is not strictly necessary. Please refer to the
[injectors in Git](https://github.com/apache/sling-org-apache-sling-models-impl/tree/master/src/main/java/org/apache/sling/models/impl/injectors) for examples.
 




# Specifying an alternate Adapter Class

By default, each model class is registered using its own implementation class as adapter. If the class has additional interfaces this is not relevant.

Since Sling Models API version 1.1.0 the `@Model` annotation provides an optional `adapters` attribute which allows specifying under which type(s) the model
implementation should be registered in the Models Adapter Factory. Prior to *Sling Models Impl 1.3.10* only the given class names
are used as adapter classes, since 1.3.10 the implementation class is always being registered implicitly as adapter as well (see [SLING-6658](https://issues.apache.org/jira/browse/SLING-6658)). 
With this attribute it is possible to register the model
to one (or multiple) interfaces, or a superclass. This allows separating the model interface from the implementation, which
makes it easier to provide mock implementations for unit tests as well.

Example:

    ::java
    @Model(adaptables = Resource.class, adapters = MyService.class)
    public class MyModel implements MyService {
        // injects fields and implements the MyService methods
    }

In this example a `Resource` can be adapted to a `MyService` interface, and the Sling Models implementation instantiates a
`MyModel` class for this.

It is possible to have multiple models implementing the same interface. By default Sling Models will just take the first one
ordered alphabetically by the class name. Applications can provide an OSGi service implementing the `ImplementationPicker`
SPI interface which could use context to determine which implementation can be chosen, e.g. depending an a tenant or
content path context. If multiple implementations of the `ImplementationPicker` interface are present, they are queried
one after another in order of their service ranking property, the first one that picks an implementation wins.

# Associating a Model Class with a Resource Type

Since API version 1.3.0 The `@Model` annotation provides an optional `resourceType` attribute which allows for model classes to be associated with one or
more resource types. This is used in three different ways.

In the case of multiple model classes implementing the same interface, the class with the "closest" resource type will be used when
adapting to the interface.

The `ModelFactory` service interface has methods `Object getModelFromResource(Resource)`, `Object getModelFromRequest(SlingJakartaHttpServletRequest)` and `Object getModelFromRequest(SlingHttpServletRequest)` which will dynamically determine the adapter class based on the `Resource` using its type. In the case of the `SlingJakartaHttpServletRequest` or `SlingHttpServletRequest` methods, it uses the request's `Resource` object (i.e. by calling `request.getResource()`)

The resource type is also used as part of the Exporter framework (see next section).

# Exporter Framework

Since API version 1.3.0 Sling Models objects can be exported to arbitrary Java objects through the Sling Models Exporter framework. Model objects can be
programatically exported by calling the `ModelFactory` method `exportModel()`. This method takes as its arguments:

* the model object
* an exporter name
* a target class
* a map of options

The exact semantics of the exporting will be determined by an implementation of the `ModelExporter` service interface. 

Sling Models currently includes a single exporter, using the Jackson framework, which is capable of serializing models as JSON or transforming them to `java.util.Map` objects. It is included in a dedicated bundle with the symbolic name [`org.apache.sling.models.jacksonexporter`](https://github.com/apache/sling-org-apache-sling-models-jacksonexporter). It supports the option key `tidy` (which will auto indent the returned JSON for better readability)

In addition, model objects can have servlets automatically registered for their resource type (if it is set) using the `@Exporter` annotation. For example, a model class with the annotation

    ::java
    @Model(adaptable = Resource.class, resourceType = "myco/components/foo")
    @Exporter(name = "jackson", extensions = "json")

results in the registration of a servlet with the resource type and extension specified and a selector of 'model' (overridable 
through the `@Exporter` annotation's `selector` attribute). When this servlet is invoked, the `Resource` will be adapted to the 
model, exported as a `java.lang.String` (via the named Exporter) and then returned to the client. The `ExportServlet` only supports models for adaptable `org.apache.sling.api.resource.Resource`, `org.apache.sling.api.SlingJakartaHttpServletRequest` or `org.apache.sling.api.SlingHttpServletRequest`. If a model is adaptable from both the `Resource` is used.

The ExportServlet allows to pass options to the exporter either via additional selectors (which just get the String value `"true"` in the used options map) or via regular request parameters (which are added to the options map with the given value or just with the String value `"true"` in case the request parameter didn't carry a value). 

# Registration of Sling Models classes via bnd plugin

With the Sling Models bnd plugin it is possible to automatically generated the necessary bundle header to register the Sling Models classes contained in the Maven bundle project - either with maven-bundle-plugin or with bnd-maven-plugin. By default the plugin generates a `Sling-Model-Classes` header (only compatible with Sling Models Impl since version 1.3.4, see [SLING-6308](https://issues.apache.org/jira/browse/SLING-6308)).

Example configuration:

    #!xml
    <plugin>
        <groupId>org.apache.felix</groupId>
        <artifactId>maven-bundle-plugin</artifactId>
        <extensions>true</extensions>
        <configuration>
            <instructions>
                <_plugin>org.apache.sling.bnd.models.ModelsScannerPlugin</_plugin>
            </instructions>
        </configuration>
        <dependencies>
            <dependency>
                <groupId>org.apache.sling</groupId>
                <artifactId>org.apache.sling.bnd.models</artifactId>
                <version>1.0.0</version>
            </dependency>
        </dependencies>
    </plugin>

If a `Sling-Model-Packages` or `Sling-Model-Classes` was already manually defined for the bundle the bnd plugin does nothing. So if you want to migrate an existing project to use this plugin remove the existing header definitions.

If you want to generate a bundle header compliant with Sling Models < 1.3.4 (i.e. `Sling-Model-Packages`) you need to specify the attribute `generatePackagesHeader=true`. An example configuration looks like this

    #!xml
    <configuration>
        <instructions>
            <_plugin>org.apache.sling.bnd.models.ModelsScannerPlugin;generatePackagesHeader=true</_plugin>
        </instructions>
    </configuration>





# Discouraged annotations

In earlier versions of Sling Models the use of the annotation `@Inject` was suggested and documented; but over time it turned out that it had 2 major issues:

* This injection iterated through all available injectors and injected the first non-null value provided by an injector. This lead to unpredictable behavior, although the order is well-defined. Also @Source would have helped but it was rarely used.
* Also this turned out to be a performance bottleneck, especially if (optional) injections were not succesful, and then all other injectors have to be tried.

For these reasons the injector-specific annotations have been created, and this documentation strongly recommends to use them. For the sake of completeness these discouraged annotations are still covered here briefly, but they should no longer be used.


`@Inject`
:   marks a field or method as injectable

`@Named`
:   declare a name for the injection (otherwise, defaults based on field or method name).

`@Optional`
:   marks a field or method injection as optional

`@Filter`
:   an OSGi service filter

`@Path`
:   only used together with the resource-path injector to specify the path of a resource

# Migration to version 2.x

After migrating to the 2.x version, some annotations may be flagged as using deprecated apis.  Below are some hints about how to resolve the warnings.

  Deprecated Annotations From Models API 1.x |  Change To Annotations From Models API 2.x
  -------------- | --------------- 
 @Model(adaptables=SlingHttpServletRequest.class) | @Model(adaptables=SlingJakartaHttpServletRequest.class) 
 @SlingObject<br>protected SlingHttpServletRequest requestFromSlingObject; | @SlingObject<br>protected SlingJakartaHttpServletRequest requestFromSlingObject;
 @ScriptVariable(name = "request")<br>protected SlingHttpServletRequest requestFromNamedScriptVariable; | @ScriptVariable(name = "jakartaRequest")<br>protected SlingJakartaHttpServletRequest requestFromNamedScriptVariable;
 @ScriptVariable<br>protected SlingHttpServletRequest request; | @ScriptVariable<br>protected SlingJakartaHttpServletRequest jakartaRequest;
 @Self<br>protected SlingHttpServletRequest requestFromSelf; | @Self<br>protected SlingJakartaHttpServletRequest requestFromSelf;

