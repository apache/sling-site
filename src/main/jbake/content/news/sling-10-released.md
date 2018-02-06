title=Apache Sling 10 released		
type=page
status=published
tags=launchpad
~~~~~~

The Sling 10 release is focused on adding improved support for newer Java versions, but we managed to sneak in a couple of improvements as well. Please see the full details below.

To find out more about running Sling, see out [getting started page](/documentation/getting-started.html).

## Java 9 and 10 support

Sling now fully supports Java 9, with the integration tests running on Java 8 and Java 9 side-by-side. Java 10 has received the same attention in terms of testing, but since it is not officially released we can not declare it as fully supported.

## Change of artifactId for the main Sling artifact

To better reflect its role, the old Sling launchpad has been renamed to the Sling starter. The name reflects that it's been used to quickly start working with Sling and also that it's aimed to start your appetite of working with Sling.

The Maven coordinates have changed from `org.apache.sling:org.apache.sling.launchpad` to `org.apache.sling:org.apache.sling.starter` .

## Migrated from tika-bundle to tika-parsers

In order to keep the Slingstart artifact size under control, we no longer embed the tika-bundle uber-artifact. Instead, we include tika-parsers and explicitly support parsing of PDF documents via PDFBox. Consumers that desire to parse other document types can include other dependencies as OSGi bundle as needed.

Discovering parsers that do not work can be done by starting Sling with the additional `-Dorg.apache.tika.service.error.warn=true` argument. See also [Troubleshooting Tika](https://wiki.apache.org/tika/Troubleshooting%20Tika) .

## Direct access to a DataStore binary when the repository allows it

Sling is now able to directly redirect clients to secure URLs of DataStore binaries when the underlying repository allows it. This feature is intended to allow quick serving of content from remote services such as S3 without having to stream the binaries from Sling.

For more details see [OAK-6575 - Provide a secure external URL to a DataStore binary](https://issues.apache.org/jira/browse/OAK-6575), [SLING-7140 - Support redirects to URLs provided by the underlying datastore](https://issues.apache.org/jira/browse/SLING-7140) and [Ian Boston's quick configuration notes](https://gist.github.com/ieb/f9e044e4033b8f810238fe9a27eeaa78).

## Exception stack traces now contain the originating bundle

When an exception is logged, the Bundle-SymbolicName and the version of the bundle containing each stack trace element are shown. The intent is to simplify debugging and support when logs are available but bundle versions are not known.

See the [logging documentation](https://sling.apache.org/documentation/development/logging.html) for more details.

## Update to Oak 1.6.8

We use the latest stable Oak version from the 1.6 stream, bringing in over 140 fixes and improvements. See the [full list of resolved issues][oak-fixes].

## Service user web console page added

Working with service users is now made simpler by a new Web Console addition which allows inspecting and managing Service Users.

![service users in web console](/documentation/development/serviceuser-web-console.png)

This console page is available as a standalone artifact at the `org.apache.sling:org.apache.sling.serviceuser.webconsole` Maven coordinates.

## Service user privilege declaration based on principal names

Service users may now be declared as having a list of principal names which exhaustively map the privileges they contain. This style of declaration is preferred since it reduces redundancy and adds clarity to the privileges used by a certain service user. Pre-authentication can also lead to performance improvements.

The OSGi configuration differs from the standard model by using an array to hold the principal names, as opposed to a single value. An example can be seen below

    org.apache.sling.serviceusermapping.impl.ServiceUserMapperImpl.amended-resourceresolver
      user.mapping=[
        "org.apache.sling.resourceresolver:mapping\=[repository-reader-service]"
      ]

See the [Oak documentation on pre-authentication](http://jackrabbit.apache.org/oak/docs/security/authentication/preauthentication.html#withoutrepository) for more details.

## Enhancements to the repoinit language

We have added several improvements to repoinit, including

* mixins in "create path" statements
* repository-level permissions
* disabling service users
* specifying oak restrictions

See the [Repository Initialization documentation](https://sling.apache.org/documentation/bundles/repository-initialization.html) for more details.

## Support for mounting JSON files in the bundle resource provider

The bundle resource provider now allows adding JSON files which hold properties for various nodes.

The feature can be enabled by adding a directive to the header entry: `propsJSON:=EXTENSION`, e.g. `propsJSON=json`.  All files having the configured extension will be treat as JSON files containing properties for the resources.

See the [Bundle resources documentation](https://sling.apache.org/documentation/bundles/bundle-resources-extensions-bundleresource.html) for more details.

[oak-fixes]: https://issues.apache.org/jira/issues/?jql=project%20%3D%20OAK%20AND%20resolution%20is%20not%20empty%20and%20fixVersion%20in%20(1.6.2%2C1.6.3%2C1.6.4%2C1.6.5%2C1.6.6%2C1.6.7%2C1.6.8)%20ORDER%20BY%20priority%20DESC%2C%20updated%20DESC)
