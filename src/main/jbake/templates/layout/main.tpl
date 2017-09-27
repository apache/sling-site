yieldUnescaped '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
html(lang:'en'){

	include template: "header.tpl"

    body() {
        include template: 'logos.tpl'
        include template: 'menu.tpl'

		div(class:"main") {
			breadcrumbs()
			
			h1 {
            	yield "${ content ? content.title : "<MISSING CONTENT OBJECT??>" }"
			}
			
			tableOfContents()
			bodyContents()

			newLine()
			include template: 'footer.tpl'
			newLine()
        }
    }
}
newLine()
