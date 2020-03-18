title=OSGi Installer		
type=page
status=published
tags=installer
~~~~~~

# Overview

The OSGi installer is a central service for handling installs, updates and uninstall of "artifacts". By default, the installer supports bundles and has an extension for handling configurations for the OSGi configuration admin.

![Apache Sling OSGI Installer Diagram](/documentation/bundles/Slide14.jpg)

The OSGi installer itself is "just" the central service managing the tasks and states of the artifacts. The artifacts can be provided through various providers, e.g. through a file system provider reading artifacts from configured directories or the jcr provider reading artifacts from a JCR repository.

A provider is just scanning for artifacts and their removal. It informs the OSGi installer about new artifacts and removed artifacts. The provider itself has usually no knowledge about the contents of an artifact. It does not know about bundles, configurations etc.

As the OSGi installer itself is not performing the actual install, update or removal of an artifact, its possible to install transformers and installer factories. A transformer inspects the artifacts and tries to detect its type. By default, detecting of bundles and configurations is supported. The final service is an installer factory creating the actual task, like install this bundle, update that bundle etc.

It's possible to add own providers, transformers and installer factories to support custom scenarios.

## API
The installer API is defined by the `org.apache.sling.installer.api` package 
of the [org.apache.sling.installer.core](https://github.com/apache/sling-org-apache-sling-installer-core) module. The main
interface is the `OsgiInstaller` with which installable resources can be registered.

The [installer integration tests][1] module can be useful to understand the details of how the installer works.

## Artifact Handling

Once an artifact is detected by a transformer, it gets a unique id. By default a bundle gets the symbolic name as the unique identifier and a configuration the PID.
In addition to this id, an artifact gets a priority information from the provider. The priority is used if an artifact with the same id is provided several times from different locations. For example if a file system provider is scanning two directories and an artifact with the same id (like a configuration) is added to both directories, one should have precedence over the other. This is handled by the priority.

Artifacts with the same unique id are grouped and then sorted by priority and maybe other artifact dependent metadata like the bundle version. Only the first artifact in this sorted group is tried to be applied!

## Bundle Handling

In general, the OSGi installer always tries to install the highest version of a bundle if several bundles with the same symbolic name are provided. In this case higher version wins over priority.
If an installed bundle is removed by a provider, for example deleted in the repository, the OSGi installer uninstall the bundle.
If a bundle is removed from a provider which is currently not installed, this has no effect at all.
If an installed bundle is removed and another version of this bundle is provided (a lower version), than this one is installed instead. This is basically a downgrade of the bundle.
If a bundle is installed and a higher version is provided, an upgrade is performed.
If an installed bundle is managed via any other OSGi tooling, like uninstalling it through the web console, the OSGi installer does no action at all!

If a failure occurs during bundle installation or update, the OSGi installer will retry this as soon as another bundle has been installed. The common use case is an application installation with several bundles where one bundle depends on another. As they are installed in arbitrary order, this mechanism ensures that in the end all bundles are properly wired and installed.

When all artifacts have been processed (either install, update or delete), a package refresh is automatically called.

### Multi-Version Support

For now this feature is considered **experimental**, see [SLING-9172](https://issues.apache.org/jira/browse/SLING-9172) 
and related tickets for details.

Starting with version 3.11.0 of the `org.apache.sling.installer.core` bundle, setting the System or Framework Property `sling.installer.multiversion=true` activates multi-version support.

When this option is active, the entity ID of each installable bundle also contains the version, enabling multiple versions of
the same bundle to be installed.

In this case, changes to the installable candidates only affect the very same version of this bundle, leading
to the following behavior:

* Different versions of the same bundle are installed side-by-side in the OSGi framework, instead of installing only the
highest version of each bundle.
* Removing an installable candidate only triggers uninstallation of the corresponding bundle version.
* Installed bundles are only updated if have SNAPSHOT versions.

This feature allows for providing multiple versions of the same Java packages, which was previously only possible
by creating bundles with different symbolic names but providing the same packages, or by using other installation mechanisms.

### Versions and Snapshots

The OSGi installer asumes that a symbolic name and version (not a snapshot version) uniquely identifies a bundle. Obviously this is a common development requirement that a released version of an artifact never changes over time. Therefore, once a bundle with a specific version is installed, it will not be reinstalled if the corresponding artifact changes. For example, if  bundle A with version 1.0 is put into the JCR repository, it gets installed. If now this jar in the repository is overwritten either with the same contents or with a different one, and this new artifact has again A as the symbolic name and version set to 1.0, nothing will happen as this exact bundle is already installed.

During development, SNAPSHOT versions should be used, like 1.0.0-SNAPSHOT (using the Maven convention). If a bundle with a snapshot version is changed, it gets updated by the OSGI installer.

## Start Level Handling

The OSGi installer supports handling of start levels for bundles. If the provided bundle artifacts contain a start level information the bundle is installed with that start level, otherwise the default start level is used.
Therefore, for initial provisioning to make use of start levels, the OSGi installer and the corresponding provider (see below) should run at a very low start level, probably at 1. This ensure that the bundles with a start level are started with respect to the start level.

When an update of bundles is performed through the installer, by default the installer stays in the current start level and updates the bundles. However, if bundles at low start levels are affected, this might result in a lot of churn going on. Therefore, the OSGi installer can be configured to use a more intelligent start level handling:

* If the framework property "sling.installer.switchstartlevel" is set to "true" and
* there is no asynchronous install task in the list of tasks to perform, then
* the start level is set to (the lowest level of the bundles to be updated - 1) - if the start level is lower than the level of the installer itself, the start level of the installer is used.
* the bundles are updated/installed
* the start level is increased to the previous level

## Plugins

### Factories

An installer factory provides support for a specific artifact type, like a configuration or a deployment package etc.

* [Configuration Installer Factory](/documentation/bundles/configuration-installer-factory.html)
* [Content Package Installer Factory](/documentation/bundles/content-package-installer-factory.html)
* [Subsystem Installer Factory](/documentation/bundles/subsystem-installer-factory.html)

### Providers

A provider provides artifacts, e.g. by scanning a directory or a database etc.

* [File Installer Provider](/documentation/bundles/file-installer-provider.html)
* [JCR Installer Provider](/documentation/bundles/jcr-installer-provider.html)

## Health Check

The OSGi installer provides a [Sling Health Check](/documentation/bundles/sling-health-check-tool.html) which validates that the processed OSGi installer resources have the correct state ([SLING-5888](https://issues.apache.org/jira/browse/SLING-5888)).
By default it will only check resources with a URL prefix `jcrinstall:/apps/`, so only the resources being provided through the [JCR Installer Provider](/documentation/bundles/jcr-installer-provider.html) initially located below the repository resource `/apps/` are considered.
The health check will fail in the following cases:

### Bundles Installation Failure

The checked bundle was not installed because it has been installed in a newer version from some other location (might even be through some other provider). For further details please look at the OSGi Installer console at `/system/console/osgi-installer` and check for all bundles with the given symbolic name (=OSGi installer's resource id) and their according URLs.

### Configuration Installation Failure

The checked configuration was not installed because it is already installed from some other location (which has a higher priority). In this case you can see from where it has been installed by looking at the OSGi Installer console at `/system/console/osgi-installer` and check all configurations with the given PID and their according URLs.

Due to [SLING-7735](https://issues.apache.org/jira/browse/SLING-7735), there might be false positives being reported by the health check, in case the configuration has already been deployed with exactly the same values in the system previously. In that case the OSGi Installer might also mark the resource as `IGNORED`. If you run into such an issue, you can fix it by removing the manually overwritten configurations: Just go to `/system/console/configMgr` and delete the according configuration. That way the OSGi installer should automatically create a new configuration for the same PID based on the configuration provided by some provider with the highest prio. 

### Limitations of the health check

Currently the health check and the OSGi installer cannot detect if a deployed bundle/configuration has been overwritten (e.g. via API or the WebConsole). So even if an OSGi installer resource is marked as `INSTALLED` it might already have been overwritten. This limitation is tracked in [SLING-7736](https://issues.apache.org/jira/browse/SLING-7736).

