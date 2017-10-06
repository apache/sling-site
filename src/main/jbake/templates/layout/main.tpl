yieldUnescaped '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
html(lang:'en'){

	include template: "header.tpl"

    body() {
        include template: 'logos.tpl'
        include template: 'menu.tpl'

		div(class:"main") {
            div(class:"pagenav") {
                breadcrumbs()
                newLine()
                tags()
                newLine()
            }
			
			if(content && content.title) {
				h1(class:"pagetitle") {
					yield "${ content.title }"
				}
			}
			
            if (content && !"false".equals(content.tableOfContents)) {
			    tableOfContents()
			    newLine()
		    }
			bodyContents()
			newLine()

            div(class:"footer") {
                lastModified()
                include template: 'footer.tpl'
            }
			newLine()
        }
    }
}
newLine()
