Title: Operators

### Contains `[name*=value]`

Select resources that have property `name` containing `value`:

    // select children pages titled 'foo', 'foo bar', 'bar foo bar', 'foofoofoo', etc.
    $(resources).children("cq:Page[jcr:content/jcr:title*=foo]")

### Contains a word `[name~=value]`

Select resources that have property `name` containing word `value` delimited with spaces:

    // select children pages titled 'foo', 'foo bar', 'bar foo bar', but not 'foofoofoo'
    $(resources).children("cq:Page[jcr:content/jcr:title~=foo]")

### Ends with `[name$=value]`

Select resources that have property `name` ending with `value`:

    // select children pages titled 'foo', 'bar foo', etc.
    $(resources).children("cq:Page[jcr:content/jcr:title$=foo]")

### Equals `[name=value]`

Select resources that have property `name` that equals to `value`:

    $(resources).children("cq:Page[jcr:content/jcr:title=foo]")

### Not equal `[name!=value]`

Select resources that have property `name` that not equals to `value`:

    $(resources).children("cq:Page[jcr:content/jcr:title!=foo]")

### Starts with `[name^=value]`

Select resources that have property `name` starting with `value`:

    // select children pages titled 'foo', 'foo bar', etc.
    $(resources).children("cq:Page[jcr:content/jcr:title^=foo]")

### Has attribute `[name]`

Select resources that have property `name`:

    $(resources).find("[markerProperty]")
