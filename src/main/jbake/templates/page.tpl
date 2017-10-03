def expandVariables(str, config) {
    def pageVariables = [
        sling_tagline : config.blog_subtitle
    ]

	// Use a closure to avoid exception on missing variable
	str = str.replaceAll(/\$\{(\w+)\}/) { key -> pageVariables[key[1]] ?: "MISSING_PAGE_VARIABLE:${key[0]}" }
}

def processBody(content, config) {
	def str = content.body

	// Temporarily disable the TOC macro, replace with a comment
	def replacement ='<!-- TODO reactivate TOC once JBake moves to flexmark-java -->\n'
	str = str.replaceAll('\\[TOC\\]', replacement)

	// Temporarily disable the syntax markers (of which there are two flavors, for some reason)
	str = str.replaceAll('(::|#\\!)(java|jsp|xml|sh|javascript|html) *\\n', '<!-- TODO syntax marker ($1$2) disabled -->')

	// Optionally expand variables
	if("true".equals(content.expandVariables)) {
		str = expandVariables(str, config)
	}
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

def exec(cmd, defaultText) {
	try {
 	    def p = cmd.execute()
	    p.waitFor()
  	    return p.text
	} catch(Exception e) {
		return defaultText
	}
}

def getRevisionInfo(filename) {
    def lastCommit = "444eb637ff1ddcf11a0f37f02dd4b3fe89eb149f"
	def gitCmd = 'git log -1 --format=%h####%ad####%an####%s ' + filename
	def defaultText = "0####0000####<MISSING>####<MISSING>"
	def gitInfo = exec(gitCmd, defaultText).split("####")
	return [
		lastCommit : gitInfo[0],
		date : gitInfo[1],
		author : gitInfo[2],
		comment : gitInfo[3]
	]
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
		tags : contents {
			div(class:"tags") {
				if(content.tags) {
					content.tags.each { tag -> 
                        a(href:"${config.site_contextPath}tags/${tag.replace(' ', '-')}.html", class:"label"){
                            yield tag
                        }
						yield " "
					}
				}
			}
		},
		tableOfContents : contents {
			// Temporary (?) ToC generation, until we get markdown support for that
			// using https://github.com/nghuuphuoc/tocjs
			div(id:"generatedToC") {}
			yieldUnescaped "<script src='/res/jquery-3.2.1.min.js' type='text/javascript'></script>"
			yieldUnescaped "<script src='/res/tocjs-1-1-2.js' type='text/javascript'></script>"
			yieldUnescaped "<script type='text/javascript'>\$(document).ready(function() { \$('#generatedToC').toc({'selector':'h1[class!=pagetitle],h2,h3'}); } );</script>"
		},
        bodyContents: contents {
            div(class:"row"){
                div(class:"small-12 columns"){
                    section(class:"wrap"){
                        yieldUnescaped processBody(content, config)
                    }
                }
            }
        },
		lastModified: contents {
			div(class:"revisionInfo") {
				def info = getRevisionInfo(content.file);
				yield "Last modified by "
				span(class:"author") { yield info.author }
				yield " on "
				a(href:"${config.sling_lastCommitBaseUrl}${info.lastCommit}") {
				    yield info.date
				}
				yield " : "
				span(class:"comment") { yield info.comment }
			}
		}