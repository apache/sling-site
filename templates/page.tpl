layout 'layout/main.tpl', true,
        projects: projects,
        bodyContents: contents {

            div(class:"row"){
                div(class:"small-12 columns"){
                    section(class:"wrap"){
                        header{
                            h1("${content.title}")
                        }
                        yieldUnescaped content.body
                    }
                }
            }

        }
