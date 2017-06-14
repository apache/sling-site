title=Release Management		
type=page
status=published
~~~~~~

Sling releases (and SNAPSHOTS) are deployed to the [Nexus repository](http://repository.apache.org) instead of the traditional deployment via the Maven 2 mirrors source on `people.apache.org`. This makes the release process much leaner and simpler. In addtion we can benefit from the Apache Parent POM 6, which has most of the release profile setup built-in.

Most of the hard work of preparing and deploying the release is done by Maven.

[TOC]



## Prerequisites

* To prepare or perform a release you *MUST BE* at least be an Apache Sling Committer.
* Each and every release must be signed; therefore the public key should be cross signed by other Apache committers (not required but suggested) and this public key should be added to [https://people.apache.org/keys/group/sling.asc](https://people.apache.org/keys/group/sling.asc) and either on pool.sks-keyservers.net or pgp.mit.edu (See Appendix A)
* Make sure you have all [Apache servers](http://maven.apache.org/developers/committer-settings.html) defined in your `settings.xml`
* See Appendix B for Maven and SCM credentials

*Note*: Listing the Apache servers in the `settings.xml` file also requires adding the password to that file. Starting with Maven 2.1 this password may be encrypted and needs not be give in plaintext. Please refer to [Password Encryption](http://maven.apache.org/guides/mini/guide-encryption.html) for more information.

In the past we staged release candidates on our local machines using a semi-manual process. Now that we inherit from the Apache parent POM version 6, a repository manager will automatically handle staging for you. This means you now only need to specify your GPG passphrase in the release profile of your `${user.home}/.m2/settings.xml`:


<settings>
...
<profiles>
<profile>
<id>apache-release</id>
<properties>
<gpg.passphrase> <!-- YOUR KEY PASSPHRASE --> </gpg.passphrase>
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
* Make sure the generated artifacts respect the Apache release [rules](http://www.apache.org/dev/release.html): NOTICE and LICENSE files should be present in the META-INF directory within the jar. For -sources artifacts, be sure that your POM does not use the maven-source-plugin:2.0.3 which is broken. The recommended version at this time is 2.0.4
* You should verify the deployment under the [snapshot](https://repository.apache.org/content/groups/snapshots/org/apache/sling) repository on Apache

1. Prepare the release

$ mvn release:clean
$ mvn release:prepare

* Preparing the release will create the new tag in SVN, automatically checking in on your behalf
* If you get a build failure because of an SVN commit problem (namely *The specified baseline is not the latest baseline, so it may not be checked out.*), just repeat the `mvn release:prepare` command until SVN is happy. This is based on a known timing issue when using the European SVN mirror.

1. Stage the release for a vote

$ mvn release:perform

* The release will automatically be inserted into a temporary staging repository for you, see the Nexus [staging documentation](http://www.sonatype.com/books/nexus-book/reference/staging.html) for full details
* You can continue to use `mvn release:prepare` and `mvn release:perform` on other sub-projects as necessary on the same machine and they will be combined in the same staging repository - this is useful when making a release of multiple Sling modules.

1. Close the staging repository:
* Login to [https://repository.apache.org](https://repository.apache.org) using your Apache SVN credentials. Click on *Staging* on the left. Then click on *org.apache.sling* in the list of repositories. In the panel below you should see an open repository that is linked to your username and IP. Right click on this repository and select *Close*. This will close the repository from future deployments and make it available for others to view. If you are staging multiple releases together, skip this step until you have staged everything

1. Verify the staged artifacts
* If you click on your repository, a tree view will appear below. You can then browse the contents to ensure the artifacts are as you expect them. Pay particular attention to the existence of *.asc (signature) files. If you don't like the content of the repository, right click your repository and choose *Drop*. You can then rollback your release (see *Canceling the Release*) and repeat the process
* Note the staging repository URL, especially the number at the end of the URL. You will need this in your vote email

## Starting the Vote

Propose a vote on the dev list with the closed issues, the issues left, and the staging repository - for example:


To: "Sling Developers List" <dev@sling.apache.org>
Subject: [VOTE] Release Apache Sling ABC version X.Y.Z

Hi,

We solved N issues in this release:
https://issues.apache.org/jira/browse/SLING/fixforversion/...

There are still some outstanding issues:
https://issues.apache.org/jira/browse/SLING/component/...

Staging repository:
https://repository.apache.org/content/repositories/orgapachesling-[YOUR REPOSITORY ID]/

You can use this UNIX script to download the release and verify the signatures:
http://svn.apache.org/repos/asf/sling/trunk/check_staged_release.sh

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
> three +1 votes were registered. Releases may not be vetoed. Generally the community
> will table the vote to release if anyone identifies serious problems, but in most cases
> the ultimate decision, once three or more positive votes have been garnered, lies with
> the individual serving as release manager. The specifics of the process may vary from
> project to project, but the 'minimum of three +1 votes' rule is universal.

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


Be sure to include all votes in the list and indicate which votes were binding. Consider -1 votes very carefully. While there is technically no veto on release votes, there may be reasons for people to vote -1. So sometimes it may be better to cancel a release when someone, especially a member of the PMC, votes -1.

If the vote is unsuccessful, you need to fix the issues and restart the process - see *Canceling the Release*. Note that any changes to the artifacts under vote require a restart of the process, no matter how trivial. When restarting a vote version numbers must not be reused, since binaries might have already been copied around.

If the vote is successful, you need to promote and distribute the release - see *Promoting the Release*.



## Canceling the Release

If the vote fails, or you decide to redo the release:

1. Remove the release tag from Subversion (`svn del ...`)
1. Login to [https://repository.apache.org](https://repository.apache.org) using your Apache SVN credentials. Click on *Staging* on the left. Then click on *org.apache.sling* in the list of repositories. In the panel below you should see a closed repository that is linked to your username and IP (if it's not yet closed you need to right click and select *Close*). Right click on this repository and select *Drop*.
1. Remove the old version from Jira
1. Create a new version in Jira with a version number following the one of the cancelled release
1. Move all issues with the fix version set to the cancelled release to the next version
1. Delete the old version from Jira
1. Commit any fixes you need to make and start a vote for a new release.

## Promoting the Release

If the vote passes:


1. Push the release to [https://dist.apache.org/repos/dist/release/sling/](https://dist.apache.org/repos/dist/release/sling/). This is only possible for PMC members (for a reasoning look at [http://www.apache.org/dev/release.html#upload-ci](http://www.apache.org/dev/release.html#upload-ci)). If you are not a PMC member, please ask one to do the upload for you.
1. Commit the released artifacts to [https://dist.apache.org/repos/dist/release/sling/](https://dist.apache.org/repos/dist/release/sling/) which is replicated to [http://www.apache.org/dist/sling/](http://www.apache.org/dist/sling/) quickly via svnpubsub. Hint: use svn import to avoid having to checkout the whole folder first. The easiest to do this is to get the released artifact using the check script (check&#95;staged&#95;release.sh) and then simply copy the artifacts from the downloaded folder to your local checkout folder. Make sure to not add the checksum files for the signature file *.asc.*).
* Make sure to *not* change the end-of-line encoding of the .pom when uploaded via svn import! Eg when a windows style eol encoded file is uploaded with the setting '*.pom = svn:eol-style=native' this would later fail the signature checks!
1. Delete the old release artifacts from that same dist.apache.org svn folder (the dist directory is archived)
1. Push the release to Maven Central
1. Login to [https://repository.apache.org](https://repository.apache.org) with your Apache SVN credentials. Click on *Staging*. Find your closed staging repository and select it by checking the select box. Select the *Releases* repository from the drop-down list and click *Release* from the menu above.
1. Once the release is promoted click on *Repositories*, select the *Releases* repository and validate that your artifacts are all there.
1. Update the news section on the website at [news](/news.html).
1. Update the download page on the website at [downloads](/downloads.cgi) to point to the new release.

For the last two tasks, it's better to give the mirrors some time to distribute the uploaded artifacts (one day should be fine). This ensures that once the website (news and download page) is updated, people can actually download the artifacts.

## Update JIRA

Go to [Manage Versions](https://issues.apache.org/jira/plugins/servlet/project-config/SLING/versions) section on the SLING JIRA and mark the X.Y.Z version as released setting the release date to the date the vote has been closed.

Also create a new version X.Y.Z+2, if that hasn't already been done.

And keep the versions sorted, so when adding a new version moved it down to just above the previous versions.

Close all issues associated with the released version.


## Create an Announcement

We usually do such announcements only for "important" releases, as opposed to small individual module
releases which are just announced on our [news](/news.html) page.

To: "Sling Developers List" <dev@sling.apache.org>, "Apache Announcements" <announce@apache.org>
Subject: [ANN] Apache Sling ABC version X.Y.Z Released

The Apache Sling team is pleased to announce the release of Apache Sling ABC version X.Y.Z

Apache Sling is a web framework that uses a Java Content Repository, such as Apache Jackrabbit, to store and manage content. Sling applications use either scripts or Java servlets, selected based on simple name conventions, to process HTTP requests in a RESTful way.

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

While the Sling IDE tooling is built using Maven, the toolchain that it is based around does not cooperate well with the maven-release-plugin. As such, the release preparation and execution are slightly different. The whole process is outlined below, assuming that we start with a development version of 1.0.1-SNAPSHOT.

1. set the fix version as released: `mvn tycho-versions:set-version -DnewVersion=1.0.2`
1. update the version of the source-bundle project to 1.0.2
1. commit the change to svn
1. manually tag in svn using `svn copy https://svn.apache.org/repos/asf/sling/trunk/tooling/ide https://svn.apache.org/repos/asf/sling/tags/sling-ide-tooling-1.0.2`
1. update to next version: `mvn tycho-versions:set-version -DnewVersion=1.0.3-SNAPSHOT` and also update the version of the source-bundle project
1. commit the change to svn
1. Checkout the version from the tag and proceed with the build from there `https://svn.apache.org/repos/asf/sling/tags/sling-ide-tooling-1.0.2`
1. build the project with p2/gpg signing enabled: `mvn clean package -Psign`
1. build the source bundle from the source-bundle directory: `mvn clean package`
1. copy the following artifacts to https://dist.apache.org/repos/dist/dev/sling/ide-tooling-1.0.2
1. source bundle ( org.apache.sling.ide.source-bundle-1.0.2.zip )
1. zipped p2 repository ( org.apache.sling.ide.p2update-1.0.2.zip )
1. ensure the artifacts are checksummed and gpg-signed by using the `tooling/ide/sign.sh` script
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
http://svn.apache.org/repos/asf/sling/trunk/tooling/ide/check_staged_release.sh

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
1. upload p2update.zip* to https://dist.apache.org/repos/dist/release/sling/
1. upload unzipped update site to https://dist.apache.org/repos/dist/release/sling/eclipse/1.0.2
1. upload the source bundle to https://dist.apache.org/repos/dist/release/sling/eclipse/1.0.2
1. create GPG signatures and checksums for all uploaded jars using the `tooling/ide/sign.sh` script
1. update https://dist.apache.org/repos/dist/release/sling/eclipse/composite{Content,Artifacts}.xml to point version 1.0.2
1. archive the old artifact versions but leave pointers to archive.apache.org, using compositeArtifacts.xml/compositeContent.xml , with a single child entry pointing to https://archive.apache.org/dist/sling/eclipse/1.0.0/
1. remove the staged artifacts from https://dist.apache.org/repos/dist/dev/sling/ide-tooling-1.0.2
1. update the news page and the download pages
1. update the Eclipse Marketplace listing

## Appendix A: Create and Add your key to [https://people.apache.org/keys/group/sling.asc](https://people.apache.org/keys/group/sling.asc)

Considering that you are using a *nix system with a working OpenSSH, GnuPG, and bash you can create and add your own key with the following commands:

1. Create a public/private pair key:

$ gpg --gen-key

When gpg asks for e-mail linked the key you *MUST USE* the &lt;committer&gt;@apache.org one. When gpg asks for comment linked the key you *SHOULD USE* "CODE SIGNING KEY"

1. Add the key to [https://people.apache.org/keys/group/sling.asc](https://people.apache.org/keys/group/sling.asc)

1. Type the following command replacing the word `<e-mail>` with your Apache's one (&lt;committer&gt;@apache.org) to get the key signature

$ gpg --fingerprint <e-mail>

The key signature is in the output following the `Key fingerprint = ` part.

1. Add the key signature into the field 'OpenPGP Public Key Primary Fingerprint' in your profile at [https://id.apache.org](https://id.apache.org).

1. You are *DONE*, but to see the changes on [https://people.apache.org/keys/group/sling.asc](https://people.apache.org/keys/group/sling.asc) you may need to wait a few hours;

1. You also have to add your public key either on `pool.sks-keyservers.net` or `pgp.mit.edu` (for the staging repository). To do so you can follow these steps:
1. Extract the key id from all the secret keys stored in the system:

$ gpg --list-secret-keys.

The output is something like this

gpg --list-secret-keys
/Users/konradwindszus/.gnupg/secring.gpg
----------------------------------------

sec   2048R/455ECC7C 2016-01-21
uid                  Konrad Windszus <kwin@apache.org>
ssb   2048R/226BCE00 2016-01-21

The key id in this case is `455ECC7C`.

1. Send the key towards e.g. `pool.sks-keyservers.net` via

$ gpg --keyserver pool.sks-keyservers.net --send-key <key-id>



## Appendix B: Maven and SCM credentials

For running the `mvn release:prepare` command without giving credentials on command line add `svn.apache.org` to your `settings.xml`:

<server>
<id>svn.apache.org</id>
<username>USERNAME</username>
<password>ENCRYPTED_PASSWORD</password>
</server>

## Appendix C: Deploy bundles on the Sling OBR (obsolete)

*Update November 2016: We do now longer maintain the Sling OBR for new releases.*

We are mainting an OSGi Bundle Repository providing all release of the Sling Bundles. This repository is maintained as part of the Apache Sling site and is available at [http://sling.apache.org/obr/sling.xml](http://sling.apache.org/obr/sling.xml). The source for this page is maintained in the SVN repository below the _site_, that is at [http://svn.apache.org/repos/asf/sling/site/](http://svn.apache.org/repos/asf/sling/site/). To update the Sling OBR repository you must be an Apache Sling Committer since this requires SVN write access.

To update the OBR you may use the Apache Felix Maven Bundle Plugin which prepares the bundle descriptor to be added to the OBR file. Follow these steps to update the OBR:

1. Checkout or update the Site Source

$ svn checkout https://svn.apache.org/repos/asf/sling/site

Note, that you have to checkout the site using the `https` URL, otherwise you will not be able to commit the changes later.

2. Deploy the Descriptor

To deploy the project descriptor, checkout the tag of the bundle to deploy and run maven

$ svn checkout http://svn.apache.org/repos/asf/sling/tags/the_module_tag
$ cd the_module_tag
$ mvn clean install             org.apache.felix:maven-bundle-plugin:deploy             -DprefixUrl=http://repo1.maven.org/maven2             -DremoteOBR=sling.xml             -DaltDeploymentRepository=apache.releases::default::file:///path_to_site_checkout/trunk/content/obr

This generates the bundle descriptor and adds it to the sling.xml file of your site checkout.
As it also installs a fresh compiled version of the artifacts, it's better to remove that version from your local repository again (A new binary has new checksums etc.).

2. Variant: Refer to Maven Repository

Instead of checking out and building the project locally, you may also use the `deploy-file` goal of the Maven Bundle Plugin:

$ wget http://repo1.maven.org/maven2/org/apache/sling/the_module/version/the_module-version.jar
$ wget http://repo1.maven.org/maven2/org/apache/sling/the_moduleversion/the_module-version.pom
$ mvn org.apache.felix:maven-bundle-plugin:deploy-file             -Dfile=the_module-version.jar -DpomFile=the_module-version.pom             -DbundleUrl=http://repo1.maven.org/maven2/org/apache/sling/the_module/version/the_module-version.jar             -Durl=file:///path_to_site_checkout/obr             -DprefixUrl=http://repo1.maven.org/maven2             -DremoteOBR=sling.xml
$ rm the_module-version.jar the_module-version.pom

3. Commit the Site Changes

In the Site checkout folder commit the changes to the `trunk/content/obr/sling.xml` files (you may also review the changes using the `svn diff` command).

$ svn commit -m"Add Bundle ABC Version X.Y.Z" trunk/content/obr/sling.xml

4. Update the Site

Wait for the buildbot to update the staging area with your site update (see dev list for an email).
Then go to the CMS at [https://cms.apache.org/redirect?uri=http://sling.apache.org/obr](https://cms.apache.org/redirect?uri=http://sling.apache.org/obr) ,
update your checkout and then publish the site.


## Appendix D: Deploy Maven plugin documentation (if applicable)

When releasing a Maven plugin, the Maven-generated documentation published under [http://sling.apache.org/components/](http://sling.apache.org/components/) needs
to be updated.

This is currently supported for:

* `maven-sling-plugin`
* `htl-maven-plugin`
* `slingstart-maven-plugin`
* `jspc-maven-plugin`

To publish the plugin documentation execute the following steps after the release:

1. Checkout the release tag of the released plugin (or reset your workspace)

2. Build and stage the maven site of the plugin. Note that this *commits* the generated content to the components folder mentioned below.

$ mvn clean site:site site:stage scm-publish:publish-scm

3. Checkout the 'components' subtree of the Sling website

$ svn checkout https://svn.apache.org/repos/asf/sling/site/trunk/content/components

4. SVN-rename the generated documenation that the site plugin commited to `<plugin-name>-archives/<plugin-name>-LATEST` to `<plugin-name>-archives/<plugin-name>-<version>`

5. SVN-remove the existing folder `<plugin-name>` and SVN-copy the folder `<plugin-name>-archives/<plugin-name>-<version>` to `<plugin-name>`

6. Commit the changes.

7. Publish the Sling site to production

8. Check the results at [http://sling.apache.org/components/](http://sling.apache.org/components/)

For background information about this process see the [Maven components reference documentation](http://maven.apache.org/developers/website/deploy-component-reference-documentation.html).
