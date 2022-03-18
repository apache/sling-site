title=Apache Sling 12 released		
type=page
status=published
tags=launchpad
~~~~~~

The Sling 12 release contains numerous improvements, such as official Java 17 support, complete migration to the [OSGi Feature Model](/documentation/development/feature-model.html], and various performance improvements and updates.

Read on to see more details about the individual improvements. To find out more about running Sling, see our [getting started page](/documentation/getting-started.html).

## Official support for Java 17

The Sling Starter and included modules are validated to work on Java 8, 11, and 17. Note that for Java 17 the `org.apache.sling.commons.threads` will not clean up leftover `ThreadLocal` instances unless the  `--add-opens java.base/java.lang=ALL-UNNAMED` is passed to the JVM.

This fix is already applied to the [official Sling Starter Docker image](https://hub.docker.com/r/apache/sling) and we anticipate further fixes in this area.

## Update to Oak 1.42.0

[Apache Jackrabbit Oak](jackrabbit.apache.org/oak/) 1.42.0 brings numerous performance improvements and new features that are now available in the Sling Starter.

### Pre-authenticated login for system users

[Oak pre-authenticated login](https://jackrabbit.apache.org/oak/docs/security/authentication/preauthentication.html) without repository involvement presents a number of advantages:

* it is faster since the repository is not involved
* allows mapping a single principal to the repositories of multiple service users, making ACLs easier to define in a fine-grained manner

### Principal-based authentication

[Oak principal-based authentication](https://jackrabbit.apache.org/oak/docs/security/authorization/principalbased.html) is an alternate way of supporting access control entries, with the main difference being that the policy entries are stored together with the user itself, rather than with the content they target.

The support has been implemented both in the Sling Starter and in repoinit.

## Migration to the feature model

The Sling Starter is now built and launched with the [OSGi Feature Model](/documentation/development/feature-model.html]. This aligns our tooling with the upstream OSGi specification work from [RFP 188](https://github.com/osgi/design/blob/master/rfps/rfp-0188-Features.pdf) and [RFC 241](https://github.com/osgi/design/tree/master/rfcs/rfc0241) and provides significant additional tooling around composing, analysing, and launching Sling applications.

Applications based on Apache Sling are encouraged to evaluate migrating to the OSGi feature model.

### New mechanism for launching the Sling Starter

The OSGi feature model does not support creating WAR files. The Sling Starter therefore no longer produces WAR files. The currently produced artifacts are:

* the [`apache/sling:12` docker image](https://hub.docker.com/r/apache/sling)
* individual feature model files which define the bundles and configurations of the Sling Starter in JSON format
* aggregate feature model files which contain include all the artifacts needed to launch Sling

## Support for content-package development

The Sling Starter fully supports development based on content packages. Content packages may be defined in the feature model, deployed via an HTTP API or using the Composum UI.

See [Content-package based development](/documentation/development/content-packages.html) for more details.

## Java API for ordering resources

The Sling `ResourceResolver` had gained a new `orderBefore` method that can be used to order child resources. Support needs to be added by various `ResourceProvider` implementations. Notably, the JCR ResourceProvider has support for this method.

## Scripting enhancements

### New scripting engines

The Sling Starter includes the Freemarker and Thymeleaf engines out-of-the-box.

### Added support for precompiled scripts

Java and HTL scripts may now be precompiled for better runtime performance and build-time checks.

## Improvements in run mode support

The Apache Sling Settings bundle now supports the OR (`,`) and AND (`.`) combinations of run modes and negations with `-` .

## Running multiple versions of the same bundle in parallel

The Sling OSGi installer now supports running multiple versions of the same bundle in parallel. See [multi-version support in the OSGi installer](/documentation/bundles/osgi-installer.html#multi-version-support-1) for details and limitations.

## Performance improvements in resource resolution

1. The result of `ResourceResolver.isResourceType` is cached
1. Optimised SQL queries are used when optimised alias resolution is enabled, ensuring especially to not touch areas like `/jcr:system` and `/jcr:versionStorage`. This applies to both aliases and vanity paths.
1. Spurious change events are no longer fired during content changes

## Repository maintenance

The repository maintenance bundle has been added to the Sling Starter. This allows configuring jobs running maintenance tasks, such as version purge, revision cleanup, and datastore cleanup.

## Version updates

Multiple bundles have been updated to the latest versions. On top of other improvements listed in this page we have added the Sling `resource.filter` bundle and no longer include commons-lang 2 in the Sling Starter.

### OSGi Core R8 compliance

Sling Starter ships with [Apache Felix 7](https://felix.apache.org/documentation/index.html) which implements [OSGi Core R8](https://docs.osgi.org/specification/osgi.core/8.0.0/) fully. In addition it comes with Felix SCR 2.2.0 which implements [Declarative Services 1.5](https://docs.osgi.org/specification/osgi.cmpn/8.0.0/service.component.html) (part of OSGi Compendium R8).
