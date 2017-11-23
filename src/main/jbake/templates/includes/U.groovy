// Shared general utilities
package includes

class U {

    U(jbakeConfig) {
        // As this class is used in each build,
        // use it to trigger the OncePerBuild stuff
        def once = new runonce.OncePerBuild(jbakeConfig)
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

    def static exec(cmd, defaultText) {
    	try {
     	    def p = cmd.execute()
    	    p.waitFor()
      	    return p.text
    	} catch(Exception e) {
    		return defaultText
    	}
    }
}