title=Sling Query		
type=page
status=published
~~~~~~

SlingQuery is a Sling resource tree traversal tool inspired by the [jQuery](http://api.jquery.com/category/traversing/tree-traversal/) JavaScript API.

## Introduction

The recommended way to find resources in the Sling repository is using tree-traversal methods, like `listChildren()` and `getParent()` rather than JCR queries. The latter are great for listing resources with given properties, but we can't leverage the repository tree structure with such queries. On the other hand, using tree-traversal method is quite verbose. Consider following code that takes an resource and returns its first ancestor, being `cq:Page`, with given `jcr:content/cq:template` attribute:

    Resource resource = ...;
    while ((resource = resource.getParent()) != null) {
        if (!resource.isResourceType("cq:Page")) {
            continue;
        }
        Resource template = resource.getChild("jcr:content/cq:template");
        if (template != null && "my/template".equals(template.adaptTo(String.class))) {
            break;
        }
    }
    if (resource != null) {
        // we've found appropriate ancestor
    }

SlingQuery is a tool that helps creating such queries in a more concise way. Above code could be written as:

    import static org.apache.sling.query.SlingQuery.$;
    // ...
    $(resource).closest("cq:Page[jcr:content/cq:template=my/template]")

Dollar sign is a static method that takes the resource array and creates SlingQuery object. The `closest()` method returns the first ancestor matching the selector string passed as the argument.

SlingQuery is inspired by the jQuery framework. jQuery is the source of method names, selector string syntax and the dollar sign method used as a collection constructor.

## Features

* useful [operations](/documentation/bundles/sling-query/methods.html) to traverse the resource tree,
* flexible [filtering syntax](/documentation/bundles/sling-query/selectors.html),
* lazy evaluation of the query result,
* `SlingQuery` object is immutable (thread-safe),
* fluent, friendly, jQuery-like API.

## Installation

Add following Maven dependency to your `pom.xml`:

	<dependency>
		<groupId>org.apache.sling</groupId>
		<artifactId>org.apache.sling.query</artifactId>
		<version>3.0.0</version>
	</dependency>

## Documentation

* [Basic ideas](/documentation/bundles/sling-query/basic-ideas.html)
* [Method list](/documentation/bundles/sling-query/methods.html)
* [Selector syntax](/documentation/bundles/sling-query/selectors.html)
      * [Operator list](/documentation/bundles/sling-query/hierarchy-operators.html)
      * [Modifier list](/documentation/bundles/sling-query/modifiers.html)
      * [Hierarchy operator list](/documentation/bundles/sling-query/operators.html)
* [Sling Query vs. JCR](/documentation/bundles/sling-query/vs-jcr.html)
* [Examples](/documentation/bundles/sling-query/examples.html)

## External resources

* See the [Apache Sling website](http://sling.apache.org/) for the Sling reference documentation. Apache Sling, Apache and Sling are trademarks of the [Apache Software Foundation](http://apache.org).
* Method names, selector syntax and some parts of documentation are inspired by the [jQuery](http://jquery.com/) library.
