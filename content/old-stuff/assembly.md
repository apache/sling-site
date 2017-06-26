title=Assembly
type=page
status=published
~~~~~~
The Assembly concept grew out of a need to bundle together a set of OSGi Bundles to deploy applications. The concept has been developped before the OSGi Deployment Package Service Specification has been published in the Release 4.1 Compendium Services Specification. It will have to be discussed whether the Assembly concept is dropped in favor of the Deplyoment Package Service.

## Introduction

This chapter discusses the units of deployment as well as the units of functionality. The following contents is based on the Module and Service specifications of the OSGi Service Platform Core Specification, Release 4 but enhances functionality for ease of use and in terms of best practices.

The term *Units of Deployment* describes the idea of packaging up functionality implemented by Java Classes into modules, so called *Bundles*. For bigger and more complicated applications the fine grained modularity of *Bundles* may be to complicated, so this chapter proposes an extension called *Assembly*. The goal of the *Assembly* specification presented below is to provide functionality to delivery a collection of bundles belonging together.

The term *Units of Functionality* describes the idea of providing services implemented by Java Classes, so called *Services*. A *Service* is an abstraction and does not actually prescribe the implementation of specific interfaces. Instead the OSGi specification states how functionality may be provided to clients by registering objects implementing interfaces defining the functionality in terms of a Java API.



## Bundles

The core unit of deployment is the *Bundle*. The OSGi core specification defines a *Bundle* to be a Java Archive (JAR) file whose manifest - the `META-INF/MANIFEST.MF` file - contains specific headers identifying the bundle. Most manifest headers are optional with defined default values - only the `Bundle-SymbolicName` header is actually required and the `Bundle-ManifestVersion` header should be set to `2` to identify the bundle to be a R4 bundle. Other information defined in the manifest is the bundle version, the list of packages exported - provided to other bundles - and imported - used and required to be provided by other bundles. See chapter *3.2.1 Bundle Manifest Header* of the OSGi Service Platform Core Specification for a complete list of the defined bundle manifest headers.

Bundles may be installed, updated , started, stopped and removed in an OSGi framework individually.



## Assemblies

For the deployment of bigger systems, the number of bundles may increase very quickly. To ease the management of products consisting of multiple bundles, this chapter introduces the *Assembly*. An Assembly is simply a collection of bundles deployed together. An Assembly - like a Bundle - is a JAR file whose manifest contains specific headers. In fact, an Assembly is just a standard bundle, with additional functionality.

Assemblies are managed by the *Assembly Manager* which itself is a bundle installed into the framework.



### Assembly manifest headers

As an Assembly is a standard Bundle, all the defined Bundle manifest headers may be specified. In addition, for the *Assembly Manager* to recognize an assembly and for the OSGi Bundle Repository to support dependency resolution, the following manifest headers are defined. All headers are optional with documented default values except where noted.

* **Assembly-Bundles** - The list of bundles contained in this assembly. See below for the definition of the syntax of this header. This header is required. The presence of this headers identifies an Assembly to the *Assembly Manager*.
* **Assembly-BundleRepository** - A comma-separated list of URLs pointing to OSGi Bundle Repository descriptors. These bundle repositories will be used to install bundles listed in the `Assembly-Bundles` header. This header is optional with not default value.



### Assembly Lifecycle

An Assembly, like all bundles, may be in any of the defined bundle states:

* **Installed** - The Assembly bundle has been installed into the system but not yet resolved. The *Assembly Manager* will try to install all bundles listed in the `Assembly-Bundles` header. The start levels of the bundles will be set according to the `startlevel` parameter. The bundles will not be started. If installation of one or more of the bundles fails, *Assembly Manager* logs an error message.
* **Resolved** - The Assembly bundle is resolved, that is all imported packages are wired into the framework. The *Assembly Manager* does not handle this state change, rather the installed bundles will be resolved by the framework either automatically after installation or when started later.
* **Started** - The Assembly bundle has been started by calling the `Bundle.start()` method. The *Assembly Manager* will start all newly installed and resolved bundles. Depending on the start level set on the bundle(s) and the current system start level, the bundles will only be permanently marked to start while actually starting the bundles may be delayed until the system enters the respective start level. If any bundle fails to start, an error message is logged.
* **Stopped** - The Assembly bundle has been stopped by calling the `Bundle.stop()` method. All bundles belong to the Assembly and linked to the Assembly are also stopped.
* **Unresolved** - The Assembly bundle has been unresolved by the system for any reason, possibly any missing dependencies. Assembly bundles entering this state are ignored by the *Assembly Manager*.
* **Uninstalled** - The Assembly bundle is being uninstalled by calling the `Bundle.uninstall()` method. The *Assembly Manager* will (try to) uninstall all bundles listed in the `Assembly-Bundles` header.
* **Updated** - The Assembly bundle will update all bundles installed previously according to the `Assembly-Bundles` header. If this header omits any bundle listed in the previous bundle version, the respective bundle is uninstalled from the system. If a bundle is already installed with the correct version, the installed bundle is not touched (It may though be uninstalled together with the Assembly Bundle if the Assembly Bundle is uninstalled).



### Bundles referenced by multiple Assembly Bundles

It is conceivable, that bundles are listed in the `Assembly-Bundles` header of more than one Assembly Bundle. If this is the case, the following collision resolution takes place:

   * If the version of the bundle installed by the first Assembly bundle handled matches the version specification of any later Assembly Bundle, the installed bundle is not touched. Otherwise, if the later Assembly Bundle lists a version specification, which is acceptable for the first Assembly Bundle, the installed bundle is updated to the required version. If the version specifications may not be matched one way or the other, the later Assembly Bundle fails to install.
   * If the bundle is installed with a defined start level, the later Assembly Bundle will not overwrite the already set start level. If the start level has not been set yet it is set to the specified start level.
   * Bundles installed through Assembly Bundles remain installed as long as there is at least one Assembly Bundle listing the bundle in the `Assembly-Bundles` header. As soon as there is no referring Assembly Bundle anymore, the bundle is uninstalled.
   * Bundles not referred to by any Assembly Bundle are ignored by the *Assembly Manager*.
   * Bundles installed through the *Assembly Manager* may be updated and/or uninstalled independently from their defining Assembly Bundle. If a bundle has been installed it will be reinstalled the next time the Assembly Bundle enters the *installed* state. If a bundle has been updated, it is not touched by the *Assembly Manager* as long as the updated version matches the version specification of the Assembly Bundle.



### Bundle Installation

When an Assembly is installed into the framework, the *Assembly Manager* checks to see whether the Assembly needs to be deployed. This is done by checking the bundles listed in the `Assembly-Bundles` header whether they are installed or not. All bundles not installed will be installed and started if requested so.

The following BNF defines the syntax =Assembly-Bundles= header value:


    Assembly-Bundles = Bundle { "," Bundle } .
    Bundle = Symbolic-Name { ";" Parameter } .
    Symbolic-Name = // The Bundle symbolic name 
    Parameter = ParameterName "=" ParameterValue .


To control the selection and installation of bundles, the following parameters may be used:

* **version** - The version of the bundle to install. This is a version range specification as per chapter 3.2.5 Version Ranges of the OSGi core specification. When this parameter is declared as a single version - eg. *1.2.3* - it is interpreted as the version range *\[1.2.3,&infin;)*. The default value is *\[0.0.0,&infin;)* to install the most recent version of the bundle available.
* **startlevel** - The start level to set for the bundle. This may be any positive integer value. Default value is undefined to use the current initial bundle start level of the framework.
* **entry** - The path of the Assembly Bundle entry providing the data to be installed.
* **linked** - Defines whether the bundle should be started and stopped together with the Assembly to which the bundle belongs. Default value is `true`.

If resolving the bundles results in more bundles to be downloaded from the bundle repository to resolve the dependency, these bundles are always automatically started and assigned a startlevel which is smaller than the smallest startlevel of any of the bundles listed.


### Bundle Location

Generally bundles to be installed with an Assembly Bundle are retrieved from an OSGi Bundle Repository. The `Assembly-BundleRepository` header may list additional URLs which will be temporarily used to resovle the bundles. Otherwise the system default bundle repositories will be used only.

If a bundle is defined in the `Assembly-Bundles` header with an `entry` parameter, the respective entry is first looked for in the Assembly Bundle. If the entry exists, it is used as the bundle source to install. If no `entry` parameter is present for a declared bundle or the entry is missing, the OSGi Bundle Repository is used.

Restrictions when packaging bundles with the Assembly:

* **Dependency Resolution** - Any missing dependencies of the bundles to be installed will not be resolved. That is, if the bundles fail to resolve, the Assembly fails to install.
* **`version` Parameter** - The `version` parameter of the bundle installation declaration is ignored because any JAR file whose name matches the bundle symbolic name to be installed, is installed.

If the `Assembly-BundleRepository` header contains a comma-separated list of URL to OSGi Bundle Repository descriptors and the OSGi Bundle Repository Service is available in the framework, the bundles declared in the `Assembly-Bundles` header are resolved through the OSGi Bundle Repository Service using the URL from the `Assembly-BundleRepository` header.

If the bundles declare any dependencies, which may not be resolved by bundles already installed in the framework or by any of the bundles to be installed, the OSGi Bundle Repository is used to try to resolve these missing dependencies. If this resolution succeeds, installation of the Assembly succeeds. Any bundles not declared in the Assembly but installed due to this dependency resolution will not be assumed to belong to the Assembly. Hence, these bundles will not be uninstalled (or updated) if the Assembly is uninstalled (or updated).

* **Example** - Assume the `Assembly-Bundles` header is set to `org.apache.sling.sample1;entry=path.jar,org.apache.sling.sample2`. The bundle `org.apache.sling.sample1` is then installed from the Assembly Bundle entry `path.jar`, while the bundle `org.apache.sling.sample2` is resolved in the OSGi Bundle Repository.




## Best Practices


### Size of Bundles

There is no fixed formula to calculate the best size for a bundle: It all depends on the contents and the intentions of the bundle and its programmer. The following list provides some hints:

   * For ease of development follow the idea of *One Bundle - One Project*
   * Don't pack too much into a bundle but do not pack a single class into a bundle (unless you have a very good reason of course :-) )
   * Do not mix and match everything into a bundle. Rather bundle things together which belong together, for example create separate bundles for a HTTP Client implementation and DB support classes
   * Use similar heuristics to decide on the contents of a bundle as you would for the contents of a plain old JAR file.


### Nomen est Omen

The symbolic name of a bundle should reflect its contents. A bundle should generally only contain a single subtree in the virtual package tree. The symbolic name of the bundle should be the root package contained within. For example, consider a bundle containing the packages `org.apache.sling.sample`, `org.apache.sling.sample.impl`, `org.apache.sling.more`. The bundle would the be named `org.apache.sling.sample`.
