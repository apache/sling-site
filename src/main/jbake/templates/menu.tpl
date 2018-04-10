// TODO read links from a Markdown or other definition file?
div(class:"menu"){

	p() {
		strong(){a(href:"${config.site_contextPath}documentation.html", "Documentation")} br() newLine()
		a(href:"${config.site_contextPath}documentation/getting-started.html", "Getting Started") br() newLine()
		a(href:"${config.site_contextPath}documentation/the-sling-engine.html", "The Sling Engine") br() newLine()
		a(href:"${config.site_contextPath}documentation/development.html", "Development") br() newLine()
		a(href:"${config.site_contextPath}documentation/bundles.html", "Bundles") br() newLine()
		a(href:"${config.site_contextPath}documentation/tutorials-how-tos.html", "Tutorials &amp; How-Tos") br() newLine()
		a(href:"http://sling.apache.org/components/", "Maven Plugins") br() newLine()
		a(href:"${config.site_contextPath}documentation/configuration.html", "Configuration") newLine()
	}

	p(){
		a(href:"http://s.apache.org/sling.wiki", "Wiki") br() newLine()
		a(href:"http://s.apache.org/sling.faq", "FAQ") br() newLine()
	}

	p(){
		strong("API Docs")  br() newLine()
		a(href:"${config.site_contextPath}apidocs/sling10/index.html", "Sling 10") br() newLine()
		a(href:"${config.site_contextPath}apidocs/sling9/index.html", "Sling 9") br() newLine()
		a(href:"${config.site_contextPath}documentation/apidocs.html", "All versions") br() newLine()
	}

	p(){
		strong("Project Info") br() newLine()
		a(href:"${config.site_contextPath}downloads.cgi", "Downloads") br() newLine()
		a(href:"http://www.apache.org/licenses/", "License") br() newLine()
		a(href:"${config.site_contextPath}news.html", "News") br() newLine()
		a(href:"${config.site_contextPath}releases.html", "Releases") br() newLine()
		a(href:"https://issues.apache.org/jira/browse/SLING", "Issue Tracker") br() newLine()
		a(href:"${config.site_contextPath}links.html", "Links") br() newLine()
		a(href:"${config.site_contextPath}contributing.html", "Contributing") br() newLine()
		a(href:"${config.site_contextPath}project-information.html", "Project Information") br() newLine()
		a(href:"${config.site_contextPath}project-information/security.html", "Security") br() newLine() 
	}

	p(){
		strong("Source") br() newLine()
		a(href:"https://github.com/apache/?utf8=%E2%9C%93&q=sling", "GitHub") br() newLine()
		a(href:"https://gitbox.apache.org/repos/asf?s=sling", "Git at Apache") br() newLine()
	}

	p(){
		strong(){a(href:"${config.site_contextPath}sitemap.html", "Site Map")}
	}

	p(){
		strong("Apache Software Foundation") br() newLine()
		a(href:"http://www.apache.org/foundation/thanks.html", "Thanks!") br() newLine()
		a(href:"http://www.apache.org/foundation/sponsorship.html", "Become a Sponsor") br() newLine()
		a(href:"http://www.apache.org/foundation/buy_stuff.html", "Buy Stuff") br() newLine()  
        a(href:"https://www.apache.org/events/current-event.html") {
            img(
                border:"0",
                alt:"Current ASF Events",
                src:"https://www.apache.org/events/current-event-125x125.png",
                width:"125px"
            )
        }
        a(href:"http://apache.org/foundation/contributing.html") {
            img(
                border:"0", 
                alt:"Support the Apache Software Foundation!", 
                src:"${config.site_contextPath}res/images/SupportApache-small.png",
                width:"125px"
            )
        }
	}
    
}

