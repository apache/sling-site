title=Method list
type=page
status=published
tags=slingquery
~~~~~~

### `$(Resource... resources)`

Create a new SlingQuery object, using passed resources as an initial collection. Example:

    $(resource); // a simple SlingQuery collection containing one resource

### `.add(Resource... resources)`

Add resources to the collection.

    $(resource).children().add(resource); // collection contains resource and all its children

### `.asList()`

Transform SlingQuery collection into a lazy list.

    $(resource).children("cq:Page").asList().get(0); // get the first child page
    $(resource).children().asList().isEmpty(); // return true if the resource have no children

### `.children([selector])`

Get list of the children for each resource in the collection. Pass `selector` to filter children. Example:

    $(resource).children("cq:Page"); // get all page children of the resource
    $(resource).children().children(); // get all grand-children of the resource

### `.closest(selector)`

For each resource in the collection, return the first element matching the selector testing the resource itself and traversing up its ancestors. Example:

    $(resource).closest("cq:Page"); // find containing page, like PageManager#getContainingPage
    // let's assume that someCqPageResource is a cq:Page
    $(someCqPageResource).closest("cq:Page"); // return the same resource

### `.eq(index)`

Reduce resource collection to the one resource at the given 0-based index. Example:

    $(resource0, resource1, resource2).eq(1); // return resource1
    $(resource).children().eq(0); // return first child of the resource

### `.filter(selector)`

Filter resource collection using given selector.

    final Calendar someTimeAgo = Calendar.getInstance();
    someTimeAgo.add(Calendar.HOUR, -5);

    // get children pages modified in the last 5 hours
    SlingQuery query = $(resource).children("cq:Page").filter(new Predicate<Resource>() {
        @Override
        public boolean accepts(Resource resource) {
            return resource.adaptTo(Page.class).getLastModified().after(someTimeAgo);
        }
    });

### `.find([selector])`

For each resource in collection return all its descendants using [selected strategy](#searchstrategystrategy). Please notice that invoking this method on a resource being a root of a large subtree may and will cause performance problems.

    $(resource).find("cq:Page"); // find all descendant pages

### `.first()`

Filter resource collection to the first element. Equivalent to `.eq(0)` or `.slice(0, 0)`.

    $(resource).siblings().first(); // get the first sibling of the current resource

### `.has(selector)`

Pick such resources from the collection that have descendant matching the selector. Example:

    $(...).children('cq:Page').has(foundation/components/richtext) // find children pages containing some richtext component

This method uses [selected strategy](#searchstrategystrategy) to iterate over resource descendants.

### `.last()`

Filter resource collection to the last element.

    $(resource).siblings().last(); // get the last sibling of the current resource

### `.map(Class<T> clazz)`

Transform the whole collection to a new `Iterable<T>` object, invoking `adaptTo(clazz)` method on each resource. If some resource can't be adapted to the class (eg. `adaptTo()` returns `null`), it will be skipped. Example:

    for (Page page : $(resource).parents("cq:Page").map(Page.class)) {
        // display breadcrumbs
    }

### `.next([selector])`

Return the next sibling for each resource in the collection and optionally filter it by a selector. If the selector is given, but the sibling doesn't match it, empty collection will be returned.

    // let's assume that resource have 3 children: child1, child2 and child3
    $(resource).children().first().next(); // return child2

### `.nextAll([selector])`

Return all following siblings for each resource in the collection, optionally filtering them by a selector.

    // let's assume that resource have 3 children: child1, child2 and child3
    $(resource).children().first().nextAll(); // return child2 and child3

### `.nextUntil(selector)`

Return all following siblings for each resource in the collection up to, but not including, resource matched by a selector.

    // let's assume that resource have 4 children: child1, child2, child3 and child4
    // additionaly, child4 has property jcr:title=Page
    $(resource).children().first().nextUntil("[jcr:title=Page]"); // return child2 and child3

### `.not(selector)`

Remove elements from the collection.

    $(resource).children().not("cq:Page"); // remove all cq:Pages from the collection
    $(resource).children().not(":first").not(":last"); // remove the first and the last element of the collection

### `.parent()`

Replace each element in the collection with its parent.

    $(resource).find("cq:PageContent[jcr:title=My page]:first").parent(); // find the parent of the first `cq:PageContent` resource with given attribute in the subtree
    
### `.parents([selector])`

For each element in the collection find all of its ancestors, optionally filtering them by a selector.

    ($resource).parents("cq:Page"); // create page breadcrumbs for the given resources

### `.parentsUntil(selector)`

For each element in the collection find all of its ancestors until a resource matching the selector is found.

    ($currentResource).parentsUntil("cq:Page"); // find all ancestor components on the current page
    
### `.prev([selector])`

Return the previous sibling for each resource in the collection and optionally filter it by a selector. If the selector is given, but the sibling doesn't match it, empty collection will be returned.

    // let's assume that resource have 3 children: child1, child2 and child3
    $(resource).children().last().prev(); // return child2

### `.prevAll([selector])`

Return all preceding siblings for each resource in the collection, optionally filtering them by a selector.

    // let's assume that resource have 3 children: child1, child2 and child3
    $(resource).children().last().prevAll(); // return child1 and child2

### `.prevUntil(selector)`

Return all preceding siblings for each resource in the collection up to, but not including, resource matched by a selector.

    // let's assume that resource have 4 children: child1, child2, child3 and child4
    // additionally, child1 has property jcr:title=Page
    $(resource).children().last().prevUntil("[jcr:title=Page]"); // return child2 and child3

### `.searchStrategy(strategy)`

Select new search strategy, which will be used in following [`find()`](#findselector) and [`has()`](#hasselector) function invocations. There 3 options:

* `SearchStrategy.DFS` - [depth-first search](http://en.wikipedia.org/wiki/Depth-first_search)
* `SearchStrategy.BFS` - [breadth-first search](http://en.wikipedia.org/wiki/Breadth-first_search)
* `SearchStrategy.QUERY` - use JCR SQL2 query (default since 1.4.0)

DFS and BFS iterate through descendants using appropriate algorithm. QUERY strategy tries to transform SlingQuery selector into a SQL2 query and invokes it. Because there are SlingQuery operations that can't be translated (eg. `:has()` modifier), the SQL2 query result is treated as a initial collection that needs further processing.

### `.siblings([selector])`

Return siblings for the given resources, optionally filtered by a selector.

    $(resource).closest("cq:Page").siblings("cq:Page"); // return all sibling pages

### `.slice(from[, to])`

Reduce the collection to a sub-collection specified by a given range. Both `from` and `to` are inclusive and 0-based indices. If the `to` parameter is not specified, the whole sub-collection starting with `from` will be returned.

    // let's assume that resource have 4 children: child1, child2, child3 and child4
    $(resource).children().slice(1, 2); // return child1 and child2

