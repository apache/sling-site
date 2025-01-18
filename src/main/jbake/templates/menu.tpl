// TODO read links from a Markdown or other definition file?
div(class:"container") {
    nav(class:"menu"){
        ul(class:"menu-list box is-shadowless is-marginless") {
            li(){
                p(class:"menu-label") {
                    strong("Documentation")
                }
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
                p(class:"menu-label") {
                    strong("API Docs")
                }
                ul() {
                    li(){a(href:"${config.site_contextPath}apidocs/sling13/index.html", "Sling 13")}
                    li(){a(href:"${config.site_contextPath}apidocs/sling12/index.html", "Sling 12")}
                    li(){a(href:"${config.site_contextPath}apidocs/sling11/index.html", "Sling 11")}
                    li(){a(href:"${config.site_contextPath}apidocs/sling10/index.html", "Sling 10")}
                    li(){a(href:"${config.site_contextPath}apidocs/sling9/index.html", "Sling 9")}
                    li(){a(href:"${config.site_contextPath}documentation/apidocs.html", "All versions")}
                }
            }
            li(){
                p(class:"menu-label") {
                    strong("Support")
                }
                ul() {
                    li(){a(href:"https://s.apache.org/sling.wiki", "Wiki")}
                    li(){a(href:"https://s.apache.org/sling.faq", "FAQ")}
                    li(){a(href:"${config.site_contextPath}sitemap.html", "Sitemap")}
                }
            }
            li(){
                p(class:"menu-label") {
                    strong("Project Info")
                }
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
                p(class:"menu-label") {
                    strong("Source")
                }
                ul() {
                    li(){a(href:"${config.site_contextPath}repolist.html", "Repositories")}
                    li(){a(href:"https://gitbox.apache.org/repos/asf#sling", "Git at Apache")}
                }
            }
            li(){
                p(class:"menu-label") {
                    strong("Apache Software<br>Foundation")
                }
                ul() {
                    li(){a(href:"https://www.apache.org/foundation/thanks.html", "Thanks!")}
                    li(){a(href:"https://www.apache.org/foundation/sponsorship.html", "Become a Sponsor")}
                    li(){a(href:"https://www.apache.org/foundation/buy_stuff.html", "Buy Stuff")}
                }
            }
            li(){
                a(class:"acevent","data-format":"square","data-event":"random") {}
            }
            li(){
                a(href:"https://apache.org/foundation/contributing.html",class:"column") {
                    img(
                        border:"0", 
                        alt:"Support the Apache Software Foundation!", 
                        src:"${config.site_contextPath}res/images/SupportApache-small.png",
                        width:"125"
                    )
                }
            }
        }
    }
}
