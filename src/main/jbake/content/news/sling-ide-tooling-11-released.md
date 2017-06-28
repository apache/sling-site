title=Apache Sling IDE Tooling 1.1 released		
type=page
status=published
~~~~~~

Here are some of the more noteworthy things available in this release.

Sightly support
==

Sightly support has been added through an additional, optional, feature named _Sling IDE Tools - Sightly Integration_.

This feature provides the following enhancements:

* auto-completion of tag named and attributes names in the HTML Editor
* wizards for creating new Sightly scripts and Use Classes ( Java and Javascript )
* Sightly-aware validation for HTML files

![Sightly Editor](/documentation/development/ide-tooling/sightly-editor.png)

These enhancements are enabled once the Sightly facet is added to a project. This is done automatically when converting a project to content project, but can also be done manually via the project properties, under the _Project Facets_ page.

Automatic configuration of debug classpath based on the bundles deployed on the server
==

When first connecting to a Sling instance, the IDE tooling tries to bind all the sources associated with the bundles deployed on the server and retrieves the associated source artifacts using Maven. Therefore, the debug classpath is as close as possible to sources used to build the bundles deployed on the server.

![Debugging](/documentation/development/ide-tooling/debug.png)

Since a first source bundle resolution can potentially take a long time, this behaviour can be disabled from the server configuration page.

Maven configurator for content-package projects
==

Maven projects configured using the `com.day.jcr.vault:content-package-maven-plugin` are now automatically configured as content projects, removing the need to manually add the needed facets after importing them into Eclipse for the first time.

Other minor improvements
==

* Keyboard shortcuts now work in the content navigator
* When creating a new server in the project creation wizard, sensible defaults are filled in
* When connecting to a server, all support bundles are automatically installed
