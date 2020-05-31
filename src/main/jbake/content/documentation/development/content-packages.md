title=Content-Package based development
type=page
status=published
tags=development,contentloading
~~~~~~

# Content-Package based development

Sling offers first-class support for [Apache Jackrabbit FileVault](https://jackrabbit.apache.org/filevault/) content packages. FileVault offers a way of mapping content on filesystem to the JCR repository and the other way around. Content packages are an alternative to [the content loader mechanism](/documentation/bundles/content-loading-jcr-contentloader.html), offering a richer tool set and better support for deploying additional entities, such as users, groups, and access control entries.

There are three components of the content packages support:

- client-side tooling for building and installing content packages
- server-side support for installing content packages at runtime
- server-side support for installing content packages at build time

The server-side support for Apache Sling is made of:

- the [Composum Package Manager](https://www.composum.com/home/nodes/pckgmgr.html), implementing the HTTP API that receives and installs content packages
- the [Apache Sling Content Package Installer Factory](/documentation/bundles/content-package-installer-factory.html), allowing the deployment of content packages at build time.

Content packages can be included at build time using either the [provisioning model](/documentation/development/slingstart.html) or the [feature model](/documentation/development/feature-model.html).

The client-side support depends on the toolset used to build the project.

For Maven projects, this support consists of

- the [filevault-package-maven-plugin](https://jackrabbit.apache.org/filevault-package-maven-plugin/) builds content packages from Maven projects
- the [wcmio-content-package-maven-plugin](https://wcm.io/tooling/maven/plugins/wcmio-content-package-maven-plugin/) uploads content packages at runtime to a Sling instance using an HTTP API

For Javascript projects, the suport consists of the [Sling Packager](https://github.com/apache/sling-slingpackager/).

## Creating a content package

### Maven projects

There are two options for getting started with content package projects via Maven.

The first one is the [Sling Project Archetype](https://github.com/apache/sling-project-archetype), which creates a multi-module project that includes content packages as part of its output. To use it, run the following command

    $ mvn archetype:generate -Dfilter=org.apache.sling:sling-project-archetype

then select the latest version of the archetype and fill in the required information.

The second one is [Content-Package Archetype](https://github.com/apache/sling-content-package-archetype) , which creates a single content package. Similar to the `sling-project-archetype`, generating a project only requires:

    $ mvn archetype:generate -Dfilter=org.apache.sling:sling-content-archetype

Using one archetype or the other is largely a matter of preference. The `sling-project-archetype` takes a more batteries-included approach, while the `sling-content-archetype` creates only a minimal content package.

### Node projects

An example project using the Sling Packager can be found at [peregrine-cms/simple-sling-vue-example](https://github.com/peregrine-cms/simple-sling-vue-example) on GitHub.

## Deploying a content package at runtime

### Maven projects

Building a content package is achieved using the Maven command line

    $ mvn package
    
After starting up Sling, the resulting file can then be deployed using the wcmio-content-package-maven-plugin

    $ mvn wcmio-content-package:install
   
### Node projects

Content packages are built with

    $ npx slingpackager package <folder>

After starting up Sling, the resulting file can then be deployed with

    $ npx slingpackager upload <content-package.zip> -i
 
### Composum UI

The Composum package manager allows performing multiple operations through its user interface. To access the package manager, ensure that you are logged in to the Sling Starter and then navigate to the Composum Package Manager at [http://localhost:8080/bin/packages.html](http://localhost:8080/bin/packages.html).

Some of the possible operations are:

- building content packages from existing content
- uploading and installing existing content packages
- uninstalling existing content packages

### OSGi Installer

Installing packages through the [OSGi installer](../bundles/osgi-installer.html) is supported via the [Content Package Installer Factory](../bundles/content-package-installer-factory.html).

### Notes

Inspecting the content package reveals that is is just a ZIP file with additional metadata. Of definite interest are the manifest - `META-INF/MANIFEST.MF` and the filter definition - `META-INF/vault/filter.xml`. More information can be found at <https://jackrabbit.apache.org/filevault/metadata.html>.

The [Sling IDE Tooling](/documentation/development/ide-tooling.html) has support for exporting and importing content incrementally to a Sling instance, and can be used alongside the Maven-based tooling.

## Installing a content package at build time

For the content package to be installed at build time, it must be available in a Maven repository at the time when the Sling application is built.

For the provisioning model, the content package must be added to an `artifacts` section, with the zip extension.

    [feature name=my-app]

    [artifacts]
      org.apache.sling.sample/org.apache.sling.sample001/1.0-SNAPSHOT/zip
      
For the feature model, the content package must be added to the `content-packages` section, also with a zip extension:

    {
      "id": "...",
      "content-packages:ARTIFACTS|true": [
        "org.apache.sling.sample:org.apache.sling.sample001:zip:1.0-SNAPSHOT"
      ]
    }
