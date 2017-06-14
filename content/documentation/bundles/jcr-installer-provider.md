title=JCR Installer Provider		
type=page
status=published
~~~~~~

The JCR installer provider scans the JCR repository for artifacts and provides them to the [OSGI installer](/documentation/bundles/osgi-installer.html).

## Configuration and Scanning

The JCR installer provider can be configured with weighted paths which are scanned. By default, the installer scans in */apps* and */libs* where artifacts found in */apps* get a higher priority. The installer does a deep scan and uses a regular expression to detect folders containing artifacts to be installed. By default, artifacts from within a folder named *install* are provided to the OSGi installer.

If such an install folder contains a binary artifact (e.g. a bundle or a config file as described in [Configuration Installer Factory](/documentation/bundles/configuration-installer-factory.html)) this is provided to the OSGi installer.

In addition every node of type *sling:OsgiConfig* is provided as a configuration to the installer. This has the advantage of leveraging the JCR structure better than binary files, but has the known limitations outlined in [SLING-4183](https://issues.apache.org/jira/browse/SLING-4183) and [SLING-2477](https://issues.apache.org/jira/browse/SLING-2477), therefore it is recommended to stick to one of the binary formats described in [Configuration Installer Factory](/documentation/bundles/configuration-installer-factory.html).

The JCR installer provider does not check or scan the artifacts itself, the detection and installation is deferred to the OSGi installer.

### Runmode Support

The JCR installer supports run modes for installing artifacts. By default folders named *install* are checked for artifacts. If Apache Sling is started with one (or more run modes), all folders named *install.[RUNMODE]* are scanned as well. To be precise, the folder name can be followed by any number of run modes separated by comma. For example, if started with run modes *dev*, *a1*, and *public*, folders like *install.dev*, *install.a1*, *install.public* are searched as well as *install.dev.a1*, or *install.a1.dev*.

Artifacts from folders with a run mode get a higher priority. For example by default, an *install* folder underneath */libs* gets the priority *50*. For each run mode in the folder name, this priority is increased by *1*, so *install.dev* has *51* and *install.a1.dev* is *52*.

## Write Back Support

The JCR installer supports writing back of configurations which are changed by some other ways, e.g by using the Apache Felix web console. If this is a new configuration which was not originally stored in the repository, a new configuration is stored under */apps/sling/install*. The highest search path is used together with a configurable folder (*sling/install* in this case).
If a configuration is changed which already exists in the repository, then it depends where the original configuration is stored. If its under */libs* a new configuration at the same path under */apps* is created. Otherwise the configuration is directly modified.
As JCR properties do not support all Java primitive types like Integer, the write back does not generate a node of type *sling:OsgiConfig* in the repository but a properties file as described in [Configuration Installer Factory](/documentation/bundles/configuration-installer-factory.html).

Write back can be turned off by configuration.

### Start Level Support

If the parent folder of a bundle has a name which is a number, this is used as the start level (when installing the bundle for the first time, compare with [SLING-2011](https://issues.apache.org/jira/browse/SLING-2011)). So e.g. a bundle in the path `/libs/sling/install/15/somebundle.jar` is having the start level **15**.

# Example
Here's a quick walkthrough of the JCR installer functionality.

## Installation
Start the Sling [launchpad/app](http://svn.apache.org/repos/asf/sling/trunk/launchpad/app) and make sure that the following bundles are present and started:
* [RunMode service]({{ refs.run-modes-org-apache-sling-runmode.path }})
* OSGi installer service ([org.apache.sling.installer.core](http://svn.apache.org/repos/asf/sling/trunk/installer/core))
* JCR installer provider ([org.apache.sling.installer.provider.jcr](http://svn.apache.org/repos/asf/sling/trunk/installer/providers/jcr))

To watch the logs produced by these modules, you can filter `sling/logs/error.log` using `egrep 'jcrinstall|osgi.installer'`.

## Install and remove a bundle

We'll use the [Knopflerfish Desktop](http://www.knopflerfish.org/releases/2.0.5/jars/desktop_awt/desktop_awt_all-2.0.0.jar) bundle for this example, it is convenient as it displays a graphical user interface when started.

We use `curl` to create content, to make it easy to reproduce the example by copying and pasting the `curl` commands. Any other way to create content in the repository will work, of course.

By default, JCRInstall picks up bundles found in folders named *install* under `/libs` and `/apps`, so we start by creating such a folder:


curl -X MKCOL  http://admin:admin@localhost:8888/apps/jcrtest
curl -X MKCOL  http://admin:admin@localhost:8888/apps/jcrtest/install


And we copy the bundle to install in that folder (a backslash in command lines means *continued on next line*):


curl -T desktop_awt_all-2.0.0.jar       http://admin:admin@localhost:8888/apps/jcrtest/install/desktop_awt_all-2.0.0.jar


That's it. After 2-3 seconds, the bundle should be picked up by JCRInstall, installed and started. If this works you'll see a small *Knopflerfish Desktop* window on your desktop, and Sling's OSGi console can of course be used to check the details.

Removing the bundle from the repository will cause it to be uninstalled, so:


curl -X DELETE       http://admin:admin@localhost:8888/apps/jcrtest/install/desktop_awt_all-2.0.0.jar


Should cause the *Knopflerfish Desktop* window to disappear as the bundle is uninstalled.


## Install, modify and remove a configuration
JCRInstall installs OSGi configurations from nodes having the *sling:OsgiConfig* node type, found in folders named *install* under the installation roots (/apps and /libs).

Let's try this feature by creating a configuration with two properties:


curl       -F "jcr:primaryType=sling:OsgiConfig"       -F foo=bar -F works=yes       http://admin:admin@localhost:8888/apps/jcrtest/install/some.config.pid


And verify the contents of our config node:

curl       http://admin:admin@localhost:8888/apps/jcrtest/install/some.config.pid.json


Which should display something like

{"foo":"bar",
"jcr:created":"Wed Aug 26 2009 17:06:40GMT+0200",
"jcr:primaryType":"sling:OsgiConfig","works":"yes"}


At this point, JCRInstall should have picked up our new config and installed it. The logs would confirm that, but we can also use the OSGi console's config status page (http://localhost:8888/system/console/config) to check it. That page should now contain:


PID=some.config.pid
BundleLocation=Unbound
_jcr_config_path=jcrinstall:/apps/jcrtest/install/some.config.pid
foo=bars
service.pid=some.config.pid
works=yes


Indicating that the configuration has been installed.

Let's try modifying the configuration parameters:


curl       -F works=updated -F even=more       http://admin:admin@localhost:8888/apps/jcrtest/install/some.config.pid


And check the changes in the console page:


PID=some.config.pid
BundleLocation=Unbound
_jcr_config_path=jcrinstall:/apps/jcrtest/install/some.config.pid
even=more
foo=bars
service.pid=some.config.pid
works=updated


We can now delete the configuration node:


curl -X DELETE       http://admin:admin@localhost:8888/apps/jcrtest/install/some.config.pid


And verify that the corresponding configuration is gone in the console page (after 1-2 seconds, like for all other JCRInstall operations).

A node named like `o.a.s.foo.bar-a` uses *o.a.s.foo.bar* as its factory PID creating a configuration with an automatically generated PID. The value of *a* is stored as an alias in the OSGi installer to correlate the configuration object with the repository node.

# Automated Tests
The following modules contain lots of automated tests (under `src/test`, as usual):

* OSGi installer integration tests ([org.apache.sling.installer.it](http://svn.apache.org/repos/asf/sling/trunk/installer/it))
* JCR installer service ([org.apache.sling.installer.providers.jcr](http://svn.apache.org/repos/asf/sling/trunk/installer/providers/jcr))

Many of these tests are fairly readable, and can be used to find out in more detail how these modules work.

# Project Info

* JCR installer provider ([org.apache.sling.installer.provider.jcr](http://svn.apache.org/repos/asf/sling/trunk/installer/providers/jcr))
