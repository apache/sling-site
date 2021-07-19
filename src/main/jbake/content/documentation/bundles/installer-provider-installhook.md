title=Installer Vault Package Install Hook
type=page
status=published
tags=installer
~~~~~~

# Background
Content packages may contain OSGi bundles/configuration which are picked up asynchronously by the [JCR Installer Provider](jcr-installer-provider.html). That means that after the installation of a package the contained bundle/configuration is usually not yet installed.

# Overview

The Installer FileVault Package Install Hook allows to install bundles and configurations synchronously during FileVault/content package installation by feeding them directly to the [OSGI Installer core](/documentation/bundles/osgi-installer.html). That way [FileVault package dependencies](http://jackrabbit.apache.org/filevault/properties.html) can be used to not only depend on content of a package, but also on configurations and bundles contained in a package (the installer install hook has to be added to the package the dependency points to). The mechanism is useful for scenarios when a package contains custom oak restrictions (e.g. [Sling Oak Restrictions](/documentationbundles/sling-oak-restrictions.html)) or other install hook(s) that use the install hook package property (e.g. `installhook.myhook.class`) to reference OSGi services that are provided by another bundle. Also see [SLING-7790](https://issues.apache.org/jira/browse/SLING-7790)

NOTE: When using with a package that should be usable with both the [Feature Model](https://sling.apache.org/documentation/development/feature-model.html) (usually without the [OSGi Installer](https://sling.apache.org/documentation/bundles/osgi-installer.html)) and [Provisioning Model](https://sling.apache.org/documentation/development/slingstart.html) (usually with the OSGi Installer), ensure you use version 1.1.0 of this hook that will auto-detect its environment and only become active when the OSGi Installer is present (see [SLING-8948](https://issues.apache.org/jira/browse/SLING-8948))

## Installation Process

The Installer Vault Package Install Hook scans through the contained files and installs bundles (extension `jar`) and OSGi configurations with extension `config` (`conf` and node configurations are not supported). Runmode folders (e.g. `install.publish` or `config.author`) are supported. To perform the installation, the hook registers the installable resources to the OSGi installer core with the exact same digest as the JCR installer would do (hence the JCR installer that will also process the resource but without causing any change as the digest matches). Files that are already installed are ignored (this is checked using the [InfoProvider](http://sling.apache.org/apidocs/sling10/org/apache/sling/installer/api/info/InfoProvider.html)).

## Pitfalls

In some cases a synchronous OSGi installer task leads to unavailability of the method by which the package has been provided (like the [Composum Package Manager](https://www.composum.com/home/nodes/pckgmgr.html)]. This is often caused by the fact that the [Dynamic Class Loader Provider restarts due to newly provided bundles](https://lists.apache.org/thread.html/57d56e31da3c1cb743cf524e0c85e46959f3af9ed946f2c4a41d33c0@%3Cdev.sling.apache.org%3E) or the whole Sling Repository restarts due to a newly provided OSGi configuration. Therefore only use this method for bundles which are not providing classes via the Dynamic Class Loader Provider (e.g. Sling Model classes used by scripts).


## Configuration

To include the install hook into a content package, use the following code:

    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-dependency-plugin</artifactId>
        <executions>
            <execution>
                <id>copy-hook-into-package</id>
                <phase>generate-resources</phase>
                <goals>
                    <goal>copy</goal>
                </goals>
                <configuration>
                    <artifactItems>
                        <artifactItem>
                            <groupId>org.apache.sling</groupId>
                            <artifactId>org.apache.sling.installer.provider.installhook</artifactId>
                            <version>1.1.0</version>
                        </artifactItem>
                    </artifactItems>
                    <outputDirectory>${project.build.directory}/vault-work/META-INF/vault/hooks</outputDirectory>
                </configuration>
            </execution>
        </executions>
    </plugin>


The following package properties are supported (only `installPathRegex` is required):

| Property  | Value| Description |
|---|---|---|
| `installPathRegex` | Regex, e.g. `/apps/myproj/.*` or `/apps/myproj/install/mybundle-1.0.0.jar` | Regex to match all bundles/configurations to be installed synchronously, . Note: The JCR installer will pick up paths that are not matched asynchronously|
| `maxWaitForOsgiInstallerInSec ` | defaults to 60 sec | Maximum wait time until installation is successful |
| `waitForOsgiEventsQuietInSec ` | defaults to 1 sec | Time to wait for OSGi events to go quiet. Default normally works well for bundles, for certain configurations that trigger restart of bundles this can be increased. |
| `osgiInstallerPriority ` | defaults to 2000 | Priority, by default higher than the standard installation priority of the JCR installer to ensure bundles/configs from this mechanism take higher priority  |
| `installhook.installer.class` | `org.apache.sling.installer.provider.installhook.OsgiInstallerHookOsgiInstallerHookEntry` | Alternative to including the hook in package, however then the bundle `org.apache.sling.installer.provider.installhook` needs to be installed as prerequisite | 
