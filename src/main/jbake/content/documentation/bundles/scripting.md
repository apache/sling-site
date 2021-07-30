title=Sling Scripting		
type=page
status=published
tags=scripts
~~~~~~

[TOC]

## Sling Scripting Engines

Sling Scripting is build around Java Scripting API (JSR 223). It allows the easy development and usage of different scripting (aka templating) engines.

The script engines are managed in `SlingScriptEngineManager` ([Scripting Core](https://github.com/apache/sling-org-apache-sling-scripting-core)).

| Engine | Language Name | Language Version | Names | Extensions | Mime Types | GitHub Repo(s) | Documentation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [FreeMarker](https://freemarker.apache.org) | `FreeMarker` | `freemarker.template.Configuration#getVersion().toString()` | `FreeMarker`<br>`freemarker`<br>(configurable) | `ftl`<br>(configurable) | `text/x-freemarker`<br>(configurable) | [sling-org-apache-sling-scripting-freemarker](https://github.com/apache/sling-org-apache-sling-scripting-freemarker) | |
| [Groovy (GString)](http://docs.groovy-lang.org/docs/next/html/documentation/template-engines.html#_gstringtemplateengine) | `Groovy GString` | `org.codehaus.groovy.util.ReleaseInfo#getVersion()` | `GString`<br>`gstring`<br>(configurable) | `gst`<br>(configurable) | (configurable) | [sling-org-apache-sling-scripting-groovy](https://github.com/apache/sling-org-apache-sling-scripting-groovy) | |
| [HTL](https://github.com/adobe/htl-spec) | `The HTL Templating Language` | `1.4` | `htl`<br>`HTL`<br>`sightly` | `html` | | [sling-org-apache-sling-scripting-sightly](https://github.com/apache/sling-org-apache-sling-scripting-sightly) | [Scripting HTL](/documentation/bundles/scripting/scripting-htl.html) |
| Java | `Java Servlet Compiler` | `1.5`| `java`<br>`Java` | `java` | | [sling-org-apache-sling-scripting-java](https://github.com/apache/sling-org-apache-sling-scripting-java) | |
| JavaScript | `ECMAScript` | `partial ECMAScript 2015 support` | `rhino`<br>`Rhino`<br>`javascript`<br>`JavaScript`<br>`ecmascript`<br>`ECMAScript` | `esp`<br>`ecma` | `text/ecmascript`<br>`text/javascript`<br>`application/ecmascript`<br>`application/javascript` | [sling-org-apache-sling-scripting-javascript](https://github.com/apache/sling-org-apache-sling-scripting-javascript) | |
| [JSP](https://projects.eclipse.org/projects/ee4j.jsp) | `Java Server Pages` | `2.1` | `jsp`<br>`JSP` | `jsp`<br>`jspf`<br>`jspx` | | [sling-org-apache-sling-scripting-jsp](https://github.com/apache/sling-org-apache-sling-scripting-jsp) | [Scripting  JSP](/documentation/bundles/scripting/scripting-jsp.html) |
| [Thymeleaf](https://www.thymeleaf.org) | `Thymeleaf` | `version` from [`/org/thymeleaf/thymeleaf.properties`](https://github.com/thymeleaf/thymeleaf/blob/3.0-master/src/main/resources/org/thymeleaf/thymeleaf.properties) | `Thymeleaf`<br>`thymeleaf`<br>(configurable) | `html`<br>(configurable)  | `text/html`<br>(configurable)  | [sling-org-apache-sling-scripting-thymeleaf](https://github.com/apache/sling-org-apache-sling-scripting-thymeleaf) | [Scripting Thymeleaf](/documentation/bundles/scripting/scripting-thymeleaf.html) |

Several more engines are available but experimental or no longer maintained:

* ESX
* JST
* Python
* Ruby
* Scala
* Velocity
* XProc

Code for really old modules might be found in the [svn attic](https://svn.apache.org/repos/asf/sling/attic).

### Mapping script extensions to engines

Since version `2.0.60` [Scripting Core](https://github.com/apache/sling-org-apache-sling-scripting-core) supports the mapping of extensions to engines in content ([SLING-4330](https://issues.apache.org/jira/browse/SLING-4330)).

This is required when registering more than one script engine for a single script extension (e.g. using HTL for *vendor-related* scripts in `/libs` and Thymeleaf for *project-related* scripts in `/apps`, both using extension `html`).

It works by adding a `sling:scripting` property to the script resource or a resource in the hierarchy above the script (e.g. project or parent folder).

The mapping consists of a *key* which is the *script extension* and a *value* which itself could consist of four values separated by colon to identify the script engine:

1. language name (required)
2. language version (optional)
3. engine name (not used yet)
4. engine version (not used yet)

The `sling:scripting` property supports multiple mappings for different extensions (e.g. `html` and `js`).

In case there is more than one script engine for a script extension registered and no mapping is found the script engine with higher service ranking gets used for rendering.

#### Sample mappings

Mapping `html` to HTL 1.4:

    "sling:scripting": [
      "html=The HTL Templating Language:1.4"
    ]

Mapping `html` to Thymeleaf 3.0:

    "sling:scripting": [
      "html=Thymeleaf:3.0"
    ]

## Bundled Scripts

Scripts may also be provided in OSGi bundles (precompiled or embedded) since [Sling Servlet Resolver 2.7.0](https://github.com/apache/sling-org-apache-sling-servlets-resolver#bundled-scripts).

## Script encoding

All scripts backed by Sling resources get their character encoding from the [character encoding set in the resource metadata](../the-sling-engine/resources.html#resource-properties). For JCR based resources this is retrieved from the underlying `jcr:encoding` JCR property. If not set it will fall back to UTF-8.

Every script evaluation in the context of a request sets the response's character encoding to UTF-8 (if the request accepts content types starting with `text/`)

## Scripting variables

See also [Scripting variables](https://cwiki.apache.org/confluence/display/SLING/Scripting+variables) and [Adding New Scripting Variables](https://cwiki.apache.org/confluence/display/SLING/Adding+New+Scripting+Variables).
