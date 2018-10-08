title=Readers Pipes
type=page
status=published
tags=pipes,slingquery
~~~~~~

those are pipes that will spit out resources, without modifying them. They are usually combined with [logical](/documentation/bundles/sling-pipes/logical.html) 
and/or [write](/documentation/bundles/sling-pipes/writers.html) pipes

### Base pipe (`echo(path)`)
outputs what is in input (so what is configured in path).

- `sling:resourceType` is `slingPipes/base`

It's handy to set the input
of a given sequence in a talkative manner:

        echo('/content/foo')
        .write('bar',true)
    
is easier to read, more obvious also than

        write('bar',true).with('path','/content/foo')

### XPathPipe (`xpath(expr)`)
retrieve resources resulting of an xpath query

- `sling:resourceType` is `slingPipes/xpath`
- `expr` should be a valid xpath query
    
        xpath('/jcr:root/content/foo//element(*,nt:unstructured)[@sling:resourceType="foo/bar"]')
        .write('foo','bar')
    
### TraversePipe (`traverse()`)
traverse current input resource's tree, outputing, as resources, either the node of the tree, either its properties

- `sling:resourceType` is `slingPipes/traverse`,
- `breadthFirst` the tree visit will be done deep first, unless this flag is set to true,
- `depth` max depth the visit should go to,
- `properties` is a flag mentioning the pipe should traverse node's property,
- `nameGlobs` filters the property that should get outputed

### MultiPropertyPipe
iterates through values of input multi value property and write them to bindings

- `sling:resourceType` is `slingPipes/multiProperty`
- `path` should be the path of a mv property (if no input)

## Sling Query Pipes

Sling Query shares with Sling Pipes the same objective to write more concise (and efficient) code for
most common operations.
Below are the most common [Sling Query](/documentation/bundles/sling-query.html) methods as reader pipes.

### Find Pipe (`$(expr)`)
executes [find](/documentation/bundles/sling-query/methods.html#findselector)(expression) that searches through the subtree below the current input resource

- `sling:resourceType` is `slingPipes/find`
- `expr` mandatory property, contains Sling Query [selector string](/documentation/bundles/sling-query/selectors.html)

        echo("/content/foo")
        .$("nt:unstructured[sling:resourceType=foo/bar]")
        .write('foo','bar')

### Children Pipe (`children(expr)`)
executes [children](/documentation/bundles/sling-query/methods.html#childrenselector)(expression) that searches through the immediate children of the current input resource)

- `sling:resourceType` is `slingPipes/children`
- `expr` mandatory property, contains Sling Query [selector string](/documentation/bundles/sling-query/selectors.html)

### Siblings Pipe (`siblings(expr)`)
executes [siblings](/documentation/bundles/sling-query/methods.html#siblings-selector-)(expression) that searches through siblings of current input resource

- `sling:resourceType` is `slingPipes/slingQuery`
- `expr` mandatory property, contains Sling Query [selector string](/documentation/bundles/sling-query/selectors.html)

### Parent Pipe (`parent()`)
executes [parent](/documentation/bundles/sling-query/methods.html#parent-)() that retrieves current parent

- `sling:resourceType` is `slingPipes/parent`

### Closest Pipe (`closest(expr)`)
executes [closest](/documentation/bundles/sling-query/methods.html#closest-selector-)(expression) that searches the closest parent resource of current input resource

- `sling:resourceType` is `slingPipes/slingQuery`
- `expr` mandatory property, contains Sling Query [selector string](/documentation/bundles/sling-query/selectors.html)

        .$("nt:unstructured[sling:resourceType=foo/bar]")
        .closest('jcr:content')
        
will find `jcr:content` nodes that have `foo/bar` typed resource somewhere in their tree

### Parents Pipe (`parents(expr)`)
executes [parents](/documentation/bundles/sling-query/methods.html#parents-selector-)(expression) that searches all the parents of the current input resource

- `sling:resourceType` is `slingPipes/slingQuery`
- `expr` mandatory property, contains Sling Query [selector string](/documentation/bundles/sling-query/selectors.html)

## InputStream reader pipes

those are specific reader pipes, that read information an input stream from defined in expr configuration,
that can be:

- a remote located file (starting with http),
- a file located in the repository (existing file stored in the repository),
- a file passed as request parameter with `pipes_inputFile` as parameter name (in that case, expr can be empty)
- direct data stream in the expression

### JsonPipe (`json(expr)`)
feeds bindings with json stream

- `sling:resourceType` is `slingPipes/json`
- `expr` see above
- `valuePath` json path like expression that defines where the json value we care about is. E.g. `$.items[2]` considers root is an object and that we want the 3rd item of items array, located at `items` key of the root object.

In case the json value is an array, the pipe will loop over the array elements, and output each one in the binding. 
Output resource remains each time the input one.

        .json('{items:[{val:1},{val:2},{val:3}]}').with('valuePath','$.items').name('demo')
        .mkdir('/content/${demo.val}')

should create a tree of 3 resources /content/1, /content/2 and /content/3.

An interesting usage of the JSON pipe can also be to loop over an array of Strings like

        .json('["/content/mySite/page1","/content/mySite/page2","/content/mySite/page3"]')
        .echo('${one}')
        .children("jcr:content")
        .write("update","something")

### CsvPipe (`csv(expr)`)
feeds bindings with csv stream

- `sling:resourceType` is `slingPipes/csv`
- `expr` see above
- `separator` separator character, default being comma `,`

        .csv('idx,val\n1,1\n2,2\n3,3').name('demo')
        .mkdir('/content/${demo.val}')

should create a tree of 3 resources /content/1, /content/2 and /content/3

### Regexp pipe (`egrep(expr)`)
feeds bindings with text input stream, parsed with a regexp

- `sling:resourceType` is `slingPipes/egrep`
- `expr` see above
- `pattern` is a regular expression, with named group (e.g. `(?<user>.*)`) that will be used to produce the output binding names

        egrep("https://sling.apache.org/")
              .with("pattern",'src=\"/res/(?<asset>/[\\-\\w\\.\\/0-9]+)\"').name("demo")
        .echo('/content/assets/${demo.asset}')
