div(class:"breadcrumb") {
    ul() {
        U.getSortedParents(content, published_content).each { item ->
            li(){ 
                a (href:"${config.site_contextPath}${item.value.uri}") {
                    yield item.value.title
                }
            }
        }
    }
}