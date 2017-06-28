div(class:"title") {
  div(class:"logo") {
	  a(href:"http://sling.apache.org") {
	  	img(border:"0", alt:"Apache Sling", src:"${config.site_contextPath}res/logos/sling.svg")
	  }
  }
  div(class:"header") {
	  a(href:"http://www.apache.org") {
	  	img(border:"0", alt:"Apache", src:"${config.site_contextPath}res/logos/apache.png")
	  }
  }
}
h1(class:"draft") { yield "DRAFT 2017 WEBSITE - SLING-6955" }