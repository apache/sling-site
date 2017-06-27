def processTOC(str) {
	def replacement ='<!-- TODO reactivate TOC once JBake moves to flexmark-java -->\n'
	return str.replaceAll('\\[TOC\\]', replacement)
}

layout 'layout/main.tpl', true,
        projects: projects,
        bodyContents: contents {

            div(class:"row"){
                div(class:"small-12 columns"){
                    section(class:"wrap"){
                        yieldUnescaped processTOC(content.body)
                    }
                }
            }

        }
