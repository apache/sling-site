title=Apache Sling Context-Aware Configuration - Default Implementation		
type=page
status=published
tags=configuration
~~~~~~

[TOC]

# About

By default the 'default implementation' us used by the Context-Aware Configuration concerning lookup and persistence of configuration data, resource and property inheritance and context path detection. Using the [SPI](http://sling.apache.org/documentation/bundles/context-aware-configuration/context-aware-configuration-spi.html) it is possible to overlay, extend or replace this functionality.

This page documents the details of the default implementation.


# Repository paths

By default all configuration data is stored in `/conf`. Fallback paths are `/conf/global`, `/apps/conf`and `/libs/conf`.

The paths are configurable in the service configuration.


# Context paths

The content resource hierarchy is defined by setting `sling:configRef` properties. Each resource that has a `sling:configRef` property set defines the root resource of a context, the whole subtree is the context. Within the subtree further nested contexts can be defined.


# Configuration resource resolving

This illustration shows an example for configuration resource lookup:

![Configuration resource lookup](./config-resource-lookup.png)

If you get the context-aware configuration via the API for any resource below `/content/tenant1/region1/site1` it is looked up in this path in this order:

1. `/conf/brand1/tenant1/region1/site1` - because referenced by `/content/tenant1/region1/site1`
2. `/conf/brand1/tenant1/region1` - because referenced by `/content/tenant1/region1` (parent context)
3. `/conf/brand1/tenant1` - because referenced by `/content/tenant1` (parent context)
4. `/conf/brand1` - because it is a parent of by `/conf/brand1/tenant1`
5. `/conf/global` - because it is configured as fallback path
6. `/apps/conf` - because it is configured as fallback path
7. `/libs/conf` - because it is configured as fallback path

So the basic rules are:

* Go up in the content resource tree until a resource with `sling:configRef` is found. This is the 'inner-most' context. Check if a configuration resource exists at the path the property points to.
* Check for parent resources of the references configuration resource (below `/conf`)
* Go further up in the content resource tree for parent contexts, and check their configuration resources as well (they may reference completely different location below `/conf`)
* Check the fallback paths


# Configuration persistence

Example for the resource structure for a configuration resource at `/conf/mysite`:

    /conf
        /mysite
            /sling:configs
                /x.y.z.MyConfig
                  @prop1 = 'value1'
                  @prop2 = 123
                  @prop3= true

Explanation:

* `sling:configs` is the bucket named which is used by the ConfigurationResolver by default for context-aware configurations. May be another name if you use the ConfigurationResourceResolver directly.
* `x.y.z.MyConfig` is the configuration name, in this case derived from an annotation class. May be any other custom name as well.
* `prop1..3`are example for configuration properties
* It is possible to use deeper hierarchies below `sling:configs` as well.
* Nested configurations are supported as well. This can be mapped to annotation classes referencing other annotation classes.

                          
# Resource inheritance

We distinguish between:

- Singleton resources: Configuration resources looked up by the `get`/`as` method variants
- Collection resources: Configuration resources lists looked up by the `getCollection`/`asCollection` method variants

For singleton resources, there is not resource inheritance. The first resource that is found in the configuration resource resolving lookup order is returned.

For collection resources there is no resource inheritance enabled by default. The children of the first resource that is found in the configuration resource resolving lookup order are returned.

By defining a property `sling:configCollectionInherit` on the configuration resource, the children of the next resource that is found in the configuration resource resolving lookup order are combined with the children of the current configuration resource, returned a merged list. If both configuration resources contain child resources with the same name, duplicates are eliminated and only the children of the first resource are included.

By setting the property `sling:configCollectionInherit` on multiple configuration resources that are part of the lookup order it is possible to form deeper inheritance chains following the same rules.

Example for resource inheritance:

![Resource inheritance](./resource-inheritance.png)

The result of this example is: **C, A, B**. It would by just **C** if the `sling:configCollectionInherit` is not set.


# Property inheritance

By default, no property inheritance takes place. That means only the properties that are stored in the configuration resource are mapped to the annotation class or returned as value map, regardless whether singleton or collection resources are returned, or if resource collection inheritance is enabled or not.

By defining a property `sling:configPropertyInherit` on the configuration resource, property merging is enabled between the current configuration resource and the next resource with the same name (singleton or resource collection item) in the configuration resource lookup order. That means that all properties that are not defined on the current configuration resource are inherited from the next resources and a merged value map is used for the configuration mapping.

By setting the property `sling:configPropertyInherit` on multiple configuration resources that are part of the lookup order it is possible to form deeper inheritance chains following the same rules.
