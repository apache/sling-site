// Shared Git utilities
package includes

class Git {

    /** Get Git revision info for the specified file */
    def static getRevisionInfo(filename) {
    	def gitCmd = 'git log -1 --format=%h####%ad####%an####%s ' + filename
    	def defaultText = "0####0000####<MISSING>####<MISSING>"
        def gitInfo = includes.OS.exec(gitCmd, defaultText).split("####")
    	return [
    		lastCommit : gitInfo[0],
    		date : gitInfo[1],
    		author : gitInfo[2],
    		comment : gitInfo[3]
    	]
    }
}