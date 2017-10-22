import groovy.json.JsonSlurper

def expandVariables(str, config) {
    def pageVariables = [
        sling_tagline : config.blog_subtitle,
        sling_minJavaVersion : "8",
        sling_minMavenVersion : "3.5.0",
        sling_releaseVersion : "9"
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

def getApacheRepos(url, apacheRepos) {
	def connection = url.openConnection() as HttpURLConnection
	
	// implicitly executes request
	if ( connection.responseCode == 200 ) {
		// get the JSON response
    		def json = connection.inputStream.withCloseable { inStream ->
        		new JsonSlurper().parse( inStream as InputStream )
		}
		apacheRepos.addAll(json);
		// evaluate link header (https://developer.github.com/v3/guides/traversing-with-pagination/)
		String link = connection.getHeaderField("Link")
		def matcher = link =~ /<(.*)>; rel="next"/
		if (matcher.find()) {
			println "Found next page"
			return new URL(matcher[0][1])
		}
	} else {
		throw new IllegalStateException("Invalid response code '$connection.responseCode' for url '$url'. Response body: '$connection.errorStream.text'. Response headers: '$connection.headerFields'")
	}
	return null
}


def getSlingRepos() {
	 URL url = new URL("https://api.github.com/orgs/apache/repos")
	 def apacheRepos = []
	 
	 while ({
       	url = getApacheRepos(url, apacheRepos)
		url != null
	}()) continue
	 
	 // filter all sling names
	 print apacheRepos
	 def slingRepos = apacheRepos.findAll { it.name.startsWith('sling') }
	 println "Found $slingRepos.size repositories"
	 return slingRepos
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
                        yieldUnescaped processBody(content, config)
                    }
                }
            }
            def slingRepos = getSlingRepos();
            div(class:"repos") {
                h2(class:"repos") {
                    yield "Repository Locations"
                }
                table {
                		tr {
                			th {
                				yield "Description"
                			}
                			th {
                				yield "Apache Gitbox URL"
                			}
                			th {
                				yield "Github URL"
                			}
                		}
                		slingRepos.each { repo ->
                		    tr {
		                    td {
		                         yield "$repo.description"
		                    }
		                    td {
		                    		a(href:"https://gitbox.apache.org/repos/asf?p=${repo.name}.git") {
		                         	yield "https://gitbox.apache.org/repos/asf/${repo.name}.git"
		                         }
		                    }
		                    td {
		                         a(href:"$repo.html_url") {
		                         	yield "$repo.clone_url"
		                         }
		                    }
	                    }
                    }
                }
            }
        }