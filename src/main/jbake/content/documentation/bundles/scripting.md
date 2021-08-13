title=Sling Scripting		
type=page
status=published
tags=scripts
~~~~~~

[TOC]

## Sling Scripting Engines

Sling Scripting is build around Java Scripting API (JSR 223). It allows the easy development and usage of different scripting (aka templating) engines.

The script engines are managed in `SlingScriptEngineManager` ([Scripting Core][8]).

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

Since version `2.0.60` [Scripting Core][8] supports the mapping of extensions to engines in content ([SLING-4330](https://issues.apache.org/jira/browse/SLING-4330)).

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

## Scripts are Servlets

The Sling API defines a `SlingScript` interface which is used to represent (executable) scripts inside of Sling. This interface is implemented in the [Scripting Core bundle][8] in the `DefaultSlingScript` class which also implements the `javax.servlet.Servlet`.

To further simplify the access to scripts from the Resource tree, the `scripting/core` bundle registers an `AdapterFactory` to adapt Resources to Scripts and Servlets (the `SlingScriptAdapterFactory`). In fact the adapter factory returns instances of the `DefaultSlingScript` class for both Scripts and Servlets.

From the perspective of the [Servlet resolver][7], scripts and servlets are handled exactly the same. In fact, internally, Sling only deals with Servlets, whereas scripts are packed inside a Servlet wrapping and representing the script.

## Resource Scripts

Scripts are looked up in a series of resource resolver locations defined by the `ResourceResolver.getSearchPath()` and the resource type (and resource super types) of the requested resource: 

    {scriptPathPrefix}/{resourceTypePath} 
    
The pseudo code for iterating the locations would be something like: 
    

    var type = resource.getResourceType(); 
    while (type != null) { 
        for (String root: resourceResolver.getSearchPath()) { 
            String path = root + type.toPath(); 
            findScriptsIn(path); 
        } 

        if (type == defaultServlet) { 
            type = null; 
        } else { 
            type = getResourceSuperType(type); 
            if (type == null) { 
                type = defaultServlet; 
            } 
        } 
    } 

### Resource script naming conventions

Depending on whether request selectors are considered, a script may have two forms: 

1. Ignoring request selectors (e.g. there are none in the request URI): `{resourceTypeLabel}.{requestExtension}.{requestMethod}.{scriptExtension}` 
2. Handling request selectors: `{selectorStringPath}.{requestExtension}.{requestMethod}.{scriptExtension}`

The constituents of these script names are as follows: 

* `{resourceTypeLabel}` - The last path segment of the path created from the resource type. This part is optional if the `{requestExtension}` is used in the script name. The resource type might either be set via the `sling:resourceType` property on the accessed node or if that property is not there its primary node type (property `jcr:primaryType`) is taken as fall-back.
* `{requestExtension}` - The request extension. This part may be omitted if the request extension is `html`, otherwise this part is required. If this part is omitted, the `{resourceTypeLabel}` is required in the case of ignoring the selectors.
* `{requestMethod}` - The request's HTTP method. This part may be omitted if the script is meant for a `GET` or a `HEAD` request. This part is required for any other HTTP method.
* `{scriptExtension}` - The extension identifying the scripting language used. This part is mandatory. For more details about the available Script Engines and their registered extensions check the [Sling Scripting](/documentation/bundles/scripting.html) page.
* `{selectorStringPath}` - The selector string converted to a path, along the lines of `selectorString.replace('.', '/')`. If less selectors are specified in the script name than given in the request, the script will only be taken into consideration if the given selectors are the **first** selectors in the request. This means *sel1/sel2.html.jsp* will be a candidate for the request url */content/test.sel1.sel2.sel3.html* but not for */content/test.sel3.sel1.sel2.html*. So the order of selectors is relevant!


## Bundled Scripts

Scripts may also be provided in OSGi bundles (precompiled or embedded) since [Sling Servlet Resolver 2.7.0](https://github.com/apache/sling-org-apache-sling-servlets-resolver#bundled-scripts) through the org.apache.sling.servlets.resolver.bundle.tracker API in addition to classical Resource based scripts.

Although traditionally scripts are deployed as content stored in the search paths of a Sling instance, this leaves very little
room for script evolution in a backwards compatible way. Furthermore, versioning scripts is a difficult process if the only
mechanism to do this is the `sling:resourceType` property, since consumers (content nodes or other resource types) have then to
explicitly mention the version expected to be executed.

Scripts should not be considered content, since their only purpose is to actually generate the rendering for a certain content
structure. They are not consumed by users, but rather by the Sling Engine itself and have very little meaning outside this
context. As such, scripts should be handled like code:

  1. they _provide an HTTP API_;
  2. they can evolve in a [_semantical_  way][1];
  3. they have a _developer audience_.

  
### Technical Background

Being built around a [`BundleTrackerCustomizer`][2], the `org.apache.sling.servlets.resolver.internal.bundle.BundledScriptTracker`
monitors the instance's bundles wired to the `org.apache.sling.servlets.resolver` bundle and scans the ones providing a `sling.servlet`
[capability][3]. The wiring is created by placing a `Require-Capability` header in the bundles that provide the `sling.servlet` capability:

```
osgi.extender;filter:="(&(osgi.extender=sling.scripting)(version>=1.0.0)(!(version>=2.0.0)))"
```

A `sling.servlet` capability has almost the same attributes as the properties required to [register a servlet on the Sling platform][4]:

  1. `sling.servlet.resourceTypes:List` - mandatory; defines the provided resource type; its value is a list of resource types
  2. `sling.servlet.selectors:List` - optional; defines the list of selectors that this resource type can handle;
  3. `sling.servlet.extensions:List` - optional; defines the list of extensions that this resource type can handle;
  4. `sling.servlet.methods:List` - optional; defines the list of HTTP methods that this resource type can handle;
  5. `version:Version` - optional; defines the version of the provided `resourceType`;
  6. `extends:String` - optional; defines which resource type it extends; the version range of the extended resource type is defined in a
    `Require-Capability`.

The `BundledScriptTracker` will register a Sling Servlet with the appropriate properties for each `sling.servlet` capability. The
servlets will be registered using the bundle context of the bundle providing the `sling.servlet` capability, making
sure to expose the different versions of a resource type as part of the registered servlet's properties. On top of this, a plain resource
type bound servlet will also be registered, which will be automatically wired to the highest version of the `resourceType`. All the
mentioned service registrations are managed automatically by the `BundledScriptTracker`.

### So how do I deploy my scripts?
Short answer: exactly like you deploy your code, preferably right next to it. Pack your scripts using the following conventions:

  1. create a `src/main/resources/javax.script` folder in your bundle (if you want to embed the scripts as they are) or just put the
   scripts in `src/main/scripts` if you want to precompiled them (e.g. JSP and HTL);
  2. each folder under the above folders will identify a `resourceType`;
  3. inside each `resourceType` folder you can optionally create a `Version` folder; this has to follow the Semantic Versioning
   constraints described at [1];
  4. add your scripts, using the same [naming conventions that you were used to from before][5];
  5. manually define your provide and require capabilities; just kidding; add the
  [`scriptingbundle-maven-plugin`](https://github.com/apache/sling-scriptingbundle-maven-plugin) to your build section and add its required
  properties in the `maven-bundle-plugin`'s instructions (check [these examples](https://github.com/apache/sling-org-apache-sling-scripting-bundle-tracker-it/tree/master/examples/));
  6. `mvn clean sling:install`.

### Integration Tests

The integration tests for bundled scripts are provided by the [`org.apache.sling.scripting.bundle.tracker.it`](https://github.com/apache/sling-org-apache-sling-scripting-bundle-tracker-it) project.

## Script resolution order

The [same rules as for servlets][6] are being followed but in addition keep in mind that bundled scripts (as well as servlets) are prefered over resource scripts.

### Example for resource script

Let's consider the following script paths for a request of a resource whose resource type is `sling\sample` and the request selectors are *print.a4* and the request extension is *html*: 
    
1. GET.esp 
1. sample.esp 
1. html.esp 
1. print.esp 
1. print/a4.esp 
1. print.html.esp 
1. print/a4.html.esp
1. a4.html.esp
1. a4/print.html.esp 
    
The priority of script selection would be (starting with the best one): 

```
(7) - (5) - (6) - (4) - (3) - (2) - (1). 
```

Note that (5) is a better match than (6) because it matches more selectors even though (6) has an extension match where (5) does not. (8) is not a candidate because it does not include the first selector (print) and (9) is not a candidate because it has the wrong order of selectors.

## Script encoding

All scripts backed by Sling resources get their character encoding from the [character encoding set in the resource metadata](../the-sling-engine/resources.html#resource-properties). For JCR based resources this is retrieved from the underlying `jcr:encoding` JCR property. If not set it will fall back to UTF-8.

Every script evaluation in the context of a request sets the response's character encoding to UTF-8 (if the request accepts content types starting with `text/`)

## Scripting variables

See also [Scripting variables](https://cwiki.apache.org/confluence/display/SLING/Scripting+variables) and [Adding New Scripting Variables](https://cwiki.apache.org/confluence/display/SLING/Adding+New+Scripting+Variables).


[1]: https://semver.org/
[2]: https://osgi.org/javadoc/r6/core/org/osgi/util/tracker/BundleTrackerCustomizer.html
[3]: http://docs.osgi.org/specification/osgi.core/7.0.0/framework.module.html#d0e2821 "Bundle Capabilities"
[4]: /documentation/the-sling-engine/servlets.html#servlet-registration
[5]: #resource-script-naming-conventions
[6]: /documentation/the-sling-engine/servlets.html##servlet-resolution-order
[7]: /documentation/the-sling-engine/servlets.html
[8]: https://github.com/apache/sling-org-apache-sling-scripting-core