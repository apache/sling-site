div(class:"tags") {
    if(content.tags) {
        content.tags.each { 
            tag ->
            span(class:"tag"){
                a(href:"${config.site_contextPath}tags/${tag.replace(' ', '-')}.html"){
                    yield tag
                }
            }
        }
    }
}