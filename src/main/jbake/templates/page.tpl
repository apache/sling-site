// Include common utilities
U = new includes.U(config)

layout 'layout/main.tpl', true,
        projects: projects,
        breadcrumbs : contents {
            include template : 'breadcrumbs-brick.tpl'
        },
        edit : contents {
            include template : 'edit-brick.tpl'
        },
        tableOfContents : contents {
            include template : 'toc-brick.tpl'
        },
        bodyContents: contents {
            div(class:"row","data-pagefind-body":true){
                div(){
                    section(){
                        yieldUnescaped U.processBody(content, config)
                    }
                }
            }
        },
        tags : contents {
            include template : 'tags-brick.tpl'
        },
        lastModified: contents {
            include template : 'lastmodified-brick.tpl'
        }
