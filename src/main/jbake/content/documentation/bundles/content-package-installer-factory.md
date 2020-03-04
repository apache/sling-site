title=Content Package Installer Factory		
type=page
status=published
tags=installer
~~~~~~

The content package installer factory provides support for [Jackrabbit FileVault Content Packages](https://jackrabbit.apache.org/filevault/index.html) to the [OSGI installer](/documentation/bundles/osgi-installer.html). The provisioning of artifacts is handled by installer providers like the [file installer](/documentation/bundles/file-installer-provider.html) or the [JCR installer](/documentation/bundles/jcr-installer-provider.html).

## Content Packages

Content Packages must be provided with extension `.zip`. They will be automatically installed/uninstalled via the [JcrPackageManager API](https://jackrabbit.apache.org/filevault/apidocs/org/apache/jackrabbit/vault/packaging/JcrPackageManager.html). The (un-)installation behaviour can be further tweaked via the OSGi configuration provided for PID `org.apache.sling.installer.factory.packages.impl.PackageTransformer`


# Project Info

* Content package installer factory ([org.apache.sling.installer.factory.packages](https://github.com/apache/sling-org-apache-sling-installer-factory-packages))
