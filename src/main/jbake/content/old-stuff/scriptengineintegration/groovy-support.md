title=Groovy Support
type=page
status=published
tags=scripts,groovy
~~~~~~

After meeting Paul King of the Groovy Team at Apache Con US 08 in New Orleans, I set out to take a stab at SLING-315 again to add Groovy support to Sling. It turned out, that the current Groovy 1.6 branch already contains the required setup to build the `groovy-all.jar` as an OSGi Bundle, which is directly usable with Sling by just installing that bundle.

Currently the Groovy team is working hard towards the 1.6 release and many things are in flux, which is really great.

So, on 11. Dec. 2008 Paul King of the Groovy Team has deployed a [first RC1 Snapshot of Groovy 1.6]({{ refs.http://snapshots.repository.codehaus.org/org/codehaus/groovy/groovy-all/1.6-RC-1-SNAPSHOT/groovy-all-1.6-RC-1-20081211.113737-1.jar.path }}) which contains all the required OSGi bundle manifest headers as well das the JSR-233 `ScriptEngine` to use the `groovy-all.jar` unmodified with Sling. So just go ahead, grab the Groovy-All 1.6 RC 1 SNAPSHOT deploy it into your Sling instance and enjoy the fun of Groovy.

If you want to be on verge of development, you might want to go for Groovy 1.7: The second SNAPSHOT of beta-1 also contains the required headers and classes and may as well be used unmodified in Sling. You may download it here: `[groovy-all-1.7-beta-1-20081210.120632-2.jar]({{ refs.http://snapshots.repository.codehaus.org/org/codehaus/groovy/groovy-all/1.7-beta-1-SNAPSHOT/groovy-all-1.7-beta-1-20081210.120632-2.jar.path }})`.


To deploy the bundle go to the Bundles page, for example at http://localhost:8080/system/console/bundles of the Apache Felix Web Console select the bundle file to upload, check the *Start* check box and click *Install or Update* button.

You may check, whether the Groovy ScriptEngine has been "accepted" by Sling, by going to the Script Engines page of the Apache Felix Web Console. You should see the entry for Groovy there, somthing like this:


    Groovy Scripting Engine, 2.0
      Language      Groovy,
      Extensions    groovy
      MIME Types    application/x-groovy
      Names         groovy, Groovy



## Testing

To test create a simple Groovy script, for example


    response.setContentType("text/plain");
    response.setCharacterEncoding("UTF-8");
    
    println "Hello World !"
    println "This is Groovy Speaking"
    println "You requested the Resource ${resource} (yes, this is a GString)"


and upload it to the repository as `/apps/nt/folder/GET.groovy` using your favourite WebDAV client or use curl to upload the file (assuming Sling is running on localhost:8080) :


    $ curl -u admin:admin -FGET.groovy=@GET.groovy -F../../nt/jcr:primaryType=sling:Folder http:host:8080/apps/nt/folder


To test it create a `/sample` `nt:Folder` node using your favourite WebDAV client or use curl again:


    $ curl -u admin:admin -Fjcr:primaryType=nt:folder http://localhost:8080/



Finally, request the `/sample` node using your favourite Browser or use curl again:


    $ curl http://localhost:8080/sample
    Hello World !
    This is Groovy Speaking
    You requested Resource JcrNodeResource, type=nt:folder, path=/sample (yes, this is a GString)



## References

* [SLING-315]({{ refs.https://issues.apache.org/jira/browse/SLING-315.path }}) -- The initial Sling issue proposing the addition of a Groovy ScriptEngine to Sling.
* [Groovy Support in Apache Sling]({{ refs.http://markmail.org/message/7sqscr5y2mbk6jko.path }}) -- A short thread on turning the Groovy `groovy-all.jar` into an OSGi Bundle.
* [Groovy in Apache Sling]({{ refs.http://markmail.org/message/47n2ow2jlo553jvk.path }}) -- Thread on adding the `DynamicImport-Package` header to the Groovy bundle manifest.
