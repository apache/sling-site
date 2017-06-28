title=Integrating Scripting Languages
type=page
status=published
~~~~~~

This page should be extended with more concrete and detailed information. For now, we have the following information:

* There will be a talk at ApacheCon US 08 in New Orleans about creating JSR-223 ScriptEngineFactory and ScriptEngine implementaitons as well as how to integrate such implementations with Sling.
* From a mail on the mailing list, this is a very condensed how-to:
      * Create the ScriptEngineFactory implementation
      * Create a bundle comprising the above implementation as well as the script language implementation.
      * Create the `META-INF/services/javax.script.ScriptEngineFactory` file listing the fully qualified name of your ScriptEngineFactory implementaiton

