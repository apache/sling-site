// TODO read links from a Markdown or other definition file?
nav(class:"menu"){
    
    ul() {
        li(){
            strong("Documentation")
            ul() {
                li(){a(href:"${config.site_contextPath}documentation.html", "Overview")}
                li(){a(href:"${config.site_contextPath}documentation/getting-started.html", "Getting Started")}
                li(){a(href:"${config.site_contextPath}documentation/the-sling-engine.html", "The Sling Engine")}
                li(){a(href:"${config.site_contextPath}documentation/development.html", "Development")}
                li(){a(href:"${config.site_contextPath}documentation/bundles.html", "Bundles")}
                li(){a(href:"${config.site_contextPath}documentation/tutorials-how-tos.html", "Tutorials &amp; How-Tos")}
                li(){a(href:"${config.site_contextPath}components/", "Maven Plugins")}
                li(){a(href:"${config.site_contextPath}documentation/configuration.html", "Configuration")}
            }
        }
        li(){
            strong("API Docs")
            ul() {
                li(){a(href:"${config.site_contextPath}apidocs/sling11/index.html", "Sling 11")}
                li(){a(href:"${config.site_contextPath}apidocs/sling10/index.html", "Sling 10")}
                li(){a(href:"${config.site_contextPath}apidocs/sling9/index.html", "Sling 9")}
                li(){a(href:"${config.site_contextPath}documentation/apidocs.html", "All versions")}
            }
        }
        li(){
            strong("Support")
            ul() {
                li(){a(href:"https://s.apache.org/sling.wiki", "Wiki")}
                li(){a(href:"https://s.apache.org/sling.faq", "FAQ")}
                li(){a(href:"${config.site_contextPath}sitemap.html", "Site Map")}
            }
        }
        li(){
            strong("Project Info")
            ul() {
                li(){a(href:"${config.site_contextPath}downloads.cgi", "Downloads")}
                li(){a(href:"https://www.apache.org/licenses/", "License")}
                li(){a(href:"${config.site_contextPath}news.html", "News")}
                li(){a(href:"${config.site_contextPath}releases.html", "Releases")}
                li(){a(href:"https://issues.apache.org/jira/browse/SLING", "Issue Tracker")}
                li(){a(href:"${config.site_contextPath}links.html", "Links")}
                li(){a(href:"${config.site_contextPath}contributing.html", "Contributing")}
                li(){a(href:"${config.site_contextPath}project-information.html", "Project Information")}
                li(){a(href:"${config.site_contextPath}project-information/security.html", "Security")} 
            }
        }
        li(){
            strong("Source")
            ul() {
                li(){a(href:"https://github.com/apache/?utf8=%E2%9C%93&q=sling", "GitHub")}
                li(){a(href:"https://gitbox.apache.org/repos/asf?s=sling", "Git at Apache")}
            }
        }
        li(){
            strong("Apache Software Foundation")
            ul() {
                li(){a(href:"https://www.apache.org/foundation/thanks.html", "Thanks!")}
                li(){a(href:"https://www.apache.org/foundation/sponsorship.html", "Become a Sponsor")}
                li(){a(href:"https://www.apache.org/foundation/buy_stuff.html", "Buy Stuff")}  
                li(){a(href:"https://www.apache.org/events/current-event.html") {
                    img(
                        border:"0",
                        alt:"Current ASF Events",
                        src:"https://www.apache.org/events/current-event-125x125.png",
                        width:"125"
                    )
                }}
                li(){a(href:"https://apache.org/foundation/contributing.html") {
                    img(
                        border:"0", 
                        alt:"Support the Apache Software Foundation!", 
                        src:"${config.site_contextPath}res/images/SupportApache-small.png",
                        width:"125"
                    )
                }}
            }
        }
    }
}

