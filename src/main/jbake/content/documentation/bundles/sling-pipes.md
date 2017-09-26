title=Sling Pipes		
type=page
status=published
~~~~~~

tool set for doing extract - transform - load operations by chaining proven code bits.

often one-shot data transformations need sample code to be written & executed. This tiny tool set intends to provide ability to do such transformations with proven & reusable blocks called pipes, streaming resources from one to the other.

## What is a pipe

             getOutputBinding

                   ^
                   |
     getInput  +---+---+   getOutput
               |       |
          +----> Pipe  +---->
               |       |
               +-------+

A sling pipe is essentially a sling resource stream:

- it provides an output as a sling resource iterator,
- it gets its input either from a configured path, either from former pipe's output,
- each pipe can have contextual inputs using any other pipe's bindings, and outputting its own bindings

At this moment, there are 3 types of pipes to consider:

- "reader" pipes, that will just output a set of resource depending on the input
- "writer" pipes, that modify the repository, depending on configuration and input
- "container" pipes, that contains pipes, and whose job is to chain their execution : input is the input of their first pipe,
 output is the output of the last pipe it contains.

A `Plumber` osgi service is provided to help getting, building & executing pipes.

## How to configure & execute a pipe

A pipe configuration is ultimately a jcr node, with properties (varying a lot depending on the pipe type):

- `sling:resourceType` property, which must be a pipe type registered by the plumber 
- `name` property, that will be used in bindings as an id, and will be the key for the output bindings (default value being a value map of the current output resource). Note that the node name will be used in case no name is provided.
- `path` property, defines pipe's input. Note that property is not mandatory in case the pipe is streamed after another pipe, in which case previous pipe output's can be used as input.
- `expr` property, expression through which the pipe will execute (depending on the type)
- `additionalBinding` is a node you can add to set "global" bindings (property=value) in pipe execution
- `additionalScripts` is a multi value property to declare scripts that can be reused in expressions
- `conf` optional child node that contains addition configuration of the pipe (depending on the type)

This configuration can be generated quickly through Pipe Builder API.

Once configuration is done, it's possible to execute Pipes 

- through plain java, with configured pipe resource as parameter,
- through PipeBuilder API,
- through HTTP API with GET (read) or POST (read/write) methods against configured pipe resource

### Pipe Builder API
Plumber can provider a PipeBuilder with `newPipe(ResourceResolver resolver)` API, that gives a fluent 
API to quickly configure and run pipes.
e.g. 

    plumber.newPipe(resolver).xpath('//element(*,nt:unstructured)[@sling:resourceType='to/delete']").rm().run();

will search for resource of type `to/delete` and remove them.

PipeBuilder basically will automatically configure a container pipe, chaining pipes you can configure
 with a fluent API:

- `pipe(type)` generate a new subpipe,
- `with(Object...)` add to actual subpipe configuration node key/value configurations,
- `expr(String)` add an expression configuration
- `path(String)` add an input path,
- `name(String)` specify a name (there would be a default one, named 'one', 'two', ... depending on the position otherwise),
- `conf(Object...)` add an extra configuration node with key/value properties/values

note that that configuration part has shortcuts for some pipes. Typically, above sample is a shorter equivalent of 

    plumber.newPipe(resolver).pipe('slingPipes/xpath').expr('//element(*,nt:unstructured)[@sling:resourceType='to/delete']").pipe('slingPipes/rm').run();

when available, shortcuts will be specified next to each pipe type documentation.

Once you are happy with the pipe you have created, you can terminate the builder with following command:

- `build()` will build the pipe under /var/pipes/... (random node under timed base path),
- `run(bindings)` will build the pipe, and run it with additional `bindings`,
- `runAsync(bindings)` will do the same, but asynchronously,
- `run()` will build & run synchronously the pipe, with no bindings. 

### HTTP API
##### Request Path

- either you'll need to create a slingPipes/plumber resource, say `etc/pipes` and then to execute

    curl -u admin:admin -F "path=/etc/pipes/mySamplePipe" http://localhost:8080/etc/pipes.json

- either you execute the request directly on the pipe Path, e.g.

    curl -u admin:admin http://localhost:8080/etc/pipes/mySamplePipe.json

which will return you the path of the resources that have been through the output of the configured pipe.

In the eventuality of a long execution (synchronous or asynchronous), you can retrieve the status of a pipe, by executing

    GET /etc/pipes/mySamplePipe.status.json

##### Request Parameter `binding`

you can add as `bindings` parameter a json object of global bindings you want to add for the execution of the pipe

e.g.


    curl -u admin:admin -F "path=/etc/pipes/test" -F "bindings={testBinding:'foo'}" http://localhost:4502/etc/pipes.json


will returns something like

    {"size":2, "items":["/one/output/resource", "another/one"]}

##### Request Parameter `writer`

you can configure output of your servlet, with `writer` parameter, a json object as a pattern to the result you want to have. The values of the json
object are expressions and can reuse each pipe's subpipe binding. 

e.g.

    curl -u admin:admin http://localhost:4502/etc/pipes/users.json?writer={"user":"${user.fullName}"}

will returns something similar to

    {"size":2, "items":[{'user':'John Smith','path':'/home/users/q/q123jk1UAZS'},{'user':'John Doe','path':'/home/users/q/q153jk1UAZS'}]}

##### Request Parameter `dryRun`
if parameter dryRun is set to true, and the executed pipe is supposed to modify content, it will log (at best it can) the change it *would* have done, without doing anything

##### Request Parameter `size`
default response is truncated to 10 items, if you need more (or less), you can modify that settings with the size parameter

##### Request Parameter `async`
allow asynchronous execution of the given type. This is advised in case you plan your pipe execution to last longer than the session of your HTTP client.
If used, the returned value will be id of the created sling Job.
In that case you can monitor the pipes path with `status` selector as described above until it has the value `finished`.

## Registered Pipes

### readers

##### Base pipe `echo(path)`
outputs what is in input (so what is configured in path)

- `sling:resourceType` is `slingPipes/base`

##### SlingQuery Pipe (`$(expr)`)
executes $(getInput()).children(expression)

- `sling:resourceType` is `slingPipes/slingQuery`
- `expr` mandatory property, contains slingQuery expression through which getInput()'s children will be computed to getOutput()

##### MultiPropertyPipe
iterates through values of input multi value property and write them to bindings

- `sling:resourceType` is `slingPipes/multiProperty`
- `path` should be the path of a mv property

##### XPathPipe (`xpath(expr)`)
retrieve resources resulting of an xpath query

- `sling:resourceType` is `slingPipes/xpath`
- `expr` should be a valid xpath query

##### TraversePipe (`traverse()`)
traverse current input resource's tree, outputing, as resources, either the node of the tree, either its properties

- `sling:resourceType` is `slingPipes/traverse`,
- `breadthFirst` the tree visit will be done deep first, unless this flag is set to true,
- `depth` max depth the visit should go to,
- `properties` is a flag mentioning the pipe should traverse node's property,
- `nameGlobs` filters the property that should get outputed

##### JsonPipe (`json(expr)`)
feeds bindings with remote json

- `sling:resourceType` is `slingPipes/json`
- `expr` mandatory property contains url that will be called, the json be sent to the output bindings, getOutput = getInput.
An empty url or a failing url will block the pipe at that given place.

In case the json is an array, the pipe will loop over
the array elements, and output each one in the binding. Output resource remains each time the input one.

##### AuthorizablePipe (`auth(conf)`)
retrieve authorizable resource corresponding to the id passed in expression, or if not found (or void expression),
from the input path, output the found authorizable's resource

- `sling:resourceType` is `slingPipes/authorizable`
- `expr` should be an authorizable id, or void (but then input should be an authorizable)
- `autoCreateGroup` (boolean) if autorizable id is here, but the authorizable not present, then create group with given id (in that case, considered as a write pipe)
- `addMembers` (stringified json array) if authorizable is a group, add instanciated members to it (in that case, considered as a write pipe)
- `addToGroup` (expression) add found authorizable to instanciated group (in that case, considered as a write pipe)
- `bindMembers` (boolean) if found authorizable is a group, bind the members (in that case, considered as a write pipe)

##### ParentPipe (`parent()`)
outputs the parent resource of input resource

- `sling:resourceType` is `slingPipes/parent`

##### FilterPipe (`grep(conf)`)
outputs the input resource if its matches its configuration

- `sling:resourceType` is `slingPipes/filter`
- `conf` node tree that will be tested against the current input of the pipe, each `/conf/sub@prop=value` will triggers a test
on `./sub@prop` property of the current input, testing if its value matches `value` regex. If the special `slingPipesFilter_noChildren=${true}`
property is there with the value instantiated as a true boolean, then filter will pass if corresponding node has no children.
- `slingPipesFilter_test='${...}'` evaluates the property value, and filters out the stream if the expression is not a boolean or false
- `slingPipesFilter_not='true'` inverts the expected result of the filter


as an example,

    echo('/content/foo').grep('foo','bar','slingPipesFilter_not',true).run()

will either return `/content/foo` either nothing depending on it
not containing `@foo=bar`

    echo('content/foo').name('FOO').grep('slingPipesFilter_test','${FOO.foo == "bar"}').run()

is an equivalent

### containers
##### Container Pipe
assemble a sequence of pipes

- `sling:resourceType` is `slingPipes/container`
- `conf` node contains child pipes' configurations, that will be configured in the order they are found (note you should use sling:OrderedFolder)

Note that pipe builder api automatically creates one for you to chain the subpipe you are configuring

##### ReferencePipe
execute the pipe referenced in path property

- `sling:resourceType` is `slingPipes/reference`
- `path` path of the referenced pipe

### writers

##### Write Pipe (`write(conf)`)
writes given nodes & properties to current input

- `sling:resourceType` is `slingPipes/write`
- `conf` node tree that will be copied to the current input of the pipe, each property's
names and value will be written to the input resource. Input resource will be outputed.
Note that properties that will be evaluated (in an expression) as `null` for a given input resource will be
removed from it. E.g. `./conf/some/node@prop=${null}` will add `./conf/some/node` structure
if not in current input resource, but remove its `prop` property if any).

e.g. `echo('/content/foo').write('foo','bar').run()` will write `@foo=bar` in `/content/foo`


##### MovePipe (`mv(expr)`)
JCR move of current input to target path (can be a node or a property)

- `sling:resourceType` is `slingPipes/mv`
- `expr` full target path, note that parent path must exists

##### RemovePipe (`rm()`)
removes the input resource, returns the parent, regardless of the resource being a node, or
a property

- `sling:resourceType` is `slingPipes/rm`
- `conf` node tree that will be used to filter relative properties & subtrees to the current resource to remove.
A subnode is considered to be removed if it has no property configured, nore any child.

##### PathPipe (`mkdir(expr)`)
get or create path given in expression

- `sling:resourceType` is `slingPipes/path`
- `nodeType` node type of the intermediate nodes to create
- `autosave` should save at each creation (will make things slow, but sometimes you don't have choice)

## Making configuration dynamic with pipe bindings
in order to make things interesting, most of the configurations are javascript template strings, hence valid js expressions reusing bindings (from configuration, or other pipes).

Following configurations are evaluated:

- `path`
- `expr`
- name/value of each property of some pipes (write, remove)

you can use name of previous pipes in the pipe container, or the special binding `path`, where `path.previousPipe` 
is the path of the current resource of previous pipe named `previousPipe`

global bindings can be set at pipe execution, external scripts can be added to the execution as well (see pipe
 configurations)

## sample configurations

##### slingQuery | write
write repository user prefix Ms/Mr depending on gender

      plumber.newPipe(resolver).xpath('/jcr:root/home/users//element(*,rep:Users)')
      .$('nt:unstructured#profile')
      .write("fullName","${(profile.gender === 'female' ? 'Ms ' + profile.fullName : 'Mr ' + profile.fullName)}")
      .run()

##### slingQuery | multiProperty | authorizable | write
move badge<->user relation ship from badge->users MV property to a user->badges MV property

     plumber.newPipe(resolver).echo('/etc/badges/jcr:content/par')
     .$('[sling:resourceType=myApp/components/badge]').name('badge')
     .pipe('slingPipes/multiProperty').path('${path.badge}/profiles').name('profile')
     .auth('${profile}').name('user')
     .echo('${path.user}/profile')
     .write('badges','+[${path.badge}]')
     .run()


##### echo | $ | $ | echo | json | write
this use case is for completing repository website with external system's data (that has an json api),
it does 

- loop over "my:Page" country/language tree under `/content/mySite`, 
- fetch json with contextual parameter that must be in upper case, 
- and write part of the returned json in the current resource. 

This pipe is run asynchronously in case the execution takes long.

 

    plumber.newPipe(resolver)
     .echo("/content/mySite")
     .$('my:Page')
     .$('my:Page').name("localePage")
     .echo('${path.localePage}/jcr:content').name("content")
     .json('https://www.external.com/api/${content.country.toUpperCase()}.json.name('api')
     .write('cachedValue','${api.remoteJsonValueWeWant}')
     .runAsync(null)


##### xpath | parent | rm

- query all user profile nodes with bad properties,
- get the parent node (user node)
- remove it

    plumber.newPipe(resolver)
    .xpath("/jcr:root/home/users//element(profile,nt:unstructured)[@bad]")
    .parent().rm().run()

some other samples are in https://github.com/npeltier/sling-pipes/tree/master/src/test/

# Compatibility
For running this tool on a sling instance you need:

- java 8 (Nashorn is used for expression)
- slingQuery (3.0.0) (used in SlingQueryPipe)
- jackrabbit api (2.7.5+) (used in AuthorizablePipe)
