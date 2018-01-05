// Include common utilities
U = new includes.U(config)

layout 'layout/main.tpl', true,
        projects: projects,
        breadcrumbs : contents {
            div(class:"breadcrumbs") {
                def separator = "&nbsp;&raquo;&nbsp;"
                U.getSortedParents(content, published_content).each { item ->
                    a (href:"${config.site_contextPath}${item.value.uri}") {
                        yield item.value.title
                    }
                    yieldUnescaped separator
                }
            }
        },
        tableOfContents : contents {
            // Temporary (?) ToC generation, until we get markdown support for that
            // using https://github.com/nghuuphuoc/tocjs
            div(id:"generatedToC") {}
            yieldUnescaped "<script src='/res/jquery-3.2.1.min.js' type='text/javascript'></script>"
            yieldUnescaped "<script src='/res/tocjs-1-1-2.js' type='text/javascript'></script>"
            yieldUnescaped "<script type='text/javascript'>\$(document).ready(function() { \$('#generatedToC').toc({'selector':'h1[class!=pagetitle],h2,h3'}); } );</script>"
        },
        bodyContents: contents {
            div(class:"row"){
                div(class:"small-12 columns"){
                    section(class:"wrap"){
                        yieldUnescaped U.processBody(content, config)
                    }
                }
            }
        },
        tags : contents {
            div(class:"tags") {
                if(content.tags) {
                    content.tags.each { tag ->
                        a(href:"${config.site_contextPath}tags/${tag.replace(' ', '-')}.html", class:"label"){
                            yield tag
                        }
                        yield " "
                    }
                }
            }
        },
        lastModified: contents {
            div(class:"revisionInfo") {
                def info = includes.Git.getRevisionInfo(content.file);
                yield "Last modified by "
                span(class:"author") { yield info.author }
                yield " on "
                span(class:"comment") { yield info.date }
            }
        }
