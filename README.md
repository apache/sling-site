# Apache Sling Website
This repository contains the content of the http://sling.apache.org/ website, which moved in September 2017 from
the Apache CMS to this JBake-generated site.

## How to build and stage the site locally  
Clone this repository, run the below Maven command, open http://localhost:8820/ and enjoy.

    mvn clean package -Prun-site
	
This allows	you to experiment with your changes before eventually publishing them.

## How to publish the website
Clone this repository and run the below commands or equivalent:

	# Build the site and review your changes
	mvn clean package

    # deploy the site
    mvn clean package -Ppublish-site -Dmsg="<describe your changes>"

The [ASF's gitpubsub mechanism](https://blogs.apache.org/infra/entry/git_based_websites_available) then synchronizes that content to http://sling.apache.org , usually within a few seconds.

## Variables in page content
Adding `expandVariables=true` to a page's front matter enables simple variables replacement, see the `pageVariables` map in
templates code for which variables are supported or to add more variables. A pattern like `${sling_tagline}` in page content
is replaced by the `sling_tagline` variable if it exists, otherwise a MISSING_PAGE_VARIABLE marker is output.

Please use a `sling.` prefix for new site-related variables in `jbake.properties`, to differentiate from JBake built-in variables.

## TODO
Here's a rough list of things that need to be done after the 2017 migration to gitpubsub.

We'll use jira tickets for more specific things, this is more an overview.

* Activate all the required links that https://whimsy.apache.org/site/ checks

## JBake and other technotes
* Currently using 2.5.1 via the `jbake-maven-plugin`, see under `/bin`, docs at http://jbake.org/docs/2.5.1
* That version of JBake uses https://github.com/sirthias/pegdown for Markdown, syntax info at https://github.com/sirthias/pegdown/blob/master/src/test/resources/MarkdownTest103/Markdown%20Documentation%20-%20Syntax.md , extensions at http://www.decodified.com/pegdown/api/org/pegdown/Extensions.html
* Using Groovy MarkupTemplateEngine, examples at https://github.com/jbake-org/jbake-example-project-groovy-mte , docs for that engine at http://groovy-lang.org/templating.html#_the_markuptemplateengine
* Other Apache projects using JBake include at least Tamaya (https://github.com/apache/incubator-tamaya-site) , OpenNLP (https://github.com/apache/opennlp-site) and http://incubator.apache.org .

## Useful scripts and commands
To find broken links use 

    wget --spider -r -nd -nv -l 5 http://localhost:8820/ 2>&1 | grep -B1 'broken link'
