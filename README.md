# Apache Sling Website
This repository contains the content of the http://sling.apache.org/ website, which moved in September 2017 from
the Apache CMS to this JBake-generated site.

## How to build and stage the site locally  
Clone this repository, run the below Maven command, open http://localhost:8820/ and enjoy.

    mvn clean package jbake:inline -Djbake.port=8820 -Djbake.listenAddress=0.0.0.0
	
This allows	you to experiment with your changes before eventually publishing them.

## How to publish the website
Clone this repository and run the below commands or equivalent:

	git checkout master

	# Build the site
	mvn clean package

	# Move aside the generated pages
    mv target/sling-site-* /tmp/slingsite

	# Switch to the live branch and sync
	git checkout asf-site
	git pull origin asf-site
	rsync -r /tmp/slingsite/* .

	# At this point, git diff as needed to verify
	# what you're about to publish the The Whole Internet
	# and then
	git commit -a -m "<put something clever here>"
	git push origin asf-site

The ASF's gitpubsub mechanism then synchronizes that content to http://sling.apache.org , usually within a few seconds.

It would be nice to automate this in a Jenkins build...patches welcome!

## TODO
Here's a rough list of things that need to be done after the 2017 migration to gitpubsub.

We'll use jira tickets for more specific things, this is more an overview.

* Activate all the required links that https://whimsy.apache.org/site/ checks

## JBake and other technotes
* Currently using 2.5.1 via the `jbake-maven-plugin`, see under `/bin`, docs at http://jbake.org/docs/2.5.1
* That version of JBake uses https://github.com/sirthias/pegdown for Markdown, syntax info at https://github.com/sirthias/pegdown/blob/master/src/test/resources/MarkdownTest103/Markdown%20Documentation%20-%20Syntax.md , extensions at http://www.decodified.com/pegdown/api/org/pegdown/Extensions.html
* Using Groovy MarkupTemplateEngine, examples at https://github.com/jbake-org/jbake-example-project-groovy-mt , docs for that engine at http://groovy-lang.org/templating.html#_simpletemplateengine
* Other Apache projects using JBake include at least Tamaya (https://github.com/apache/incubator-tamaya-site) , OpenNLP (https://github.com/apache/opennlp-site) and http://incubator.apache.org .

## Useful scripts and commands
To find broken links use 

    wget --spider -r -nd -nv -l 5 http://localhost:8820/ 2>&1 | grep -B1 'broken link'
