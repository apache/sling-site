title=Modifiers
type=page
status=published
~~~~~~

### `:eq(index)`

Reduce the set of matched elements to the one at the specified 0-based index. Example:

    $(...).find("foundation/components/richtext:eq(2)"); // find the third richtext in the subtree

### `:even`

Reduce the set of matched elements to those which indexes are even numbers:

    $(...).children("cq:Page:even"); // get even children pages for each resource in the collection

### `:first`

Reduce the set of matched elements to the first one:

    $(...).find("foundation/components/richtext:first"); // find the first richtext in the subtree

### `:gt(index)`

Reduce the set of matched elements to those which indexes are greater than the argument:

    $(...).children("cq:Page:gt(2)"); // filter out first 3 pages

### `:has(selector)`

Reduce the set of the matched elements to those which have descendant matching the selector:

    $(...).children("cq:Page:has(foundation/components/richtext)]"); // get children pages containing richtext component

### `:last`

Reduce the set of matched elements to the last one:

    $(...).find("foundation/components/richtext:last"); // find the last richtext in the subtree

### `:lt(index)`

Reduce the set of matched elements to those which indexes are lesser than the argument:

    $(...).children("cq:Page:lt(3)"); // get first 3 matches

### `:not(selector)`

Reduce the set of matched elements to those which doesn't match the selector. The selector may contain other modifiers as well, however in this case the function will be evaluated eagerly:

    $(...).find(":not(:parent)"); // ancestor resources that doesn't contain any children

### `:odd`

Reduce the set of matched elements to those which indexes are odd numbers:

    $(...).children("cq:Page:odd"); // get odd children pages for each resource in the collection

### `:parent`

Reduce the set of the matched elements to those which have any descendant resource.

    $(...).children(":parent]"); // get children resources containing any resource
