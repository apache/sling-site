// TODO read links from a Markdown or other definition file?
div(class:"menu"){

	p() {
		strong(){a(href:"${config.site_contextPath}documentation.html", "Documentation")} br() newLine()
		a(href:"${config.site_contextPath}documentation/getting-started.html", "Getting Started") br() newLine()
		a(href:"${config.site_contextPath}documentation/the-sling-engine.html", "The Sling Engine") br() newLine()
		a(href:"${config.site_contextPath}documentation/development.html", "Development") br() newLine()
		a(href:"${config.site_contextPath}documentation/bundles.html", "Bundles") br() newLine()
		a(href:"${config.site_contextPath}documentation/tutorials-how-tos.html", "Tutorials &amp; How-Tos") br() newLine()
		a(href:"${config.site_contextPath}documentation/configuration.html", "Configuration")   
	}

	p(){
		a(href:"http://s.apache.org/sling.wiki", "Wiki") br() newLine()
		a(href:"http://s.apache.org/sling.faq", "FAQ") br() newLine()
	}

	p(){
		strong("API Docs")  br() newLine()
		a(href:"${config.site_contextPath}apidocs/sling9/index.html", "Sling 9") br() newLine()
		a(href:"${config.site_contextPath}apidocs/sling8/index.html", "Sling 8") br() newLine()
		a(href:"${config.site_contextPath}apidocs/sling7/index.html", "Sling 7") br() newLine()
		a(href:"${config.site_contextPath}apidocs/sling6/index.html", "Sling 6") br() newLine()
		a(href:"${config.site_contextPath}apidocs/sling5/index.html", "Sling 5") br() newLine()
		a(href:"${config.site_contextPath}javadoc-io.html", "Archive at javadoc.io") br() newLine()
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
		strong("Sponsorship") br() newLine()
		a(href:"http://www.apache.org/foundation/thanks.html", "Thanks") br() newLine()
		a(href:"http://www.apache.org/foundation/sponsorship.html", "Become a Sponsor") br() newLine()
		a(href:"https://donate.apache.org/", "Donate!") br() newLine()
		a(href:"http://www.apache.org/foundation/buy_stuff.html", "Buy Stuff") br() newLine()  
	}

	p(){
		strong(){a(href:"${config.site_contextPath}sitemap.html", "Site Map")}
	}

}

