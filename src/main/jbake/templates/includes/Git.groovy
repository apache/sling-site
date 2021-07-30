// Shared Git utilities
package includes

class Git {

    /** Get Git revision info for the specified file */
    def static getRevisionInfo(filename) {
    	// the date is used for both the XML sitemap and at the bottom of website pages
    	// YYYY-MM-DD format looks good enough for that, if we need a different format
        // we probably need to parse that and reformat.        
    	def gitCmd = 'git log -1 --date=short --format=%h####%ad####%an####%s ' + filename
    	def defaultText = "0####0000####<MISSING>####<MISSING>"
        def gitInfo = includes.OS.exec(gitCmd, defaultText).split("####")
        // For untracked files the command does not return anything
        // After committing this will work, but otherwise it produces
        // cryptic errors, so best avoid it
        if ( gitInfo.length != 4 ) {
            gitInfo = defaultText.split("####")
        } 
    	return [
    		lastCommit : gitInfo[0],
    		date : gitInfo[1],
    		author : gitInfo[2],
    		comment : gitInfo[3]
    	]
    }
}
