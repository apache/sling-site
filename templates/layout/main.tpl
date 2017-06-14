yieldUnescaped '<!DOCTYPE html>'
html(lang:'en'){

    head {
        include template: "header.tpl"
    }

    body() {

        include template: 'menu.tpl'

		div(class:"main") {
			bodyContents()

			newLine()
			include template: 'footer.tpl'
			newLine()
        }
    }
}
newLine()
