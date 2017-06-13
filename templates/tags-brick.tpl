p {
    def contextPath = "${config.site_contextPath}"
    post.tags.each { tag ->
        tag = tag.trim()

        span{
            a(href:"${contextPath}tags/${tag.replace(' ','-')}.html", class:"label","${tag}")
        }
    }
}
