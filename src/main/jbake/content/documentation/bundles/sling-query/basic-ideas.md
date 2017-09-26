title=Basic Ideas
type=page
status=published
~~~~~~

### Collections

`SlingQuery` class represents a collection of resources. Basic collection can be created explicitly via a dollar method:

    $(resource1, resource2, resource3)
    
Above method creates a new `SlingQuery` object that consists of 3 resources. This object implements `Iterable<Resource>` interface, so can be used in foreach statements directly:

    for (Resource resource in $(...)) { }
    
### Operations

`SlingQuery` class defines a number of methods which can be used to transform current collection into a new one. Following code:

    $(resource1, resource2).parent()

will replace each resource with its direct parent. If some resource is a repository root, it will be skipped. Some methods replace each resource with another resource (eg. `parent()` or `closest()`). Other methods can replace each resource with a set of resources:

    $(resource1, resource2).children();
    
Resulting object will contain direct children of both `resource1` and `resource2` objects. There are also methods that doesn't add any new resources, but removes existing:

    $(resource1, resource2).first();
    
Methods can be chained to create more complex query. Eg. following code will return last direct child of the `resource`:

    $(resource).children().last();
    
#### Laziness

All operations are lazy (except `prev()` and sometimes `not()`). It means that `SlingQuery` won't read any resources until it's actually necessary. Example:

    $(resource).children().children().first();

`children().children()` construction reads all grand-children of the given resource. However, the last method limits the output to the first found resource. As a result, `SlingQuery` won't iterate over all children and grand-children, but it will simply take the first child of the `resource` and return its first child.

#### Immutability

`SlingQuery` object is immutable and each operation creates a new one. We can "freeze" some collection before performing more operations on it:

    SlingQuery children = $(resource).children();
    SlingQuery firstChild = children.first();
    for (Resource child : children) { /* will display all children */ }
    for (Resource child : firstChild) { /* will display the first child */ }

### Selectors

Some operations may take an additional string selector parameter that defines a filtering. Selector could be used to define resource type, resource attributes and additional modifiers. Example selector could look like this:

    "cq:Page"
    
It will match all resources with the given resource type. Example:

    $(resource).children("cq:Page")
    
will return only children with `cq:Page` resource type. You could also filter these resources defining any number of attributes in the square brackets:

    $(resource).children("cq:Page[jcr:title=Some title][jcr:description=Some desc]")

And finally, you could add some modifiers at the end:

    $(resource).children("cq:Page[jcr:content/cq:template=my/template]:even")

Above resources will find `cq:Page` children of the resource, using template `my/template` and return not all of them, but only those with even indices (eg. if matching children of the `resource` are `page_0`, `page_1` and `page_2`, only the first and the last will be returned).

All parts of the selector are optional. In fact, an empty string (`""`) is a valid selector, accepting all resources. However, the defined order (resource type, attributes in square brackets and modifiers) has to be followed. Example selectors:

    "foundation/components/richtext" // resource type
    "foundation/components/richtext:first" // resource type with modifier
    "[property=value][property2=value2]" // two attributes
    ":even" // modifier
    ":even:not(:first)" // two modifiers, the second one is nested

