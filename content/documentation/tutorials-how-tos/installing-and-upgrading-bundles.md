title=Installing and Upgrading Bundles		
type=page
status=published
~~~~~~
Excerpt: Explains how to install, upgrade and uninstall Bundles using the Sling Management console.

<div class="note">
We recommend to use the Apache Felix Web Console. The documentation below describes the old Sling Management Console, which isn't in use any more. Please refer to the documentation of the <a href="http://felix.apache.org/site/apache-felix-web-console.html">Apache Felix Web Console</a>.
</div>

OSGi bundles installed in the OSGi framework, which is provided by Sling, may be upgraded or removed and new bundles may be installed by using the Sling Management Console. This page is about using the Sling Management Console for those tasks.

Basically, you have two choices to install and upgrade bundles: Upload the bundle files or install them from a Bundle Repository.



## Sling Management Console

The Sling Management Console is installed by default when Sling is running and may be reached at on the page `/system/console` in the Sling Context by default. For example if you installed the Sling Web Application in the `/sample` context of the Servlet Container running at `http://somehost:4402`, you would access the Sling Management Console at `http://somehost:4402/sample/system/console`.

You will be prompted for a user name and password to access the Sling Management Console. This password is preset to be *admin* for the user name and *admin* for the password.

NB: Both the username and password and the location of the Sling Management Console inside the Web Application Context is configurable in the *Sling Management Console* configuration on the *Configuration* page.



## Installing and upgrading bundles by Upload

To install a new bundle or upgrade an already installed bundle, go to the *Bundles* page in the Sling Management Console. At the top and the bottom of the page you have a form to specify and upload a bundle as a file :

* Select the bundle file to upload
* Click the *Start* checkbox, if you want to start the bundle after installation. If the bundle is upgraded, this checkbox is ignored.
* Specify the start level of the bundle in the *Start Level* field. This must be a number higher than 0 and is ignored for bundles, which are already installed. Most of the time, you will use the default value.
* Click the *Install or Update* button

After clicking the button, the bundle file will be uploaded. If a bundle with the same bundle symbolic name is already installed, the respective bundle will be updated with the new bundle file. Otherwise the bundle file will be installed as a new bundle and its start level is set as defined. Additionally the bundle will optionally be started.

After having updated a bundle, you should also refresh the packages by clicking on the *Refresh Packages* button. The reson for this is, that the old version of the bundle is still used by other bundles even after upgrading to a new version. Only when the packages are refreshed any users of the bundle will be relinked to use the new bundle version. As this might be a somewhat lengthy operation, which also stops and restarts using bundles, this operation has to be executed explicitly.

Also, if you plan to upgrade multiple bundles, you may wish to upgrade all bundles before repackaging the using bundles.



## Installing and upgrading bundles from the Bundle Repository

The OSGi Bundle Repository is a repository of bundles, from which Sling may download and install or upgrade bundles very easily. Unlike the installation of bundles by file upload, the OSGi Bundle Repository has the functionality to resolve and dependencies of bundles to be installed.

Say you wish to install bundle *X* which depends on packages provided by bundle *Y*. When uploading bundle *X* as a file it will not resolve, that is Sling (the OSGi framework actually) is not able to ensure proper operation of bundle *X* and thus prevents the bundle from being started and used. You will have to manually upload bundle *Y* yourself. When using the OSGi Bundle Repository, you just select bundle *X* for installation and the bundle repository will find out, that bundle *Y* is also required and will automatically download and install it along with bundle *X*.


### The Bundle Repository page

Installation or update of bundles may be done on the *Bundle Repository* page of the Sling Management Console. In the upper part of the page, you will see a list (usually just a single entry) of OSGi Bundle Repositories known to Sling. In the lower part of the list you see the bundles available from these repositories. To install or update bundles, just check the respective button and click on the *Deploy Selected* or *Deploy and Start Selected* button at the bottom of the page depending on whether you want to start the bundle(s) after installation or not.

See below for more information on OSGi Bundle Repository management.



### The Bundles page

You may also want to upgrade already installed bundles from the *Bundles* page of the Sling Management Console. For each bundle listed in this page, there is an *Upgrade* button. If there is an upgrade to the installed bundle available in the OSGi Bundle Repository, the button is enabled and clicking on the button will upgrade the respective bundle. If no upgrade is available from the OSGi Bundle Repository, this button is disabled.



### Managing OSGi Bundle Repositories

Currently management of known OSGi Bundle Repositories is very simple. If a configured bundle repository is not available on startup, it will be marked as being inactive. If you know the repository is now available, you may click on the *Refresh* button, to activate it. Similarly, the contents of the repository may be modified by for example adding new bundles or updating bundles in the repository, these changes will be made known to Sling by clicking the *Refresh* button.

There exists no GUI functionality yet to add a new repository to the list of known repositories. Instead you may submit a request with parameters `action` whose value must be `refreshOBR` and `repository` whose value must be the URL to the repository descriptor file generally called `repository.xml`.

For example, if you run Sling on `http://localhost:7402/sample` with default location of the Sling Management Console, the following request would add a repository at `/tmp/repo/repository.xml` in the filesystem:

:::html
http://localhost:7402/sample/system/console/bundlerepo?action=refreshOBR&repository=file:///tmp/repo/repository.xml

Note: Only use `file:` URLs if you know Sling has access to the named file !
