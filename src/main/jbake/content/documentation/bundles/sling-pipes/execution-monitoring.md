title=Sling Pipes Configuration, Execution and monitoring
type=page
status=published
tags=pipes
~~~~~~

### JCR persistence of a pipe

A pipe configuration is ultimately a jcr node, with properties (varying a lot depending on the pipe type):

| Configuration node property | Explanation |
|---|---|
| `sling:resourceType` | which must be a pipe type registered by the plumber | 
| `name` | that will be used in bindings as an id, and will be the key for the output bindings (default value being a value map of the current output resource). Note that the node name will be used in case no name is provided. |
| `path` | defines pipe's input. Note that property is not mandatory in case the pipe is streamed after another pipe, in which case previous pipe output's can be used as input. |
| `expr` | expression through which the pipe will execute (depending on the type) |
| `additionalScripts` | multi value property to declare scripts that can be reused in [expressions](/documentation/bundles/sling-pipes/bindings.html) |

| Configuration child node | Explanation |
|---|---|
| `conf` | optional, contains addition configuration of the pipe (depending on the type) |
| `additionalBinding`  | set "global" [bindings](/documentation/bundles/sling-pipes/bindings.html) (property=value) in pipe execution |
| `writer` | set a writer with key / value property being label, and value of each added entry. Those values can be [expressions](/documentation/bundles/sling-pipes/bindings.html) | 

### Java

`Plumber` is an osgi service you can access that will help you registering a pipe (must implement Pipe interface, and would better extend BasePipe class),
and get a pipe from a resource (assuming you have a [pipe configuration JCR](/documentation/bundles/sling-pipes/execution-monitoring.html#jcr-persistence-of-a-pipe) tree already set)

        Pipe pipe = plumber.getPipe(resource);
        
Once the pipe is obtained, you can just iterate through the output of it by retrieving it's output

        Iterator<Resource> outputResources = pipe.getOutput();
        
Be aware that if the pipe is modifying content, you might need to save it.

You can encapsulate the whole execution of a pipe through the `execute` methods that are used internally by both Pipe Builder and HTTP APIs.  

### Pipe Builder API

Plumber osgi service provides PipeBuilder with `newPipe(ResourceResolver resolver)` API, that gives a fluent API to quickly configure and run pipes.
e.g. 

    plumber.newPipe(resolver).xpath("//element(*,nt:unstructured)[@sling:resourceType='to/delete']").rm().run();

will search for resource of type `to/delete` and remove them.

PipeBuilder will configure a container pipe, chaining pipes you can configure with a fluent API. 
This works pretty well with a groovy console just by entering following set of instruction

         def plumber = getService("org.apache.sling.pipes.Plumber");
         
         plumber.newPipe(resourceResolver)
             .echo("/content/mySite")
             .run();
 
 
| Pipe Builder Method | Explanation |
|---|---|
| `pipe(type)` | generate a new subpipe |
| `with(Object...)` | add to actual subpipe configuration node key/value configurations |
| `expr(String)` | add an `expr` configuration |
| `path(String)` | add an `path` configuration |
| `name(String)` | specify a name (there would be a default one, named 'one', 'two', ... depending on the position otherwise), that will be use in the persistence and bindings |
| `conf(Object...)` | add an extra configuration node with key/value properties/values |

note that that configuration part has shortcuts for some pipes. Typically, above sample is a shorter equivalent of 

        plumber.newPipe(resolver)
            .pipe('slingPipes/xpath').expr("//element(*,nt:unstructured)[@sling:resourceType='to/delete']")
            .pipe('slingPipes/rm').run();

when available, shortcuts will be specified next to each pipe type documentation, for

- [reader pipes](/documentation/bundles/sling-pipes/readers.html), that will just output a set of resource depending on the input, without modifying anything,
- [writer pipes](/documentation/bundles/sling-pipes/writers.html), that modify the repository, depending on configuration and input,
- [logical pipes](/documentation/bundles/sling-pipes/logical.html), that refer to other pipes, chaining them or using their results in a general way 

Once you are happy with the pipe you have created, you should terminate the builder with following commands

| Pipe Builder Method | Explanation |
|---|---|
| `outputs(keys...)` | set the keys you want as an output |
| `build(path)` | builds the requested pipe at the given `path` location |
| `build()` | will build the pipe under /var/pipes/... (random node under timed base path) |
| `run(bindings)` or `runWith(bindings...)` | will build the pipe in random location, and run it with passed bindings |
| `runAsync(bindings)` | will do the same, but asynchronously |

### Apache Felix Gogo

when installing pipes bundle, [apache felix gogo](http://felix.apache.org/documentation/subprojects/apache-felix-gogo.html) commands are exposed to the console that allow you to
- build (pipe:build or just build if no other command) 
- run (pipe:run or just run if no other command)
- execute (pipe:execute or just execute if no other command)
- and print help on how to use the above

the pipe is here represented as `/` character as `|` is already used by gogo console, an heavy usage of the gogo console is made in the [main page videos](http://localhost:8820/documentation/bundles/sling-pipes.html#adaptto-introductions), or you can direcly check 
in there for sample gogo commands for [99 bottles of beer](https://github.com/npeltier/99-bottles-of-beers-with-sling) sample.

### HTTP API

#### Build & Run Pipe from command line

now you can run same commands as gogo commands directly from your command line tool, using either 
pipe_cmd parameter and `echo /content | write child/foo=bar` value. Either you can use `pipe_cmdfile` with several 
pipes in there. In that case `cmd_line_N` where `N` is the nth effective pipe of your script is a binding added
with the corresponding pipe path (useful for using reference pipes).  

#### Pipe HTTP Request bits 
If the pipe already exists in your repository you can run it following up below constraints 

| request bit | Explanation |
|---|---|
| request path | path of a pipe configuration resource (see above), or a resource of type `slingPipes/plumber` with a path parameter indicating the pipe configuration resource path.|
| request method | `GET` or `POST`. Note that `GET` will not work on pipe modifying content (unless you are using a `dryRun`) |
| request extension | `.json` or `.csv` |
| request selectors | you can add `status` to get status on a currently executed pipe|

##### Pipe HTTP Request parameter

| request parameter | Explanation |
|---|---|
| `size` | size of the returned excerpt. Default response is truncated to 10 items, if you need more (or less), you can modify that settings with the size parameter. 0 value will return all the items |
| `binding` | json object of global bindings you want to add for the execution of the pipe e.g. `{testBinding:'foo'}` |
| `writer` | you can configure output of your servlet, with `writer` parameter, a json object as a pattern to the result you want to have. The values of the json object are expressions and can reuse each pipe's subpipe binding. This will be entries of your json output, or headers and values of your csv output, e.g `{"user":"${user.fullName}"}` |
| `dryRun=true` | if parameter dryRun is set to true, and the executed pipe is supposed to modify content, it will log (at best it can) the change it *would* have done, without doing anything |              
| `async=true` | allow asynchronous execution of the given type. This is advised in case you plan your pipe execution to last longer than the session of your HTTP client. If used, the returned value will be id of the created sling Job. In that case you can monitor the pipes path with `status` selector as described above until it has the value `finished`. |

### PipeModel

a [Sling Model](/documentation/bundles/models.html) is shipped with sling pipes bundle that allows you to add a set of pipes to a component instance. 

A typical usage would be to have some list pipes stored e.g. under `/etc/pipes/navigation-lists` and then  

a component instance would be

        {
            "jcr:primaryType":"nt:unstructured",
            "sling:resourceType":"my/navigation/breadcrumb",
            "pipes": {
                "jcr:primaryType":"nt:unstructured",
                "breadcrumb": {
                    "jcr:primaryType":"nt:unstructured",
                    "sling:resourceType":"slingPipes/reference"
                    "expr":"/etc/pipes/navigation-lists/breadcrumb"
                }
            }
        }

and then the sightly script for "/apps/my/navigation/breadcrumb" could look like 

            <ol class="breadcrumb"
                     data-sly-use.pipe="org.apache.sling.pipes.models.PipeModel"
                     data-sly-list.nav="${pipe.outputs.breadcrumb}">
                <sly data-sly-resource="${breadcrumb.path}"></sly>
            </ol>
            
This allows not to have to write a new model or POJO for each component you do, if all you need is a set of resources.
A very similar exemple is in action in the [PipeModel integration test](https://github.com/apache/sling-org-apache-sling-pipes/blob/master/src/test/java/org/apache/sling/pipes/it/PipeModelIT.java)

Note that a specific [binding](/documentation/bundles/sling-pipes/bindings.html), `currentResource` is added to each pipes executed by the model, allowing pipes to 
be executed in the context of the component.

so a breadcrumb pipe could be something like

        .echo('${path.currentResource}')
        .parents("my:PageContent[showInNav=true]")
        .parent("my:Page")  
            
### JMX

as soon as you add `monitored=true` flag to a pipe configuration, you'll make the given pipe monitored by JMX, giving stats, status, and an entry point
to execute it. Note that if you don't see the pipe you just added, you might have to refresh monitored pipes by hitting the related button
in plumber mbean.