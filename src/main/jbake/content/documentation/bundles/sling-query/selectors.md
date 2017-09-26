Title: Selectors

Selector string are something between filters and content descriptors. Selector can filter resources by their [type](#resource-type), [name](#resource-name), [attributes](#attributes) and [additional modifiers](#modifiers). They can be also [chained together](#joining-selectors) to describe more sophisticated hierarchy structure or [combined with comma](#combining-selectors).

## Syntax

Selector consists of four parts:

### Resource type

Resource type, which could be a `sling:resourceType`, like `foundation/components/richtext` or the underlying JCR node type, like `cq:Page` or `nt:unstructured`. In the latter case, SlingQuery takes types hierarchy into consideration (eg. `nt:base` matches everything). JCR mixin types could be used as well.

### Resource name

Resource name can be defined with a hash `#` character, after the resource type (or instead of it):

    $(resource).children("cq:Page#some-name")

If the desired resource name contains colon (`:`) character, the whole string should be escaped with apostrophes:

    $(resource).children("#'jcr:content'[jcr:title=My title]")

### Attributes

After the resource type and resource name one could pass a number of filtering attributes. Each attribute has following form: `[property=value]`. Passing multiple attributes will match only those resources that have all of them set. Property name could contain `/`. In this case property will be taken from the child resource, eg.:

    $(resource).children("cq:Page[jcr:content/jcr:title=My title]")
    
will return only children of type `cq:Page` that have sub-resource called `jcr:content` with property `jcr:title` set to `My title`. Besides the `=` you may use other operators like `*=`, which means *contains*:

    $(resource).children("cq:Page[jcr:content/jcr:title*=title]")

See the [fulll list of operators](operators.html).

### Modifiers

At the end of the selector one could define any number of modifiers that will be used to filter out the resources matched by the resource type and attributes. Each modifier starts with colon, some of them accepts a parameter set in parentheses. Example:

    $(resource).children("cq:Page:first");
    $(resource).children("cq:Page:eq(0)"); // the same
    $(resource).children(":first"); // modifier can be used alone

It is important that modifier filters out sub-collection created for each node, before it is merged. Eg.:, there is a difference between:

    $(resource1, resource2).children().first();

and

    $(resource1, resource2).children(":first");
    
In the first case we create a new collection consisting of children of the `resource1` and `resource2` and then we get the first element of the merged collection. On the other hand, the second example takes *first child* of each resource and creates a collection from them.

See the [full list of modifiers](modifiers.html).

## Joining selectors

Selectors can be joined together using [hierarchy operators](hierarchy-operators.html). This feature enables the developer to create sophisticated filters describing desired resource structure, eg.:

    $(resource).children("cq:Page foundation/components/parsys > foundation/components/richtext")

will all `cq:Page`s containing paragraph systems with a richtext inside.

## Combining selectors

You may specify any number of selectors to combine into a single result. Use comma to join a few conditions. Comma is treated as `OR` statement:

    $(resource).children("#en, #de, #fr"); // return all direct children named `en` or `de` or `fr`.
