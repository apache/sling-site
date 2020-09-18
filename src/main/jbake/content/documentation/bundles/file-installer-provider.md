title=File Installer Provider		
type=page
status=published
tags=installer
~~~~~~

The file installer provider scans configured directories and provides the found artifacts (files) to the [OSGI installer](/documentation/bundles/osgi-installer.html). The functionality is very similar to Apache Felix FileInstall, with the major difference that this service implements just the task of scanning a file directory. All the management logic is implemented in the OSGi installer and support of various artifact types like bundles, configurations or custom formats is implemented by plugins for the OSGi installer.

 	 
## Setup
 	 
The file installer can be configured with these framework (system) properties:
 	 
|Property|Default|Description|
|---|---|---|
|`sling.fileinstall.dir`| |The name/path of the directories to watch. Several directories can be specified by using a comma separated list. Each directory might have arbitrarily many sub directories (even nested ones) which may contain the artifacts|
|`sling.fileinstall.interval`|5000 ms|Number of milliseconds between 2 polls of the directory|
|`sling.fileinstall.writeback`|true|If the file provider supports writeback of changed artifacts, e.g. if a configuration is changed through Config Admin the change is written back to the file system.|

## Bundles

Bundles are supported by the OSGi installer. If a bundle jar is added to a scanned directory, this bundle is installed. If the file is updated/changed, the bundle is updated. If the file is removed, the bundle gets removed.
Of course, these are the simple rules. The actual action depends by the overall state of the system and is controlled by the OSGi installer. For example if already the same bundle with a higher version is installed, when a bundle is dropped into the install folder, the OSGi installer will perform no operation.

Start levels are supported as well by creating a directory with the name of the start level within the scan directory and putting the bundles within this directory. For example, if the `install` folder is scanned, the bundle `install/3/mybundle.jar` will be installed with start level 3. Without such a directory the default start level is used.

## Configurations

Configurations are handled by the [Configuration Installer Factory](/documentation/bundles/configuration-installer-factory.html). The different formats are described there.
 	 
## Custom Artifacts

Custom artifacts are handled by the OSGi installer depending on the installed plugins. Have a look at the OSGi installer and its plugins for more information.

## Run Mode Support

The file installer supports run modes for installing artifacts (added with [SLING-4478](https://issues.apache.org/jira/browse/SLING-4478)). Within the scanned directory, a folder prefixed with `install.` and followed by one or more run modes (separated by `.`) will only be considered if all the respective run modes are active. For example artifacts below a folder named `install.a1.dev` are only taken into account if the run modes `a1` and `dev` are both active. 

Since version 1.3.0 of the File Installer bundle ([SLING-9031](https://issues.apache.org/jira/browse/SLING-9031) and [SLING-8548](https://issues.apache.org/jira/browse/SLING-8548)) advanced run mode support has been added, so that folder names in the form `install.[RUNMODESPEC]` are supported. `RUNMODESPEC` is defined in [Sling Settings](/documentation/bundles/sling-settings-org-apache-sling-settings.html#decisions-based-on-run-modes).

You can even combine start level and run mode support. Just pay attention that the run mode foldername must be set on a direct child folder of `sling.fileinstall.dir` while the start level must be set directly on the parent folder of the artifact you want to install. E.g. `<sling.fileinstall.dir>/install.a1.dev/3/mybundle.jar` will only be considered if both run modes `a1` and `dev` are set. If this is the case then the according artifact will be installed in start level 3.

# Project Info

* File installer provider ([org.apache.sling.installer.provider.file](https://github.com/apache/sling-org-apache-sling-installer-provider-file))
