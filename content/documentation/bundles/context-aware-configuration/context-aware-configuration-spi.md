title=TODO title for context-aware-configuration-spi.md 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: Apache Sling Context-Aware Configuration - SPI

[TOC]


# About

The Context-Aware Configuration implementation provides a set of Service Provider Interfaces (SPI) that allows you to overlay, enhance or replace the default implementation and adapt it to your needs.

Please use the SPI with care, and first check if the [Default Implementation](http://sling.apache.org/documentation/bundles/context-aware-configuration/context-aware-configuration-default-implementation.html) does not already fulfill your needs.



# General principles

All SPIs share a common principle:

- Support multiple strategies at the same time
- No need to switch off or „copy“ the initial strategy
- Apply additional strategies only for those places where needed (“minimally invasive”)

All existing implementations are iterated in order of their service ranking.


# Context Path Strategy

By providing an implementation of `org.apache.sling.caconfig.resource.spi.ContextPathStrategy` you can provide additional ways how context paths and their configuration references are detected in your content resource hierarchy.

E.g. you could implement detecting context paths by project-specific conventions.


# Configuration Resource Resolver Strategy

By providing an implementation of `org.apache.sling.caconfig.resource.spi.ConfigurationResourceResolvingStrategy` you can define where configuration data is looked up, and how resource and property inheritance is handled.


# Configuration Inheritance Strategy

By providing an implementation of `org.apache.sling.caconfig.spi.ConfigurationInheritanceStrategy` you can define if and how resources are inherited across the inheritance chain.


# Configuration Persistence Strategy

By providing an implementation of `org.apache.sling.caconfig.spi.ConfigurationPersistenceStrategy2` you can define the persistence structure of the configuration within the configuration resources.

E.g. you could use a specific JCR node type or slightly different content structure to store the configuration data.


# Configuration Metadata Provider

By providing an implementation of `org.apache.sling.caconfig.spi.ConfigurationMetadataProvider` you can provide information about configuration metadata from other sources than annotation classes.


# Configuration Override Provider

By providing an implementation of `org.apache.sling.caconfig.spi.ConfigurationOverrideProvider` you can provide your own overrides - if the built-in override providers do not fit your needs.

See [Override](http://sling.apache.org/documentation/bundles/context-aware-configuration/context-aware-configuration-override.html) for the list of built-in providers and the override syntax.
