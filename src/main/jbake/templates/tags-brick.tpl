div(class:"tags") {
    if(content.tags) {
        content.tags.each { 
            tag ->
            a(href:"${config.site_contextPath}tags/${tag.replace(' ', '-')}.html", class:"label"){
                yield tag
            }
            yield " "
        }
    }
}