title=Sling Pipes
type=page
status=published
tags=pipes
~~~~~~

Sling pipes is a tool set for doing extract - transform - load operations by chaining proven code blocks.

## Introduction

Sling Pipes can be seen as a language that optimizes communication between two developers knowing sling terminology, 
just as they would talk about it, e.g.
 
        searching for resources with type "foo/bar" and setting property id to 3
    
Such sentence with that limited amount of words is enough between two sling developers to understand fully what it is 
doing. However, implementing this as a servlet would take a lot more words, risks of failure, complexity of deployement 
and would be more opaque, not talking about monitoring or execution common, but complex features you'd like to add.

With Sling Pipes, what you need to develop, and what is readable by another developer is
 
        plumber.newPipe(resolver).$("[sling:resourceType='foo/bar']").write("id",3).build("/etc/demo")
        
this is enough to persist a pipe in `/etc/demo` that is executable as http, java, groovy console script, or JMX. 
You can make it monitor it with JMX, logs, http, you'll have dry run possibility of that execution for example, or asynchronous execution. 
You could also use a pipe to create a java-free json or csv servlet, or a list component whose list possibilities are pipes accessed through the `PipeModel`   

## What is a pipe

A sling pipe is essentially a sling resource stream, encapsulating a well-known sling operation

- it provides an output as a sling resource iterator,
- it gets its input either from a configured path, either from former pipe's output,
- each pipe can have scripted configuration, accessing bindings from others

Important bits of a pipe are:

- its type, specifying what sling block you will use, through a RT property, or a method depending on what [builder you use](/documentation/bundles/sling-pipes/execution-monitoring.html),
- its `name`, used in logs, JCR persistence, and bindings,
- its input, forced with `path` property, or because the pipe follows another one,
- its optional expression, configured with `expr` property, that means different things depending on the pipe,
- its configuration node, configured with `conf` node, that means different things depending on the pipe

## Get Started

You can [configure and execute a pipe with java, groovy console, http, or jmx](/documentation/bundles/sling-pipes/execution-monitoring.html)
 
To get more familiar with pipes go through the 3 families of pipes to consider and the samples detailed:

- [reader pipes](/documentation/bundles/sling-pipes/readers.html), that will just output a set of resource depending on the input, without modifying anything,
- [writer pipes](/documentation/bundles/sling-pipes/writers.html), that modify the repository, depending on configuration and input,
- [logical pipes](/documentation/bundles/sling-pipes/logical.html), that refer to other pipes, chaining them or using their results in a general way 

Once you've successfully run your first try, you can get into more complicated configuration, making them dynamics with [bindings](/documentation/bundles/sling-pipes/bindings.html)
and have a look at some [other samples](/documentation/bundles/sling-pipes/samples.html) 
## Compatibility
For running this tool on a sling instance you need:

- java 8 (Nashorn is used for expression)
- slingQuery (3.0.0) (used in SlingQueryPipe)
- jackrabbit api (2.7.5+) (used in AuthorizablePipe)
