// Shared OS-related utilities
package includes

class OS {
    /* Execute an OS command and return its output,
     * or the defaultText if an error occurs
     */
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