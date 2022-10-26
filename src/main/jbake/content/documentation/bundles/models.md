title=Sling Models		
type=page
status=published
tags=models
~~~~~~

[TOC]

Many Sling projects want to be able to create model objects - POJOs which are automatically mapped from Sling objects, typically resources, but also request objects. Sometimes these POJOs need OSGi services as well.

# Design Goals

* Entirely annotation driven. "Pure" POJOs.
* Use standard annotations where possible.
* Pluggable
* OOTB, support resource properties (via ValueMap), SlingBindings, OSGi services, request attributes
* Adapt multiple objects - minimal required Resource and SlingHttpServletRequest
* Client doesn't know/care that these objects are different than any other adapter factory
* Support both classes and interfaces.
* Work with existing Sling infrastructure (i.e. not require changes to other bundles).

# Basic Usage
## Model Classes

In the simplest case, the class is annotated with `@Model` and the adaptable class. Fields which need to be injected are annotated with `@Inject`:

    ::java
    @Model(adaptables=Resource.class)
    public class MyModel {
    
        @Inject
        private String propertyName;
    }

In this case, a property named "propertyName" will be looked up from the Resource (after first adapting it to a `ValueMap`) and it is injected. Fields can use any visibility modifier:

    ::java
    @Model(adaptables=Resource.class)
    public class PublicFieldModel {
    
        @Inject
        public String publicField;
    }

    @Model(adaptables=Resource.class)
    public class ProtectedFieldModel {
    
        @Inject
        protected String protectedField;
    }

    @Model(adaptables=Resource.class)
    public class PrivateFieldModel {
    
        @Inject
        private String privateField;
    }

    @Model(adaptables=Resource.class)
    public class PackagePrivateFieldModel {
    
        @Inject
        String packagePrivateField;
    }

 
For an interface, it is similar:

	::java
	@Model(adaptables=Resource.class)
	public interface MyModel {
	 
	    @Inject
	    String getPropertyName();
	}

Interface methods must be `public`. Even though private interface methods have been available since Java 9, Sling Models uses Dynamic Proxies to instantiate the interfaces, which does not work with private interface methods. Additionally, while default interface methods will work with interface injection, the default implementation (in the interface) is currently not used, and will not be executed.

Constructor injection is also supported (as of Sling Models 1.1.0):

    ::java
    @Model(adaptables=Resource.class)
    public class MyModel {    
        @Inject
        public MyModel(@Named("propertyName") String propertyName) {
          // constructor code
        }
    }

Because the name of a constructor argument parameter cannot be detected via the Java Reflection API a `@Named` annotation is mandatory for injectors that require a name for resolving the injection.

Constructors may use any visibility modifier (as of [Sling Models 1.5.0](https://issues.apache.org/jira/browse/SLING-8069)):

    ::java
    @Model(adaptables=Resource.class)
    public class PublicConstructorModel {    
        @Inject
        public PublicConstructorModel() {
          // constructor code
        }
    }

    @Model(adaptables=Resource.class)
    public class ProtectedConstructorModel {    
        @Inject
        protected ProtectedConstructorModel() {
          // constructor code
        }
    }

    @Model(adaptables=Resource.class)
    public class PrivateConstructorModel {    
        @Inject
        private PrivateConstructorModel() {
          // constructor code
        }
    }

    @Model(adaptables=Resource.class)
    public class PackagePrivateConstructorModel {    
        @Inject
        PackagePrivateConstructorModel() {
          // constructor code
        }
    }

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

If you use the Sling Models bnd plugin all required bundle headers are generated automatically at build time (see chapter 'Registration of Sling Models classes via bnd plugin' below).

# Client Code
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
## ModelFactory (since 1.2.0)
*See also  [SLING-3709](https://issues.apache.org/jira/browse/SLING-3709)*

Since Sling Models 1.2.0 there is another way of instantiating models. The OSGi service `ModelFactory` provides a method for instantiating a model that throws exceptions. This is not allowed by the Javadoc contract of the adaptTo method. That way `null` checks are not necessary and it is easier to see why instantiation of the model failed.

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
[Sling Models Use Provider](/documentation/bundles/scripting/scripting-htl.html#java-use-provider-1) (internally uses the `ModelFactory` from above).

# Other Options
## Names
If the field or method name doesn't exactly match the property name, `@Named` can be used:

	::java
	@Model(adaptables=Resource.class)
	public class MyModel {
	 
	    @Inject @Named("secondPropertyName")
	    private String otherName;
	} 
 
## Optional and Required
`@Inject`ed fields/methods are assumed to be required. To mark them as optional, use `@Optional`:

	::java
	@Model(adaptables=Resource.class)
	public class MyModel {
	 
	    @Inject @Optional
	    private String otherName;
	}

If a majority of `@Inject`ed fields/methods are optional, it is possible (since Sling Models API 1.0.2/Impl 1.0.6) to change the default injection
strategy by using adding `defaultInjectionStrategy = DefaultInjectionStrategy.OPTIONAL` to the `@Model` annotation:

	::java
	@Model(adaptables=Resource.class, defaultInjectionStrategy=DefaultInjectionStrategy.OPTIONAL)
	public class MyModel {

	    @Inject
	    private String otherName;
	}

To still mark some fields/methods as being mandatory while relying on `defaultInjectionStrategy = DefaultInjectionStrategy.OPTIONAL` for all other fields, the annotation `@Required` can be used.

`@Optional` annotations are only evaluated when using the `defaultInjectionStrategy = DefaultInjectionStrategy.REQUIRED` (which is the default), `@Required` annotations only if using `defaultInjectionStrategy = DefaultInjectionStrategy.OPTIONAL`.

## Defaults
A default value can be provided (for Strings & primitives):

	::java
	@Model(adaptables=Resource.class)
	public class MyModel {
	 
	    @Inject @Default(values="defaultValue")
	    private String name;
	}

Defaults can also be arrays:

	::java
	@Model(adaptables=Resource.class)
	public class MyModel {
	 
	    @Inject @Default(intValues={1,2,3,4})
	    private int[] integers;
	}


OSGi services can be injected:

	::java
	@Model(adaptables=Resource.class)
	public class MyModel {
	 
	    @Inject
	    private ResourceResolverFactory resourceResolverFactory;
	} 

 
In this case, the name is not used -- only the class name.

## Collections
Lists and arrays are supported by some injectors. For the details look at the table given in [Available Injectors](#available-injectors):

	::java
	@Model(adaptables=Resource.class)
	public class MyModel {
	 
	    @Inject
	    private List<Servlet> servlets;
	}

List injection for *child resources* works by injecting grand child resources (since Sling Models Impl 1.0.6). For example, the class

	::java
	@Model(adaptables=Resource.class)
	public class MyModel {

	    @Inject
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
 
## OSGi Service Filters
OSGi injection can be filtered:

	::java
	@Model(adaptables=SlingHttpServletRequest.class)
	public class MyModel {
	 
	    @Inject
	    private PrintWriter out;
	 
	    @Inject
	    @Named("log")
	    private Logger logger;
	 
	    @Inject
	    @Filter("(paths=/bin/something)")
	    private List<Servlet> servlets;
	}

## PostConstruct Methods 
The `@PostConstruct` annotation can be used to add methods which are invoked upon completion of all injections:

	::java
	@Model(adaptables=SlingHttpServletRequest.class)
	public class MyModel {
	 
	    @Inject
	    private PrintWriter out;
	 
	    @Inject
	    @Named("log")
	    private Logger logger;
	 
	    @PostConstruct
	    protected void sayHello() {
	         logger.info("hello");
	    }
	}

`@PostConstruct` methods in a super class will be invoked first. If a `@PostConstruct` method exists in a subclass with the same name as in the parent class, only the subclass method will be invoked. This is the case regardless of the scope of either method.

Since Sling Models Implementation 1.4.6, `@PostConstruct` methods may return a `false` boolean value in which case the model creation will fail without logging any exception
(a message will be logged at the `DEBUG` level).

## Via 
In some cases, a different object should be used as the adaptable instead of the original adaptable. This can be done
using the `@Via` annotation. By default, this can be done using a JavaBean property of the adaptable:

	::java
	@Model(adaptables=SlingHttpServletRequest.class)
	public interface MyModel {
	 
	    // will return request.getResource().getValueMap().get("propertyName", String.class)
	    @Inject @Via("resource")
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

See the [Via Types](#via-types-since-api-134implementation-140) section below for details on the included types for `@Via`.

## Source
If there is ambiguity where a given injection could be handled by more than one injector, the `@Source` annotation can be used to define which injector is responsible:

	::java
	@Model(adaptables=SlingHttpServletRequest.class)
	public interface MyModel {
	 
	    // Ensure that "resource" is retrived from the bindings, not a request attribute 
	    @Inject @Source("script-bindings")
	    Resource getResource();
	} 

## Adaptations
If the injected object does not match the desired type and the object implements the `Adaptable` interface, Sling Models will try to adapt it. This provides the ability to create rich object graphs. For example:

	::java
	@Model(adaptables=Resource.class)
	public interface MyModel {
	 
	    @Inject
	    ImageModel getImage();
	}
	
	@Model(adaptables=Resource.class)
	public interface ImageModel {
	 
	    @Inject
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

        @Inject
        private String propertyName;
    }

Note: storing the original adaptable (request/resource) in a field is discouraged. Please see the note about <a href="#caching-self-reference-note">caching and self references</a> below.

## Sling Validation (since 1.2.0)
<a name="validation" />
*See also [SLING-4161](https://issues.apache.org/jira/browse/SLING-4161)*


You can use the attribute `validation` on the Model annotation to call a validation service on the resource being used by the Sling model. That attribute supports three different values:

  Value |  Description |  Invalid validation model |  No validation model found |  Resource invalid according to model
  ----- | ------- | ------------- | -------------| ---------
 `DISABLED` (default) | don't validate the resource bound to the Model | Model instantiated | Model instantiated  | Model instantiated  
 `REQUIRED` | enforce validation of the resource bound to the Model | Model not instantiated | Model not instantiated | Model not instantiated
 `OPTIONAL` | validate the resource bound to the Model (if a validation model is found) | Model not instantiated | Model instantiated | Model not instantiated

In case the model is not instantiated an appropriate error message is logged (if `adaptTo()` is used) or an appropriate exception is thrown (if `ModelFactory.createModel()` is used).

The only implementation for this Sling Models validation service is leveraging [Sling Validation](/documentation/bundles/validation.html) and is located in the bundle [org.apache.sling.models.validation-impl](https://github.com/apache/sling-org-apache-sling-models-validation-impl). Validation is only working on models which are adapted from either `Resource` or `SlingHttpServletRequest` and if the Sling Validation Bundle is deployed.

# Custom Injectors

To create a custom injector, simply implement the `org.apache.sling.models.spi.Injector` interface and register your implementation with the OSGi service registry. Please refer to the [standard injectors in Git](https://github.com/apache/sling-org-apache-sling-models-impl/tree/master/src/main/java/org/apache/sling/models/impl/injectors) for examples.

Injectors are invoked in order of their service ranking, from lowest to highest. See the table below for the rankings of the standard injectors.

# Annotation Reference
`@Model`
:   declares a model class or interface

`@Inject`
:   marks a field or method as injectable

`@Named`
:   declare a name for the injection (otherwise, defaults based on field or method name).

`@Optional`
:   marks a field or method injection as optional

`@Source`
:   explictly tie an injected field or method to a particular injector (by name). Can also be on other annotations.

`@Filter`
:   an OSGi service filter

`@PostConstruct`
:   methods to call upon model option creation (only for model classes)

`@Via`
:   change the adaptable as the source of the injection

`@Default`
:   set default values for a field or method

`@Path`
:   only used together with the resource-path injector to specify the path of a resource

`@Exporters`/`@Exporter`/`@ExporterOptions`/`@ExporterOption`
:   See Exporter Framework section below

In addition all [injector-specific annotations](#injector-specific-annotations).

# Available Injectors

Title              |  Name (for `@Source`)   | Service Ranking     | Available Since (Implementation Version) | Description  | Applicable To (including using `@Via`) | Accepts Null Name? | Array Support | Parameterized Type Support
-----------------  | ----------------------- | ------------------- | ---------------------------------------- | ------------ | -------------------------------------- | ------------------ | ------------- | --------------------------
Script Bindings    | `script-bindings`       | 1000                | 1.0.0                                    | Lookup objects in the script bindings object by name. | A ServletRequest object which has the `Sling Bindings` attribute defined | no | no conversion is done | If a parameterized type is passed, the bindings value must be of a compatible type of the parameterized type.
Value Map          | `valuemap`              | 2000                | 1.0.0                                    | Gets a property from a `ValueMap` by name. | Any object which is or can be adapted to a `ValueMap`| no | Primitive arrays wrapped/unwrapped as necessary. Wrapper object arrays are unwrapped/wrapped as necessary. | Parameterized `List` and `Collection` injection points are injected by getting an array of the component type and creating an unmodifiable `List` from the array.
Child Resources    | `child-resources`       | 3000                | 1.0.0                                    | Gets a child resource by name. | `Resource` objects | no | none | if a parameterized type `List` or `Collection` is passed, a `List<Resource>` is returned (the contents of which may be adapted to the target type) filled with all child resources of the resource looked up by the given name.
Request Attributes | `request-attributes`    | 4000                | 1.0.0                                    | Get a request attribute by name. | `ServletRequest` objects | no | no conversion is done | If a parameterized type is passed, the request attribute must be of a compatible type of the parameterized type.
OSGi Services      | `osgi-services`         | 5000                | 1.0.0                                    | Lookup services based on class name. Since Sling Models Impl 1.2.8 ([SLING-5664](https://issues.apache.org/jira/browse/SLING-5664)) the service with the highest service ranking is returned. In case multiple services are returned, they are ordered descending by their service ranking (i.e. the one with the highest ranking first). | Any object | yes | yes | Parameterized `List` and `Collection` injection points are injected by getting an array of the services and creating an unmodifiable `List` from the array.
Context-Aware Configuration | `caconfig`     | 6000                |                                          | Lookup context-aware configuration. See [Context-Aware Configuration](#context-aware-configuration). | Any object | yes | yes | If a parameterized type `List` or `Collection` is used, a configuration collection is looked up.
Resource Path      | `resource-path`         | 2500                | 1.1.0                                    | Injects one or multiple resources. The resource paths are either given by `@Path` annotations, the element `path` or `paths` of the annotation `@ResourcePath` or by paths given through a resource property being referenced by either `@Named` or element `name` of the annotation `@ResourcePath`. | `Resource` or `SlingHttpServletRequest` objects | yes | yes | none
Self               | `self`                  | `Integer.MAX_VALUE` | 1.1.0                                    | Injects the adaptable object itself (if the class of the field matches or is a supertype). If the @Self annotation is present it is tried to adapt the adaptable to the field type.  | Any object | yes | none | none
Sling Object       | `sling-object`          | `Integer.MAX_VALUE` | 1.1.0                                    | Injects commonly used sling objects if the field matches with the class: request, response, resource resolver, current resource, SlingScriptHelper. This works only if the adaptable can get the according information, i.e. all objects are available via `SlingHttpServletRequest` while `ResourceResolver` can only resolve the `ResourceResolver` object and nothing else. A discussion around this limitation can be found at [SLING-4083](https://issues.apache.org/jira/browse/SLING-4083). Also `Resource`s can only be injected if the according injector-specific annotation is used (`@SlingObject`). | `Resource`, `ResourceResolver` or `SlingHttpServletRequest` objects (not all objects can be resolved by all adaptables).  | yes | none | none


# Injector-specific Annotations

*Introduced with [SLING-3499](https://issues.apache.org/jira/browse/SLING-3499) in Sling Models Impl 1.0.6*

Sometimes it is desirable to use customized annotations which aggregate the standard annotations described above. This will generally have
the following advantages over using the standard annotations:

 * Less code to write (only one annotation is necessary in most of the cases)
 * More robust (in case of name collisions among the different injectors, you make sure that the right injector is used)
 * Better IDE support (because the annotations provide elements for each configuration which is available for that specific injector, i.e. `filter` only for OSGi services)

The follow annotations are provided which are tied to specific injectors:

Annotation          | Supported Optional Elements    | Injector | Description
-----------------   | ------------------------------ |-------------------------
`@ScriptVariable`   | `injectionStrategy` and `name`          | `script-bindings` | Injects the script variable defined via [Sling Bindings](https://cwiki.apache.org/confluence/display/SLING/Scripting+variables). If `name` is not set the name is derived from the method/field name. 
`@ValueMapValue`    | `injectionStrategy`, `name` and `via`   | `valuemap` | Injects a `ValueMap` value. If `via` is not set, it will automatically take `resource` if the adaptable is the `SlingHttpServletRequest`. If `name` is not set the name is derived from the method/field name.
`@ChildResource`    | `injectionStrategy`, `name` and `via`   | `child-resources` | Injects a child resource by name. If `via` is not set, it will automatically take `resource` if the adaptable is the `SlingHttpServletRequest`. If `name` is not set the name is derived from the method/field name.
`@RequestAttribute` | `injectionStrategy`, `name` and `via`   | `request-attributes` | Injects a request attribute by name. If `name` is not set the name is derived from the method/field name.
`@ResourcePath`     | `injectionStrategy`, `path`, and `name` | `resource-path` | Injects a resource either by path or by reading a property with the given name.
`@OSGiService`      | `injectionStrategy`, `filter`           | `osgi-services` | Injects an OSGi service by type. The `filter` can be used give an OSGi service filter.
`@ContextAwareConfiguration` | `injectionStrategy`, `name`    | `caconfig` | Lookup context-aware configuration. See [Context-Aware Configuration](#context-aware-configuration).
`@Self`             | `injectionStrategy`                     | `self` | Injects the adaptable itself. If the field type does not match with the adaptable it is tried to adapt the adaptable to the requested type.
`@SlingObject`      | `injectionStrategy`                     | `sling-object` |Injects commonly used sling objects if the field matches with the class: request, response, resource resolver, current resource, SlingScriptHelper

## Hints

Those annotations replace `@Via`, `@Filter`, `@Named`, `@Optional`, `@Required`, `@Source` and `@Inject`. 
Instead of using the deprecated annotation element `optional` you should rather use `injectionStrategy` with the values `DEFAULT`, `OPTIONAL` or `REQUIRED` (see also [SLING-4155](https://issues.apache.org/jira/browse/SLING-4155)).
`@Default` may still be used in addition to the injector-specific annotation to set default values. All elements given above are optional.
 
## Context-Aware Configuration

Since [SLING-7256](https://issues.apache.org/jira/browse/SLING-7256) it is possible to inject 
[Context-Aware Configuration](https://sling.apache.org/documentation/bundles/context-aware-configuration/context-aware-configuration.html) directly in Sling Models.

To use it, the following additional bundles are required (with given minimal version):

* Apache Sling Context-Aware Configuration Implementation 1.6.0 (`org.apache.sling.caconfig.impl`)
* Apache Sling Context-Aware Configuration SPI 1.4.0 (`org.apache.sling.caconfig.spi`)
* Apache Sling Context-Aware Configuration API 1.1.2 (`org.apache.sling.caconfig.api`)
* Apache Sling Models Context-Aware Configuration 1.0.0 (`org.apache.sling.models.caconfig`) - this bundle contains both the `@ContextAwareConfiguration` injector annotation and the injector implementation.

Usage example for injecting a single Context-Aware configuration looked up in context of the current resource (`SingleConfig` is an annotation class describing the context-aware configuration):

    ::java
    @Model(adaptables = { SlingHttpServletRequest.class, Resource.class })
    public class SingleConfigModel {

        @ContextAwareConfiguration
        private SingleConfig config;

    }

Example for injecting a configuration list (`ListConfig` is an annotation class configured as context-aware configuration list):

    ::java
    @Model(adaptables = { SlingHttpServletRequest.class, Resource.class })
    public class ListConfigModel {

        @ContextAwareConfiguration
        private List<ListConfig> configList;
    }

For more examples, see [example models from unit tests](https://github.com/apache/sling-org-apache-sling-models-caconfig/tree/master/src/test/java/org/apache/sling/models/caconfig/example/model).

## Custom Annotations

To create a custom annotation, implement the `org.apache.sling.models.spi.injectorspecific.StaticInjectAnnotationProcessorFactory` interface.
This interface may be implemented by the same class as implements an injector, but this is not strictly necessary. Please refer to the
[injectors in Git](https://github.com/apache/sling-org-apache-sling-models-impl/tree/master/src/main/java/org/apache/sling/models/impl/injectors) for examples.
 
# Specifying an Alternate Adapter Class (since 1.1.0)

By default, each model class is registered using its own implementation class as adapter. If the class has additional interfaces this is not relevant.

The `@Model` annotations provides an optional `adapters` attribute which allows specifying under which type(s) the model
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

# Associating a Model Class with a Resource Type (since 1.3.0)

The `@Model` annotation provides an optional `resourceType` attribute which allows for model classes to be associated with one or
more resource types. This is used in three different ways.

In the case of multiple model classes implementing the same interface, the class with the "closest" resource type will be used when
adapting to the interface.

The `ModelFactory` service interface has methods `Object getModelFromResource(Resource)` and `Object getModelFromRequest(SlingHttpServletRequest)` which will dynamically determine the adapter class based on the `Resource` using its type. In the case of the `SlingHttpServletRequest` method, it uses the request's `Resource` object (i.e. by calling `request.getResource()`)

The resource type is also used as part of the Exporter framework (see next section).

# Exporter Framework (since 1.3.0)

Sling Models objects can be exported to arbitrary Java objects through the Sling Models Exporter framework. Model objects can be
programatically exported by calling the `ModelFactory` method `exportModel()`. This method takes as its arguments:

* the model object
* an exporter name
* a target class
* a map of options

The exact semantics of the exporting will be determined by an implementation of the `ModelExporter` service interface. 

Sling Models currently includes a single exporter, using the Jackson framework, which is capable of serializing models as JSON or transforming them to `java.util.Map` objects. It is included in a dedicated bundle with the symbolic name [`org.apache.sling.models.jacksonexporter`](https://github.com/apache/sling-org-apache-sling-models-jacksonexporter).

In addition, model objects can have servlets automatically registered for their resource type (if it is set) using the `@Exporter` annotation. For example, a model class with the annotation

    ::java
    @Model(adaptable = Resource.class, resourceType = "myco/components/foo")
    @Exporter(name = "jackson", extensions = "json")

results in the registration of a servlet with the resource type and extension specified and a selector of 'model' (overridable 
through the `@Exporter` annotation's `selector` attribute). When this servlet is invoked, the `Resource` will be adapted to the 
model, exported as a `java.lang.String` (via the named Exporter) and then returned to the client.


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

# Caching

By default, Sling Models do not do any caching of the adaptation result and every request for a model class will
result in a new instance of the model class. However, there are two notable cases when the adaptation result can be cached. The first case is when the adaptable extends the `SlingAdaptable` base class. Most significantly, this is the case for many `Resource` adaptables as `AbstractResource` extends `SlingAdaptable`.  `SlingAdaptable` implements a caching mechanism such that multiple invocations of `adaptTo()` will return the same object. For example:

    ::java
    // assume that resource is an instance of some subclass of AbstractResource
    ModelClass object1 = resource.adaptTo(ModelClass.class); // creates new instance of ModelClass
    ModelClass object2 = resource.adaptTo(ModelClass.class); // SlingAdaptable returns the cached instance
    assert object1 == object2;

While this is true for `AbstractResource` subclasses, it is notably **not** the case for `SlingHttpServletRequest` as this class does not extend `SlingAdaptable`. So:

    ::java
    // assume that request is some SlingHttpServletRequest object
    ModelClass object1 = request.adaptTo(ModelClass.class); // creates new instance of ModelClass
    ModelClass object2 = request.adaptTo(ModelClass.class); // creates another new instance of ModelClass
    assert object1 != object2;

Since API version 1.3.4, Sling Models *can* cache an adaptation result, regardless of the adaptable by specifying `cache = true` on the `@Model` annotation.


    ::java
    @Model(adaptable = SlingHttpServletRequest.class, cache = true)
    public class ModelClass {}

    ...

    // assume that request is some SlingHttpServletRequest object
    ModelClass object1 = request.adaptTo(ModelClass.class); // creates new instance of ModelClass
    ModelClass object2 = request.adaptTo(ModelClass.class); // Sling Models returns the cached instance
    assert object1 == object2;

When `cache = true` is specified, the adaptation result is cached regardless of how the adaptation is done:

    ::java
    @Model(adaptable = SlingHttpServletRequest.class, cache = true)
    public class ModelClass {}

    ...

    // assume that request is some SlingHttpServletRequest object
    ModelClass object1 = request.adaptTo(ModelClass.class); // creates new instance of ModelClass
    ModelClass object2 = modelFactory.createModel(request, ModelClass.class); // Sling Models returns the cached instance
    assert object1 == object2;

<a name="caching-self-reference-note"></a>
### A note about cache = true and using the self injector

In general, it is **strongly** discouraged to store a reference to the original adaptable using the `self` injector. Using implementation version 1.4.8 or below, storing the original adaptable in a Sling Model, can cause heap space exhaustion, crashing the JVM. Starting in version 1.4.10, storing the original adaptable will not crash the JVM, but it can cause unexpected behavior (e.g. a model being created twice, when it should be cached). The issue was first reported in [SLING-7586](https://issues.apache.org/jira/browse/SLING-7586).

The problem can be avoided by discarding the original adaptable when it is no longer needed. This can be done by setting affected field(s) to `null` at the end of the `@PostConstruct` annotated method:

    ::java
    @Model(adaptable = SlingHttpServletRequest.class, cache = true)
    public class CachableModelClass {
        @Self
        private SlingHttpServletRequest request;
        
        @PostConstruct
        private void init() {
          ... do something with request ...
          
          this.request = null;
        }
    }

Alternatively, the same effect can be achieved using constructor injection, by not storing the reference to the adaptable:

    ::java
    @Model(adaptable = SlingHttpServletRequest.class, cache = true)
    public class CachableModelClass {
        public CachableModelClass(SlingHttpServletRequest request) {
          ... do something with request ...
        }
    }

# Via Types (Since API 1.3.4/Implementation 1.4.0)
 
As discussed in the [Via](#via) section above, it is possible to select a different adaptable than the original value using the `@Via` annotation. The following standard types are provided (all types are in the package `org.apache.sling.models.annotations.via`)

`@Via` type value             | Description
----------------------------- | ------------------------------ 
`BeanProperty`  (default)     | Uses a JavaBean property from the adaptable.
`ChildResource`               | Uses a child resource from the adaptable, assuming the adaptable is a `Resource`. In case the adaptable is a `SlingHttpServletRequest` uses a wrapper overwriting the `getResource()` to point to the given child resource ([SLING-7321](https://issues.apache.org/jira/browse/SLING-7321)).
`ForcedResourceType`          | Creates a wrapped resource with the provided resource type. If the adaptable is a `SlingHttpServletRequest`, a wrapped request is created as well to contain the wrapped resource.
`ResourceSuperType`           | Creates a wrapped resource with the resource type set to the adaptable's resource super type. If the adaptable is a `SlingHttpServletRequest`, a wrapped request is created as well to contain the wrapped resource.

## Custom Via Type

Defining your own type for the `@Via` annotation is a two step process. The first step is to create a marker class implementing the `@ViaProviderType` annotation. This class can be entirely empty, e.g.

    ::java
    public class MyCustomProviderType implements ViaProviderType {}

The second step is to create an OSGi service implementing the `ViaProvider` interface. This interface defines two methods:

* `getType()` should return the marker class. 
* `getAdaptable()` should return the new adaptable or `ViaProvider.ORIGINAL` to indicate that the original adaptable should be used.
