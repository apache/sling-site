title=Content Package Installer Factory		
type=page
status=published
tags=installer,contentloading
~~~~~~

The content package installer factory provides support for [Jackrabbit FileVault Content Packages](https://jackrabbit.apache.org/filevault/index.html) to the [OSGI installer](/documentation/bundles/osgi-installer.html). The provisioning of artifacts is handled by installer providers like the [file installer](/documentation/bundles/file-installer-provider.html) or the [JCR installer](/documentation/bundles/jcr-installer-provider.html).

## Content Packages

Content Packages must be provided with extension `.zip`. They will be automatically installed/uninstalled via the [JcrPackageManager API](https://jackrabbit.apache.org/filevault/apidocs/org/apache/jackrabbit/vault/packaging/JcrPackageManager.html). The (un-)installation behaviour can be further tweaked via the OSGi configuration provided for PID `org.apache.sling.installer.factory.packages.impl.PackageTransformer`

## Configuration

As of version 1.0.4 the bundle requires a service user mapping to function correctly. An example mapping, using the provisioning model is


    org.apache.sling.serviceusermapping.impl.ServiceUserMapperImpl.amended-installer-factories
      user.mapping=[
        "org.apache.sling.installer.factory.packages\=sling-package-install"
      ]


The service user requires needs access to all locations which are covered by packages and to `/etc/packages` itself.

A sample user configuration using repoinit is


    create service user sling-package-install

    set ACL for sling-package-install
        allow  jcr:all     on  /
        allow  jcr:namespaceManagement,jcr:nodeTypeDefinitionManagement on :repository
    end

In addition it is necessary to list the service user in the OSGi configuration for PID `org.apache.jackrabbit.vault.packaging.impl.PackagingImpl` to allow execution of [Install Hooks](https://jackrabbit.apache.org/filevault/installhooks.html).

# Project Info

* Content package installer factory ([org.apache.sling.installer.factory.packages](https://github.com/apache/sling-org-apache-sling-installer-factory-packages))
