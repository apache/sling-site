title=Logical Pipes
type=page
status=published
tags=pipes
~~~~~~
Those pipes help assembling pipes, or modifying the resource streams 
[readers](/documentation/bundles/sling-pipes/readers.html) or [writers](/documentation/bundles/sling-pipes/writers.html)
could create.


### Super pipes
Pipes that litterally contains sub pipes

#### Container Pipe
assemble a simple sequence of pipes

- `sling:resourceType` is `slingPipes/container`
- `conf` node contains child pipes' configurations, that will be configured in the order they are found (note you should use sling:OrderedFolder)

Note that pipe builder api automatically creates one for you to chain the subpipe you are configuring.

#### ReferencePipe (`ref(path)`)
executes the pipe referenced in path property

- `sling:resourceType` is `slingPipes/reference`
- `path` path of the referenced pipe

#### Manifold
allows parallel execution of the sub pipes listed in configuration

- `sling:resourceType` is `slingPipes/filter`
- `conf` node contains child pipes' configurations, that will be configured in the order they are found (note you should use sling:OrderedFolder)
- `queueSize` size of the merged resource queue,
- `numThread` thread pool size for the execution of the subpipes
- `executionTimeout` execution time out for each sub pipe

### FilterPipe (`grep(conf)`)
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

### NotPipe
executes the pipe referenced in path property, passes input only if referenced pipe doesn't return any resource

- `sling:resourceType` is `slingPipes/not`
- `path` path of the referenced pipe
