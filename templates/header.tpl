meta(charset:"utf-8") newLine()

title("${config.blog_title}") newLine()

// For now, try to reproduce the layout of the current website, to be able to compare pages

link(rel:"stylesheet", href:"${config.site_contextPath}res/css/site.css") newLine()
link(rel:"stylesheet", href:"${config.site_contextPath}res/css/codehilite.css") newLine()

div(class:"title") {
  div(class:"logo") {
	  a(href:"http://sling.apache.org") {
	  	img(border:"0", alt="Apache Sling", src="${config.site_contextPath}res/logos/sling.svg")
	  }
  }
  div(class:"header") {
	  a(href:"http://www.apache.org") {
	  	img(border:"0", alt="Apache", src="${config.site_contextPath}res/logos/apache.png")
	  }
  }
}
