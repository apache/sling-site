title=Apache Sling Launchpad 9 released		
type=page
status=published
~~~~~~

Here are some of the more noteworthy things available in this release.

Updated to Oak 1.6.1 and segment-tar persistence
---

We now include the latest stable version of Oak and have switched to the latest
form of the disk-based persitence - oak-segment-tar. This module provides better
runtime characteristics when compared to the oak-segment persistence and also
allows reliable online compaction of the repository.

If you're upgrading from a previous version of Sling you will need to manually
upgrade the repository. See the [Oak documentation on Repository migration](http://jackrabbit.apache.org/oak/docs/migration.html)
for more details.

The Sling Explorer is replaced with Composum
---

The Sling Launchpad ships with a new repository explorer and administration tool - [Composum](https://github.com/ist-dresden/composum). Composum is more reliable and featureful compared to the previous Sling explorer.

The Slingshot sample is included
---

The default Sling configuration now includes the Slingshot sample. Slingshot exemplifies
how to build and deploy a Sling application.

New Resource Provider and Observation API
---

The Resource Provider API has been replaced with a new implementation, which is more performant
and better suited for future evolution. Existing ResourceProvider will be able to work using
a backwards-compatible layer, but developers are nonetheless encouraged to move to the
new implementation.

In the same manner, the Observation API has been refreshed.

New modules added: Validation, Context-Aware Configuration, Repository Initialization Language
---

A number of new general-purpose modules have been added to the Sling Launchpad:

* [Validation](/documentation/bundles/validation.html)
* [Context-Aware configuration](/documentation/bundles/context-aware-configuration/context-aware-configuration.html)
* [Repository Initialization Language](/documentation/bundles/repository-initialization.html)

Tooling: HTL Maven Plugin
---

The [HTL Maven Plugin](http://sling.apache.org/components/htl-maven-plugin/) provides build-time validation for projects using HTL. Furthermore, the HTL engine has been modularised into an HTL Compiler, an HTL Java Compiler and an HTL Script Engine, with the first two allowing to build other HTL tools in a Sling-independent way.

Streaming Upload Support
---

The version of the Sling Engine shipped in the Launchpad now supports streaming uploads,
for better I/O throughput. Streaming uploads are opt-in via setting the following HTTP Header:

    Sling-UploadMode: stream

Discovery: added Oak-based discovery implementation
---

The Sling discovery mechanism has been augmented with a mechanism which delegates instance
discovery to Oak. When working with a DocumentNodeStore-based Oak implementation, this information
is already available to Oak so there is no point in duplicating the work.

Security: loginAdministrative deprecation
---

We believe that the vast majority of bundles performing background work do not require
administrative access to the repository via `loginAdministrative`. We have removed many usages
of `loginAdministrative` in the Sling code and replaced then with a service-based approach
- `loginService`. We encourage you to do the same.

Documentation available at [Service Authentication](/documentation/the-sling-engine/service-authentication.html).

Removed org.apache.sling.commons.json and org.json bundles
---

Apache projects are no longer allowed, for legal reasons, to ship code which uses or links to the 
JSON.org Java implementation. As a consequence we have removed all code which references that
API.

If you need to use these bundles, you can always retrieve then from Maven Central and incorporate
them in your launchpad.
