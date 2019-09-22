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

## Scripting variables

See also [Scripting variables](https://cwiki.apache.org/confluence/display/SLING/Scripting+variables) and [Adding New Scripting Variables](https://cwiki.apache.org/confluence/display/SLING/Adding+New+Scripting+Variables).
