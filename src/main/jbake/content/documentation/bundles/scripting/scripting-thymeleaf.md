title=Sling Scripting Thymeleaf
type=page
status=published
tags=scripts,thymeleaf
~~~~~~

Sling Scripting Thymeleaf is the scripting engine for [_Thymeleaf_](https://www.thymeleaf.org) (3.0) templates.

[TOC]

# Features

* Supporting all of Thymeleaf's extension points: [_TemplateResolver_](https://www.thymeleaf.org/apidocs/thymeleaf/3.0.0.RELEASE/org/thymeleaf/templateresolver/ITemplateResolver.html)﻿s, [_MessageResolver_](https://www.thymeleaf.org/apidocs/thymeleaf/3.0.0.RELEASE/org/thymeleaf/messageresolver/IMessageResolver.html)﻿s, [_Dialect_﻿](https://www.thymeleaf.org/apidocs/thymeleaf/3.0.0.RELEASE/org/thymeleaf/dialect/IDialect.html)s, [_LinkBuilder_](https://www.thymeleaf.org/apidocs/thymeleaf/3.0.0.RELEASE/org/thymeleaf/linkbuilder/ILinkBuilder.html)﻿s, [_DecoupledTemplateLogicResolver_](https://www.thymeleaf.org/apidocs/thymeleaf/3.0.0.RELEASE/org/thymeleaf/templateparser/markup/decoupled/IDecoupledTemplateLogicResolver.html), [_CacheManager_](https://www.thymeleaf.org/apidocs/thymeleaf/3.0.0.RELEASE/org/thymeleaf/cache/ICacheManager.html) and [_EngineContextFactory_](https://www.thymeleaf.org/apidocs/thymeleaf/3.0.0.RELEASE/org/thymeleaf/context/IEngineContext.html)
* `SlingResourceTemplateResolver` customizable through `TemplateModeProvider`﻿
* `ResourceBundleMessageResolver` backed by `ResourceBundleProvider` from [Sling i18n](https://sling.apache.org/documentation/bundles/internationalization-support-i18n.html) customizable through optional `AbsentMessageRepresentationProvider`﻿
* `PatternTemplateModeProvider` supporting [`Pattern`](https://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html) configurations for all [template modes](https://www.thymeleaf.org/apidocs/thymeleaf/3.0.0.RELEASE/org/thymeleaf/templatemode/TemplateMode.html) (`HTML`, `XML`, `TEXT`, `JAVASCRIPT`, `CSS` and `RAW`)
* `SlingDialect`
* Thymeleaf's [`TemplateEngine`](https://www.thymeleaf.org/apidocs/thymeleaf/3.0.0.RELEASE/org/thymeleaf/ITemplateEngine.html) registered as OSGi Service ([`ITemplateEngine`](https://www.thymeleaf.org/apidocs/thymeleaf/3.0.0.RELEASE/org/thymeleaf/ITemplateEngine.html)) for direct use

# Installation

For running Sling Scripting Thymeleaf with Sling's Launchpad some dependencies need to be resolved. This can be achieved by installing the following bundles:

    mvn:org.attoparser/attoparser/2.0.2.RELEASE
    mvn:org.unbescape/unbescape/1.1.4.RELEASE
    mvn:org.apache.servicemix.bundles/org.apache.servicemix.bundles.ognl/3.2_1
    mvn:org.javassist/javassist/3.20.0-GA

There is a feature for Karaf:

    karaf@root()> feature:install sling-scripting-thymeleaf

**Note:** Sling Scripting Thymeleaf requires an implementation of OSGi Declarative Services 1.3 (e.g. [Apache Felix Service Component Runtime](https://felix.apache.org/documentation/subprojects/apache-felix-service-component-runtime.html) 2.0.0 or greater)

# Configuration

## Apache Sling Scripting Thymeleaf “ScriptEngineFactory”

By default Sling Scripting Thymeleaf's _ScriptEngineFactory_ is configured for templates with extension `html` and mime type `text/html` and uses all of Thymeleaf's standard extensions either _also_ or _exclusively_.

![Apache Sling Scripting Thymeleaf “ScriptEngineFactory”](Scripting-Thymeleaf-ScriptEngineFactory.png)

## Apache Sling Scripting Thymeleaf “Sling Resource TemplateResolver”

The _Sling Resource TemplateResolver_ is configured to resolve templates with _use decoupled logic_ enabled.

![Apache Sling Scripting Thymeleaf “Sling Resource TemplateResolver”](Scripting-Thymeleaf-Sling-Resource-TemplateResolver.png)

## Apache Sling Scripting Thymeleaf “Pattern TemplateModeProvider”

The _Pattern TemplateModeProvider_ is configured to match template paths against default extensions for providing template modes (of course except no-op mode `RAW`).

![Apache Sling Scripting Thymeleaf “Pattern TemplateModeProvider](Scripting-Thymeleaf-Pattern-TemplateModeProvider.png)

## Apache Sling Scripting Thymeleaf “ResourceBundle MessageResolver”

The _ResourceBundle MessageResolver_ is configured to use the message's key as absent message representation.

![Apache Sling Scripting Thymeleaf “ResourceBundle MessageResolver”](Scripting-Thymeleaf-ResourceBundle-MessageResolver.png)

# Sling Dialect

Sling Scripting Thymeleaf comes with its own dialect using the `sling` prefix/namespace currently supporting the _include_ feature known from [Sling Scripting JSP Taglib](/documentation/bundles/scripting/scripting-jsp.html).

## include

`<header data-sling-include="${resource}" data-sling-resourceType="'example/page/header'" data-sling-unwrap="true"/>`

`include` - The resource object ([`Resource`](https://sling.apache.org/apidocs/sling7/org/apache/sling/api/resource/Resource.html)) or the path (`String`) of the resource object to include in the current request processing. If this path is relative it is appended to the path of the current resource whose script is including the given resource.

### supported options (* = [RequestDispatcher option](https://sling.apache.org/apidocs/sling7/org/apache/sling/api/request/RequestDispatcherOptions.html))

* `addSelectors` (`String`) *: When dispatching, add the value provided by this option to the selectors.
* `replaceSelectors` (`String`) *: When dispatching, replace selectors by the value provided by this option.
* `replaceSuffix` (`String`) *: When dispatching, replace the suffix by the value provided by this option.
* `resourceType` (`String`) *: The resource type of a resource to include. If the resource to be included is specified with the path attribute, which cannot be resolved to a resource, the tag may create a synthetic resource object out of the path and this resource type. If the resource type is set the path must be the exact path to a resource object. That is, adding parameters, selectors and extensions to the path is not supported if the resource type is set.
* `unwrap` (`Boolean`): removes the host element

# Class Diagram

[![Class Diagram](Scripting-Thymeleaf-Class-Diagram.png)](Scripting-Thymeleaf-Class-Diagram.png)

# Sample

The [Sling Fling Sample](https://github.com/apache/sling-samples/tree/master/fling) is a sample using Sling Scripting Thymeleaf with [Sling Models](/documentation/bundles/models.html) and [Sling Query](/documentation/bundles/sling-query.html).

![Sling Fling Sample](sling-fling-sample.png)
