title=Bundle Resources (org.apache.sling.bundleresource.impl)		
type=page
status=published
tags=resources,bundles
~~~~~~

[TOC]

# Introduction

The Bundle Resource Provider provides access to files/directories included in an OSGi bundle through the Sling `ResourceResolver`. 

# Configuration

If a bundle wants to provide resources, it must specify the Bundle manifest header `Sling-Bundle-Resources` containing a list of absolute paths. The paths are separated by comma. Without any additional information such a path is mapped 1:1 meaning that the specified path is used as the root resource path and the corresponding resource is at the same path in the bundle. 

The following example header maps the paths `/libs/sling/explorer` and `/libs/sling/servlet/default/explorer` in the resource tree to resources in the bundle at the same path:

    ...
    Sling-Bundle-Resources: /libs/sling/explorer,                         
        /libs/sling/servlet/default/explorer
    ...

If such an entry points to a file in the bundle, only this file is mapped. If such an entry points to a directory in the bundle, the whole sub tree below this directory is mapped.

It's also possible to map resources from the bundle to a different location in the resource tree. In this case the path has to be extended with a path directive to declare where the resources are in the bundle. Again the following example maps the path `/libs/sling/explorer` in the resource tree to resources below `/resources/explorer` in the bundle

    ...
    Sling-Bundle-Resources: /libs/sling/explorer;path:=/resources/explorer
    ...

# Resource Types

Files and directories are mapped into the resource tree as regular `Resource` instances whose resource type depends on the actual nature of the mapped resource:

   * Regular files are assigned the `nt:file` resource type
   * Directories are assigned the `nt:folder` resource type
   
The default resource type is stored under the `sling:resourceType` property and can be accessed using the value map. You can change this behavior by adding `skipSettingResourceTypeProperty` flag to the manifest:

    ...
    Sling-Bundle-Resources: /products;skipSettingResourceTypeProperty:=true
    ...
    
After setting the flag, `Resource.getResourceType()` will still return valid resource type.


# Defining Resources Through JSON

By default, there is a 1:1 mapping between resources in the bundle and resources in the resource tree as explained above. While this works for adding files to the resource tree, it doesn't support adding arbitrary resources to the resource tree where the resources just have a map of properties and are not actually a file. By specifying the directive `propsJSON` with an extension, all files in the bundle having this extension are passed as JSON files and the contained structure is added as resources.

For example with the following definition in the manifest:

    ...
    Sling-Bundle-Resources: /products;path:=/resources/products.json;propsJSON:=json
    ...

the resource path `/products` is mapped to bundle resources at `/resources/products.json` and all bundle resources with the `json` extension are parsed. For example with the following `products.json`:

    {
        "sling:resourceType" : "products",
        "sling" : {
            "sling:resourceType" : "product",
            "name" : "sling",
            "title : "Apache Sling"
        }
    }
    
a resource named `products` with the resource type `products` has a single child resource named `sling` and the above three properties.

It's also possible to add additional properties to a file from a bundle resource. For example if the bundle contains the resource `tree.gif` and a JSON file `tree.gif.json` with the directive to parse all files ending in `json`, a file resource `tree.gif` exists in the resource tree with the additional properties from the json file. The JSON file can also override the default resource type in this case. In addition this json file can also contain nested resources below the file resource.

# Adapters

Filesystem resources extend from Sling's `AbstractResource` class and thus are adaptable to any type for which an `AdapterFactory` is registered supporting bundle resources. In addition `BundleResource` support the following adapters natively:

   * `java.net.URL` -- A valid `bundle://` URL to the resource in the bundle. 
   * `java.io.InputStream` -- An `InputStream` to read file contents. Doesn't apply to folders.


# Capability

The bundle implementing the support for bundle resources must provide the following extender capability:

    <Provide-Capability>
       osgi.extender;osgi.extender="org.apache.sling.bundleresource";version:Version="1.1"
    <Provide-Capability>

Bundles providing resources to the resource tree using the described mechanism should also require this capability to ensure at runtime that there is an implementation picking up those bundle resources. This can be done by using the following require capability header:

    <Require-Capability>
        osgi.extender;filter:="(&(osgi.extender=org.apache.sling.bundleresource)(version<=1.1.0)(!(version>=2.0.0)))"
    </Require-Capability>

Without requiring the capability, the bundle containing the resources might resolve successfully but the resource are not part of the resource tree as there is no implementation picking them up.

# WebConsole Plugin

The Bundle Resource Provider also has a web console plugin through which the currently installed bundles can be seen.
