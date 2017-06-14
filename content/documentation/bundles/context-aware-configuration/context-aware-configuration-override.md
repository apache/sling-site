title=Apache Sling Context-Aware Configuration - Override		
type=page
status=published
~~~~~~

[TOC]


# About

Using overrides it is possible to override context-aware configuration values globally or for specific content paths (and their subtrees) within an instance. If an override is active the Configuration API returns the overridden values instead of the values from the configuration resources.

An example use case is to overwrite the Site URLs on your staging system which has a copy of the configuration content of the production system installed.

Via the [SPI](http://sling.apache.org/documentation/bundles/context-aware-configuration/context-aware-configuration-spi.html) you can add your own override providers - but in most cases the built-in ones described in this page are sufficient. All override providers use the same override syntax.


# Override syntax

Generally an override consists of one single line. Syntax examples:

{configName}/{propertyName}={propertyJsonValue}
{configName}={propertyJsonObject}
[{contextPath}]{configName}/{propertyName}={propertyJsonValue}
[{contextPath}]{configName}={propertyJsonObject}

The different parts:

* `{configName}` - Configuration name - can be a relative path with sub-resources
* `{propertyName}` - Property name
* `{propertyJsonValue}` - Property value in JSON value syntax.
* `{propertyJsonObject}` - If the property name is missing a JSON object can be defined containing all properties as key-value pairs.
* `{contextPath}` - If the context path is missing, the override is applied to all context path. If it is defined (enclosed in brackets), the override is applied only to this content path and it's subtree.

When the syntax `{configName}/{propertyName}={propertyJsonValue}` is used, only this specific property is overwritten leaving all other properties in the configuration resource untouched. When the syntax `{configName}={propertyJsonObject}` is used, all configuration properties in the configuration resources are replaced with the set from the JSON object.

Override string examples with real values:

my-config/property1="value 1"
my-config/sub1/property1="value 1"
my-config/property1=["value 1","value 2"]
my-config/property1=123
x.y.z.MyConfig={"prop1"="value1","prop2"=[1,2,3],"prop3"=true,"prop4"=1.23}
[/content/region1]my-config/property1="value 1"
[/content/region1]my-config/sub1={"prop1":"value 1"}

If multiple statements are defined affecting the same content path, configuration name and property name, they overwrite each other. That means the override string defined last wins.


# Built-in override providers

## Override via system properties

Allows to define configuration property overrides from system environment properties.

The parameters are defined when starting the JVM using the -D command line parameter. Each parameter contains an override string. All parameter names have to be prefixed with the string `sling.caconfig.override.`.

Example:

-Dsling.caconfig.override.my-config/sub1/property1=123
-D"sling.caconfig.override.my-config/property1=["value 1","value 2"]"
-D"sling.caconfig.override.[/content/region1]x.y.z.MyConfig={"prop1"="value1","prop2"=[1,2,3],"prop3"=true,"prop4"=1.23}"

This provider is not active by default, it has to be activated via OSGi configuration ("Apache Sling Context-Aware System Property Configuration Override Provider").

## Override via OSGi configuration

Allows to define configuration property overrides from OSGi configuration.

You can provide multiple providers using a factory configuration ("Apache Sling Context-Aware OSGi Configuration Override Provider"), each of them provides list of override strings.
