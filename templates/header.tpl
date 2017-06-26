head {
	meta("http-equiv":"Content-Type", content:"text/html;charset=UTF-8") newLine()
	title("${config.blog_title} :: ${content.title}") newLine()

	// For now, try to reproduce the layout of the current website, to be able to compare pages
	link(rel:"icon", href:"${config.site_contextPath}res/favicon.ico") newLine()
	link(rel:"stylesheet", href:"${config.site_contextPath}res/css/site.css") newLine()
}