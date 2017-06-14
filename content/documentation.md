title=TODO title for documentation.md 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: Documentation

[TOC]

#Overview

The documentation is split into different parts:

   * [Getting Started](/documentation/getting-started.html), the right place to start!
   * [The Sling Engine](/documentation/the-sling-engine.html), all about the heart of Sling
   * [Development](/documentation/development.html), how do I get and develop with Sling
   * [Bundles](/documentation/bundles.html), which bundle delivers which features to Sling
   * [Tutorials & How-Tos](/documentation/tutorials-how-tos.html)
   * [Wiki](http://cwiki.apache.org/SLING/)
   * [Configuration](/documentation/configuration.html)
   * [API Doc](http://sling.apache.org/apidocs/sling8/index.html)


# How you can contribute

We're on the way to improve the documentation, but it's a long way. If you would like to contribute to the documentation you are very welcome. Please directly post your proposals to the [public wiki](http://cwiki.apache.org/SLING/) or post your suggestions to the [mailing list](/project-information.html).


# How the documentation is generated

*The Sling web site and documentation are managed with the [Apache CMS](https://www.apache.org/dev/cms.html).
For Apache Sling specific extensions see the [The Sling Site](#the-sling-site)
section below.*

<div class="info">
<p>
The Sling site was converted from a Confluence exported site to an
Apache CMS managed site. All non-fully converted pages will show a tip box pointing to
the original Confluence exported page for reference.
</p>

<p>
Once migration of a page has completed the <code>translation_pending</code>
header should be removed from the page source. After that the tip box will not be
shown any more.
</p>

</div>

The basic documentation of Sling is made up of four parts:

1. The Sling Site at http://sling.apache.org/ (you are here)
1. The Public Wiki at http://cwiki.apache.org/SLING
1. The JavaDoc
1. The Maven plugin documentation

This page is about how this documentation is maintained and who is allowed to do what.


## The Sling Site

The site is managed with the [Apache CMS](https://www.apache.org/dev/cms.html)
where the source is kept in SVN at <https://svn.apache.org/repos/asf/sling/site/trunk/content>.

This section lists some Apache Sling features to help with the maintenance
of the site, such as automatic link generation.

Start the file with a `Title:` line to define the page title and the first H1 tag:

    Title: Page Title
    
    Here comes the content separated with a blank like from the
    header ...
    
The last modification information from SVN (revision, committer, and
date/time) is automatically added when the page is rendered

Excerpts can be added to a page using the `Excerpt:` header:

    Title: Page Title
    Excerpt: Summary of the page for inclusion in other pages;
       continuation of the excerpt must be indented
       
    Here comes the content separated with a blank like from the
    header ...

Metadata from child pages can be referred to in the content with the
Django variable reference notation using the child page name (without
extension) as its container; e.g. for the child page named `childpage`:

    :::django
    {{ y|default:"{{" }} children.childpage.headers.excerpt }}
    {{ y|default:"{{" }} children.childpage.headers.title }}

Content Pages can contain Django templates of the form `{{ y|default:"{{" }}...}}` and `{{ y|default:"{%" }}...%}`.
If so, the page content is evaluated as a Django template before running
it through the page template.

Any page in the site can be referenced with refs.pagename returning properties:

`.path`
:    the absolute path of the page on the site

`.headers`
:    page headers (e.g. `.title`, `.excerpt`)

`.content`
:    the raw page content
       
All pages in the children namespace are also available in the refs namespace
    
Some usefull hints:

Printing title of another page "handler":
       
       :::django
       {{ y|default:"{{" }} refs.handler.headers.title }}

Printing excerpt of another page "handler":
       
       :::django
       {{ y|default:"{{" }} refs.handler.headers.excerpt }}
  
Linking to another page "handler":
       
       :::django
       ({{ y|default:"{{" }} refs.handler.path }})
       
Printing title as a link to another page "handler":
       
       :::django
       [{{ y|default:"{{" }} refs.handler.headers.title }}]({{ y|default:"{{" }} refs.handler.path }})
       
Printing excerpt as a link to another page "handler":
       
       :::django
       [{{ y|default:"{{" }} refs.handler.headers.excerpt }}]({{ y|default:"{{" }} refs.handler.path }})
       
Print a bullet pointed child page list:

       :::django
       {{ y|default:"{%" }} for label, page in children %}* [{{ y|default:"{{" }} page.headers.title }}]({{ y|default:"{{" }} page.path }})
       {{ y|default:"{%" }} endfor %}

<div class="note">
It is important to have the first part as a single line, otherwise
the Django/Markdown combo will create a list for each entry.
</div>

### Code Highlighting

Code Highlighting works by indenting code by four blanks. To indicate the
type of highlighting preced the code style text with either `:::<lexer>` to
get high lighted code using the given `<lexer>` or `#!<lexer>` to get high
lighted code with line numbers using the given `<lexer>`. See
<http://www.apache.org/dev/cmsref.html#code-hilighter> for main info and
<http://pygments.org/docs/lexers/> for supported lexers


### Manual Generation

When commiting changes to pages into SVN the pages are automatically
generated in [the staging site](http://sling.staging.apache.org).

To manually generate the site or single pages the [site](http://svn.apache.org/repos/asf/felix/site)
can be checked out from SVN. In addition Perl and Python must be installed
for the build tools to work.

To prepare for site build, the Markdown daemon has to be started:

    :::sh
    $ export MARKDOWN_SOCKET="$PWD/tools/build/../markdown.socket"
    $ export PYTHONPATH="$PWD/tools/build"
    $ python "$PWD/tools/build/markdownd.py"

The `MARKDOWN_SOCKET` environment variables is also required by the `build_site.pl`
and `build_file.pl` scripts to connect to the Markdown daemon.

To build the complete site use the `build_site.pl` script:

    :::sh
    $ tools/build/build_site.pl --source-base $PWD/trunk \
        --target-base $PWD/trunk/target

To build a single page use the `build_file.pl` script:

    :::sh
    $ tools/build/build_site.pl --source-base $PWD/trunk \
        --target-base $PWD/trunk/target \
        --source content/documentation.mdtext

The argument to the `--source` parameter is relative to the `--source-base` folder.


## The Public Wiki

The public wiki of Sling is available at [http://cwiki.apache.org/SLING](http://cwiki.apache.org/SLING) and is maintained in the Confluence space *SLING*. Everyone can create an account there. To gain edit rights please ask via the [mailing list](/project-information.html). Any of the administrators listed in the [Space Overview](https://cwiki.apache.org/confluence/spaces/viewspacesummary.action?key=SLING&showAllAdmins=true) can give you access.


## The JavaDoc

With every major release of Sling the JavaDoc of all containing bundles are published below [http://sling.apache.org/apidocs/](http://sling.apache.org/apidocs/).
The script for generating this aggregation JavaDoc is at [http://svn.apache.org/repos/asf/sling/trunk/tooling/release/](http://svn.apache.org/repos/asf/sling/trunk/tooling/release/) in `generate_javadoc_for_release.sh`

In addition every released bundle is released together with its JavaDoc (which is also pushed to Maven Central).

## The Maven Plugin Documentation

For the most important Maven Plugins the according Maven Sites (generated with the `maven-site-plugin`) are published at [http://sling.apache.org/components/](http://sling.apache.org/components/). The description on how to publish can be found at [Release Management](/documentation/development/release-management.html).
