title=Apache Sling 11 released		
type=page
status=published
tags=launchpad
~~~~~~

The Sling 11 release adds better support for present and future Java versions, upgrades to the latest stable Oak and OSGi specification releases and features improved ACL setup for out-of-the-box.

To find out more about running Sling, see our [getting started page](/documentation/getting-started.html).

## Removed the need to use '--add-modules'

Sling 10 worked just fine on Java 9 or newer but required the addition of the _--add-modules java.se.ee_ flag. This is no longer needed, and Sling is validated to work on all Java versions from 8 to 11.

## Update to Oak 1.8.8

We use the latest stable Oak version from the 1.8 stream, bringing in over 1200 fixes and improvements. See the [full list of resolved issues for Oak 1.8.0 to 1.8.8][oak-fixes].

## Update to OSGi R7 implementations

The Config Admin, SCR, Event Admin, Metatype and HTTP bundles are now at the R7 level. These updates bring numerous improvements and fixes, such as:

- constructor injection for declarative services components
- improved Java 9 support
- bundle annotations
- activation fields for declarative services components

For more details, see [A summary of the OSGi r7 release][osgi-r7].

## Update to HTL 1.4

The 1.4 version of the HTML Template Language Specification brings the following enhancements:

* `data-sly-list` and `data-sly-repeat` iteration control
* the introduction of the `in` relational operator
* support for negative Number literals
* attribute identifier for the `data-sly-unwrap` block statement
* an extended list of attributes for which the `uri` display context is applied automatically
* a new block statement - `data-sly-set`

For more details, see the [HTL 1.4 release][htl-release]

## Starter content moved to /content

The Sling Starter application now installs all content under `/content/starter` to prevent clashes with other applications.  

## Anonymous access restricted to /content

Moving all content under `/content` has made it possible for the Sling Starter to have a more secure setup out-of-the-box, where only `/content`
is accessible to unauthenticated users.

## Repoinit enhancements

Repoinit, the repository initialisation language, has received a number of enhancements:

* definition of intermediate paths when creating users
* registration of custom privileges
* support for empty `rep:glob` restrictions

See the [repoinit documentation][repoinit] for more details.

## Form-based login for Web Console

The Web Console and regular Sling login experiences have been unified, and if a user
accesses the web console without being authenticated the configured Sling login 
mechanism is used. By default this mechanism is the form-based one.

[oak-fixes]: https://issues.apache.org/jira/issues/?jql=project%20%3D%20OAK%20AND%20resolution%20is%20not%20empty%20and%20fixVersion%20in%20(1.8.0%2C%201.8.1%2C%201.8.2%2C1.8.3%2C1.8.4%2C1.8.5%2C1.8.6%2C1.8.7%2C1.8.8)%20ORDER%20BY%20priority%20DESC%2C%20updated%20DESC
[osgi-r7]: https://blog.osgi.org/2018/02/osgi-r7-highlights-proposed-final-draft.html
[htl-release]: https://github.com/Adobe-Marketing-Cloud/htl-spec/releases/tag/1.4
[repoinit]: https://sling.apache.org/documentation/bundles/repository-initialization.html
