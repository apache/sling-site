layout 'layout/main.tpl', true,
        projects: projects,
        bodyContents: contents {

            div(class:"row"){
                div(class:"small-12 columns"){
                    section(class:"wrap"){
                        header{
                            h2("${content.title}")

                            time(datetime:"${content.date.format('yyyy-MM-dd')}"){
                                small("${content.date.format('dd.MM.yyyy')}")
                            }
                            hr()
                        }
                        div(class:"row"){
                            div(class:"small-12 columns"){
                                div(class:"project-meta"){
                                    dl{
                                        dt{
                                            strong("website")
                                        }
                                        dd{
                                            a(href:"${content.website}", "$content.website")
                                        }

                                        dt{
                                            strong("gitHub")
                                        }
                                        dd{
                                            a(href:"${content.github}","$content.github")
                                        }

                                        dt{
                                            strong("git")
                                        }
                                        dd{
                                            code {
                                                yieldUnescaped "git clone $content.git"
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        div(class:"row"){
                            div(class:"small-12 columns"){
                               yieldUnescaped content.body
                            }
                        }
                    }
                }
            }

        }
