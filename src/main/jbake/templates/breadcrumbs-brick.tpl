div(class:"breadcrumb") {
    U.getSortedParents(content, published_content).each { item ->
        a (href:"${config.site_contextPath}${item.value.uri}") {
            yield item.value.title
        }
    }
}