title=Sling Pipes Bindings
type=page
status=published
tags=pipes
~~~~~~

in order to make things interesting, most of the configuration strings are expressions 
strings, hence valid JEXL expressions reusing bindings (from configuration, or other pipes). 
They work the same as JS expressions, except you can't add full JS files. 

You can also set whatever scripting engine you want per pipe (including nashorn, rhino, groovy, ...)

## configuration expression

an expression (path, expr, or property name or value in conf tree) can be either a pure string, like `/content/foo/bar`
or `nt:unstructured[title=foo]`. 
But using _static_ expressions like this is rather limited for most of the cases, hence usage of ECMA expressions
like `/content/${one.value}/bar` or more sophisticated using functions `nt:unstructured[title=${getValue(currentField)}]`

In case the expression has an error (bad expression, or undefined variable we'll name `bindings`) non instanciated expression 
will be outputed

## output binding

each single pipe has to declare an output binding at the same time it outputs a resource. The binding will be named as the name
of the pipe outputing it. If a pipe as been created as a sub pipe of a container with pipe builder api, it will have default 
name of "one", "two", ... depending on its position in the pipe, you can override the name with `.name(...)` api. 
 
so following pipe

        echo /content/foo | children nt:unstructured @ name example | write jcr:description='this node property prop = ${example.prop}'
        
with following `/content/foo` tree

        { 
            "jcr:primaryType":"nt:unstructured",
            "firstItem": {
                "prop":"firstVal"
            },
            "firstItem": {
                "prop":"secondVal"
            }
        }

will loop twice on the pipe `example`, making available each time for the following pipes' expressions the default binding `example`,
 which would be a map with one key prop. Accessing it with `{example.prop}` would give you `firstVal` and then `secondVal`.
 So resulting tree will be
  
        { 
            "jcr:primaryType":"nt:unstructured",
            "firstItem": {
                "prop":"firstVal"
                "jcr:description":"this node property prop = firstVal"
            },
            "firstItem": {
                "prop":"secondVal"
                "jcr:description":"this node property prop = secondVal"
            }
        }         

## additional bindings

`additionalBindings` is a [node you add to any pipe definition](/documentation/bundles/sling-pipes/execution-monitoring.html#jcr-persistence-of-a-pipe.html), that
sets its properties as bindings for this pipe's context execution.
you can also add `additionalBindings/providers` children, that should be read-only pipes that will get executed before this pipe
execution, to provide dynamic bindings. 

You can also add some through [pipe builder api](/documentation/bundles/sling-pipes/execution-monitoring.html#pipe-builder-api)
with a map of bindings

        .run(bindings)
        
or with a set of key / value pairs

        .runWith("env", "prod")
        
[http api](/documentation/bundles/sling-pipes/execution-monitoring.html#http-api) for this is a binding parameter
    
        -F bindings='{"env":"prod"}'
        
In case a pipe needs a more dynamic binding, you can use another pipe as binding provider, 
                 
## additional scripts

some times you want heavy js logic in your expression instantiation. In that case, you need to store your javascript somewhere
in the JCR, and mentions the path in the [additionalScripts MV property](/documentation/bundles/sling-pipes/execution-monitoring.html#jcr-persistence-of-a-pipe.html)

## bindings forward

in case a pipe references, or contain another pipe, same binding space will be used

## Context Aware configuration 

there is the possibility to use [context aware configurations](https://sling.apache.org/documentation/bundles/context-aware-configuration/context-aware-configuration.html)
 in the bindings like the following: `caconfig.pipeName.bucket.property` where `pipeName` is a pipe name, bucket & property typical ca configuration accessors.