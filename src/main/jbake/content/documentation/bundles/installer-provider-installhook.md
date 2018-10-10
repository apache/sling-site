title=Installer Vault Package Install Hook
type=page
status=published
tags=installer
~~~~~~

## Overview

The Installer Vault Package Install Hook allows to install bundles and configurations synchronously during vault package installation by feeding them directly to the [OSGI installer core](/documentation/bundles/osgi-installer.html). That way [vault package dependencies](http://jackrabbit.apache.org/filevault/properties.html) can be used to not only depend on content of a package, but also on configurations and bundles contained in a package (the installer install hook has to be added to the package the dependency points to). The mechanism is useful for scenarios when a package contains custom oak restrictions (e.g. [Sling Oak Restrictions](/documentationbundles/sling-oak-restrictions.html)) or other install hook(s) that use the install hook package property (e.g. `installhook.myhook.class`) to reference OSGi services that are provided by another bundle. Also see [SLING-7790](https://issues.apache.org/jira/browse/SLING-7790)

## Installation Process

The Installer Vault Package Install Hook scans through the contained files and installs bundles (extension `jar`) and OSGi configurations with extension `config` (`conf` and node configurations are not supported). Runmode folders (e.g. `install.publish` or `config.author`) are supported. To perform the installation, the hook registers the installable resources to the OSGi installer core with the exact same digest as the JCR installer would do (hence the JCR installer that will also process the resource but without causing any change as the digest matches). Files that are already installed are ignored (this is checked using [InfoProvider.html](http://sling.apache.org/apidocs/sling10/org/apache/sling/installer/api/info/InfoProvider.html))

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
                            <version>1.0.0</version>
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
| `installhook.installer.class` | `org.apache.sling.installer.provider.installhook.OsgiInstallerHook` | Alternative to including the hook in package, however then the bundle `org.apache.sling.installer.provider.installhook` needs to be installed as prerequisite | 
