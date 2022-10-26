title=Readers Pipes
type=page
status=published
tags=pipes,slingquery
~~~~~~

those are pipes that will spit out resources, without modifying them. They are usually combined with [logical](/documentation/bundles/sling-pipes/logical.html) 
and/or [writer](/documentation/bundles/sling-pipes/writers.html) pipes

### Base pipe (`echo <path>`)
outputs what is in input (so what is configured in path).

It's handy to set the input of a given sequence in a talkative manner:

        echo /content | write foo=bar
    
You can also pipe it with relative path to go to a children:
    
        echo /content | $ some/parent | echo child/path | ...

### XPath Pipe (`xpath <xpath query>`)
    
        xpath /jcr:root/content/foo//element(*,nt:unstructured)[@sling:resourceType="foo/bar"] | write foo=bar

### Traverse Pipe (`traverse`)
traverse current input resource's tree, outputing, as resources, either the node of the tree, either its properties

- `breadthFirst` the tree visit will be done deep first, unless this flag is set to true,
- `depth` max depth the visit should go to,
- `properties` is a flag mentioning the pipe should traverse node's property,
- `nameGlobs` filters the property that should get outputed

        echo /content | traverse @ with breadFirst=true depth=10 properties=true | ...

### MultiProperty Pipe (`mp`)
iterates through values of input multi value property and write them to bindings

        echo /content/my/months | mp @ name currentMonth | echo /content/year/${currentMonth} | write visited=true
        
## Sling Query Pipes

Sling Query shares with Sling Pipes the same objective to write more concise (and efficient) code for
most common operations. Below are the most common [Sling Query](/documentation/bundles/sling-query.html) methods as reader pipes.

### Find Pipe (`$ <expr>`)
executes [find](/documentation/bundles/sling-query/methods.html#findselector)(expression) that searches through the subtree below the current input resource. 
Typical handy usage would be to use resource type selector like that: 

        echo /content | $ foo/bar

### Children Pipe (`children <expr>`)
executes [children](/documentation/bundles/sling-query/methods.html#childrenselector)(expression) that searches through the immediate children of the current input resource)

        echo /content/some/container | children foo/bar

### Siblings Pipe (`siblings <expr>`)
executes [siblings](/documentation/bundles/sling-query/methods.html#siblings-selector-)(expression) that searches through siblings of current input resource

        echo /content | siblings foo/bar

### Parent Pipe (`parent <expr>`)
executes [parent](/documentation/bundles/sling-query/methods.html#parent-)() that retrieves current parent

### Closest Pipe (`closest <expr>`)
executes [closest](/documentation/bundles/sling-query/methods.html#closest-selector-)(expression) that searches the closest parent resource of current input resource

        echo /content | $ foo/bar | closest jcr:content
        
will find `jcr:content` nodes that have `foo/bar` typed resource somewhere in their tree

### Parents Pipe (`parents <expr>`)
executes [parents](/documentation/bundles/sling-query/methods.html#parents-selector-)(expression) that searches all the parents of the current input resource

## InputStream reader pipes

those are specific reader pipes, that read information an input stream from defined in expr configuration,
that can be:

- a remote located file (starting with http),
- a file located in the repository (existing file stored in the repository),
- a file passed as request parameter with `pipes_inputFile` as parameter name (in that case, expr can be empty)
- direct data stream in the expression

### Json Pipe (`json expr`)
feeds bindings with json stream
`valuePath` is a property as a json path like expression that defines where the json value we care about is. E.g. `$.items[2]` considers root is an object and that we want the 3rd item of items array, located at `items` key of the root object.

In case the json value is an array, the pipe will loop over the array elements, and output each one in the binding. 
Output resource remains each time the input one.

        json {"items":[{"val":"1"},{"val":"2"},{"val":"3"}]} @ with valuePath=$.items @ name demo | mkdir /content/${demo.val}

will create a tree of 3 resources /content/1, /content/2 and /content/3.

An interesting usage of the JSON pipe can also be to loop over an array of Strings like

        json ["/content/mySite/page1","/content/mySite/page2","/content/mySite/page3"]
        | echo ${one}
        | echo jcr:content
        | write update=something

### Csv Pipe (`csv <expr>`)
feeds bindings with csv stream

        csv idx,val\\n1,1\n2,2\\n3,3 @ name demo
        | mkdir /content/${demo.val}

should create a tree of 3 resources /content/1, /content/2 and /content/3. You can change separator with `separator` property

        csv a;b @ with separator=;

### Regexp pipe (`egrep <expr>`)
feeds bindings with text input stream, parsed with a regexp `pattern`, that is a regular expression, with named 
group (e.g. `(?<user>.*)`) that will be used to produce the output binding names

        egrep http://some.site.com @ with pattern=/res/(?<asset>/[\-\w\.\/0-9]+) @ name demo
        | echo /content/assets
        | write test=demo.asset

If the regex should be applied directly to the value of the expression rather than fetching the input from the url, property `url_mode=as_is` can be configured

        | json ["https://sling.apache.org/","http://sling.apache.org/"] @name domain
        | egrep ${domain} @ with pattern=(?<httpspattern>https.*) with url_mode=as_is @ name httpsDomains
        | write test=${httpsDomains.httpspattern}
