title=Hierarchy operators
type=page
status=published
tags=slingquery
~~~~~~

### Child operator (`parent > child`)

Select all direct child resources specified by `child` of resources specified by `parent`

    // find all richtext components placed directly into parsys resources
    $(resource).find('foundation/components/parsys > foundation/components/richtext')
    // alternative version
    $(resource).find('foundation/components/parsys').children('foundation/components/richtext')

### Descendant operator (`ancestor descendant`)

Select all resources that are `descendant`s of a given `ancestor`

    // find all resources containing `someAttribute` on the `cq:Page`s being direct children of the resource
    $(resource).children('cq:Page [someAttribute]')
    // alternative version
    $(resource).children('cq:Page').find('[someAttribute]')

### Next adjacent operator (`prev + next`)

Selects all next resources matching `next` that are immediately preceded by a sibling `prev`

    // find next sibling of the cq:Page containing the resource
    $(resource).closest('cq:Page + cq:Page')
    // alternative version
    $(resource).closest('cq:Page').next('cq:Page')

### Next siblings operator (`prev ~ siblings`)

Selects all sibling resources that follow after the `prev` element, have the same parent, and match the filtering `siblings` selector

    // find all siblings of the cq:Page containing the resource
    $(resource).closest('cq:Page ~ cq:Page')
    // alternative version
    $(resource).closest('cq:Page').nextAll('cq:Page')
