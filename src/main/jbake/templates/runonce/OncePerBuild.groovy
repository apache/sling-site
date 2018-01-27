package runonce

/** Stuff that runs once for each build
 ** like generating the list of Sling Git modules etc.
 **/
class OncePerBuild {
    static boolean hasRun
    
    def OncePerBuild(jbakeConfig) {
        synchronized(this.class) {
            if(!hasRun) {
                hasRun = true
                execute(jbakeConfig)
            }
        }
    }
    
    /** Call things that need to run once during the website build here */
    def execute(jbakeConfig) {
        // I used this to test the mechanism, feel
        // free to remove this code once this method
        // starts doing something useful
        // new File("/tmp/sling-site-once.txt").append("The build ran at " 
        //    + new java.util.Date() 
        //    + " with config " + jbakeConfig + "\n")
    }
}