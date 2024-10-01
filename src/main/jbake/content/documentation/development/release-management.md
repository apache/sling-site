title=Release Management		
type=page
status=published
tags=development,pmc
~~~~~~

[TOC]

## Prerequisites

* To prepare or perform a release you *MUST BE* at least be an Apache Sling Committer.
* Try to update to the most recent parent release prior to doing a release
* Each release must be signed, see _Appendix A_ below about creating and registering your key.
* Make sure you have all [Apache servers](http://maven.apache.org/developers/committer-settings.html) defined in your `settings.xml`
* See Appendix B for Maven and SCM credentials

*Note*: Listing the Apache servers in the `settings.xml` file also requires adding the password to that file. Starting with Maven 2.1 this password may be encrypted and needs not be give in plaintext. Please refer to [Password Encryption](http://maven.apache.org/guides/mini/guide-encryption.html) for more information.

In the past we staged release candidates on our local machines using a semi-manual process. Now that we inherit from the Apache parent POM version 6, a repository manager will automatically handle staging for you. This means you now only need to specify your GPG passphrase in the release profile of your `$\{user.home\}/.m2/settings.xml`:


    <settings>
        ...
        <profiles>
            <profile>
                <id>apache-release</id>
                <properties>
                    <gpg.passphrase> <!-- YOUR (encrypted) KEY PASSPHRASE --> </gpg.passphrase>
                </properties>
            </profile>
        </profiles>
        ...
    </settings>


Everything else has been configured in the latest Sling Parent POM:


    <parent>
        <groupId>org.apache.sling</groupId>
        <artifactId>sling</artifactId>
        <version>6</version>
    </parent>


## Experimental Release Management Docker Image

Some the release management steps can be further automated by using the [Sling Commiter CLI Docker Image](https://github.com/apache/sling-org-apache-sling-committer-cli). The image is for now work-in-progress but has been used to drive multiple release. Please see the README file in the linked repository for usage details.

## Staging the Release Candidates

First prepare your POMs for release:

1. Make sure there are no snapshots in the POMs to be released. In case you rely on a release version which is not yet promoted, you have to temporarily switch that dependency version to the release version. This might break the Jenkins CI build though, as the staged version is not yet visible to Jenkins, so revert this change after you have staged the release candidate.
1. Check that your POMs will not lose content when they are rewritten during the release process

        $ mvn release:prepare -DdryRun=true

    Compare the original `pom.xml` with the one called `pom.xml.tag` to see if the license or any other info has been removed. This has been known to happen if the starting `<project>` tag is not on a single line. The only things that should be different between these files are the `<version>` and `<scm>` elements. If there are any other changes, you must fix the original `pom.xml` file and commit before proceeding with the release.

1. Publish a snapshot

        $ mvn deploy
        ...
        [INFO] [deploy:deploy]
        [INFO] Retrieving previous build number from apache.snapshots.https
        ...

    * If you experience an error during deployment like a HTTP 401 check your settings for the required server entries as outlined in the *Prerequisites*
    * Depending on the OS & the gpg version you have, you might hit https://issues.apache.org/jira/browse/MGPG-59, in which case you need, before maven command, to run `gpg --use-agent --armor --detach-sign --output $(mktemp) pom.xml`
    * Make sure the generated artifacts respect the Apache release [rules](http://www.apache.org/dev/release.html): NOTICE and LICENSE files should be present in the META-INF directory within the jar. For \-sources artifacts, be sure that your POM does not use the maven-source-plugin:2.0.3 which is broken. The recommended version at this time is 2.0.4
    * You should verify the deployment under the [snapshot](https://repository.apache.org/content/groups/snapshots/org/apache/sling) repository on Apache

1. Prepare the release

        $ mvn release:clean
        $ mvn release:prepare

    * Preparing the release will create the new tag in GIT, automatically checking in on your behalf

1. Stage the release for a vote

        $ mvn release:perform

    * The release will automatically be inserted into a temporary staging repository for you, see the Nexus [staging documentation](http://www.sonatype.com/books/nexus-book/reference/staging.html) for full details
    * You can continue to use `mvn release:prepare` and `mvn release:perform` on other sub-projects as necessary on the same machine and they will be combined in the same staging repository - this is useful when making a release of multiple Sling modules.

1. Close the staging repository:
    * Login to [https://repository.apache.org](https://repository.apache.org) using your Apache credentials. Click on *Staging Repositories* on the left. Then click on *org.apache.sling* in the list of repositories. In the panel below you should see an open repository that is linked to your username and IP. Right click on this repository and select *Close*. This will close the repository from future deployments and make it available for others to view. If you are staging multiple releases together, skip this step until you have staged everything

1. Verify the staged artifacts
    * If you click on your repository, a tree view will appear below. You can then browse the contents to ensure the artifacts are as you expect them. Pay particular attention to the existence of \*.asc (signature) files. If you don't like the content of the repository, right click your repository and choose *Drop*. You can then redo (see [Redoing release perform](#redoing-release-perform)) or rollback your release (see *Canceling the Release*) and repeat the process
    * Note the staging repository URL, especially the number at the end of the URL. You will need this in your vote email

### Redoing release perform

If perform fails for whatever reason (e.g. staged artifacts are incomplete or signed with a wrong key) drop the staging repository and create a required `release.properties` file containing `scm.url` and `scm.tag` manually.

Example `release.properties` file:

    scm.url=scm:git:https://gitbox.apache.org/repos/asf/sling-org-apache-sling-settings.git
    scm.tag=org.apache.sling.settings-1.3.10

Execute perform step again:

    $ mvn release:perform

### Redeploying staged artifacts

It may happen that deployment to Nexus fails or is partially successful. To fix such a deployment, you can re-deploy the artifacts from within the SCM checkout:

    $ cd target/checkout
    $ mvn deploy -Papache-release

## Starting the Vote

Propose a vote on the dev list with the closed issues, the issues left, and the staging repository - for example:


    To: "Sling Developers List" <dev@sling.apache.org>
    Subject: [VOTE] Release Apache Sling ABC version X.Y.Z
    
    Hi,
    
    We solved N issues in this release:
    https://issues.apache.org/jira/secure/ReleaseNote.jspa?projectId=12310710&version=[YOUR JIRA RELEASE VERSION ID]&styleName=Text
    
    Staging repository:
    https://repository.apache.org/content/repositories/orgapachesling-[YOUR REPOSITORY ID]/
    
    You can use this UNIX script to download the release and verify the signatures:
    https://raw.githubusercontent.com/apache/sling-tooling-release/master/check_staged_release.sh
    
    Usage:
    sh check_staged_release.sh [YOUR REPOSITORY ID] /tmp/sling-staging
    
    Please vote to approve this release:
    
      [ ] +1 Approve the release
      [ ]  0 Don't care
      [ ] -1 Don't release, because ...
    
    This majority vote is open for at least 72 hours.

## Wait for the Results

From [Votes on Package Releases](http://www.apache.org/foundation/voting.html):

> Votes on whether a package is ready to be released follow a format similar to majority 
> approval -- except that the decision is officially determined solely by whether at least 
> three \+1 votes were registered. Releases may not be vetoed. Generally the community 
> will table the vote to release if anyone identifies serious problems, but in most cases 
> the ultimate decision, once three or more positive votes have been garnered, lies with 
> the individual serving as release manager. The specifics of the process may vary from 
> project to project, but the 'minimum of three \+1 votes' rule is universal.

The list of binding voters is available on the [Project Team](/project-information/project-team.html) page.


If the vote is successful, post the result to the dev list - for example:



    To: "Sling Developers List" <dev@sling.apache.org>
    Subject: [RESULT] [VOTE] Release Apache Sling ABC version X.Y.Z
    
    Hi,
    
    The vote has passed with the following result :
    
    +1 (binding): <<list of names>>
    +1 (non binding): <<list of names>>
    
    I will copy this release to the Sling dist directory and
    promote the artifacts to the central Maven repository.


Be sure to include all votes in the list and indicate which votes were binding. Consider \-1 votes very carefully. While there is technically no veto on release votes, there may be reasons for people to vote \-1. So sometimes it may be better to cancel a release when someone, especially a member of the PMC, votes \-1.

If the vote is unsuccessful, you need to fix the issues and restart the process - see *Canceling the Release*. Note that any changes to the artifacts under vote require a restart of the process, no matter how trivial. When restarting a vote version numbers must not be reused, since binaries might have already been copied around.

If the vote is successful, you need to promote and distribute the release - see *Promoting the Release*.



## Canceling the Release

If the vote fails, or you decide to redo the release:

1. Remove the release tag from Git (`git push --delete origin ${tagName}`)
1. Login to [https://repository.apache.org](https://repository.apache.org) using your Apache credentials. Click on *Staging Repositories* on the left. Then click on *org.apache.sling* in the list of repositories. In the panel below you should see a closed repository that is linked to your username and IP (if it's not yet closed you need to right click and select *Close*). Right click on this repository and select *Drop*.
1. Remove the old version from Jira
    1. Create a new version in Jira with a version number following the one of the cancelled release
    1. Move all issues with the fix version set to the cancelled release to the next version
    1. Delete the old version from Jira
1. Reply to the original release vote email to announce the cancellation
    1. Add `[CANCELLED]` to the subject line
    1. Briefly explain why the release needs to be cancelled 
1. Commit any fixes you need to make and start a vote for a new release.

## Promoting the Release

If the vote passes:


1. Push the release to [https://dist.apache.org/repos/dist/release/sling/](https://dist.apache.org/repos/dist/release/sling/). This is only possible for PMC members (for a reasoning look at [http://www.apache.org/dev/release.html#upload-ci](http://www.apache.org/dev/release.html#upload-ci)). If you are not a PMC member, please ask one to do the upload for you.
	1. Commit the released artifacts to [https://dist.apache.org/repos/dist/release/sling/](https://dist.apache.org/repos/dist/release/sling/) which is replicated to [http://www.apache.org/dist/sling/](http://www.apache.org/dist/sling/) quickly via svnpubsub. See [the section on quick artifact updates](#quick-update-of-artifacts-in-dist) for a way to avoid having to checkout the whole folder first. The easiest to do this is to get the released artifact using the check script (check&#95;staged&#95;release.sh) and then simply copy the artifacts from the downloaded folder to your local checkout folder. Make sure to not add the checksum files for the signature file \*.asc.\*).
        * Make sure to *not* change the end-of-line encoding of the .pom when uploaded via svn import! Eg when a windows style eol encoded file is uploaded with the setting '*.pom = svn:eol-style=native' this would later fail the signature checks!
    1. Delete the old release artifacts from that same dist.apache.org svn folder (the dist directory is archived)
1. Push the release to Maven Central
    1. Login to [https://repository.apache.org](https://repository.apache.org) with your Apache SVN credentials. Click on *Staging Repositories*. Find your closed staging repository and select it by checking the select box. Click *Release* from the menu above and confirm.
    2. Once the release is promoted click on *Repositories* on the left, select the *Releases* repository and validate that your artifacts are all there.
3. Following the release promotion you will receive an email from the 'Apache Reporter Service'. Follow the link and add the release data, as it used by the PMC chair to prepare board reports. To simplify this task you can use the script from [https://github.com/apache/sling-tooling-release/blob/master/update_reporter.sh](https://github.com/apache/sling-tooling-release/blob/master/update_reporter.sh).
2. Update the releases section on the website at [releases](/releases.html).
3. For new modules, update the download page on the website at [downloads](/downloads.cgi) to point to the new release. For this you need to modify the [according Groovy Template](https://github.com/apache/sling-site/blob/master/src/main/jbake/templates/downloads.tpl). For existing modules the [renovate app](https://github.com/renovatebot/renovate/) will generate a pull request. The pull request must be manually merged.
4. If you think that this release is worth a news entry, update the website at  [news](/news.html)

For the last two tasks, it's better to give the CDN some time to process the uploaded artifacts (15 minutes should be fine). This ensures that once the website (news and download page) is updated, people can actually download the artifacts.

### Quick update of artifacts in dist

It is possible to update the artifacts without needing to checkout or update the full dist folder, which can be quite slow, by using `svn import` and `svn delete` on the remote SVN repository.

Assuming that we are releasing `org.apache.sling.engine 2.6.22` and the old version artifact names start with `org.apache.sling.engine-2.6.20`, we can run the following commands

    $ cd <folder where 2.6.22 is found>
    $ svn import -m "Release org.apache.sling.engine-2.6.22" . https://dist.apache.org/repos/dist/release/sling
    $ svn delete -m "Remove old version org.apache.sling.engine-2.6.20" $(svn ls https://dist.apache.org/repos/dist/release/sling/ | grep org.apache.sling.engine-2.6.20 | while read line; do echo "https://dist.apache.org/repos/dist/release/sling/$line"; done)

This makes sure that the new artifacts are imported and the old ones are deleted.

## Update JIRA

Go to [Manage Versions](https://issues.apache.org/jira/plugins/servlet/project-config/SLING/versions) section on the SLING JIRA and mark the X.Y.Z version as released setting the release date to the date the vote has been closed.

Also create a new version X.Y.Z+2, if that hasn't already been done.

And keep the versions sorted, so when adding a new version moved it down to just above the previous versions.

Close all issues associated with the released version.

## Update the Sling Starter Module

If the new release should be included in the [Sling Starter](https://github.com/apache/sling-org-apache-sling-starter), please create PR after the artifacts are available on Maven Central. That usually happens within 60 minutes of the staging repository being closed.

If the released module was already included in the Sling Starter, a pull request will be generated by the [renovate app](https://github.com/renovatebot/renovate/), you can approve it as soon as the automated checks pass.

## Create an Announcement

We usually do such announcements only for "important" releases, as opposed to small individual module
releases which are just announced on our [news](/news.html) page.

    To: "Sling Developers List" <dev@sling.apache.org>, "Apache Announcements" <announce@apache.org>
    Subject: [ANN] Apache Sling ABC version X.Y.Z Released
    
    The Apache Sling team is pleased to announce the release of Apache Sling ABC version X.Y.Z
    
    Apache Sling is a web framework that uses a Java Content Repository, such as Apache 
    Jackrabbit, to store and manage content.  Sling applications use either scripts or 
    Java servlets, selected based on simple name conventions, to process HTTP requests 
    in a RESTful way.
    
    <<insert short description of the sub-project>>
    
    http://sling.apache.org/site/apache-sling-ABC.html
    
    This release is available from http://sling.apache.org/site/downloads.cgi

    Building from verified sources is recommended, but convenience binaries are
    also available via Maven:
    
    <dependency>
        <groupId>org.apache.sling</groupId>
        <artifactId>org.apache.sling.ABC</artifactId>
        <version>X.Y.Z</version>
    </dependency>
        
    Release Notes:
    
    <<insert release notes in text format from JIRA>>
    
    Enjoy!
    
    -The Sling team

*Important*: Add the release to the Software section of the next board report below [Reports](https://cwiki.apache.org/confluence/display/SLING/Reports).

## Related Links

1. [http://www.apache.org/dev/release-signing.html](http://www.apache.org/dev/release-signing.html)
1. [http://wiki.apache.org/incubator/SigningReleases](http://wiki.apache.org/incubator/SigningReleases)

## Releasing the Sling IDE Tooling

<div class="note">Eclipse is very aggresive about caching artifacts with the same coordinates. Make sure that once you build the artifacts 
with code signing enabled you install the right ones. If you install artifacts with the same version but not signed, Eclipse will cache
that version indefinitely with no known workaround except setting up a new installation of Eclipse.</div>

While the Sling IDE tooling is built using Maven, the toolchain that it is based around does not cooperate well with the maven-release-plugin. As such, the release preparation and execution are slightly different. Also note that we sign release using the Symantec code signing service, see [Using the code signing service ](https://reference.apache.org/pmc/codesigning) for details.

Before starting, it is recommended to run throught the [Sling IDE Tooling release testing](https://cwiki.apache.org/confluence/display/SLING/Sling+IDE+Tooling+release+testing),
to make sure no regressions have snuck in.

<div class="note">While we sort out a proper location you will need to locally build install the <tt>codesign-maven-plugin</tt> from
<a href="https://github.com/apache/sling-whiteboard/tree/master/codesign">https://github.com/apache/sling-whiteboard/tree/master/codesign</a>.</div>

The whole process is outlined below, assuming that we start with a development version of 1.0.1-SNAPSHOT.

1. set the fix version as released: `mvn tycho-versions:set-version -DnewVersion=1.0.2`
1. update the version of the source-bundle project to 1.0.2
1. commit and push the change
1. Tag the commit using `git tag -a -m 'Tag 1.0.2 release' sling-ide-tooling-1.0.2`
1. update to next version: `mvn tycho-versions:set-version -DnewVersion=1.0.3-SNAPSHOT` and also update the version of the source-bundle project
1. commit and push the change
1. checkout the version from the tag and proceed with the build from there `git checkout sling-ide-tooling-1.0.2`
1. In `p2update/pom.xml`, uncomment the `codesign-maven-plugin` declaration and change the code signing service to _Java Signing Sha256_. Note that the process might fail during the code signing with a SAAJ error, retrying usually fixes it.
1. build the project with p2/gpg signing enabled: `mvn clean package -Pcodesign`
1. manually build the zipped p2 repository: `cd p2update/target/repository-signed && zip -r org.apache.sling.ide.p2update-1.0.2.zip . && cd -`
1. build the source bundle from the source-bundle directory: `mvn clean package`    
1. copy the following artifacts to https://dist.apache.org/repos/dist/dev/sling/ide-tooling-1.0.2   
    1. source bundle ( org.apache.sling.ide.source-bundle-1.0.2.zip )
    1. zipped p2 repository ( org.apache.sling.ide.p2update-1.0.2.zip )    
1. ensure the artifacts are checksummed and gpg-signed by using the `sign.sh` script
1. call the vote       

The format of the release vote should be

    To: "Sling Developers List" <dev@sling.apache.org>
    Subject: [VOTE] Release Apache Sling IDE Tooling version X.Y.Z

    Hi,

    We solved N issues in this release:
    https://issues.apache.org/jira/browse/SLING/fixforversion/

    There are still some outstanding issues:
    https://issues.apache.org/jira/browse/SLING/component/12320908

    The release candidate has been uploaded at
    https://dist.apache.org/repos/dist/dev/sling, The release artifact is
    the source bundle - org.apache.sling.ide.source-bundle-X.Y.Z.zip -
    which can be used to build the project using

        mvn clean package

    The resulting binaries can be installed into an Eclipse instance from
    the update site which is found at p2update/target/repository after
    building the project.

    You can use this UNIX script to download the release and verify the signatures:
    https://gitbox.apache.org/repos/asf?p=sling-ide-tooling.git;a=blob_plain;f=check_staged_release.sh;hb=HEAD 

    Usage:
    sh check_staged_release.sh X.Y.Z /tmp/sling-staging

    Please vote to approve this release:

      [ ] +1 Approve the release
      [ ]  0 Don't care
      [ ] -1 Don't release, because ...

    This majority vote is open for at least 72 hours
    

Once the release has passed, the following must be done:

1. announce the result of the vote, see [Wait for the results](#wait-for-the-results)
1. update versions in jira, see [Update JIRA](#update-jira)
1. upload *p2update.zip* to https://dist.apache.org/repos/dist/release/sling/1.0.2
1. upload unzipped update site to https://dist.apache.org/repos/dist/release/sling/eclipse/1.0.2
1. upload the source bundle to https://dist.apache.org/repos/dist/release/sling/eclipse/1.0.2
    1. create GPG signatures and checksums for all uploaded jars using the `ide-tooling/sign.sh` script
1. update https://dist.apache.org/repos/dist/release/sling/eclipse/composite\{Content,Artifacts}.xml to point version 1.0.2
    1. The timestamps in the composite xml files should be refreshed to "now", for instance by using the value of ``echo "`date +%s`000"``
1. remove the old artifact versions but leave pointers to archive.apache.org, using compositeArtifacts.xml/compositeContent.xml , with a single child entry pointing to https://archive.apache.org/dist/sling/eclipse/1.0.0/
1. remove the staged artifacts from https://dist.apache.org/repos/dist/dev/sling/ide-tooling-1.0.2
1. update the news page and the download pages
1. update the Eclipse Marketplace listing

## Appendix A: Creating and registering your PGP key

Each Sling release must be signed, and the corresponding keys must be available at [https://downloads.apache.org/sling/KEYS](https://downloads.apache.org/sling/KEYS) .

This page only provides minimal information, the canonical reference for this is the
[ASF Infrastructure Release Signing](https://infra.apache.org/release-signing.html) page.

Assuming you are using a \*nix system with a working OpenSSH, GnuPG, and bash you can create and add your own key with the following commands:

1. Create a public/private pair key:

        $ gpg --gen-key

    When gpg asks for e-mail linked the key you *MUST USE* the &lt;committer&gt;@apache.org one. When gpg asks for comment linked the key you *SHOULD USE* "CODE SIGNING KEY"

1. Add your public key to <https://downloads.apache.org/sling/KEYS> by adding it via SVN to <https://dist.apache.org/repos/dist/release/sling/KEYS>. This is only possible for PMC members (for a reasoning look at [http://www.apache.org/dev/release.html#upload-ci](http://www.apache.org/dev/release.html#upload-ci)). If you are not a PMC member, please ask one to do the upload for you. The actual update can be achieved e.g. via

        $ svn checkout https://dist.apache.org/repos/dist/release/sling/ sling --depth empty
        $ cd sling
        $ svn up KEYS

   Add the public key to `KEYS` file with your favourite editor and afterwards
   
        $ svn commit -m "my key added" KEYS

1. It's also good to upload your key to a public key server, see the [ASF Infrastructure Release Signing](https://infra.apache.org/release-signing.html) page for more info.

## Appendix B: Deploy Maven plugin documentation (if applicable)

When releasing a Maven plugin, the Maven-generated documentation published under [http://sling.apache.org/components/](http://sling.apache.org/components/) needs
to be updated.

To publish the plugin documentation execute the following steps after the release:

1. Checkout the release tag of the released plugin (or reset your workspace)

2. Build the Maven site of the plugin locally.
   
        $ mvn clean site:site

3. Checkout the Sling website

        $ git clone https://github.com/apache/sling-site.git

4. Switch to branch `asf-site`

5. Replace the content of the existing folder `components/<plugin-name>` with the generated Maven site from `target/site`

6. Create a new folder `src/main/jbake/assets/components/<plugin-name>-archives/<plugin-name>-<version>` and copy the generated maven site there as well

7. Commit the changes

8. Check the results at [http://sling.apache.org/components/](http://sling.apache.org/components/)
