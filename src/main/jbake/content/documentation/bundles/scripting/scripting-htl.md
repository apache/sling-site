title=HTL Scripting Engine		
type=page
status=published
tags=scripts,htl
~~~~~~

The Apache Sling HTL Scripting Engine, [formerly known as Sightly](https://issues.apache.org/jira/browse/SLING-6028), is the reference implementation of the [HTML Template Language 1.4](https://github.com/Adobe-Marketing-Cloud/htl-spec).

[TOC]

# Modules

The Sling implementation is comprised of the following modules:

1. [`org.apache.sling.scripting.sightly.compiler`](https://github.com/apache/sling-org-apache-sling-scripting-sightly-compiler) - provides support for compiling HTML Template Language scripts into an Abstract Syntax Tree
2. [`org.apache.sling.scripting.sightly.compiler.java`](https://github.com/apache/sling-org-apache-sling-scripting-sightly-compiler-java) - provides support for transpiling the Abstract Syntax Tree produced by the `org.apache.sling.scripting.sightly.compiler` module into Java source code
3. [`org.apache.sling.scripting.sightly`](https://github.com/apache/sling-org-apache-sling-scripting-sightly) - the HTL Scripting Engine bundle
4. [`org.apache.sling.scripting.sightly.js.provider`](https://github.com/apache/sling-org-apache-sling-scripting-sightly-js-provider) - the HTL JavaScript Use Provider, implementing support for the `use` JavaScript function
5. [`org.apache.sling.scripting.sightly.models.provider`](https://github.com/apache/sling-org-apache-sling-scripting-sightly-models-provider) - [Sling Models](https://sling.apache.org/documentation/bundles/models.html) Use Provider
6. [`org.apache.sling.scripting.sightly.repl`](https://github.com/apache/sling-org-apache-sling-scripting-sightly-repl) - HTL Read-Eval-Print Loop Environment (REPL), useful for quickly prototyping scripts
7. [`htl-maven-plugin`](https://github.com/apache/sling-htl-maven-plugin) - M2Eclipse compatible HTL Maven Plugin that provides support for validating HTML Template Language scripts from projects during build time

# The Use-API

The [HTML Template Language Specification](https://github.com/Adobe-Marketing-Cloud/htl-spec/blob/1.2/SPECIFICATION.md#4-use-api) explicitly defines two ways of implementing support for business logic objects:

1. Java Use-API, through POJOs, that may optionally implement an `init` method:

        /**
         * Initialises the Use bean.
         *
         * @param bindings All bindings available to the HTL scripts.
         **/
        public void init(javax.script.Bindings bindings);


2. JavaScript Use-API, by using a standardised use function

        /**
         * In the following example '/libs/dep1.js' and 'dep2.js' are optional
         * dependencies needed for this script's execution. Dependencies can
         * be specified using an absolute path or a relative path to this
         * script's own path.
         *
         * If no dependencies are needed the dependencies array can be omitted.
         */
        use(['dep1.js', 'dep2.js'], function (Dep1, Dep2) {
            // implement processing

            // define this Use object's behaviour
            return {
                propertyName: propertyValue
                functionName: function () {}
            }
        });

The HTL implementation from Sling provides the basic POJO support through the [`org.apache.sling.scripting.sightly.pojo.Use`](https://github.com/apache/sling-org-apache-sling-scripting-sightly-compiler-java/blob/master/src/main/java/org/apache/sling/scripting/sightly/pojo/Use.java) interface and the [`JavaUseProvider`](https://github.com/apache/sling-org-apache-sling-scripting-sightly/blob/master/src/main/java/org/apache/sling/scripting/sightly/impl/engine/extension/use/JavaUseProvider.java), whereas the `use` function is implemented by the `org.apache.sling.scripting.sightly.js.provider` bundle.

# Type conversions

The HTL Specification talks about the following types which are supported to be used with native Java types. The conversion rules are outlined in the table below.

HTL Type | Conversion from Java Type | Code Link
--- | --- | --- 
`Boolean` | `java.lang.Boolean` (no conversion necessary). In addition it returns `true` for every other Java object except for `null`, `java.lang.Number` having value `0`, empty String, array, Collection, Map, Iterator or Iterable's iterator  | [`ObjectModel.toBoolean(Object)`](https://github.com/apache/sling-org-apache-sling-scripting-sightly-runtime/blob/org.apache.sling.scripting.sightly.runtime-1.2.4-1.4.0/src/main/java/org/apache/sling/scripting/sightly/render/ObjectModel.java#L151)
`String` | Almost every type via `Object.toString()`. `Collections` are handled differently, by joining their elements. All types supported since HTL Runtime 1.2.6-1.4.0 ([SLING-9968](https://issues.apache.org/jira/browse/SLING-9968)).| [`ObjectModel.toString(Object)`](https://github.com/apache/sling-org-apache-sling-scripting-sightly-runtime/blob/org.apache.sling.scripting.sightly.runtime-1.2.4-1.4.0/src/main/java/org/apache/sling/scripting/sightly/render/ObjectModel.java#L238)
`Date` | `java.util.Date`, `java.util.Calendar`, `java.time.Instant` ([SLING-10651](https://issues.apache.org/jira/browse/SLING-10651)) | [`AbstractRuntimeObjectModel.toDate(Object)`](https://github.com/apache/sling-org-apache-sling-scripting-sightly-runtime/blob/6bcc04f159290aac39f0f6fa725da0a87f59076b/src/main/java/org/apache/sling/scripting/sightly/render/AbstractRuntimeObjectModel.java#L91)
`Number` | `java.lang.Number`, every other type first converted to `java.lang.String` and then converted to Number via [`NumberUtils.createNumber(String)`](https://commons.apache.org/proper/commons-lang/apidocs/org/apache/commons/lang3/math/NumberUtils.html#createNumber-java.lang.String-). | [`ObjectModel.toNumber(Object)`](https://github.com/apache/sling-org-apache-sling-scripting-sightly-runtime/blob/org.apache.sling.scripting.sightly.runtime-1.2.4-1.4.0/src/main/java/org/apache/sling/scripting/sightly/render/ObjectModel.java#L204)
`Collection` | `java.util.Collection`, `java.util.Iterator`, `java.lang.Iterable`, `java.util.Enumeration` and arrays return the underlying list or collection. `java.lang.String` or `java.lang.Number` are converted to a list containing the object as single item. For `java.util.Map` the key set is used. Everything else returns an empty list till HTL Runtime 1.2.4-1.4.0, newer versions return a single item list containing the object ([SLING-10679](https://issues.apache.org/jira/browse/SLING-10679)) | [`ObjectModel.toCollection(Object)`](https://github.com/apache/sling-org-apache-sling-scripting-sightly-runtime/blob/org.apache.sling.scripting.sightly.runtime-1.2.4-1.4.0/src/main/java/org/apache/sling/scripting/sightly/render/ObjectModel.java#L277)

## Support for Optional

Starting with [SLING-8228](https://issues.apache.org/jira/browse/SLING-8228), `java.util.Optional` objects are expanded before being passed to the conversion methods provided by the
[`org.apache.sling.scripting.sightly.render.ObjectModel`](https://github.com/apache/sling-org-apache-sling-scripting-sightly-runtime/blob/org.apache.sling.scripting.sightly.runtime-1.2.4-1.4.0/src/main/java/org/apache/sling/scripting/sightly/render/ObjectModel.java).

## JavaScript

As the HTL Engine in Sling is a Java implementation even the objects provided by the JS Use Provider are first converted into native Java types. The type conversion from JS to Java is done with [Rhino](https://github.com/mozilla/rhino), afterwards the semantics from the table above are used.


# Extensions of the HTL Specification

The Sling HTL Scripting engine fully complies with the [HTML Template Language Specification 1.4](https://github.com/adobe/htl-spec/blob/1.4/SPECIFICATION.md). In addition it adds some extensions which are not part of the specification. 

## Expression Options


### Display Context (supported since HTL Engine 1.4.22-1.4.0)

In addition to the contexts defined in [HTL Spec 1.2.1](https://github.com/adobe/htl-spec/blob/1.4/SPECIFICATION.md#121-display-context) a context with name `jsonString` is supported which escapes a text according to the JSON string grammar defined by [ECMA-404](https://www.ecma-international.org/wp-content/uploads/ECMA-404_2nd_edition_december_2017.pdf) in chapter 9 ([SLING-11538](https://issues.apache.org/jira/browse/SLING-11538)).


### I18n

In addition to the options defined in [HTL Spec 1.2.3](https://github.com/adobe/htl-spec/blob/1.4/SPECIFICATION.md#123-i18n) the option `basename` is supported to set the basename of the used [Sling i18n Resource bundle](../internationalization-support-i18n.html#resourcebundle-with-base-names) ([SLING-5314](https://issues.apache.org/jira/browse/SLING-5314)).


### Format Date

In addition to the regular patterns defined in [HTL Spec 1.2.2.2](https://github.com/adobe/htl-spec/blob/1.4/SPECIFICATION.md#1222-dates) the following special formatting patterns are supported ([SLING-9983](https://issues.apache.org/jira/browse/SLING-9983)) for formatting dates only (disregarding time) in a decent format for the used locale.
*The resulting format depends on the JDK version though, as it changed fundamentally with [JDK 8](https://openjdk.java.net/jeps/252), and even afterwards the different [CLDR releases](http://cldr.unicode.org/index/downloads) implemented in the different JDK versions differ quite substantially.*


Pattern | Description | Example (for Locale en_US)
--- | --- | ---
`short` | A short representation of the date (disregarding time), typically numeric | 10/26/85
`medium` | A medium representation of the date (disregarding time), with some detail | Oct 26, 1985 
`long` | A long representation of the date (disregarding time), with lots of detail | October 26, 1985
`full` | The full represenation of the date (disregarding time), with the most detail | Saturday, October 26, 1985
`default` | Is equal to `medium` | Oct 26, 1985

Those pattern values are case-insensitive.

The implementation uses [`DateTimeFormatter.ofLocalizedDate(FormatStyle)`](https://docs.oracle.com/javase/8/docs/api/java/time/format/DateTimeFormatter.html#ofLocalizedDate-java.time.format.FormatStyle-) for formatting those dates.


## Use-API Extensions

The Sling implementation provides a few extensions to the Use-API.

A full HTL installation provides the following Use Providers, in the order of their priority (the higher the service ranking value, the higher the priority):

|Service Ranking  | Use Provider    | Bundle                 | Functionality     |Observations|
|--------------     |--------------   |-----------------  |---------------    |----------- |
|100|[`RenderUnitProvider`](https://github.com/apache/sling/blob/trunk/bundles/scripting/sightly/engine/src/main/java/org/apache/sling/scripting/sightly/impl/engine/extension/use/RenderUnitProvider.java)|`org.apache.sling.scripting.sightly`|support for loading HTL templates through `data-sly-use`||
|95|[`SlingModelsUseProvider`](https://github.com/apache/sling/blob/trunk/bundles/scripting/sightly/models-use-provider/src/main/java/org/apache/sling/scripting/sightly/models/impl/SlingModelsUseProvider.java)|`org.apache.sling.scripting.sightly.models.provider`|support for loading [Sling Models](https://sling.apache.org/documentation/bundles/models.html)||
|90|[`JavaUseProvider`](https://github.com/apache/sling/blob/trunk/bundles/scripting/sightly/engine/src/main/java/org/apache/sling/scripting/sightly/impl/engine/extension/use/JavaUseProvider.java)|`org.apache.sling.scripting.sightly`|support for loading Java objects such as: <ol><li>OSGi services</li><li>POJOs adaptable from `SlingHttpServletRequest` or `Resource`</li><li>POJOs that implement `Use`</li></ol>|The POJOs can be exported by bundles or can be backed by `Resources`. In the latter case the POJOs' package names should correspond to the backing resource's path; invalid Java characters which are valid path elements should be replaced by an underscore - `_`.|
|80|[`JsUseProvider`](https://github.com/apache/sling/blob/trunk/bundles/scripting/sightly/js-use-provider/src/main/java/org/apache/sling/scripting/sightly/js/impl/JsUseProvider.java)|`org.apache.sling.scripting.sightly.js.provider`|support for loading objects defined through the JavaScript `use` function|The `org.apache.sling.scripting.sightly.js.provider` also provides a trimmed down [asynchronous implementation](https://github.com/apache/sling/tree/trunk/bundles/scripting/sightly/js-use-provider/src/main/resources/SLING-INF/libs/sling/sightly/js) of the `Resource` API. However this was deprecated in [SLING-4964](https://issues.apache.org/jira/browse/SLING-4964) (version 1.0.8 of the bundle) in favour of the synchronous API provided by the `org.apache.sling.scripting.javascript` bundle.|
|0  |[`ScriptUseProvider`](https://github.com/apache/sling/blob/trunk/bundles/scripting/sightly/engine/src/main/java/org/apache/sling/scripting/sightly/impl/engine/extension/use/ScriptUseProvider.java)|`org.apache.sling.scripting.sightly`|support for loading objects returned by scripts interpreted by other Script Engines available on the platform||

The `service.ranking` value of each Use Provider is configurable, allowing for fine tuning of the order in which the providers are queried when `data-sly-use` is called. However, in order to not affect core functionality the `RenderUnitProvider` should always have the highest ranking. If you need to configure the providers' service ranking head over to the configuration console at [http://localhost:8080/system/console/configMgr](http://localhost:8080/system/console/configMgr).

### Global Objects

The following global objects are available to all Use objects, either as a request attribute or as a property made available in the `javax.script.Bindings` map or attached to the `this` context of the `use` function:

        currentNode         // javax.jcr.Node
        currentSession      // javax.jcr.Session
        log                 // org.slf4j.Logger
        out                 // java.io.PrintWriter
        properties          // org.apache.sling.api.resource.ValueMap
        reader              // java.io.BufferedReader
        request             // org.apache.sling.api.SlingHttpServletRequest
        resolver            // org.apache.sling.api.resource.ResourceResolver
        resource            // org.apache.sling.api.resource.Resource
        response            // org.apache.sling.api.SlingHttpServletResponse
        sling               // org.apache.sling.api.scripting.SlingScriptHelper


### Sling Models Use Provider
Loading a Sling Model can be done with the following code:

        <div data-sly-use.model3="org.example.models.Model3">
            ${model3.shine}
        </div>

Depending on the implementation the above code would either load the implementation with the highest service ranking of `Model3` if `org.example.models.Model3` is an interface, or would load the model `org.example.models.Model3` if this is a concrete implementation.

It's important to note that this use provider will only load models that are adaptable from `SlingHttpServletRequest` or `Resource`.

#### Passing parameters

Passed parameters will be made available to the Sling Model as request attributes. Assuming the following markup:

        <div data-sly-use.model3="${'org.example.models.Model3' @ colour='red', path=resource.path}">
            ${model3.shine}
        </div>

the model would retrieve the parameters using the following constructs:

        @Model(adaptables=SlingHttpServletRequest.class)
        public class Model3 {

            @Inject
            private String colour;

            @Inject
            private String path;
        }

### Java Use Provider
The Java Use Provider can be used to load OSGi services, objects exported by bundles or backed by a `Resource`.


#### Resource-backed Java classes
When objects are backed by `Resources` the Java Use Provider will automatically handle the compilation of these classes. The classes' package names should correspond to the path of the backing resource, making sure to replace illegal Java characters with underscores - `_`.

**Example:**
Assuming the following content structure:

        └── apps
            └── my-project
                └── components
                    └── page
                        ├── PageBean.java
                        └── page.html

`page.html` could load `PageBean` either like:

        <!DOCTYPE html>
        <html data-sly-use.page="apps.my_project.components.page.PageBean">
        ...
        </html>

or like:

        <!DOCTYPE html>
        <html data-sly-use.page="PageBean">
        ...
        </html>

The advantage of loading a bean using just the simple class name (e.g. `data-sly-use.page="PageBean"`) is that an inheriting component can overlay the `PageBean.java` file and provide a different logic. In this case the package name of the `PageBean` class will automatically be derived from the calling script's parent path (e.g. `apps.my_project.components.page`) - the bean doesn't even have to specify it. However, keep in mind that loading a bean this way is slower than providing the fully qualified class name, since the provider has to check if there is a backing resource. At the same time, loading an object using its fully qualified class name will not allow overriding it by inheriting components.

#### Passing parameters
Passed parameters will be made available to the Use object as request attributes and, if the object implements the [`org.apache.sling.scripting.sightly.pojo.Use`](https://github.com/apache/sling-org-apache-sling-scripting-sightly-compiler-java/blob/master/src/main/java/org/apache/sling/scripting/sightly/pojo/Use.java) interface, through the `javax.script.Bindings` passed to the `init` method. Assuming the following markup:

        <div data-sly-use.useObject="${'org.example.use.MyUseObject' @ colour='red', year=2016}">
            ${useObject.shine}
        </div>

the object implementing `Use` would be able to retrieve the parameters using the following constructs:

        package org.example.use.MyUseObject;

        import javax.script.Bindings;

        import org.apache.sling.commons.osgi.PropertiesUtil;
        import org.apache.sling.scripting.sightly.pojo.Use;

        public class MyUseObject implements Use {

            private String colour;
            private Integer year;

            public void init(Bindings bindings) {
                colour = PropertiesUtil.toString(bindings.get("colour"), "");
                year = PropertiesUtil.toInteger(bindings.get("year"), Calendar.getInstance().get(Calendar.YEAR));
            }
        }

or, if the object is adaptable from a `SlingHttpServletRequest`, through its `AdapterFactory`:

    package org.example.use;

    import org.apache.felix.scr.annotations.Component;
    import org.apache.felix.scr.annotations.Properties;
    import org.apache.felix.scr.annotations.Property;
    import org.apache.felix.scr.annotations.Service;
    import org.apache.sling.api.SlingHttpServletRequest;
    import org.apache.sling.api.adapter.AdapterFactory;

    @Component
    @Service
    @Properties({
            @Property(
                    name = AdapterFactory.ADAPTABLE_CLASSES,
                    value = {
                            "org.apache.sling.api.SlingHttpServletRequest"
                    }
            ),
            @Property(
                    name = AdapterFactory.ADAPTER_CLASSES,
                    value = {
                            "org.example.use.MyUseObject"
                    }
            )
    })
    public class RequestAdapterFactory implements AdapterFactory {

        @Override
        public <AdapterType> AdapterType getAdapter(Object adaptable, Class<AdapterType> type) {
            if (type == MyUseObject.class && adaptable instanceof SlingHttpServletRequest) {
                SlingHttpServletRequest request = (SlingHttpServletRequest) adaptable;
                String colour = PropertiesUtil.toString(request.getAttribute("colour"), "");
                Integer year = PropertiesUtil.toInteger(request.getAttribute("year"), Calendar.getInstance().get(Calendar.YEAR));
                /*
                 * for the sake of this example we assume that MyUseObject has this constructor
                 */
                return (AdapterType) new MyUseObject(colour, year);
            }
            return null;
        }
    }

### JavaScript Use Provider
The JavaScript Use Provider allows loading objects created through the `use` function, by evaluating scripts passed to `data-sly-use`. The JavaScript files are evaluated server-side by the [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino) scripting engine, through the `org.apache.sling.scripting.javascript` implementation bundle. This allows you to mix JavaScript API with the Java API exported by the platform. For more details about how you can access Java APIs from within JavaScript please check the [Rhino Java Scripting guide](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino/Scripting_Java#Accessing_Java_Packages_and_Classes).

**Example:**
Assuming the following content structure:

        └── apps
            └── my-project
                └── components
                    └── page
                        ├── page.html
                        └── page.js

`page.html` could load `page.js` either like:

        <!DOCTYPE html>
        <html data-sly-use.page="/apps/my-project/components/page/page.js">
        ...
        </html>

or like:

        <!DOCTYPE html>
        <html data-sly-use.page="page.js">
        ...
        </html>

Similar to the Java Use Provider, loading the script using a relative path allows inheriting components to overlay just the Use script, without having to also overlay the calling HTL script.

#### Global Objects
Besides the global objects available to all Use Providers, the JavaScript Use Provider also provides the following global objects available in the context of the `use` function:

    console         // basic wrapper on top of log, but without formatting / throwable support
    exports         // basic Java implementation of CommonJS - http://requirejs.org/docs/commonjs.html
    module          // basic Java implementation of CommonJS - http://requirejs.org/docs/commonjs.html
    setImmediate    // Java implementation of the Node.js setImmediate function
    setTimeout      // Java implementation of the Node.js setTimeout function
    sightly         // the namespace object under which the asynchronous Resource-API implemented by
                    // org.apache.sling.scripting.sightly.js.provider is made available to consumers
    use             // the use function

With the exception of the `console` and `use` objects, all the other global objects implemented by the JavaScript Use Provider are present in order to support the asynchronous Resource-API implemented by `org.apache.sling.scripting.sightly.js.provider`. However, this was deprecated starting with version 1.0.8 - see [SLING-4964](https://issues.apache.org/jira/browse/SLING-4964).

#### Passing parameters
Passed parameters will be made available to the Use object as properties of `this`. Assuming the following markup:

        <div data-sly-use.logic="${'logic.js' @ colour='red', year=2017}">
            My colour is ${logic.colour ? logic.colour : 'not important'} and I'm from ${logic.year}
        </div>

the object would be able to access the parameters like:

        use(function() {
            'use strict';

            var colour = this.colour || '';
            var year = this.year || new Date().getFullYear();

            return {
                colour: colour,
                year: year
            }
        });

#### Caveats

Since these scripts are evaluated server-side, by compiling JavaScript to Java, you need to pay attention when comparing primitive objects using the strict equal operator (`===`) since comparisons between JavaScript and Java objects with the same apparent value will return `false` (this also applies to the strict not-equal operator - `!==`).

Assuming the following HTL script:

        <ol data-sly-use.obj="logic.js" data-sly-list="${obj}">
            <li>
               Code <code>${item.code}</code> evaluates to <code>${item.result}</code>
            </li>
        </ol>

and the following JavaScript file:

        use(function() {

            return [
                {
                    code: 'new java.lang.String("apples") === "apples"',
                    result: new java.lang.String("apples") === "apples"
                },
                {
                    code: 'new java.lang.String("apples") == "apples"',
                    result: new java.lang.String("apples") == "apples"
                },
                {
                    code: 'new java.lang.String("apples") !== "apples"',
                    result: new java.lang.String("apples") !== "apples"
                },
                {
                    code: 'new java.lang.String("apples") != "apples"',
                    result: new java.lang.String("apples") != "apples"
                },
                {
                    code: 'new java.lang.Integer(1) === 1',
                    result: new java.lang.Integer(1) === 1
                },
                {
                    code: 'new java.lang.Integer(1) == 1',
                    result: new java.lang.Integer(1) == 1
                },
                {
                    code: 'new java.lang.Integer(1) !== 1',
                    result: new java.lang.Integer(1) !== 1
                },
                {
                    code: 'new java.lang.Integer(1) != 1',
                    result: new java.lang.Integer(1) != 1
                },
                {
                    code: 'java.lang.Boolean.TRUE === true',
                    result: java.lang.Boolean.TRUE === true
                },
                {
                    code: 'java.lang.Boolean.TRUE == true',
                    result: java.lang.Boolean.TRUE == true
                },
                {
                    code: 'java.lang.Boolean.TRUE !== true',
                    result: java.lang.Boolean.TRUE !== true
                },
                {
                    code: 'java.lang.Boolean.TRUE != true',
                    result: java.lang.Boolean.TRUE != true
                }
            ];
        });

the output would be:

         1. Code new java.lang.String("apples") === "apples" evaluates to false
         2. Code new java.lang.String("apples") == "apples" evaluates to true
         3. Code new java.lang.String("apples") !== "apples" evaluates to true
         4. Code new java.lang.String("apples") != "apples" evaluates to false
         5. Code new java.lang.Integer(1) === 1 evaluates to false
         6. Code new java.lang.Integer(1) == 1 evaluates to true
         7. Code new java.lang.Integer(1) !== 1 evaluates to true
         8. Code new java.lang.Integer(1) != 1 evaluates to false
         9. Code java.lang.Boolean.TRUE === true evaluates to false
        10. Code java.lang.Boolean.TRUE == true evaluates to true
        11. Code java.lang.Boolean.TRUE !== true evaluates to true
        12. Code java.lang.Boolean.TRUE != true evaluates to false

Evaluations of Java objects in JavaScript constructs where the operand is automatically type coerced will work, but Rhino might complain about the Java objects not correctly calling the Rhino helper function `Context.javaToJS()`. In order to avoid these warnings it's better to explicitly perform your comparisons like in the following example:

        if (myObject) {
            ...
        }
        // should be replaced by
        if (myObject != null) {
           ...
        }

        myObject ? 'this' : 'that'
        //should be replaced by
        myObject != null ? 'this' : 'that'


### Script Use Provider
The Script Use Provider allows loading objects evaluated by other script engines available on the platform. The same loading considerations as for the Java and JavaScript Use Providers apply.

### Picking the best Use Provider for a project
The following table summarises the pros and cons for each Use Provider, with the obvious exception of the Render Unit Use Provider.

<table>
  <tr>
   <th>Use Provider</th>
   <th>Advantages</th>
   <th>Disadvantages</th>
  </tr>
  <tr>
    <td>Sling Models Use Provider</td>
    <td><ul><li>convenient injection annotations for data retrieval</li><li>easy to extend from other Sling Models</li><li>simple setup for unit testing</li></ul></td>
    <td><ul><li>lacks flexibility in terms of component overlaying, relying on <code>service.ranking</code> configurations; this was solved for Sling Models 1.3.0 by <a href="https://issues.apache.org/jira/browse/SLING-5992">SLING-5992</a></li></ul></td>
  </tr>
  <tr>
    <td>Java Use Provider</td>
    <td>
      <p>Use-objects provided through bundles:</p>
      <ul>
        <li>faster to initialise and execute than Sling Models for similar code</li>
        <li>easy to extend from other similar Use-objects</li>
        <li>simple setup for unit testing</li>
      </ul>
      <p>Use-objects backed by <code>Resources</code>:</p>
      <ul>
        <li>faster to initialise and execute than Sling Models for similar code</li>
        <li>easy to override from inheriting components through search path overlay or by using the <code>sling:resourceSuperType</code> property, allowing for greater flexibility</li>
        <li>business logic for components sits next to the HTL scripts where the objects are used</li>
      </ul>
    </td>
    <td>
      <p>Use-objects provided through bundles:</p>
      <ul>
        <li>lacks flexibility in terms of component overlaying</li>
      </ul>
      <p>Use-objects backed by <code>Resources</code>:</p>
      <ul>
        <li>cannot extend other Java objects</li>
        <li>the Java project might need a different setup to allow running unit tests, since the objects will be deployed like content</li>
      </ul>
    </td>
  </tr>
  <tr>
  <td>JavaScript Use Provider</td>
  <td>
    <ul>
      <li>allows JavaScript developers to develop component logic</li>
      <li>can be reused through the dependency mechanism provided by the <code>use</code> function</li>
    </ul>
  </td>
  <td>
    <ul>
      <li>harder to test and debug, relying mostly on end-to-end testing and console logging</li>
      <li>slower to execute than both Sling Models and Java Use-API objects</li>
    </ul>
  </td>
  </tr>
  <tr>
    <td>Script Use Provider</td>
    <td>
      <ul>
        <li>allows the usage of Use objects evaluated by other Script Engines available in the platform</li>
      </ul>
    </td>
    <td>
      <ul>
        <li>like in the case of the JavaScript Use Provider, the performance is influenced by the Script Engine's implementation</li>
      </ul>
    </td>
  </tr>
</table>
