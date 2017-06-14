// TODO read links from a Markdown or other definition file?
div(class:"menu"){

strong(){a(href:"${config.site_contextPath}documentation.html", "Documentation")} br()
a(href:"${config.site_contextPath}documentation/getting-started.html", "Getting Started") br()
a(href:"${config.site_contextPath}documentation/the-sling-engine.html", "The Sling Engine") br()
a(href:"${config.site_contextPath}documentation/development.html", "Development") br()
a(href:"${config.site_contextPath}documentation/bundles.html", "Bundles") br()
a(href:"${config.site_contextPath}documentation/tutorials-how-tos.html", "Tutorials &amp; How-Tos") br()
a(href:"${config.site_contextPath}documentation/configuration.html", "Configuration")   

p(){}
a(href:"http://s.apache.org/sling.wiki", "Wiki") br()
a(href:"http://s.apache.org/sling.faq", "FAQ") br()

p(){}
strong("API Docs")  br()
a(href:"${config.site_contextPath}apidocs/sling9/index.html", "Sling 9") br()
a(href:"${config.site_contextPath}apidocs/sling8/index.html", "Sling 8") br()
a(href:"${config.site_contextPath}apidocs/sling7/index.html", "Sling 7") br()
a(href:"${config.site_contextPath}apidocs/sling6/index.html", "Sling 6") br()
a(href:"${config.site_contextPath}apidocs/sling5/index.html", "Sling 5") br()
a(href:"${config.site_contextPath}javadoc-io.html", "Archive at javadoc.io") br()

p(){}
strong("Project info") br()
a(href:"${config.site_contextPath}downloads.cgi", "Downloads") br()
a(href:"http://www.apache.org/licenses/", "License") br()
a(href:"${config.site_contextPath}contributing.html", "Contributing") br()
a(href:"${config.site_contextPath}news.html", "News") br()
a(href:"${config.site_contextPath}links.html", "Links") br()
a(href:"${config.site_contextPath}project-information.html", "Project Information") br()
a(href:"https://issues.apache.org/jira/browse/SLING", "Issue Tracker") br()
a(href:"http://ci.apache.org/builders/sling-trunk", "Build Server") br()
a(href:"${config.site_contextPath}project-information/security.html", "Security") br() 

p(){}
strong("Source") br()
a(href:"http://svn.apache.org/viewvc/sling/trunk", "Subversion") br()
a(href:"git://git.apache.org/sling.git", "Git") br()
a(href:"https://github.com/apache/sling", "Github Mirror") br()

p(){}
strong("Sponsorship") br()
a(href:"http://www.apache.org/foundation/thanks.html", "Thanks") br()
a(href:"http://www.apache.org/foundation/sponsorship.html", "Become a Sponsor") br()
a(href:"http://www.apache.org/foundation/buy_stuff.html", "Buy Stuff") br()  

p(){}
strong(){a(href:"${config.site_contextPath}sitemap.html", "Site Map")}
}

