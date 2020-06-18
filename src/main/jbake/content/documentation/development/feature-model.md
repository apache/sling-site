title=The OSGi Feature Model
type=page
status=published
tags=slingstart,maven,launchers,featuremodel
~~~~~~

The OSGi Feature Model, created in 2018, is meant to replace the Sling Provisioning Model as the primary way of defining and assembling Sling applications.

Compared to the Provisioning Model, the Feature Model is richer and more general, and might evolve into an OSGi
standard. It has been created in Sling as that's its primary audience for now, but might move elsewhere as it
evolves.

This page provides a high-level overview of the Feature Model.

See the [main sling-org-apache-sling-feature repository](https://github.com/apache/sling-org-apache-sling-feature) for more 
technical information about the Feature Model. 
A [number of other modules](https://github.com/search?q=topic%3Asling+topic%3Aosgi-feature-model+topic%3Aosgi+org%3Aapache&type=Repositories)
provide additional functionality related to the Feature Model.

The [Feature Model How-To Guide](/documentation/feature-model/feature-model-howto.html) provides a progressive tutorial
and concrete examples.

### The Feature Model

As said above the Feature Model is an *OSGi* version of the Sling Provisioning Model, which at its core
is independent from Sling.

OSGi bundles can be installed on an OSGi container but there is a much more to it to install it onto
an application or create an application. The Feature Model provides these additional parts necessary
to build applications by defining the dependencies, properties, configuration and setup actions.

It is important to note that a Feature Model does **not have to contain all parts** and some of them
can be just providing for example configurations to customize a module or to override a configuration
provided by another Feature Model. 

A Feature Model provides:

* A unique Identifier
* Title, Description, Vendor etc
* Bundle Dependencies
* Framework Properties
* Configurations
* Repo(sitory)-init statements

Some of these parts are handled by Feature Model Extensions so that they can be loaded if required.

Because Feature Model can be easily aggregated basically every bundle can provide their own feature model
which then can be aggregated into a bigger module or application (like Sling).

### Feature Model Ecosystem

The [Feature Model Ecosystem](https://github.com/search?q=topic%3Asling+topic%3Aosgi-feature-model+topic%3Aosgi+org%3Aapache&type=Repositories)
is mostly comprised of the following parts:

* Feature Model (JSon file)
* Feature Model Maven Plugin (sling-slingfeature-maven-plugin)
* Feature Launcher
* Feature Model Extension (provides handling for additional Feature Model parts)
* Feature Model Converters (Content Package or Provisioning Model to Feature Models)
* Feature Model Converter Maven Plugins (Maven Plugin wrapper for Converters)
* Maven Repository / Cache

### Feature Model and Maven Repository

If not inside a project Feature Models and other Artifact created from processing Feature Models
are stored in the local Maven Repository. They may or may not be stored in the same location
as the project.

This allows the Feature Aggregator and/or Launcher to obtain Feature Models from other sources than
just the current project without to know anything about the project(s) that provide them.

### Aggregration

The most important principal of Feature Model is that fact that they can be aggregated into bigger
modules or entire applications. This applies to all part of a Feature Model and resolving conflicts.

Aggregation to generate consolidated Feature Models is done by the **Feature Model Maven Plugin**
(sling-slingfeature-maven-plugin) which takes a list of Feature Modules and then creates
a new Feature Model with all aggregates in it. It also provides the ability to mark a Feature
Model as complete or final, provide artifact, variable, configuration and framwork property
overwrites. Feature Models can added as files, by their classifiers or as Maven dependencies.

Overwrites are used to decide which version of a conflicting element is added to the aggregate.

### Feature Reference Files

A **text file** that contains a list of **Maven Ids** or **Maven Urls** of Feature Models which then can
be used as a reference to include all of the listed Feature Models.
So instead of listing all the desired Feature Models a single Feature Reference file with all of
the Feature Models listed is enough.

Feature Reference Files can be added for example by adding it as **Selection** with type **REFS_INCLUDE**.

