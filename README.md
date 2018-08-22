[<img src="http://sling.apache.org/res/logos/sling.png"/>](http://sling.apache.org)

 [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

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

The [ASF's gitpubsub mechanism](https://blogs.apache.org/infra/entry/git_based_websites_available) then synchronizes that content to [http://sling.apache.org](http://sling.apache.org), usually within a few seconds. More details about the publication process can be found in the [ASF Documentation about Project sites](https://www.apache.org/dev/project-site.html).

We could automate this using a Jenkins job that's restricted to run on build nodes having the `git-websites` label, as done by [Apache PLC4X](http://plc4x.incubator.apache.org/developers/website.html).

Note that the publish-scm goal might fail if you add lots of changes due to [MSCMPUB-18](https://issues.apache.org/jira/browse/MSCMPUB-18). In that scenario you have to manually perform the git operations, see for instance [this file at revision 3e58fbd7](https://github.com/apache/sling-site/blob/3e58fbd768344d90185a2123ca30afb6ec4f9000/README.md).

## Variables in page content
Adding `expandVariables=true` to a page's front matter enables simple variables replacement, see the `pageVariables` map in
templates code for which variables are supported or to add more variables. A pattern like `${sling_tagline}` in page content
is replaced by the `sling_tagline` variable if it exists, otherwise a MISSING_PAGE_VARIABLE marker is output.

Please use a `sling.` prefix for new site-related variables in `jbake.properties`, to differentiate from JBake built-in variables.

## Other Apache projects using JBake 
It's sometimes useful to ~~steal ideas~~ get inspiration from other projects using similar tools, for now we know of:

 * Tamaya - https://github.com/apache/incubator-tamaya-site
 * OpenNLP - https://github.com/apache/opennlp-site
 * Incubator - https://github.com/apache/incubator

## JBake and other technotes
* Currently using 2.6.1 via the `jbake-maven-plugin`, see under `/bin`, docs at http://jbake.org/docs/2.6.1
* That version of JBake uses [Flexmark](https://github.com/vsch/flexmark-java) as parser for Markdown and [Pegdown extensions](https://github.com/sirthias/pegdown)
* The templates use the [Groovy Markup Template Engine](http://groovy-lang.org/templating.html#_the_markuptemplateengine), other examples are provided at https://github.com/jbake-org/jbake-example-project-groovy-mte


## Useful scripts and commands
To find broken links use

    wget --spider -r -nd -nv -l 5 http://localhost:8820/ 2>&1 | grep -B1 'broken link'

## Deploying when git is configured with user.useConfigOnly = true

It it possible to configure git to not inherit or infer the `user.name` and `user.email`
properties, to avoid the situation where an incorrect value is used.

However, this breaks site publishing as the git checkout no longer inherits the global
configuration settings. To still be able to publish, the following steps are needed

    mvn package -Ppublish-site -Dmsg="your-msg-here"
    cd target/scm-checkout
    git config user.email user@apache.org
    mvn package -Ppublish-site -Dmsg="your-msg-here"

We are publishing the site once, which creates the SCM checkout, and fails to push
since no `user.email` config is set. Then we manually configure this property in
the SCM checkout and try publishing again. Be careful to avoid any `clean` operations
with Maven since it will erase the initial checkout.
