title=Apache Sling IDE Tooling 1.2 released
type=page
status=published
tags=ide,eclipse
~~~~~~

This page contains information about the new features in the Sling IDE Tooling 1.2.0 release. For
a full overview of the features and installation instructions, please see the 
[Sling IDE Tooling](/documentation/development/ide-tooling.html) documentation page.

# Custom contribution for provisioning model feature files

Content projects using _slingstart_ packaging now have a custom contribution
that makes provisioning model files easier to access.

![Slingstart Project](/documentation/development/ide-tooling/launchpad-models-directory.png)

# Enhanced error reporting for content projects

The content navigator now shows warnings and error markers, making it easier
to spot problems.

![Content navigator warnings](/documentation/development/ide-tooling/content-navigator-warnings.png)

Additionally, XML files are now checked using a validator aware for FileVault serialization
semantics, which means validation can be enabled without triggering false errors.

![Content navigator XML validation](/documentation/development/ide-tooling/content-navigator-xml-validation.png)

# More fine-grained control over the Maven project configurators

The Maven project configurators for content bundle projects can now be enabled and disabled at the
workspace level. Additionally, only the additional WTP natures and facets can be disabled for content
projects.

The preferences can be accesed via _Sling IDE_ → _Maven Project Configurator_ preference page.

![Maven Project Configurator preferences](/documentation/development/ide-tooling/maven-configurators-preferences.png)

# Support for the bnd-maven-plugin

Projects configured usign the `bnd-maven-plugin` are now properly configured as bundle projects. Previously
only the `maven-bundle-plugin` was supported.

# Support for the new Jackrabbit filevault-package-maven-plugin

Projects configured using the `filevault-package-maven-plugin` from Apache Jackrabbit are now properly configured as
content projects. Previously only the `content-package-maven-plugin`

