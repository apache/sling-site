title=Bundle Resources (extensions.bundleresource)		
type=page
status=published
tags=resources,bundles
~~~~~~

[TOC]

## Introduction

The Bundle Resource Provider provides access to files/directories included in an OSGi bundle through the Sling `ResourceResolver`. 

## Resource Types

Files and directories are mapped into the resource tree as regular `Resource` instances whose resource type depends on the actual nature of the mapped resource:

   * Regular files are assigned the `nt:file` resource type
   * Directories are assigned the `nt:folder` resource type


## Adapters

Filesystem resources extend from Sling's `AbstractResource` class and thus are adaptable to any type for which an `AdapterFactory` is registered supporting bundle resources. In addition `BundleResource` support the following adapters natively:

   * `java.net.URL` -- A valid `bundle://` URL to the resource in the bundle. 
   * `java.io.InputStream` -- An `InputStream` to read file contents. Doesn't apply to folders.


## Configuration

Providing bundles have a Bundle manifest header `Sling-Bundle-Resources` containing a list of absolute paths provided by the bundle. The paths are separated by comma or whitespace (SP, TAB, VTAB, CR, LF). 

Example (manifest.mf):


    ...
    Sling-Bundle-Resources: /libs/sling/explorer,                         
        /libs/sling/servlet/default/explorer
    ...


It's also possible to map resources from the bundle to a different location in the resource tree. In this case the path has to be extended with a path attrribute to declare where the resources are in the bundle:


    ...
    Sling-Bundle-Resources: /somepath/inthe/resourcetree;path:=/path/inthe/bundle
    ...


The Bundle Resource Provider also has a web console plugin through which the currently installed bundles can be seen.
