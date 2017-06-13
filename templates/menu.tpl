div(class:"row"){

    div(class:"small-12 large-12 middle-12 small-text-center large-text-center middle-text-center columns"){
        div(class:"title-box"){
            div(class:"title-content"){
                h1("${config.blog_title}")
                newLine()
                p("${config.blog_subtitle}")
                newLine()
                p(class:"title-contact"){
                    a(href:"https://twitter.com/javabake"){
                        i(class:"foundicon-twitter"){}
                    }
                    a(href:"https://github.com/jbake-org/jbake"){
                        i(class:"foundicon-github"){}
                    }
                }
            }
        }
        div(class:"sticky contain-to-grid"){
            nav(class:"top-bar", "data-topbar":"", role:"navigation"){
                ul(class:"title-area"){
                    li(class:"name"){}
                    comment 'Remove the class "menu-icon" to get rid of menu icon. Take out "Menu" to just have icon alone'
                    li(class:"toggle-topbar menu-icon"){
                        a(href:"#"){
                            span("Menu")
                        }
                    }
                }

                section(class:"top-bar-section"){
                    ul(class:"left"){
                        li{
                            a(href:"${config.site_contextPath}index.html","Home")
                        }
                        li{
                            a(href:"${config.site_contextPath}${config.archive_file}","Archive")
                        }

                        li(class:"has-dropdown"){
                            a(href:"#",'Projects')
                            ul(class:"dropdown"){
                                projects.each { project ->
                                    li{
                                        a(href:"${config.site_contextPath}${project.uri}","${project.doctitle}")
                                    }
                                }
                            }
                        }

                        li{
                            a(href:"${config.site_contextPath}about.html","About")
                        }
                        li{
                            a(href:"${config.site_contextPath}${config.feed_file}","Subscribe")
                        }
                    }
                }
            }
        }
    }
}

