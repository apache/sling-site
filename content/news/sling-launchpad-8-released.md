Title: Apache Sling Launchpad 8 released

Here are some of the more noteworthy things available in this release.

Switched to Apache Jackrabbit Oak
---

The Sling launchpad has switched from Apache Jackrabbit 2.7.5 to Apache Jackrabbit Oak 1.3.7 as a persistence engine. Apache Jackrabbit Oak is now supported in Sling with two persistence modes: SegmentNodeStore ( file-based ) and DocumentNodeStore ( MongoDB-based ). See [the Oak documentation](http://jackrabbit.apache.org/oak/docs/index.html) for more details about the Oak persistence modes and [the Sling Launchpad documentation](https://sling.apache.org/documentation/the-sling-engine/the-sling-launchpad.html#launchpad-app-and-launchpad-webapp) for details about configuring the persistence mode.

Provisioning model
---

Sling is now provisioned using a simple, text-based, model. See See [the Sling Provisioning Model documentation](http://sling.apache.org/documentation/development/slingstart.html) for details.

Sightly
---

Sightly is an HTML templating language, similar to JSP (Java Server Pages) and ESP (ECMAScript Server Pages). The name “Sightly” (meaning “pleasing to the eye”) highlights its focus on keeping your markup beautiful, and thus maintainable, once made dynamic.

The cornerstones of Sightly are:

- Secure by default: Sightly automatically filters and escapes all variables being output to the presentation layer to prevent cross-site-scripting (XSS) vulnerabilities
- Supports separation of concerns: The expressiveness of the Sightly template language is purposely limited, in order to make sure that a real programming language is used to express the corresponding presentation logic
- Built on HTML 5: A Sightly file is itself a valid HTML5 file. All Sightly-specific syntax is expressed either within a data attribute, or within HTML text.

See [the Sightly HTML Templating Language Specification](https://github.com/Adobe-Marketing-Cloud/htl-spec/blob/master/SPECIFICATION.md) for details.

Versioning support in the Resource API
---

The Java Resource API and the HTTP API are now able to work with versioned resources. See [SLING-848 - Support getting versioned resources by using uri path parameters](https://issues.apache.org/jira/browse/SLING-848) for more details.

Improved testing tools
---

The Sling testing tools have seen numerous additions since the last release, including a family of Mock libraries known as the Sling Mocks and a Teleporter JUnit module for running Sling tests in provisioned Sling instances. For more details, see the documentation on [JUnit server-side testing support bundles](https://sling.apache.org/documentation/bundles/org-apache-sling-junit-bundles.html) and [Sling Mocks](https://sling.apache.org/documentation/development/sling-mock.html) .

Servlet API 3.0
---

Sling now uses and requires Servlet API 3.0. See [JSR 315: JavaTM Servlet 3.0 Specification](https://jcp.org/en/jsr/detail?id=315) for details.

Performance
---

Various performance and concurrency improvements were added to the Engine and JCR Resource bundles.

Dependency updates
---

Some of the notable dependency updates are:

* Apache Felix has been upgraded to version 5.2.0
* Apache Tika has been updated to version 1.10
* Apache HttpClient 4.4 has been added

