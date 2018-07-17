title=Wrap or Decorate Resources		
type=page
status=published
tags=resources
~~~~~~

## Introduction

The Sling API provides an easy way to wrap or decorate a resource before returning. Use cases for this could for example be
* overwrite resource type/resource super type (for example based on the resource path)
* add metadata

## 

To add a resource decorator just register one or more services which implement the interface `ResourceDecorator`

    ::java
    interface ResourceDecorator {
        /** Optionally decorate the supplied Resource */
        Resource decorate(Resource)
    
        /** Only called if using older versions of Sling, see below */
        @Deprecated
        Resource decorate(Resource, HttpServletRequest)
    } 


The registered decorators will be called from the resource resolver for each resource returned. 
If the service decorates the resource it should return the new resource (often using a `ResourceWrapper` to wrap the original Resource). 
If the service does not want to decorate the resource, it should return the original resource or null. 

Starting with version 2.1.0 of the JCR Resource bundle, the two-argument `decorate` method is not called anymore. 
Implementors of this interface targeting both newer and older versions of this bundle are advised to implement this method as:

    ::java
    public Resource decorate(Resource resource, HttpServletRequest request) {
        return this.decorate(resource);
    }

And use some other mechanism (e.g. a `ThreadLocal`) to obtain the current request if necessary.
