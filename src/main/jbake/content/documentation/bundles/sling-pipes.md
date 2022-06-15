title=Sling Pipes
type=page
status=published
tags=pipes
~~~~~~

Sling pipes is a tool set for doing extract - transform - load operations by chaining proven code blocks.

## Introduction

Sling Pipes can be seen as a language that takes profit of optimized communication between two developers knowing sling terminology, 
e.g.
 
        searching for resources with type "foo/bar" and setting property id to 3
    
Such sentence with that limited amount of words is enough between two sling developers to understand fully what it is 
doing. However, implementing that change with a computer language directly will take much more words, risks of failure, 
complexity of deployement and would be more opaque, not talking about monitoring or execution commons, but complex 
features you'd like to add.

With Sling Pipes, what you need to develop, and what is readable by another developer is
 
        plumber.newPipe(resolver).echo("content").$("foo/bar").write("id",3).build("/etc/demo")
        
this is enough to persist a pipe in `/etc/demo` that is executable as http, java, groovy console script, or JMX. 
You can monitor it with JMX, logs, http, you'll have dry run possibility of that execution for example, or asynchronous execution.
If it's a one-off execution, and you can access a groovy script or anything you can use external command line tool like [pipe](https://github.com/adobe/adobe-dx/blob/master/apps/scripts/pipe) 
to run 

        pipe "echo /content | $ foo/bar | write id=3"  
        
Those examples are using echo, find and [write](/documentation/bundles/sling-pipes/writers.html#write-pipe-writeconf) subpipes.
        
You could also use a pipe to create a java-free json or csv servlet, or a list component whose list possibilities are pipes accessed through the `PipeModel`
you can check some introductions at different adaptTo presentations:

### AdaptTo introductions

some presentations were made at the adaptTo conference, last three were:
[latest presentation at a 2021 lightning talk](https://adapt.to/2020/en/schedule/lightning-talks/sling-pipes-400-update.html). This introduces 
the change of being able to manipulate pipes through command line.
<iframe width="560" height="415" src="https://www.youtube.com/embed/Z5UtXh9XzwY" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

[General introduction at a 2017 lightning talk](https://adapt.to/2017/en/schedule/lightning-talks/apache-sling-pipes.html).

<iframe width="560" height="415" src="https://www.youtube.com/embed/XcWMB26bMxA?start=666" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

and [latest news at a 2018 lightning talk](https://adapt.to/2018/en/schedule/lightning-talks/whats-new-with-filters-pipes.html)

<iframe width="560" height="415" src="https://www.youtube.com/embed/LhxVE-56p2Y?start=122" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>   

## Get Started

You can either use it with [adobe's scripts](https://github.com/adobe/adobe-dx/blob/master/apps/scripts) or just [configure and execute a pipe with java, groovy console, http, or jmx](/documentation/bundles/sling-pipes/execution-monitoring.html)
 
To get more familiar with pipes go through the 3 families of pipes to consider and the samples detailed:

- [reader pipes](/documentation/bundles/sling-pipes/readers.html), that will just output a set of resource depending on the input, without modifying anything,
- [writer pipes](/documentation/bundles/sling-pipes/writers.html), that modify the repository, depending on configuration and input,
- [logical pipes](/documentation/bundles/sling-pipes/logical.html), that refer to other pipes, chaining them or using their results in a general way 

Once you've successfully run your first try, you can get into more complicated configuration, making them dynamics with [bindings](/documentation/bundles/sling-pipes/bindings.html)
and have a look at some [other samples](/documentation/bundles/sling-pipes/samples.html) 
## Compatibility
For running this tool on a sling instance you need:

- java 8 (Nashorn is used for expression) for version < 4.0.0, for 4.0.0+ you are good with upper java versions
- slingQuery (3.0.0) (used in SlingQueryPipe)
- jackrabbit api (2.7.5+) (used in AuthorizablePipe)
