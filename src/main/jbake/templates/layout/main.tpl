yieldUnescaped '<!DOCTYPE html>'
html(lang:'en'){
    include template: "header.tpl"
    body() {
    div(class:"section"){
        div(class:"level is-marginless") {
            include template: 'logos.tpl'
        }
        section(class:"searchbox level is-marginless") {
            div(id:"searchbox") {}
        }
        div(class:"columns is-gapless") {
            div(class:"column is-narrow sidemenu") {
                include template: 'menu.tpl'
            }
            div(class:"column main") {
                div(class:"box is-shadowless is-marginless"){
                    div(class:"level") {
                        div(class:"pagenav") {
                            breadcrumbs()
                        }
                        tags()
                    }

                    if( content ) {
                        if(content.title) {
                            h1(class:"title") {
                                yield "${ content.title }"
                            }
                        }
                        if (!"false".equals(content.tableOfContents)) {
                            tableOfContents()
                        }
                        div(class:"content is-marginless"){
                            bodyContents()
                        }
                    }
                }
            }
        }//columns
        footer(class:"footer") {
            div(class:"content has-text-centered is-small"){
                edit()
                lastModified()
                include template: 'footer.tpl'
            }
        }
    }
    }//body
}

