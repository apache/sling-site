# sling-jbake
Experimenting with JBake for the Apache Sling website.

See also https://issues.apache.org/jira/browse/SLING-6955

## How to publish the website
Build the site as described below, and sync the ./output folder to the asf-site branch 
of this Git repository. The ASF's gitpubsub mechanism then synchronizes that content
on the http://sling.apache.org website.

TODO gitpubsub is not active so far, I will request a test setup to start with.

## How to build the site locally
* Clone this repository
* Run `./bake.sh`
* Open http://localhost:8820/ and enjoy.

## TODO

### "Looks easy" (famous last words)
* Enumerate child pages in documentation/tutorials-how-tos.html -> replace with a manually generated list? or use tags to mark and select that content.
* Fix references like `refs.authentication-tasks.headers.excerpt` as well as `.title` references -> replace with copies of those titles and excerpts, or use tags to mark and select
* Fix remaining `refs.` links -> those are probably broken anyway
* The `#!java` macro is not supported -> convert to monospaced code
* Test the downloads.cgi page, requires an apache.org setup (INFRA-14390)
* Create sitemap page
* Activate all the required links checked by https://whimsy.apache.org/site/

### Nice to have
* JBake 2.5.x does not support the `[TOC]` macro but apparently that will be available once JBake moves to https://github.com/vsch/flexmark-java , probably in its next version. We might wait for that and just mark the TOCs as unsupported for now.
* Left menu is not yellow as on the old site (we might refresh the overall style anyway)

### Final validation, activation etc.
* Review all pages
* Resync the content with the current Sling website if needed, initially synced at r1798604

## Broken tables
The current pegdown parser has troubles with table cells containing special characters.

The following pages still have problems with that:

* http://localhost:8820/documentation/the-sling-engine/the-sling-launchpad.html
* http://localhost:8820/documentation/bundles/sling-settings-org-apache-sling-settings.html
* http://localhost:8820/documentation/bundles/web-console-extensions.html

### Done
* Fix internal links like `refs.project-information.path` 
* Page header and footer, logo etc
* Remove unused assets files and templates (copied from JBake Groovy sample)
* Tables work now, needed the pegdown TABLES extension
* Move images and other files to /assets and convert their links

## JBake and other techn notes
* Currently using 2.5.1, see under `/bin`, docs at http://jbake.org/docs/2.5.1
* Uses https://github.com/sirthias/pegdown for Markdown, syntax info at https://github.com/sirthias/pegdown/blob/master/src/test/resources/MarkdownTest103/Markdown%20Documentation%20-%20Syntax.md , extensions at http://www.decodified.com/pegdown/api/org/pegdown/Extensions.html
* Groovy MarkupTemplateEngine examples at https://github.com/jbake-org/jbake-example-project-groovy-mt , docs for that engine at http://groovy-lang.org/templating.html#_simpletemplateengine
* Other Apache projects using JBake include at least Tamaya and OpenNLP and the Incubator is apparently also switching to it.

## Useful scripts and commands
To find broken links use 

    wget --spider -r -nd -nv -l 5 http://localhost:8820/ 2>&1 | grep -B1 'broken link'

To find leftover `refs.` in pages use

    wget -r -nv -l 5 http://localhost:8820/
    find localhost\:8820/ -type f | xargs grep -l 'refs\.'
