Title: Incremental Builds in Sling IDE tooling for Eclipse

[TOC]

## Overview

The Sling IDE Tooling relies on the [m2e incremental build support](https://wiki.eclipse.org/M2E_compatible_maven_plugins) for the generation of the bundle's manifest, the component descriptions as well as the metatype resources (the latter two being generated through OSGi 6 [component annotations](https://osgi.org/javadoc/r6/cmpn/org/osgi/service/component/annotations/package-summary.html) and [metatype annotations](https://osgi.org/javadoc/r6/cmpn/org/osgi/service/metatype/annotations/package-summary.html) or through [Apache Felix SCR annotations](http://felix.apache.org/documentation/subprojects/apache-felix-maven-scr-plugin/scr-annotations.html)). That means whenever at least one java class is touched and the auto-build in Eclipse is enabled the annotations on that class should be reevaluated. This may lead to a modification of the bundle's manifest and/or generation/modification of service description XMLs and/or Metatype resource files.
Depending on which maven plugins you use you must adjust their configuration accordingly to properly support incremental builds.

## Manifest Generation

### maven-bundle-plugin

The [maven-bundle-plugin](http://felix.apache.org/documentation/subprojects/apache-felix-maven-bundle-plugin-bnd.html) is based on the [bnd library](http://bnd.bndtools.org/). It uses bnd to generate the bundle's manifest.

#### maven-bundle-plugin prior to version 3.2.0

This version needs [m2eclipse-tycho](https://github.com/tesla/m2eclipse-tycho) (an Eclipse plugin) to generate the manifest and service descriptions during the incremental build. This plugin can be installed through the Maven Discovery feature of m2e.

#### maven-bundle-plugin since version 3.2.0

Natively supports incremental builds for the `manifest` goal ([FELIX-4009](https://issues.apache.org/jira/browse/FELIX-4009)) which needs to be explicitly configured as outlined in the [maven-bundle-plugin FAQ](http://felix.apache.org/documentation/faqs/apache-felix-bundle-plugin-faq.html#use-scr-metadata-generated-by-bnd-in-unit-tests). m2e-tycho is incompatible with that version, because it leads to errors like `Duplicate bundle executions found. Please remove any explicitly defined bundle executions in your pom.xml.` and `Duplicate manifest executions found. Please remove any explicitly defined manifest executions in your pom.xml.` (compare with [issue 31](https://github.com/tesla/m2eclipse-tycho/issues/31)). Therefore uninstall m2eclipse-tycho if you want to use newer versions of the `maven-bundle-plugin`.

### bnd-maven-plugin

The [bnd-maven-plugin](https://github.com/bndtools/bnd/tree/master/maven/bnd-maven-plugin) is developed from the bnd team and is based on bnd as well. It is versioned in parallel with bnd and bndtools. It natively supports incremental builds since version 3.1.0 ([issue 1180](https://github.com/bndtools/bnd/issues/1180)).

## Service Description and Metatype Resources

OSGi component and metatype annotations (for OSGi 6) are natively supported through bnd (and therefore automatically generated through both maven-bundle-plugin and bnd-maven-plugin). You don't need to configure anything explicitly since version 3.0.0 of bnd ([issue 1041](https://github.com/bndtools/bnd/issues/1041)).

The maven-bundle-plugin can be optionally coupled with the [maven-scr-plugin](http://felix.apache.org/documentation/subprojects/apache-felix-maven-scr-plugin/apache-felix-maven-scr-plugin-use.html). Both maven-bundle-plugin as well as bnd-maven-plugin can be optionally coupled with the [scr-bnd-plugin](http://felix.apache.org/documentation/subprojects/apache-felix-maven-scr-plugin/apache-felix-scr-bndtools-use.html). Both approaches can be used to generate components descriptions and metatype resources out of the [Felix SCR annotations](http://felix.apache.org/documentation/subprojects/apache-felix-maven-scr-plugin/scr-annotations.html). The recommended way for new projects though is to rely on OSGi 6 annotations. However if you need to rely on Felix SCR annotations though it is recommended to rather use the scr-bnd-plugin over the maven-scr-plugin, as the former is nicely integrated into bnd and therefore means less overhead during the build.