# sling-jbake
Experimenting with JBake for the Apache Sling website.

See also https://issues.apache.org/jira/browse/SLING-6955


## How to build the site locally
* Clone this repository
* Run `./bake.sh`
* Open http://localhost:8820/ and enjoy.

## TODO

### "Looks easy" (famous last words)
* Move images and other files to /assets and convert their links
* Enumerate child pages in documentation/tutorials-how-tos.html -> replace with a manually generated list? or use tags to mark and select that content.
* Fix references like `refs.authentication-tasks.headers.excerpt` as well as `.title` references -> replace with copies of those titles and excerpts, or use tags to mark and select
* Fix remaining `refs.` links -> those are probably broken anyway
* The `#!java` macro is not supported -> convert to monospaced code
* Finish the dynamic downloads page, links are still TODO + test with CGI script

### Might be harder
* Remove or replace the `[TOC]` macro (but we might do without it)

### Nice to have, maybe later
* Left menu is not yellow as on the old site (we might refresh the overall style anyway)

### Final validation, activation etc.
* Review all pages
* Resync the content with the current Sling website if needed, initially synced at r1798604
* Move the Git repository to apache.org, create an `asf-site` branch for the live content and ask infra to setup gitpubsub to activate it

### Done
* Fix internal links like `refs.project-information.path` 
* Page header and footer, logo etc
* Remove unused assets files and templates (copied from JBake Groovy sample)
* Tables work now, needed the pegdown TABLES extension

## JBake notes
* Currently using 2.5.1, see under `/bin`, docs at http://jbake.org/docs/2.5.1
* Uses https://github.com/sirthias/pegdown for Markdown, syntax info at https://github.com/sirthias/pegdown/blob/master/src/test/resources/MarkdownTest103/Markdown%20Documentation%20-%20Syntax.md , extensions at http://www.decodified.com/pegdown/api/org/pegdown/Extensions.html
* Groovy MarkupTemplateEngine examples at https://github.com/jbake-org/jbake-example-project-groovy-mt , docs for that engine at http://groovy-lang.org/templating.html#_simpletemplateengine
