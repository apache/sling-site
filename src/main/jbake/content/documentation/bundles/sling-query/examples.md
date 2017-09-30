title=Examples
type=page
status=published
tags=slingquery
~~~~~~

Get containing page (like [PageManager#getContainingPage](https://docs.adobe.com/docs/en/aem/6-3/develop/ref/javadoc/com/day/cq/wcm/api/PageManager.html#getContainingPage(org.apache.sling.api.resource.Resource)))

    $(resource).closest("cq:Page")

Get first ancestor with a given template

    $(resource).closest("cq:Page[jcr:content/cq:template=/apps/geometrixx/templates/homepage]")

List siblings of the current page which can be displayed in the navigation

    $(resource).closest("cq:Page").siblings("cq:Page[jcr:content/hiddenInNav=false]")

Get the first sibling of the current page

    $(resource).closest("cq:Page").siblings("cq:Page").first()

Get page ancestor closest to the root

    $(resource).parents("cq:Page").last()

Get the second child of each resource:

    $(resource1, resource2, resource3).children(":eq(1)")

Get the first two children of each resource:

    $(resource1, resource2, resource3).children(":lt(2)")

Closest ancestor page having non-empty parsys

    $(resource).closest("cq:Page foundation/components/parsys:parent")

Get all parents of the current resource and adapt them to Page object

    Iterable<Page> breadcrumbs = $(resource).parents("cq:Page").map(Page.class);

Get all parents of the current resource up to the home page

    Iterable<Page> breadcrumbs;
    breadcrumbs = $(resource).parentsUntil(
        "cq:Page[jcr:content/cq:template=/apps/geometrixx/templates/homepage]",
        "cq:Page").map(Page.class);

List all grand-children pages having empty parsys

    $(resource).children("cq:Page").children("cq:Page").has("foundation/components/parsys:empty)

Use JCR query to find all `cq:Page`s with a given template

    $(resourceResolver)
        .searchStrategy(SearchStrategy.QUERY)
        .find("cq:PageContent[cq:template=/apps/geometrixx/templates/homepage]")
        .parent()

Find children named `en` or `de`

    $(resource).children("#en, #de")
