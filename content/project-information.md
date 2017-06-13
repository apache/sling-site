Title: Project Information

This document provides an overview of the various documents and links that are part of this project's general information:

* [Community Roles and Processes]({{ refs.apache-sling-community-roles-and-processes.path }})
* [Project Team]({{ refs.project-team.path }})
* [Mailing Lists](#mailing-lists)
* [Issue Tracking](#issue-tracking)
* [Source Repository](#source-repository)
* [Continuous Integration](#continuous-integration)
* [Project License]({{ refs.project-license.path }})
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

This project uses Subversion to manage its source code. Instructions on Subversion use can be found at [http://svnbook.red-bean.com/](http://svnbook.red-bean.com/).

### Web Access

The following is a link to the online source repository.


    http://svn.apache.org/viewvc/sling/trunk


### Anonymous access

The source can be checked out anonymously from SVN with this command:


    $ svn checkout http://svn.apache.org/repos/asf/sling/trunk sling


### Developer access

Everyone can access the Subversion repository via HTTPS, but Committers must checkout the Subversion repository via HTTPS.


    $ svn checkout https://svn.apache.org/repos/asf/sling/trunk sling


To commit changes to the repository, execute the following command to commit your changes (svn will prompt you for your password)


    $ svn commit --username your-username -m "A message"


### Access from behind a firewall

For those users who are stuck behind a corporate firewall which is blocking http access to the Subversion repository, you can try to access it via the developer connection:


    $ svn checkout https://svn.apache.org/repos/asf/sling/trunk sling


### Access through a proxy

The Subversion client can go through a proxy, if you configure it to do so. First, edit your "servers" configuration file to indicate which proxy to use. The files location depends on your operating system. On Linux or Unix it is located in the directory "~/.subversion". On Windows it is in "%APPDATA%\Subversion". (Try "echo %APPDATA%", note this is a hidden directory.)

There are comments in the file explaining what to do. If you don't have that file, get the latest Subversion client and run any command; this will cause the configuration directory and template files to be created.

Example : Edit the 'servers' file and add something like :


    [global]
    http-proxy-host = your.proxy.name
    http-proxy-port = 3128


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
