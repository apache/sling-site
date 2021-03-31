title=Internationalization Support (i18n)		
type=page
status=published
tags=i18n
~~~~~~

Internationalization support in Sling consists of four methods in the `SlingHttpServletRequest` interface:

   * `getLocale()` -- Returns the primary `Locale` for the current request. This method is inherited from the `javax.servlet.ServletRequest` interface.
   * `getLocales()` -- Returns the `Locale` instances for the current request. This method is inherited from the `javax.servlet.ServletRequest` interface.
   * `getResourceBundle(Locale)` -- Returns a `ResourceBundle` for the given `Locale`. This method is specific to Sling.
   * `getResourceBundle(String, Locale)` -- Returns a `ResourceBundle` of a given base name for the given `Locale`. This method is specific to Sling.


These methods have a default implementation in the `org.apache.sling.core` bundle and an extended and extensible implementation in the `org.apache.sling.i18n` bundle.


## Default Implementation in the `org.apache.sling.engine` Bundle

The default implementation of the above mentioned four methods in the Sling Engine bundle is contained in the bundle-private class `org.apache.sling.engine.impl.SlingHttpServletRequestImpl` which is the primary implementation of the `SlingHttpServletRequest` interface:

   * `getLocale()` -- Returns the `Locale` from the request object of the servlet container in which Sling is running. As per the Servlet API specification, this is either the primary Locale of the `Accept-Language` request header or the server default locale.
   * `getLocales()` -- Returns the `Enumeration` from the request object of the servlet container in which Sling is running. As per the Servlet API specification, this is either based on the `Accept-Language` request header or just the server default locale.
   * `getResourceBundle(Locale)` -- Returns a `ResourceBundle` whose `getString(String key)` method returns the `key` as the message and whose `getKeys()` method returns an empty `Enumeration`.
   * `getResourceBundle(String, Locale)` -- Returns a `ResourceBundle` whose `getString(String key)` method returns the `key` as the message and whose `getKeys()` method returns an empty `Enumeration`.


NOTE: Unlike the default implementations of the `ResourceBundle` abstract class in the Java Runtime -- `PropertyResourceBundle` and `ListResourceBundle` -- the `ResourceBundle` returned by the default implementation of the `getResourceBundle(Locale)` and `getResourceBundle(String, Locale)` always returns a string message for any key, which is the key itself. This prevents throwing `MissingResourceException`.



## Extensible Implementation in the `org.apache.sling.i18n` Bundle

The `org.apache.sling.i18n` Bundle implements a request level `Filter` providing extensible implementations of the above mentioned three methods. Extensibility is attained by defining two service interfaces:

   * `LocaleResolver` -- The `LocaleResolver` interface defines a method which may be implemented by a service outside of the sling.i18n bundle. If no such service is registered the default behaviour is as described above for the sling.core bundle. The service described by this interface is used to implement the `getLocale()` and `getLocales()` method. 

   * `ResourceBundleProvider` -- The `ResourceBundleProvider` interface defines two methods to acquire a `ResourceBundle` for any `Locale` and an optional base name. This service interface is not intended to be implemented outside of the sling.i18n bundle: A JCR Repository based implementation is contained in the sling.i18n bundle. The `ResourceBundleProvider` service is not only used within the sling.i18n bundle to implement the `SlingHttpServletRequest.getResourceBundle(Locale)` and  `SlingHttpServletRequest.getResourceBundle(String, Locale)` methods. The service may also be used by Sling applications to acquire `ResourceBundle` instances without having a request object by getting the service and calling its `getResourceBundle(Locale)` or `getResourceBundle(String, Locale)` method directly.



### JCR Repository based `ResourceBundleProvider`

The sling.i18n Bundle provides the implementation of the `ResourceBundleProvider` interface, which may also be used outside of Sling requests for service tasks. This implementation gets the messages from a JCR Repository stored below nodes of the mixin node type `mix:language`. These language nodes have a `jcr:language` property naming the language of the resources. In the context of the JCR based `ResourceBundleProvider` this is of course expected to be the string value of respective `Locale`. The format may either be the format as described in [Locale.toString](http://docs.oracle.com/javase/7/docs/api/java/util/Locale.html#toString%28%29) or as described in [BCP 47](https://tools.ietf.org/html/bcp47), while for the latter you may only provide ISO 3166-1 country codes (for the region) and ISO 639-1 alpha 2 language codes (for the language). Both formats are also accepted in lower-case.

The exact location of these nodes is not relevant as the `ResourceBundleProvider` finds them by applying a JCR search.

Two different types of storage formats are supported for the individual dictionaries

#### `sling:MessageEntry` based

The (direct) child nodes of the `mix:language` node must have the `jcr:primaryType` set to `sling:MessageEntry` and must contain two special properties naming the key string and the message:

   * `sling:key` -- The `sling:key` property is a string property being the key for which the node contains the message(s). This property is optional. If it is not set the key is determined by the name of this `sling:messageEntry` resource.
   * `sling:message` -- The `sling:message` property represents the resource for the key.

It is only required that the message nodes are located below `mix:language` nodes. Such structures may also be scattered in the repository to allow storing message resources next to where they are most likely used, such as request scripts.

##### Sample Resources

Content for dictionaries in this format might look like this:

       /libs/languages
               +-- English (nt:folder, mix:language)
               |    +-- jcr:language = en
               |    +-- m1 (sling:MessageEntry)
               |    |    +-- sling:key = "msg001"
               |    |    +-- sling:message = "This is a message"
               |    +-- m2 (sling:MessageEntry)
               |         +-- sling:key = "msg002"
               |         +-- sling:message = "Another message"
               +-- Deutsch (nt:folder, mix:language)
                    +-- jcr:language = de
                    +-- m1 (sling:MessageEntry)
                    |    +-- sling:key = "msg001"
                    |    +-- sling:message = "Das ist ein Text"
                    +-- m2 (sling:MessageEntry)
                         +-- sling:key = "msg002"
                         +-- sling:message = "Ein anderer Text"
    
       /apps/myApp
               +-- English (nt:folder, mix:language)
               |    +-- jcr:language = en
               |    +-- mx (sling:MessageEntry)
               |         +-- sling:key = "msgXXX"
               |         +-- sling:message = "An Application Text"
               +-- Deutsch (nt:folder, mix:language)
                    +-- jcr:language = de
                    +-- mx (sling:MessageEntry)
                         +-- sling:key = "msgXXX"
                         +-- sling:message = "Ein Anwendungstext"

This content defines two languages *en* and *de* with three messages *msg001*, *msg002* and *msgXXX* each. The names of the respective resources have no significance (in case the `sling:key` is set).

#### JSON-file based

Since Version 2.4.2 the i18n bundle supports dictionaries in JSON-format ([SLING-4543](https://issues.apache.org/jira/browse/SLING-4543)).
Since loading such dictionaries is much faster than loading the ones based on `sling:MessageEntry`s this format should be used preferably.
This format is assumed if the `mix:language` resource name is ending with the extension `.json`.
The parser will take any "key":"value" pair in the JSON file, including those in nested objects or arrays. Normally, a dictionary will be just a single json object = hash map though.

##### Sample Resources

Content for this format might look like this:

       /libs/languages
               +-- english.json (nt:file, mix:language)
               |    +-- jcr:language = en
               |    +-- jcr:content (nt:resource)
               |         + jcr:data (containing the actual JSON file)
               +-- deutsch.json (nt:file, mix:language)
                    +-- jcr:language = de
                    +-- jcr:content (nt:resource)
                        + jcr:data (containing the actual JSON file)


#### JCR Node Types supporting the JCR Repository based `ResourceBundleProvider`

The sling.i18n bundle asserts the following node types:

    [mix:language]
        mixin
      - jcr:language (string)


The `mix:language` mixin node type allows setting the `jcr:language` property required by the `ResourceBundleProvider` implementation to identify the message `Locale`.

    [sling:Message]
        mixin
      - sling:key (string)
      - sling:message (undefined)
    
    [sling:MessageEntry] > nt:hierarchyNode, sling:Message  


The `sling:Message` and `sling:MessageEntry` are helper node types. The latter must be used to create the nodes for the `sling:MessageEntry` based format.

### `ResourceBundle` with base names

Similar to standard Java `ResourceBundle` instances, Sling `ResourceBundle` instances may be created for base names through any of the `getResourceBundle(String, Locale)` methods. These methods use the base name parameter as a selector for the values of the `sling:basename` property of the `mix:language` nodes.

The base name argument can take one three values:

| Value | `ResourceBundle` selection |
|---|---|
| `null` | Selects messages of `mix:language` nodes ignoring the existence or absence of `sling:basename` properties |
| Empty String | Selects messages of `mix:language` nodes which have `sling:basename` properties, ignoring the actual values |
| Any other Value | Selects messages of `mix:language` nodes whose `sling:basename` properties has any value which matches the base name string |

The `sling:basename` property may be multi-valued, that is the messages of a `mix:language` nodes may belong to multiple base names and thus `ResourceBundle` instances.

### `ResourceBundle` hierarchies
The dictionary entries for one `JcrResourceBundle` are always ordered like the resource resolver search paths, so usually

   1. dictionary entries below `/apps`
   2. dictionary entries below `/libs`
   3. dictionary entries anywhere else (outside the search path)

That means that the message for the same key in `/apps` overwrites the one in `/libs` (if both are for the same locale and base name). Within those categories the order is non-deterministic, so if there is more than one entry for the same key in `/apps/...` (for the same locale and base name), any of those entries may be used.

The resource bundles of the same base name with different locales also form a hierarchy. Each key is looked up recursively first in the current resource bundle and then in its parent resource bundle. The parent resource bundle is the one having the same base name but the parent locale.

The locale hierarchy is ordered like this:

1. `<Language> <Country> <Variant>`
2. `<Language> <Country>`
3. `<Language>`
4. `<Default Locale>`, usually `en`

So for the locale `de-DE-MAC` the fallback order would be

1. `de-DE-MAC`
2. `de-DE`
3. `de`
4. `en`

In case there is a resource bundle requested for a locale without country or variant, there is only 1 fallback (i.e. the default locale).
The last resort (root resource bundle in all hierarchies) is always the bundle which returns the requested key as the value.

#### Locate non JCR based ResourceBundle resources

Since version 2.5.16 the i18n bundle supports locating ResourceBundle resources that exist outside of the JCR repository.  A new osgi.extender technique can be utilized so that a bundle can declare certain paths that should be traversed to locate ResourceBundle resources.

For example, the bundle providing the ResourceBundle resources can define something like this:

    Require-Capability: osgi.extender;filter:="(&(osgi.extender=org.apache.sling.i18n.resourcebundle.locator.registrar)(version<=1.0.0)(!(version>=2.0.0)))"
    
    Provide-Capability: org.apache.sling.i18n.resourcebundle.locator;paths="/libs/i18n/path123";depth=1

The "Provide-Capability" instruction defines which (csv) resource paths to traverse via the "paths" clause and how deep to drill down via the optional "depth" clause (depth=1 by default) looking for candidates.

