title=Maven Archetypes		
type=page
status=published
tags=development,maven
~~~~~~

Sling includes several Maven archetypes to quick start development. See [http://maven.apache.org/archetype/maven-archetype-plugin/](http://maven.apache.org/archetype/maven-archetype-plugin/) for general information on using Maven archetypes. The Maven groupId for all Sling archetypes is `org.apache.sling`.

### sling-bundle-archetype

This archetype generates a Maven project which will build a basic OSGi bundle including support for the Felix SCR Annotations. It is pre-configured to install using the Felix Web Console when the profile `autoInstallBundle` is activated.

### sling-content-package-archetype

Maven archetype for a Jackrabbit FileVault content package

### sling-initial-content-archetype

This archetype generates a Maven project which will build an OSGi bundle that supports JCR NodeType registration (in `SLING-INF/nodetypes/nodetypes.cnd`) and initial content loading (in `SLING-INF/scripts` and `SLING-INF/content`).

### sling-jcrinstall-bundle-archetype

This archetype generates a Maven project which will build a basic OSGi bundle including support for the Felix SCR Annotations. It is pre-configured to install using a WebDAV PUT into the JCR when the profile `autoInstallBundle` is activated.

### sling-launchpad-standalone-archetype

This archetype generates a Maven project which will build a standalone Launchpad JAR file using the default bundle set. For demonstration purposes, the generated project includes an extra bundle list file (`src/main/bundles/list`) which includes Apache Felix FileInstall as well as a test configuration file (`src/test/config/sling.properties`).

### sling-launchpad-webapp-archetype

This archetype generates a Maven project which will build a Launchpad WAR file using the default bundle set. For demonstration purposes, the generated project includes an extra bundle list file (`src/main/bundles/list`) which includes Apache Felix FileInstall as well as a test configuration file (`src/test/config/sling.properties`).

### sling-project-archetype

This archetype will create a Sling project that can be deployed on the Sling 12. In contrast to the Apache Sling Maven Archetypes this one is geared towards creating a full project and not just a single module. See the [sling-project-archetype github repo](https://github.com/apache/sling-project-archetype) for more details.

### sling-servlet-archetype

This archetype generates a Maven project which will build an OSGi bundle containing two Servlets registered with Sling, one registered by path and one registered by resource type.