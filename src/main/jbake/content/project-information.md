title=Project Information		
type=page
status=published
tags=mailinglists,issuetracker,sourcecode,git,github
~~~~~~

This document provides an overview of the various documents and links that are part of this project's general information:

* [Community Roles and Processes](/project-information/apache-sling-community-roles-and-processes.html)
* [Project Team](/project-information/project-team.html)
* [Mailing Lists](#mailing-lists)
* [Issue Tracking](#issue-tracking)
* [Source Repository](#source-repository)
* [Continuous Integration](#continuous-integration)
* [Project License](/project-information/project-license.html)
* [Documentation Repository](#documentation-repository)


## Mailing Lists

These are the mailing lists that have been established for this project. For each list, there is a subscribe, unsubscribe, and an archive link.

The Sling Users List is the preferred way of getting help with Sling. However, you can also [Ask a Sling question on StackOverflow](http://stackoverflow.com/questions/ask?tags=sling) if you prefer.

| Name | Subscribe | Unsubscribe | Post | Archive | Other Archives |
|--|--|--|--|--|--|
| Sling Users List | [Subscribe](mailto:users-subscribe@sling.apache.org) | [Unsubscribe](mailto:users-unsubscribe@sling.apache.org) | users at sling.apache.org | [lists.apache.org](https://lists.apache.org/list.html?users@sling.apache.org) | [www.mail-archive.com](http://www.mail-archive.com/users@sling.apache.org/) [MarkMail](http://sling.markmail.org) [Nabble](http://apache-sling.73963.n3.nabble.com/Sling-Users-f73968.html) |
| Sling Developers List | [Subscribe](mailto:dev-subscribe@sling.apache.org) | [Unsubscribe](mailto:dev-unsubscribe@sling.apache.org) | dev at sling.apache.org | [lists.apache.org](https://lists.apache.org/list.html?dev@sling.apache.org) | [www.mail-archive.com](http://www.mail-archive.com/dev@sling.apache.org/) [MarkMail](http://sling.markmail.org) [Nabble](http://apache-sling.73963.n3.nabble.com/Sling-Dev-f73966.html) |
| Sling Source Control List | [Subscribe](mailto:commits-subscribe@sling.apache.org) | [Unsubscribe](mailto:commits-unsubscribe@sling.apache.org) | | [lists.apache.org](https://lists.apache.org/list.html?commits@sling.apache.org) | [www.mail-archive.com](http://www.mail-archive.com/commits@sling.apache.org/) [MarkMail](http://sling.markmail.org) |


## Issue Tracking

This project uses JIRA a J2EE-based, issue tracking and project management application. Issues, bugs, and feature requests should be submitted to the following issue tracking system for this project.

The issue tracker can be found at [http://issues.apache.org/jira/browse/SLING](http://issues.apache.org/jira/browse/SLING)


## Source Repository

As of October 2017 the Sling source code has migrated to multiple GitHub repositories, synced to the canonical ASF Git repositories using the [ASF Git](https://gitbox.apache.org/) services.

All our repositories have `sling` in their name and are found under the `apache` organization, use [this search link](https://github.com/apache/?utf8=%E2%9C%93&q=sling) to find them.

As of October 19th this migration is not fully complete, see [SLING-3987](https://issues.apache.org/jira/browse/SLING-3987) for details.


## Continuous Integration

Sling builds run automatically on the [ASF's Jenkins instance](https://builds.apache.org/), triggered
by commits.

We maintain multiple build jobs, typically one or two per module. These are grouped into two views:

* [Sling](https://builds.apache.org/view/S-Z/view/Sling/), which holds all Sling-related jobs
* [Sling-Dashboard](https://builds.apache.org/view/S-Z/view/Sling-Dashboard/), which holds all Sling jobs needing attention, such as failed jobs.

More documentation regarding the Jenkins setup is available as wiki links from the views mentioned above.

## Documentation Repository
The documentation website, in fact the very page that you are reading right now, is located at [The ASF Content Management System’s Sling project](https://cms.apache.org/sling/). You can contribute without being an official project committer.

###Save your changes as an SVN patch:

1. Log in as username *anonymous* and leave the password blank.
1. Click *Get sling Working Copy* to check out a local branch through the browser.
1. Navigate to a document and click *edit*.
1. Edit the page in the online markdown editor.
1. Uncheck *Quick Mail*.
1. Click *submit*.
1. Click *Diff*, then *Download Diff* and save the SVN patch to your computer.

###Submit your changes:

1. Navigate to the [Jira issue tracker](https://issues.apache.org/jira/browse/SLING).
1. Create an account and/or login.
1. Create a ticket, enter a description and choose *Documentation* for *Components*.
1. Select the ticket, click *more*, select *attach files* and attach your SVN patch.

###Further resources:

1. Read the [ASF CMS reference for non-committers](http://www.apache.org/dev/cmsref#non-committer).
1. Watch a [video tutorial by Rob Weir for anonymous users](http://s.apache.org/cms-anonymous-tutorial).
