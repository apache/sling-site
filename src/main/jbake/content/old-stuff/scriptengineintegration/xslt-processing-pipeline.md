title=XSLT Processing Pipeline
type=page
status=published
~~~~~~

In the *Apache Sling Scripting W3C XML Processing Support* bundle, Juanjo Vàzquez has implemented XSLT processing support for Sling as another new scripting engine, based on the [Cocoon 3 pipeline engine](http://cocoon.apache.org/3.0/).

## Intro

An XML pipeline specifies a sequence of operations to be performed on zero or more XML documents. There are a number of advantages to using pipelines above all in terms of separation of concerns. On the other hand, we talk about XSLT processing if the operations in a pipeline are performed executing or applying XSLT stylesheets.

XSLT processing support is implemented in Sling as an scripting engine bundle named *Apache Sling Scripting W3C XML Processing Support*. This bundle is based on the [Cocoon 3 pipeline engine](http://cocoon.apache.org/3.0/) and uses the [W3C XProc language](http://www.w3.org/TR/xproc/) in order to specify pipelines to be processed.

For the time being, XProc is partially implemented and it is not clear that Sling must support all W3C recomendation yet. This could depend of concrete user requirements or use cases.

The source code is found in the [contrib/scripting/xproc](http://svn.apache.org/repos/asf/incubator/sling/trunk/contrib/scripting/xproc) module.

## How to Install

Install the `org.apache.sling.scripting.xproc` bundle in order to work with XProc. You can achieve this either building it from `contrib/scripting/xproc` folder in the Sling trunk or by downloading it from the Apache Snapshot repository here: [org.apache.sling.scripting.xproc-2.0.0-incubator-20090403.114403-1.jar](http://people.apache.org/repo/m2-snapshot-repository/org/apache/sling/org.apache.sling.scripting.xproc/2.0.0-incubator-SNAPSHOT/org.apache.sling.scripting.xproc-2.0.0-incubator-20090403.114403-1.jar).

To deploy the bundle go to the bundles page of Apache Felix Web Console (http://localhost:8888/system/console/bundles), select the bundle file to upload, check the Start check box and click Install or Update button.

In order to check whether XProc scripting engine has been installed, go to the Script Engines page of the Apache Felix Web Console and see the entry for XProc there:


    Apache Sling Scripting W3C XML Processing Support, 2.0.0-incubator-SNAPSHOT
      	Language 	XMLProc, 1.0
      	Extensions 	xpl
      	MIME Types 	application/xml
      	Names 	XProc, xml processing, xml pipeline processor 


## How it works

As explained above, the bundle is able to perform a sequence of XSLT transforms on an XML document just as is expressed in a pipeline definition. A pipeline definition is a file with an xpl extension that follows the [W3C XProc grammar](http://www.w3.org/TR/xproc/). Only `p:xslt` steps are supported at the moment.

For the XML input of pipeline, the processing uses a Cocoon generator named `SlingGenerator` that tries to resolve the requested resource as (in order of preference):

* a static XML file 
* a dynamically generated XML 
* the underlying node's export document view 

## Samples

Let's see some samples in order to understand the processing behaviour.

1. Create some content

        #!bash
        $ curl -u admin:admin -F sling:resourceType=xproc -F title="some title" \
        -F text="And some text" http://localhost:8888/foo

2. Use WebDAV or curl to create a pipeline script at `/apps/xproc/xproc.xpl` :

        #!xml
        <?xml version="1.0" encoding="UTF-8"?>
        <p:pipeline xmlns:p="http://www.w3.org/ns/xproc">
        
          <p:xslt>
            <p:input port="stylesheet">
              <p:document href="/apps/xproc/one.xsl"/>
            </p:input>
          </p:xslt>
        
          <p:xslt>
            <p:input port="stylesheet">
              <p:document href="/apps/xproc/two.xsl"/>
            </p:input>
          </p:xslt>
        
        </p:pipeline>

3. Store the XSLT transforms in the repository:

    **`/apps/xproc/one.xsl`**
    
        #!xml
        <xsl:stylesheet version="1.0"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        
            <xsl:template match="/">
              <one>
                <xsl:copy-of select="."/>
              </one>
            </xsl:template>
        
        </xsl:stylesheet>

    **`/apps/xproc/two.xsl`**
    
        #!xml
        <xsl:stylesheet version="1.0"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        
            <xsl:template match="/">
              <two>
                <xsl:copy-of select="."/>
              </two>
            </xsl:template>
        
        </xsl:stylesheet>

4. Request foo.html to execute the pipeline:

        #!bash
        $ curl http://admin:admin@localhost:8888/foo.html
        
        <?xml version="1.0" encoding="UTF-8"?>
        <two>
          <one>
            <foo ...sling:resourceType="xproc" text="And some text" title="some title"/>
          </one>
        </two>

    In this case, the node's document view has been the pipeline's source.

5. Now, store a static XML in the repository at `/foo.xml`:
    
        #!xml
        <?xml version="1.0" encoding="UTF-8"?>
        <foo>
        	<content>
        		foo: static content
        	</content>
        </foo>

    
6. Again, request foo.html to execute the pipeline:

        #!bash
        $ curl http://admin:admin@localhost:8888/foo.html
        
        <?xml version="1.0" encoding="UTF-8"?>
        <two>
          <one>
            <foo>
            	<content>
            	  foo: static content
            	</content>
            </foo>
          </one>
        </two>
    
    This time the pipeline's source has been a static XML file.
    
7. Store a script in the repository at `/apps/xproc/xproc.xml.esp`
    
        #!xml
        <?xml version="1.0" encoding="UTF-8"?>
        <foo>
        	<content>
        		foo: dynamic content
        	</content>
        </foo>


8. Delete the previously created static xml file `/foo.xml`.

9. Request foo.html to execute the pipeline:

        #!bash
        $ curl http://admin:admin@localhost:8888/foo.html
        
        <?xml version="1.0" encoding="UTF-8"?>
        <two>
          <one>
            <foo>
            	<content>
            	  foo: dynamic content
            	</content>
            </foo>
          </one>
        </two>

    This time the pipeline's source has been a dinamically generated XML.

## References

* [Cocoon 3 pipeline engine](http://cocoon.apache.org//3.0/)
* [W3C XProc language](http://www.w3.org/TR/xproc/)
* [SLING-893](https://issues.apache.org/jira/browse/SLING-893)
* [Mail list discussion](http://markmail.org/thread/33h5nhk5e3mswrue)
