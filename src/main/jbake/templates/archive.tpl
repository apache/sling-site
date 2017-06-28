layout 'layout/main.tpl', true,
        projects: projects,
        bodyContents: contents {

            div(class:"row"){
                div(class:"small-12 columns"){
                    section(class:"wrap"){
                        h1("Blog Archive")

                        def last_month=null
                        published_posts.each {post ->
                            if (last_month) {
                               if (post.date.format("MMMM yyyy") != last_month) {
                                    yieldUnescaped "</ul>"
                                    h4("${post.date.format("MMMM yyyy")}")
                                    yieldUnescaped "<ul>"
                                }
                            }
                            else {
                                h4("${post.date.format("MMMM yyyy")}")
                                yieldUnescaped "<ul>"
                            }

                            li{
                                yield "${post.date.format("dd")} - "
                                a(href:"${config.site_contextPath}${post.uri}","${post.title}")
                            }
                            last_month = post.date.format("MMMM yyyy")
                        }
                        yield "</ul>"

                    }
                }
            }

	    }