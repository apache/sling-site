[![Apache Sling](https://sling.apache.org/res/logos/sling.png)](https://sling.apache.org)

&#32;[![Build Status](https://ci-builds.apache.org/job/Sling/job/modules/job/sling-site/job/master/badge/icon)](https://ci-builds.apache.org/job/Sling/job/modules/job/sling-site/job/master/)&#32;[![Sonarcloud Status](https://sonarcloud.io/api/project_badges/measure?project=apache_sling-site&metric=alert_status)](https://sonarcloud.io/dashboard?id=apache_sling-site) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

# Apache Sling Website
This repository contains the content of the http://sling.apache.org/ website, which moved in September 2017 from the Apache CMS to this JBake-generated site.

## How to build and stage the site locally  
Clone this repository, run the below Maven command, open <http://localhost:8820/> and enjoy.

    mvn clean package -Prun-site
	
This allows	you to experiment with your changes before eventually publishing them.

To also activate the site search feature, use

    mvn clean package -Ppagefind,run-site

## How to publish the website

The publishing process consists out of 2 steps:

```
Original: master branch (mainly markdown files)

   |  
   |   1. Build site via Jenkins or local Maven Build with JBake
  \|/  

asf-site branch (mainly JBake-generated html files, but also m-site-p generated Maven plugin sites or Javadocs)

   |
   |   2. Publish via ASF gitpubsub, controlled via .asf.yaml
  \|/  

https://sling.apache.org
```

Each push to the `master` branch automatically regenerates and publishes the website to <https://sling.apache.org>, see
[SLING-7180](https://issues.apache.org/jira/browse/SLING-7180) for details. The corresponding Jenkins job is linked from the "build"
badge at the top of this file. The publication contains out of multiple steps.

First the site is built with JBake and then the results are pushed again to the same Git repository into the dedicated branch `asf-site`. This happens with [maven-scm-publish-plugin](https://maven.apache.org/plugins/maven-scm-publish-plugin/).
Note that the `publish-scm` goal might fail if you add lots of changes due to [MSCMPUB-18](https://issues.apache.org/jira/browse/MSCMPUB-18). In that scenario you have to manually perform the git operations, see for instance [this file at revision 3e58fbd7](https://github.com/apache/sling-site/blob/3e58fbd768344d90185a2123ca30afb6ec4f9000/README.md).

Afterwards [ASF's gitpubsub mechanism](https://blogs.apache.org/infra/entry/git_based_websites_available) synchronizes that content from branch `asf-site` to [https://sling.apache.org](https://sling.apache.org), usually within a few seconds. More details about the publication process can be found in the [ASF Documentation about Project sites](https://www.apache.org/dev/project-site.html). If for some reason this process fails, you can use [the self-service page from ASF Infra](https://selfserve.apache.org/) to trigger a resync of the git repo.

However, if for some reason you need to manually publish the website to the `asf-site` branch the following instructions can be used:

Clone this repository and run the below commands or equivalent:

	# Build the site and review your changes
	mvn clean package

    # deploy the site
    mvn clean package -Ppublish-site -Dmsg="<describe your changes>"


## Variables in page content
Adding `expandVariables=true` to a page's front matter enables simple variables replacement, see the `pageVariables` map in
templates code for which variables are supported or to add more variables. A pattern like `${sling_tagline}` in page content
is replaced by the `sling_tagline` variable if it exists, otherwise a MISSING_PAGE_VARIABLE marker is output.

Please use a `sling.` prefix for new site-related variables in `jbake.properties`, to differentiate from JBake built-in variables.

## Front Matter
A number of Markdown front matter variables are taken into account, here's an example:

    title=Tutorials & How-Tos               
    type=page
    status=published
    tags=tutorials,beginner
    tableOfContents=false
    ~~~~~~

## Syntax highlighting
The site uses [highlight.js](https://highlightjs.org/) for that.

Highlighting can be disabled by specifying an unknown language in the `<pre>` blocks that are highlighted by default, like for example

    <pre class="language-no-highlight">
    This will not be highlighted.
    </pre>

## Site search

The site search is based on [Pagefind](https://pagefind.app/), which is also used by the ASF
[community](https://community.apache.org/) and [www](https://www.apache.org/) websites. Searching the source code for "pagefind" shows how the integration works.

## Other Apache projects using JBake 
It's sometimes useful to ~~steal ideas~~ get inspiration from other projects using similar tools, for now we know of:

 * Tamaya - https://github.com/apache/incubator-tamaya-site
 * OpenNLP - https://github.com/apache/opennlp-site
 * Incubator - https://github.com/apache/incubator
 
And [this query for the `jbake` topic](https://github.com/search?q=topic%3Ajbake+org%3Aapache&type=Repositories) might find others.

## JBake and other technotes
* Currently using 2.7.0-rc.7 via the `jbake-maven-plugin`, docs at <https://jbake.org/docs/latest/>
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
