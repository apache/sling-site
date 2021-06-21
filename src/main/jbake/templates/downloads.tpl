// ------------------------------------------------------------------------------------------------
// Sling downloads page
// http://www.apache.org/dev/release-download-pages.html explains how the apache.org mirrored
// downloads page work. Basically, we provide a downloads.html page with a few placeholders
// and a form to select the download mirrog, and a downloads.cgi page which wraps the apache.org
// download logic CGI.
//
// To test this page in a local build, open http://localhost:8820/downloads.html - the navigation
// link points to the .cgi variant which doesn't work locally.
// ------------------------------------------------------------------------------------------------

// ------------------------------------------------------------------------------------------------
// Downloads template data
// The page template itself is found below.
// To convert from the old svn downloads.list ust
//    while read l; do echo "  \"$l\","; done < content/downloads.list
// ------------------------------------------------------------------------------------------------
U = new includes.U(config)
def PIPE_SEP = "\\|"
def launchpadVersion="11"

def slingIDETooling=[
  "Sling IDE Tooling for Eclipse|eclipse|1.2.2|A p2 update site which can be installed in Eclipse.|sling-ide-tooling"
]

def slingApplication=[
  "Sling Starter Standalone|A self-runnable Sling jar, for experimenting and learning|org.apache.sling.starter|.jar|${launchpadVersion}|Y",
  "Sling Starter WAR|A ready-to run Sling webapp as a war file, for experimenting and learning|org.apache.sling.starter|-webapp.war|${launchpadVersion}|Y",
  "Sling Source Release|The released Sling source code|org.apache.sling.starter|-source-release.zip|${launchpadVersion}|Y",
  "Sling CMS App|A reference CMS App built on Apache Sling|org.apache.sling.cms.feature|.jar|1.0.2|org.apache.sling.app.cms",
  "Sling Feature Model converter|A CLI tool for converting from content packages to feature model files|org.apache.sling.feature.cpconverter|.zip|1.1.2|Y",
]

def mavenPlugins=[
  "JSPC Maven Plugin|jspc-maven-plugin|2.2.2|Y",
  "Maven Launchpad Plugin|maven-launchpad-plugin|2.3.4|Y",
  "Scripting Bundle Maven Plugin 0.3.0|scriptingbundle-maven-plugin|0.3.0|Y",
  "Sling Maven Plugin|sling-maven-plugin|2.4.2|Y",
  "Sling Feature Maven Plugin|slingfeature-maven-plugin|1.5.4|Y",
  "Sling Feature Converter Maven Plugin|sling-feature-converter-maven-plugin|1.0.4|Y",
  "Sling Feature Launcher Maven Plugin|sling-feature-launcher-maven-plugin|0.1.0|Y",
  "Slingstart Maven Plugin|slingstart-maven-plugin|1.9.12|Y",
  "HTL Maven Plugin|htl-maven-plugin|2.0.2-1.4.0|Y",
  "Sling Kickstart Maven Plugin|sling-kickstart-maven-plugin|0.0.8|Y",
]

def bndPlugins=[
  "Context-Aware Configuration bnd Plugin|org.apache.sling.caconfig.bnd-plugin|1.0.2|Y",
  "Models bnd Plugin|org.apache.sling.bnd.models|1.0.0|Y",
  "bnd Remove Parameters from OSGi Headers Plugin|org.apache.sling.bnd.plugin.headers.parameters.remove|1.0.0|Y"
]

def bundles=[
  "Adapter|org.apache.sling.adapter|2.1.10|Y|jar",
  "Adapter Annotations (JSON) 1.x|adapter-annotations|1.0.0|Y|jar",
  "Adapter Annotations 2.x|org.apache.sling.adapter.annotations|2.0.0|Y|jar",
  "API|org.apache.sling.api|2.23.4|Y|jar",
  "Auth Core|org.apache.sling.auth.core|1.5.4|Y|jar",
  "Form Based Authentication|org.apache.sling.auth.form|1.0.24|Y|jar",
  "Authentication XING API|org.apache.sling.auth.xing.api|0.0.2|Y|jar",
  "Authentication XING Login|org.apache.sling.auth.xing.login|0.0.2|Y|jar",
  "Authentication XING OAuth|org.apache.sling.auth.xing.oauth|0.0.2|Y|jar",
  "Bundle Resource Provider|org.apache.sling.bundleresource.impl|2.3.4|Y|jar",
  "Capabilities|org.apache.sling.capabilities|0.1.2|Y|jar",
  "Capabilities JCR|org.apache.sling.capabilities.jcr|0.1.2|Y|jar",
  "Clam|org.apache.sling.clam|1.1.0|Y|jar",
  "Classloader Leak Detector|org.apache.sling.extensions.classloader-leak-detector|1.0.0|Y|jar",
  "CMS App API|org.apache.sling.cms.api|1.0.2|org.apache.sling.app.cms|jar",
  "CMS App Archetype|org.apache.sling.cms.archetype|1.0.2|org.apache.sling.app.cms|jar",
  "CMS App Core|org.apache.sling.cms.core|1.0.2|org.apache.sling.app.cms|jar",
  "CMS App Integration Tests|org.apache.sling.cms.it|1.0.2|org.apache.sling.app.cms|jar",
  "CMS App Login|org.apache.sling.cms.login|1.0.2|org.apache.sling.app.cms|jar",
  "CMS App Reference|org.apache.sling.cms.reference|1.0.2|org.apache.sling.app.cms|jar",
  "CMS App Transformer|org.apache.sling.cms.transformer|1.0.2|org.apache.sling.app.cms|jar",
  "CMS App UI|org.apache.sling.cms.ui|1.0.2|org.apache.sling.app.cms|jar",
  "Commons Classloader|org.apache.sling.commons.classloader|1.4.4|Y|jar",
  "Commons Clam|org.apache.sling.commons.clam|2.0.0|Y|jar",
  "Commons Compiler|org.apache.sling.commons.compiler|2.4.0|Y|jar",
  "Commons Crypto|org.apache.sling.commons.crypto|1.0.0|Y|jar",
  "Commons FileSystem ClassLoader|org.apache.sling.commons.fsclassloader|1.0.8|Y|jar",
  "Commons HTML|org.apache.sling.commons.html|1.1.0|Y|jar",
  "Commons Johnzon|org.apache.sling.commons.johnzon|1.2.6|Y|jar",
  "Commons Log|org.apache.sling.commons.log|5.1.12|Y|jar",
  "Commons Log WebConsole Plugin|org.apache.sling.commons.log.webconsole|1.0.0|Y|jar",
  "Commons Log Service|org.apache.sling.commons.logservice|1.1.0|Y|jar",
  "Commons Messaging|org.apache.sling.commons.messaging|1.0.0|Y|jar",
  "Commons Messaging Mail|org.apache.sling.commons.messaging.mail|1.0.0|Y|jar",
  "Commons Metrics|org.apache.sling.commons.metrics|1.2.8|Y|jar",
  "Commons RRD4J metrics reporter|org.apache.sling.commons.metrics-rrd4j|1.0.4|Y|jar",
  "Commons Mime Type Service|org.apache.sling.commons.mime|2.2.2|Y|jar",
  "Commons OSGi|org.apache.sling.commons.osgi|2.4.2|Y|jar",
  "Commons Scheduler|org.apache.sling.commons.scheduler|2.7.2|Y|jar",
  "Commons Testing|org.apache.sling.commons.testing|2.1.2|Y|jar",
  "Commons Threads|org.apache.sling.commons.threads|3.2.20|Y|jar",
  "Connection Timeout Agent|org.apache.sling.connection-timeout-agent|1.0.2|Y|jar",
  "Content Detection Support|org.apache.sling.commons.contentdetection|1.0.4|Y|jar",
  "Content Parser API|org.apache.sling.contentparser.api|2.0.0|Y|jar",
  "Content Parser JSON|org.apache.sling.contentparser.json|2.0.0|Y|jar",
  "Content Parser XML|org.apache.sling.contentparser.xml|2.0.0|Y|jar",
  "Content Parser XML JCR|org.apache.sling.contentparser.xml-jcr|2.0.0|Y|jar",
  "Content Parser Test Utilities|org.apache.sling.contentparser.testutils|2.0.0|Y|jar",
  "Context-Aware Configuration API|org.apache.sling.caconfig.api|1.2.0|Y|jar",
  "Context-Aware Configuration Impl|org.apache.sling.caconfig.impl|1.5.0|Y|jar",
  "Context-Aware Configuration Mock Plugin|org.apache.sling.testing.caconfig-mock-plugin|1.3.2|Y|jar",
  "Context-Aware Configuration SPI|org.apache.sling.caconfig.spi|1.3.4|Y|jar",
  "Crankstart API|org.apache.sling.crankstart.api|1.0.0|N|jar",
  "Crankstart API Fragment|org.apache.sling.crankstart.api.fragment|1.0.2|N|jar",
  "Crankstart Core|org.apache.sling.crankstart.core|1.0.0|N|jar",
  "Crankstart Launcher|org.apache.sling.crankstart.launcher|1.0.0|Y|jar",
  "Crankstart Launcher Sling Extensions|org.apache.sling.crankstart.sling.extensions|1.0.0|Y|jar",
  "Crankstart Launcher Test Services|org.apache.sling.crankstart.test.services|1.0.0|Y|jar",
  "DataSource Provider|org.apache.sling.datasource|1.0.4|Y|jar",
  "Discovery API|org.apache.sling.discovery.api|1.0.4|Y|jar",
  "Discovery Impl|org.apache.sling.discovery.impl|1.2.12|Y|jar",
  "Discovery Commons|org.apache.sling.discovery.commons|1.0.24|Y|jar",
  "Discovery Base|org.apache.sling.discovery.base|2.0.10|Y|jar",
  "Discovery Oak|org.apache.sling.discovery.oak|1.2.34|Y|jar",
  "Discovery Standalone|org.apache.sling.discovery.standalone|1.0.2|Y|jar",
  "Discovery Support|org.apache.sling.discovery.support|1.0.6|Y|jar",
  "Distributed Event Admin|org.apache.sling.event.dea|1.1.4|Y|jar",
  "Distribution API|org.apache.sling.distribution.api|0.4.0|Y|jar",
  "Distribution Core|org.apache.sling.distribution.core|0.4.2|Y|jar",
  "Distribution Integration Tests|org.apache.sling.distribution.it|0.1.2|Y|jar",
  "Distribution Sample|org.apache.sling.distribution.sample|0.1.6|Y|jar",
  "Distribution Journal Core|org.apache.sling.distribution.journal|0.1.16|Y|jar",
  "Distribution Journal Messages|org.apache.sling.distribution.journal.messages|0.1.8|Y|jar",
  "Distribution Journal Kafka|org.apache.sling.distribution.journal.kafka|0.1.4|Y|jar",
  "Distribution Journal ITs|org.apache.sling.distribution.journal.it|0.1.2|Y|jar",
  "Dynamic Include|org.apache.sling.dynamic-include|3.2.0|Y|jar",
  "Engine|org.apache.sling.engine|2.7.6|Y|jar",
  "Event|org.apache.sling.event|4.2.22|Y|jar",
  "Event API|org.apache.sling.event.api|1.0.0|Y|jar",
  "Feature Model|org.apache.sling.feature|1.2.22|Y|jar",
  "Feature Model Analyser|org.apache.sling.feature.analyser|1.3.24|Y|jar",
  "Feature Model Launcher|org.apache.sling.feature.launcher|1.1.6|Y|jar",
  "Feature Model Converter|org.apache.sling.feature.modelconverter|1.0.14|Y|jar",
  "Feature Model Content Package Converter|org.apache.sling.feature.cpconverter|1.1.4|Y|jar",
  "Feature Model Extension API Regions|org.apache.sling.feature.extension.apiregions|1.2.10|Y|jar",
  "Feature Flags|org.apache.sling.featureflags|1.2.2|Y|jar",
  "File Optimization|org.apache.sling.fileoptim|0.9.2|org.apache.sling.file.optimization|jar",
  "File System Resource Provider|org.apache.sling.fsresource|2.1.16|Y|jar",
  "GraphQL Core|org.apache.sling.graphql.core|0.0.10|Y|jar",
  "I18n|org.apache.sling.i18n|2.5.16|Y|jar",
  "HApi|org.apache.sling.hapi|1.1.0|Y|jar",
  "Health Check API|org.apache.sling.hc.api|1.0.4|Y|jar",
  "Health Check Support|org.apache.sling.hc.support|1.0.6|Y|jar",
  "Health Check JUnit Bridge|org.apache.sling.hc.junit.bridge|1.0.2|Y|jar",
  "Installer Core|org.apache.sling.installer.core|3.11.4|Y|jar",
  "Installer Configuration Support|org.apache.sling.installer.factory.configuration|1.3.2|Y|jar",
  "Installer Console|org.apache.sling.installer.console|1.1.0|Y|jar",
  "Installer Content Package Support|org.apache.sling.installer.factory.packages|1.0.4|Y|jar",
  "Installer Factory Feature Model|org.apache.sling.installer.factory.model|0.4.0|Y|jar",
  "Installer File Provider|org.apache.sling.installer.provider.file|1.3.0|Y|jar",
  "Installer Health Checks|org.apache.sling.installer.hc|2.0.2|Y|jar",
  "Installer JCR Provider|org.apache.sling.installer.provider.jcr|3.3.0|Y|jar",
  "Installer Vault Package Install Hook|org.apache.sling.installer.provider.installhook|1.0.4|Y|jar",
  "javax activation|org.apache.sling.javax.activation|0.1.0|Y|jar",
  "JCR API|org.apache.sling.jcr.api|2.4.0|Y|jar",
  "JCR API Wrapper|org.apache.sling.jcr.jcr-wrapper|2.0.0|Y|jar",
  "JCR Base|org.apache.sling.jcr.base|3.1.8|Y|jar",
  "JCR ClassLoader|org.apache.sling.jcr.classloader|3.2.4|Y|jar",
  "JCR Content Loader|org.apache.sling.jcr.contentloader|2.4.0|Y|jar",
  "JCR Content Parser|org.apache.sling.jcr.contentparser|1.2.8|Y|jar",
  "JCR DavEx|org.apache.sling.jcr.davex|1.3.10|Y|jar",
  "JCR Jackrabbit AccessManager|org.apache.sling.jcr.jackrabbit.accessmanager|3.0.10|Y|jar",
  "JCR Jackrabbit UserManager|org.apache.sling.jcr.jackrabbit.usermanager|2.2.14|Y|jar",
  "JCR Maintenance|org.apache.sling.jcr.maintenance|1.0.2|Y|jar",
  "JCR Oak Server|org.apache.sling.jcr.oak.server|1.2.10|Y|jar",
  "JCR Package Init|org.apache.sling.jcr.packageinit|1.0.4|Y|jar",
  "JCR Registration|org.apache.sling.jcr.registration|1.0.6|Y|jar",
  "JCR Resource|org.apache.sling.jcr.resource|3.0.22|Y|jar",
  "JCR Resource Security|org.apache.sling.jcr.resourcesecurity|1.0.2|Y|jar",
  "JCR Web Console Plugin|org.apache.sling.jcr.webconsole|1.1.0|Y|jar",
  "JMX Resource Provider|org.apache.sling.jmx.provider|1.0.2|Y|jar",
  "JCR WebDAV|org.apache.sling.jcr.webdav|2.3.8|Y|jar",
  "JUnit Core|org.apache.sling.junit.core|1.1.2|Y|jar",
  "JUnit Remote Tests Runners|org.apache.sling.junit.remote|1.0.12|Y|jar",
  "JUnit Scriptable Tests Provider|org.apache.sling.junit.scriptable|1.0.12|Y|jar",
  "JUnit Tests Teleporter|org.apache.sling.junit.teleporter|1.0.22|Y|jar",
  "JUnit Health Checks|org.apache.sling.junit.healthcheck|1.0.6|Y|jar",
  "Kickstart Project|org.apache.sling.kickstart|0.0.12|Y|jar",
  "Launchpad API|org.apache.sling.launchpad.api|1.2.0|Y|jar",
  "Launchpad Base|org.apache.sling.launchpad.base|6.0.2-2.6.36|Y|jar",
  "Launchpad Base - Application Launcher|org.apache.sling.launchpad.base|6.0.2-2.6.36|Y|war",
  "Launchpad Base - Web Launcher|org.apache.sling.launchpad.base|6.0.2-2.6.36|Y|war",
  "Launchpad Installer|org.apache.sling.launchpad.installer|1.2.2|Y|jar",
  "Launchpad Integration Tests|org.apache.sling.launchpad.integration-tests|1.0.10|Y|jar",
  "Launchpad Test Fragment Bundle|org.apache.sling.launchpad.test-fragment|2.0.16|Y|jar",
  "Launchpad Test Bundles|org.apache.sling.launchpad.test-bundles|0.0.6|Y|jar",
  "Launchpad Testing|org.apache.sling.launchpad.testing|11|Y|jar",
  "Launchpad Testing WAR|org.apache.sling.launchpad.testing-war|11|Y|jar",
  "Launchpad Testing Services|org.apache.sling.launchpad.test-services|2.0.16|Y|jar",
  "Launchpad Testing Services WAR|org.apache.sling.launchpad.test-services-war|2.0.16|Y|war",
  "Log Tracer|org.apache.sling.tracer|1.0.6|Y|jar",
  "Models API|org.apache.sling.models.api|1.3.8|Y|jar",
  "Models Implementation|org.apache.sling.models.impl|1.4.16|Y|jar",
  "Models Jackson Exporter|org.apache.sling.models.jacksonexporter|1.0.8|Y|jar",
  "Models Validation Implementation|org.apache.sling.models.validation-impl|1.0.0|Y|jar",
  "NoSQL Generic Resource Provider|org.apache.sling.nosql.generic|1.1.0|Y|jar",
  "NoSQL Couchbase Client|org.apache.sling.nosql.couchbase-client|1.0.2|Y|jar",
  "NoSQL Couchbase Resource Provider|org.apache.sling.nosql.couchbase-resourceprovider|1.1.0|Y|jar",
  "NoSQL MongoDB Resource Provider|org.apache.sling.nosql.mongodb-resourceprovider|1.1.0|Y|jar",
  "Oak Restrictions|org.apache.sling.oak.restrictions|1.0.2|Y|jar",
  "Pax Exam Utilities|org.apache.sling.paxexam.util|1.0.4|Y|jar",
  "Performance Test Utilities|org.apache.sling.performance.base|1.0.2|org.apache.sling.performance|jar",
  "Pipes|org.apache.sling.pipes|4.0.0|Y|jar",
  "Provisioning Model|org.apache.sling.provisioning.model|1.8.6|Y|jar",
  "Repoinit JCR|org.apache.sling.jcr.repoinit|1.1.36|Y|jar",
  "Repoinit Parser|org.apache.sling.repoinit.parser|1.6.10|Y|jar",
  "Resource Access Security|org.apache.sling.resourceaccesssecurity|1.0.0|Y|jar",
  "Resource Builder|org.apache.sling.resourcebuilder|1.0.4|Y|jar",
  "Resource Collection|org.apache.sling.resourcecollection|1.0.2|Y|jar",
  "Resource Filter|org.apache.sling.resource.filter|1.0.0|Y|jar",
  "Resource Inventory|org.apache.sling.resource.inventory|1.0.8|Y|jar",
  "Resource Merger|org.apache.sling.resourcemerger|1.4.0|Y|jar",
  "Resource Presence|org.apache.sling.resource.presence|0.0.2|Y|jar",
  "Resource Resolver|org.apache.sling.resourceresolver|1.7.8|Y|jar",
  "Rewriter|org.apache.sling.rewriter|1.3.0|Y|jar",
  "Failing Server-Side Tests|org.apache.sling.testing.samples.failingtests|1.0.6|N|jar",
  "Sample Integration Tests|org.apache.sling.testing.samples.integrationtests|1.0.6|N|jar",
  "Sample Server-Side Tests|org.apache.sling.testing.samples.sampletests|1.0.6|N|jar",
  "Scripting API|org.apache.sling.scripting.api|2.2.0|Y|jar",
  "Scripting SPI|org.apache.sling.scripting.spi|1.0.2|Y|jar",
  "Scripting Bundle Tracker|org.apache.sling.scripting.bundle.tracler|0.1.0|Y|jar",
  "Scripting Console|org.apache.sling.scripting.console|1.0.0|Y|jar",
  "Scripting Core|org.apache.sling.scripting.core|2.3.6|Y|jar",
  "Scripting EL API Wrapper|org.apache.sling.scripting.el-api|1.0.4|Y|jar",
  "Scripting Java|org.apache.sling.scripting.java|2.1.6|Y|jar",
  "Scripting JavaScript|org.apache.sling.scripting.javascript|3.1.4|Y|jar",
  "Scripting JSP|org.apache.sling.scripting.jsp|2.5.2|Y|jar",
  "Scripting JSP API Wrapper|org.apache.sling.scripting.jsp-api|1.0.2|Y|jar",
  "Scripting JSP Taglib|org.apache.sling.scripting.jsp.taglib|2.4.0|Y|jar",
  "Scripting FreeMarker|org.apache.sling.scripting.freemarker|1.0.4|Y|jar",
  "Scripting Groovy|org.apache.sling.scripting.groovy|1.2.0|Y|jar",
  "Scripting HTL Runtime|org.apache.sling.scripting.sightly.runtime|1.2.4-1.4.0|Y|jar",
  "Scripting HTL Compiler|org.apache.sling.scripting.sightly.compiler|1.2.10-1.4.0|Y|jar",
  "Scripting HTL Java Compiler|org.apache.sling.scripting.sightly.compiler.java|1.2.2-1.4.0|Y|jar",
  "Scripting HTL Engine|org.apache.sling.scripting.sightly|1.4.8-1.4.0|Y|jar",
  "Scripting HTL JS Use Provider|org.apache.sling.scripting.sightly.js.provider|1.2.6|Y|jar",
  "Scripting HTL Sling Models Use Provider|org.apache.sling.scripting.sightly.models.provider|1.0.8|Y|jar",
  "Scripting HTL REPL|org.apache.sling.scripting.sightly.repl|1.0.6|Y|jar",
  "Scripting Thymeleaf|org.apache.sling.scripting.thymeleaf|2.0.2|Y|jar",
  "Security|org.apache.sling.security|1.1.20|Y|jar",
  "Service User Mapper|org.apache.sling.serviceusermapper|1.4.2|Y|jar",
  "Service User WebConsole|org.apache.sling.serviceuser.webconsole|1.0.2|Y|jar",
  "Servlet Annotations|org.apache.sling.servlets.annotations|1.2.6|Y|jar",
  "Servlet Helpers|org.apache.sling.servlet-helpers|1.4.2|Y|jar",
  "Servlets Get|org.apache.sling.servlets.get|2.1.40|Y|jar",
  "Servlets Post|org.apache.sling.servlets.post|2.4.4|Y|jar",
  "Servlets Resolver|org.apache.sling.servlets.resolver|2.7.14|Y|jar",
  "Settings|org.apache.sling.settings|1.4.2|Y|jar",
  "Slf4j MDC Filter|org.apache.sling.extensions.slf4j.mdc|1.0.0|Y|jar",
  "Sling Query|org.apache.sling.query|4.0.2|Y|jar",
  "Starter Content|org.apache.sling.starter.content|1.0.8|Y|jar",
  "Superimposing Resource Provider|org.apache.sling.superimposing|0.2.0|Y|jar",
  "System Bundle Extension: Activation API|org.apache.sling.fragment.activation|1.0.2|Y|jar",
  "System Bundle Extension: WS APIs|org.apache.sling.fragment.ws|1.0.2|Y|jar",
  "System Bundle Extension: XML APIs|org.apache.sling.fragment.xml|1.0.2|Y|jar",
  "Tenant|org.apache.sling.tenant|1.1.4|Y|jar",
  "Testing Clients|org.apache.sling.testing.clients|2.0.6|Y|jar",
  "Testing Email|org.apache.sling.testing.email|1.0.0|Y|jar",
  "Testing Hamcrest|org.apache.sling.testing.hamcrest|1.0.2|Y|jar",
  "Testing JCR Mock|org.apache.sling.testing.jcr-mock|1.5.2|Y|jar",
  "Testing Logging Mock|org.apache.sling.testing.logging-mock|2.0.0|Y|jar",
  "Testing OSGi Mock Core|org.apache.sling.testing.osgi-mock.core|3.1.2|org.apache.sling.testing.osgi-mock|jar",
  "Testing OSGi Mock JUnit 4|org.apache.sling.testing.osgi-mock.junit4|3.1.2|org.apache.sling.testing.osgi-mock|jar",
  "Testing OSGi Mock JUnit 5|org.apache.sling.testing.osgi-mock.junit5|3.1.2|org.apache.sling.testing.osgi-mock|jar",
  "Testing PaxExam|org.apache.sling.testing.paxexam|3.1.0|Y|jar",
  "Testing Rules|org.apache.sling.testing.rules|2.0.0|Y|jar",
  "Testing Resource Resolver Mock|org.apache.sling.testing.resourceresolver-mock|1.2.0|Y|jar",
  "Testing Server Setup Tools|org.apache.sling.testing.serversetup|1.0.4|Y|jar",
  "Testing Sling Mock Core|org.apache.sling.testing.sling-mock.core|3.0.2|org.apache.sling.testing.sling-mock|jar",
  "Testing Sling Mock JUnit 4|org.apache.sling.testing.sling-mock.junit4|3.0.2|org.apache.sling.testing.sling-mock|jar",
  "Testing Sling Mock JUnit 5|org.apache.sling.testing.sling-mock.junit5|3.0.2|org.apache.sling.testing.sling-mock|jar",
  "Testing Sling Mock Oak|org.apache.sling.testing.sling-mock-oak|2.1.10-1.16.0|Y|jar",
  "Tooling Support Install|org.apache.sling.tooling.support.install|1.0.6|Y|jar",
  "Tooling Support Source|org.apache.sling.tooling.support.source|1.0.4|Y|jar",
  "URL Rewriter|org.apache.sling.urlrewriter|0.0.2|Y|jar",
  "Validation API|org.apache.sling.validation.api|1.0.0|Y|jar",
  "Validation Core|org.apache.sling.validation.core|1.0.4|Y|jar",
  "Web Console Branding|org.apache.sling.extensions.webconsolebranding|1.0.2|Y|jar",
  "Web Console Security Provider|org.apache.sling.extensions.webconsolesecurityprovider|1.2.2|Y|jar",
  "XSS Protection API|org.apache.sling.xss|2.2.14|Y|jar",
  "XSS Protection Compat|org.apache.sling.xss.compat|1.1.0|N|jar"
]

def deprecated=[
  "Auth OpenID|Not Maintained|org.apache.sling.auth.openid|1.0.4",
  "Auth Selector|Not Maintained|org.apache.sling.auth.selector|1.0.6",
  "Background Servlets Engine|Not Maintained|org.apache.sling.bgservlets|1.0.8",
  "Background Servlets Integration Test|Not Maintained|org.apache.sling.bgservlets.testing|1.0.0",
  "Commons JSON|Replaced with Commons Johnzon|org.apache.sling.commons.json|2.0.20",
  "Explorer|Replaced with Composum|org.apache.sling.extensions.explorer|1.0.4",
  "GWT Integration|Not Maintained|org.apache.sling.extensions.gwt.servlet|3.0.0",
  "Health Check Annotations|Migrated to Apache Felix Health Checks|org.apache.sling.hc.annotations|1.0.6",
  "Health Check Core|Migrated to Apache Felix Health Checks|org.apache.sling.hc.core|1.2.10",
  "Health Check Integration Tests|Migrated to Apache Felix Health Checks|org.apache.sling.hc.it|1.0.4",
  "Health Check Samples|Migrated to Apache Felix Health Checks|org.apache.sling.hc.samples|1.0.6",
  "Health Check Webconsole|Migrated to Apache Felix Health Checks|org.apache.sling.hc.webconsole|1.1.2",
  "Installer Subystems Support|Not Maintained|org.apache.sling.installer.factory.subsystems|1.0.0",
  "JCR Compiler|Replaced with FS ClassLoader|org.apache.sling.jcr.compiler|2.1.0",
  "JCR Jackrabbit Server|Replaced with Apache Jackrabbit Oak|org.apache.sling.jcr.jackrabbit.server|2.3.0",
  "JCR Prefs|Replaced with CA Configs|org.apache.sling.jcr.prefs|1.0.0",
  "Karaf repoinit|Removed|org.apache.sling.karaf-repoinit|0.2.0",
  "Launchpad Content|Replaced with Starter Content|org.apache.sling.launchpad.content|2.0.12",
  "Path-based RTP sample|Not Maintained|org.apache.sling.samples.path-based.rtp|2.0.4",
  "Scripting JSP Taglib Compat|Superseded by the XSS API bundle|org.apache.sling.scripting.jsp.taglib.compat|1.0.0",
  "Scripting JST|Not Maintained|org.apache.sling.scripting.jst|2.0.6",
  "Servlets Compat|Not Maintained|org.apache.sling.servlets.compat|1.0.2",
  "Starter Startup|Replaced with Apache Felix HC Service Unavailable Filter|org.apache.sling.starter.startup|1.0.6",
  "Testing Sling Mock Jackrabbit|Not Maintained|org.apache.sling.testing.sling-mock-jackrabbit|1.0.0",
  "Testing Tools|SLING-5703|org.apache.sling.testing.tools|1.0.16",
  "Thread Dumper|Replaced with Apache Felix Thread Dumper|org.apache.sling.extensions.threaddump|0.2.2"
]

// ------------------------------------------------------------------------------------------------
// Utilities
// ------------------------------------------------------------------------------------------------
def downloadLink(label, artifact, version, suffix) {
	def sep = version ? "-" : ""
	def path = "sling/${artifact}${sep}${version}${suffix}"
	def digestsBase = "https://downloads.apache.org/${path}"

	a(href:"[preferred]${path}", label)
	yield " ("
	a(href:"${digestsBase}.asc", "asc")
	yield ", "
	a(href:"${digestsBase}.sha1", "sha1")
	yield ")"
	newLine()
}

def githubLink(artifact,ghflag) {
	if(ghflag == 'Y') {
		artifact = artifact.replaceAll('\\.','-')
    def url = "https://github.com/apache/sling-${artifact}"
    // remove duplicate sling- prefix
    url = url.replaceAll('sling-sling-','sling-')
		a(href:url, "GitHub")
		newLine()
	} else if (ghflag != 'N') {
		artifact = ghflag.replaceAll('\\.','-')
    // remove duplicate sling- prefix
    def url = "https://github.com/apache/sling-${artifact}"
    url = url.replaceAll('sling-sling-','sling-')
		a(href:url, "GitHub")
		newLine()
	} else {
		yield "N/A"
	}
}

def tableHead(String [] headers) {
	thead() {
		tr() {
			headers.each { header ->
				th(header)
			}
		}
	}

}

 // ------------------------------------------------------------------------------------------------
// Downloads page layout
// ------------------------------------------------------------------------------------------------
layout 'layout/main.tpl', true,
        projects: projects,
        breadcrumbs : contents {
            include template : 'breadcrumbs-brick.tpl'
        },
        tableOfContents : contents {
            include template : 'toc-brick.tpl'
        },
        bodyContents: contents {

            div(class:"row"){
                div(class:"small-12 columns"){
                    section(class:"wrap"){
                        yieldUnescaped U.processBody(content, config)

						h3("Sling Application")
						table(class:"table") {
							tableHead("Artifact", "Version", "GitHub", "Provides", "Package")
							tbody() {
								slingApplication.each { line ->
									tr() {
										def data = U.splitLine(line, PIPE_SEP, 6)
										td(data[0])
										td(data[4])
										td(){
											githubLink(data[2], data[5])
										}
										td(data[1])
										def artifact = "${data[2]}-${data[4]}${data[3]}"
										td(){
											downloadLink(artifact, artifact, "", "")
										}
									}
								}
							}
						}

						h3("Sling IDE Tooling")
						table(class:"table") {
							tableHead("Artifact", "Version", "Provides", "Update Site")
							tbody() {
								slingIDETooling.each { line ->
									tr() {
										def data = U.splitLine(line, PIPE_SEP, 3)
										td(data[0])
										td(data[2])
										td(data[3])
										def artifact = "${data[1]}/${data[2]}"
										td(){
											downloadLink("Update site", artifact, "", "")
										}
									}
								}
							}
						}

						h3("Sling Components")
						table(class:"table") {
							tableHead("Artifact", "Version", "GitHub", "Binary", "Source")
							tbody() {
								bundles.each { line ->
									tr() {
										def data = U.splitLine(line, PIPE_SEP, 5)
										td(data[0])
										td(data[2])
										def artifact = data[1]
										def version = data[2]
										def ghflag = data[3]
										def extension = data[4]
										td(){
											githubLink(artifact,ghflag)
										}
										td(){
											downloadLink("Bundle", artifact, version, "." + extension)
										}
										td(){
											downloadLink("Source ZIP", artifact, version, "-source-release.zip")
										}
									}
								}
							}
						}

						h3("Maven Plugins")
						table(class:"table") {
							tableHead("Artifact", "Version", "GitHub", "Binary", "Source")
							tbody() {
								mavenPlugins.each { line ->
									tr() {
										def data = U.splitLine(line, PIPE_SEP, 4)
										td(data[0])
										td(data[2])
										def artifact = data[1]
										def version = data[2]
										def ghflag = data[3]
										td(){
											githubLink(artifact, ghflag)
										}
										td(){
											downloadLink("Maven Plugin", artifact, version, ".jar")
										}
										td(){
											downloadLink("Source ZIP", artifact, version, "-source-release.zip")
										}
									}
								}
							}
						}

						h3("bnd Plugins")
						table(class:"table") {
							tableHead("Artifact", "Version", "GitHub", "Binary", "Source")
							tbody() {
								bndPlugins.each { line ->
									tr() {
										def data = U.splitLine(line, PIPE_SEP, 4)
										td(data[0])
										td(data[2])
										def artifact = data[1]
										def version = data[2]
										def ghflag = data[3]
										td(){
											githubLink(artifact, ghflag)
										}
										td(){
											downloadLink("bnd Plugin", artifact, version, ".jar")
										}
										td(){
											downloadLink("Source ZIP", artifact, version, "-source-release.zip")
										}
									}
								}
							}
						}

						h3("Deprecated")
						table(class:"table") {
							tableHead("Artifact", "Replacement", "Version", "Binary", "Source")
							tbody() {
								deprecated.each { line ->
									tr() {
										def data = U.splitLine(line, PIPE_SEP, 4)
										td(data[0])
										td(data[1])
										td(data[3])
										def artifact = data[2]
										def version = data[3]
										td(){
											downloadLink("Bundle", artifact, version, ".jar")
										}
										td(){
											downloadLink("Source ZIP", artifact, version, "-source-release.zip")
										}
									}
								}
							}
						}
                    }
                }
            }
        },
        tags : contents {
            include template: 'tags-brick.tpl'
        },
        lastModified: contents {
            include template : 'lastmodified-brick.tpl'
        }
