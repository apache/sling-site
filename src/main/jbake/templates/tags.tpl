layout 'layout/main.tpl', true,
        projects: projects,
        bodyContents: contents {

            div(class:"row"){
                div(class:"small-12 columns"){
                    div(class:"wrap"){

                        div(class:"row"){
                            div(class:"small-12 columns"){
                                div(class:"tags"){
                                    alltags.sort().each { tag ->
                                        tag = tag.trim()
                                        def count = all_content.findAll { p -> p.tags && p.tags.contains(tag) }.size()
                                        span{
                                            a(href:"${config.site_contextPath}tags/${tag.replace(' ', '-')}.html", class:"label"){
                                                yield "$tag"
                                                span(class:"badge","${count}")
                                            }
											yield " "
											newLine()
                                        }
                                    }
                                }
                            }
                        }
                        div(class:"taglinks"){
                            div(class:"small-12 columns"){
								h2("Tagged with '${tag}'")
                                all_content.sort({p -> p.title}).each { p ->
                                    if ( p.status == 'published' && p.tags && p.tags.contains(tag) ) {
                                        div(class:"taglink"){
                                            a(href:"${config.site_contextPath}${p.uri}"){
                                                yield p.title
                                            }
                                        }
										newLine()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }