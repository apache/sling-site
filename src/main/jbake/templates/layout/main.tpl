yieldUnescaped '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
html(lang:'en'){

	include template: "header.tpl"

    body() {
        include template: 'logos.tpl'
        include template: 'menu.tpl'

		div(class:"main") {
			breadcrumbs()
			
			if(content && content.title) {
				h1(class:"pagetitle") {
					yield "${ content.title }"
				}
			}
			
			tableOfContents()
			newLine()
			bodyContents()
			newLine()
			tags()
			newLine()
			lastModified()

			newLine()
			include template: 'footer.tpl'
			newLine()
        }
    }
}
newLine()
