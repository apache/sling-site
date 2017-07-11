def processContent(str) {
	// Temporarily disable the TOC macro, replace with a comment
	def replacement ='<!-- TODO reactivate TOC once JBake moves to flexmark-java -->\n'
	str = str.replaceAll('\\[TOC\\]', replacement)

	// Temporarily disable the syntax markers (of which there are two flavors, for some reason)
	str = str.replaceAll('(::|#\\!)(java|jsp|xml|sh|javascript|html) *\\n', '<!-- TODO syntax marker ($1$2) disabled -->')
	return str
}

// Is parent an ancestor of child?
def isAncestor(parent, child) {
	// assuming .html extension
	return child.uri[0..-6].contains(parent.uri[0..-6]) && !child.uri.equals(parent.uri)
}

// Return the parents of supplied content, sorted by
// their depth in the tree, root first
def getSortedParents(content, published_content) {
	def result = new TreeMap()
	result.put(0, [ uri:"", title:"Home" ])
	published_content.each { item ->
		if(isAncestor(item, content)) {
			result.put(item.uri.length(), item)
		}
	}
	return result
}

layout 'layout/main.tpl', true,
        projects: projects,
		breadcrumbs : contents {
			div(class:"breadcrumbs") {
				def separator = "&nbsp;&raquo;&nbsp;"
				getSortedParents(content, published_content).each { item ->
					a (href:"${config.site_contextPath}${item.value.uri}") {
						yield item.value.title
					}
					yieldUnescaped separator
				}
			}
		},
        bodyContents: contents {
            div(class:"row"){
                div(class:"small-12 columns"){
                    section(class:"wrap"){
                        yieldUnescaped processContent(content.body)
                    }
                }
            }
        }
