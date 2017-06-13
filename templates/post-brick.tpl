div(class:"row"){
    div(class:"small-12 middle-12 large-12 columns"){
        article(class:"wrap"){
            header{
                div(class:"row"){
                    div(class:"small-3 medium-1 large-1 columns"){
                        include template: 'date-brick.tpl'
                    }

                    div(class:"small-9 medium-11 large-11 columns"){

                        div{
                            h2{
                                a(href:"${config.site_contextPath}${post.uri}","${post.title}")
                            }
                            include template: 'tags-brick.tpl'
                            hr()
                        }
                    }
                }
            }

            div(class:"row"){
                div(class:"small-9 small-offset-3 medium-11 medium-offset-1 large-11 large-offset-1 columns"){
                    yieldUnescaped post.body
                }
            }
        }
    }
}