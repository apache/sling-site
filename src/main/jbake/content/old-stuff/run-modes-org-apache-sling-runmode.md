title=Run Modes
type=page
status=published
tags=runmodes,configuration
~~~~~~

<div markdown="1" class="note">
As of Sling 6 the <code>org.apache.sling.runmode</code> bundle is replaced
by the new <a href="/documentation/bundles/sling-settings-org-apache-sling-settings.html">Sling Settings (org.apache.sling.settings)</a>
Bundle. For backwards compatibility this bundle may still exist in your environment. New code should use the API of the new
Sling Settings Bundle, though.
</div>

# Overview

Run modes are meant to define different sets of configuration parameters for various Sling instances.

In a web publishing environment, for example, one could use run modes like *staging, production, dev, dmz* or combinations of such values.

The *[org.apache.sling.runmode]({{ refs.https://svn.apache.org/repos/asf/sling/trunk/contrib/extensions/runmode.path }})* bundle provides a simple way of defining and querying a list of run modes.

# Installation

The run mode service is not present in the default Sling launchpad builds, to activate it install and start the *org.apache.sling.runmode* bundle.

# Configuration

Run modes can only be configured using a system property, or via the *sling.properties* file.

Using *-Dsling.run.modes=foo,bar* on the JVM command-line, for example, activates the *foo* and *bar* run modes.

This command-line parameter takes precedence over a similar definition (*sling.run.modes=dev,staging*) that might be present in the *sling.properties* file found in the Sling home directory.

# Getting the current list of run modes

The [RunMode service]({{ refs.https://svn.apache.org/repos/asf/sling/trunk/contrib/extensions/runmode/src/main/java/org/apache/sling/runmode/RunMode.java.path }}) provides the current list of run modes, examples:

    ::java
    RunMode r = ...get from BundleContext...
    String [] currentRunModes = r.getCurrentRunModes();

    String [] expectedRunModes = { "foo", "wii" };
    if(r.isActive(expectedRunModes)) {
      // at least one of (foo,wii) run modes
      // is active
    }


# See also

The RunMode service is used by the [jcrinstall]({{ refs.jcr-installer-provider.path }}) services.

