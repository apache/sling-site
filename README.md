# sling-jbake
Experimenting with JBake for the Apache Sling website

## TODO
* Add proper front matter to all pages
* Use the page template instead of post
* Use tags in the page template and for navigation
* Fix internal links like `refs.project-information.path` (how? not sure so far)
* Left menu is not yellow as on the old site
* Page header and footer, logo etc
* Move images and other files to /assets and convert their links
* Remove unused assets files and templates (copied from JBake Groovy sample)
* Implement the dynamic downloads page
* Enumerate child pages in documentation/tutorials-how-tos.html
* Tables are broken in project-information.html for example
* Fix references like `refs.authentication-tasks.headers.excerpt` as well as `.title` references
* Fix remaining `refs.` links
* Remove or replace the `[TOC]` macro
* Resync the content with the current Sling website if needed, initially synced at r1798604

## JBake notes
* Currently using 2.5.1, see under `/bin`, docs at http://jbake.org/docs/2.5.1
* Apparently uses https://github.com/sirthias/pegdown for Markdown, syntax info at https://github.com/sirthias/pegdown/blob/master/src/test/resources/MarkdownTest103/Markdown%20Documentation%20-%20Syntax.md
* Groovy MarkupTemplateEngine examples at https://github.com/jbake-org/jbake-example-project-groovy-mt , docs for that engine at http://groovy-lang.org/templating.html#_simpletemplateengine
