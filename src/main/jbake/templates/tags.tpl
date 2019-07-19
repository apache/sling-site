layout 'layout/main.tpl', true,
        projects: projects,
        bodyContents: contents {
            div(class:"taglinks"){
                h2("Tagged with '${tag}'")
                all_content.sort({p -> p.title}).each { p ->
                if ( p.status == 'published' && p.tags && p.tags.contains(tag) ) {
                    div(class:"taglink"){
                        a(href:"${config.site_contextPath}${p.uri}"){
                            yield p.title
                        }
                    }
                }
            }
            
            h2("All tags")
            newLine()
            div(class:"field is-grouped is-grouped-multiline"){
                alltags.sort().each { tag ->
                    tag = tag.trim()
                    def count = all_content.findAll { p -> p.tags && p.tags.contains(tag) }.size()
                    div(class:"control"){
                    div(class:"tags has-addons") {
                        span(class:"tag") {
                            a(href:"${config.site_contextPath}tags/${tag.replace(' ', '-')}.html"){
                                yield "$tag"
                            }
                        }
                        span(class:"tag is-link","${count}")
                    }
                    }
					newLine()
                }
            }
        }
    }