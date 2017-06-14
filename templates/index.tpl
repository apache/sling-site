layout 'layout/main.tpl', true,
        projects: projects,
        bodyContents: contents {

// TODO our "news" section might work like that? with posts tagged as "news"?
//            published_posts[0..2].each { post ->
//                model.put('post', post)
//                include template: 'post-brick.tpl'
//            }

            div(class:"row"){
                div(class:"small-12 columns"){
                    hr()
                    yield "Older post are available in the "
                    a(href:"${config.site_contextPath}${config.archive_file}","archive")
                }
            }

        }
