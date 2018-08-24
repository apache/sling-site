// ------------------------------------------------------------------------------------------------
// Sling downloads page
// http://www.apache.org/dev/release-download-pages.html explains how the apache.org mirrored
// downloads page work. Basically, we provide a downloads.html page with a few placeholders
// and a form to select the download mirrog, and a downloads.cgi page which wraps the apache.org
// download logic CGI.
// ------------------------------------------------------------------------------------------------

// ------------------------------------------------------------------------------------------------
// Downloads template data
// The page template itself is found below.
// To convert from the old svn downloads.list ust
//    while read l; do echo "  \"$l\","; done < content/downloads.list
// ------------------------------------------------------------------------------------------------
def launchpadVersion="10"

def slingIDETooling=[
  "Sling IDE Tooling for Eclipse|eclipse|1.2.2|A p2 update site which can be installed in Eclipse.|sling-ide-tooling"
]

def slingApplication=[
  "Sling Starter Standalone|A self-runnable Sling jar|org.apache.sling.starter|.jar|${launchpadVersion}",
  "Sling Starter WAR|A ready-to run Sling webapp as a war file|org.apache.sling.starter|-webapp.war|${launchpadVersion}",
  "Sling Source Release|The released Sling source code|org.apache.sling.starter|-source-release.zip|${launchpadVersion}",
  "Sling CMS App|A reference CMS App built on Apache Sling|org.apache.sling.cms.builder|.jar|0.9.0",
]

def mavenPlugins=[
  "JSPC Maven Plugin|jspc-maven-plugin|2.1.0",
  "Maven Launchpad Plugin|maven-launchpad-plugin|2.3.4",
  "Maven Sling Plugin|maven-sling-plugin|2.3.8",
  "Slingstart Maven Plugin|slingstart-maven-plugin|1.8.2",
  "HTL Maven Plugin|htl-maven-plugin|1.1.8-1.4.0",
]

def bundles=[
  "Validation API|org.apache.sling.validation.api|1.0.0",
  "Validation Core|org.apache.sling.validation.core|1.0.4",
  "Adapter|org.apache.sling.adapter|2.1.10",
  "Adapter Annotations|adapter-annotations|1.0.0",
  "API|org.apache.sling.api|2.18.2",
  "Auth Core|org.apache.sling.auth.core|1.4.2",
  "Auth Form|org.apache.sling.auth.form|1.0.10",
  "Auth OpenID|org.apache.sling.auth.openid|1.0.4",
  "Auth Selector|org.apache.sling.auth.selector|1.0.6",
  "Authentication XING API|org.apache.sling.auth.xing.api|0.0.2",
  "Authentication XING Login|org.apache.sling.auth.xing.login|0.0.2",
  "Authentication XING OAuth|org.apache.sling.auth.xing.oauth|0.0.2",
  "Background Servlets Engine|org.apache.sling.bgservlets|1.0.8",
  "Background Servlets Integration Test|org.apache.sling.bgservlets.testing|1.0.0",
  "Bundle Resource Provider|org.apache.sling.bundleresource.impl|2.3.2",
  "Classloader Leak Detector|org.apache.sling.extensions.classloader-leak-detector|1.0.0",                                                                   
  "CMS App Core|org.apache.sling.cms.core|0.9.0",
  "CMS App Reference|org.apache.sling.cms.reference|0.9.0",
  "CMS App UI|org.apache.sling.cms.ui|0.9.0",                                                                    
  "Commons Classloader|org.apache.sling.commons.classloader|1.4.2",
  "Commons Compiler|org.apache.sling.commons.compiler|2.3.6",
  "Commons FileSystem ClassLoader|org.apache.sling.commons.fsclassloader|1.0.8",
  "Commons HTML|org.apache.sling.commons.html|1.0.2",
  "Commons Johnzon|org.apache.sling.commons.johnzon|1.1.0",
  "Commons Log|org.apache.sling.commons.log|5.1.8",
  "Commons Log WebConsole Plugin|org.apache.sling.commons.log.webconsole|1.0.0",
  "Commons Log Service|org.apache.sling.commons.logservice|1.0.6",
  "Commons Metrics|org.apache.sling.commons.metrics|1.2.4",
  "Commons RRD4J metrics reporter|org.apache.sling.commons.metrics-rrd4j|1.0.2",
  "Commons Mime Type Service|org.apache.sling.commons.mime|2.1.10",
  "Commons OSGi|org.apache.sling.commons.osgi|2.4.0",
  "Commons Scheduler|org.apache.sling.commons.scheduler|2.7.2",
  "Commons Testing|org.apache.sling.commons.testing|2.1.2",
  "Commons Threads|org.apache.sling.commons.threads|3.2.18",
  "Content Detection Support|org.apache.sling.commons.contentdetection|1.0.2",
  "Context-Aware Configuration API|org.apache.sling.caconfig.api|1.1.0",
  "Context-Aware Configuration bnd Plugin|org.apache.sling.caconfig.bnd-plugin|1.0.2",
  "Context-Aware Configuration Impl|org.apache.sling.caconfig.impl|1.4.12",
  "Context-Aware Configuration Mock Plugin|org.apache.sling.testing.caconfig-mock-plugin|1.3.2",
  "Context-Aware Configuration SPI|org.apache.sling.caconfig.spi|1.3.2",
  "Crankstart API|org.apache.sling.crankstart.api|1.0.0",
  "Crankstart API Fragment|org.apache.sling.crankstart.api.fragment|1.0.2",
  "Crankstart Core|org.apache.sling.crankstart.core|1.0.0",
  "Crankstart Launcher|org.apache.sling.crankstart.launcher|1.0.0",
  "Crankstart Launcher Sling Extensions|org.apache.sling.crankstart.sling.extensions|1.0.0",
  "Crankstart Launcher Test Services|org.apache.sling.crankstart.test.services|1.0.0",
  "DataSource Provider|org.apache.sling.datasource|1.0.2",
  "Discovery API|org.apache.sling.discovery.api|1.0.4",
  "Discovery Impl|org.apache.sling.discovery.impl|1.2.12",
  "Discovery Commons|org.apache.sling.discovery.commons|1.0.20",
  "Discovery Base|org.apache.sling.discovery.base|2.0.8",
  "Discovery Oak|org.apache.sling.discovery.oak|1.2.22",
  "Discovery Standalone|org.apache.sling.discovery.standalone|1.0.2",
  "Discovery Support|org.apache.sling.discovery.support|1.0.4",
  "Distributed Event Admin|org.apache.sling.event.dea|1.1.2",
  "Distribution API|org.apache.sling.distribution.api|0.3.0",
  "Distribution Core|org.apache.sling.distribution.core|0.2.8",
  "Distribution Integration Tests|org.apache.sling.distribution.it|0.1.2",
  "Distribution Sample|org.apache.sling.distribution.sample|0.1.6",
  "Dynamic Include|org.apache.sling.dynamic-include|3.1.2",
  "Engine|org.apache.sling.engine|2.6.14",
  "Event|org.apache.sling.event|4.2.12",
  "Event API|org.apache.sling.event.api|1.0.0",
  "Explorer|org.apache.sling.extensions.explorer|1.0.4",
  "Feature Model|org.apache.sling.feature|0.1.2",
  "Feature Model Analyser|org.apache.sling.feature.analyser|0.1.2",
  "Feature Model IO|org.apache.sling.feature.io|0.1.2",
  "Feature Model Converter|org.apache.sling.feature.modelconverter|0.1.2",
  "Feature Flags|org.apache.sling.featureflags|1.2.2",
  "File Optimization|org.apache.sling.fileoptim|0.9.0",
  "Thread Dumper|org.apache.sling.extensions.threaddump|0.2.2",
  "File System Resource Provider|org.apache.sling.fsresource|2.1.14",
  "I18n|org.apache.sling.i18n|2.5.12",
  "HApi|org.apache.sling.hapi|1.1.0",
  "Health Check Annotations|org.apache.sling.hc.annotations|1.0.6",
  "Health Check Core|org.apache.sling.hc.core|1.2.10",
  "Health Check API|org.apache.sling.hc.api|1.0.2",
  "Health Check Integration Tests|org.apache.sling.hc.it|1.0.4",
  "Health Check JUnit Bridge|org.apache.sling.hc.junit.bridge|1.0.2",
  "Health Check Samples|org.apache.sling.hc.samples|1.0.6",
  "Health Check Support|org.apache.sling.hc.support|1.0.4",
  "Health Check Webconsole|org.apache.sling.hc.webconsole|1.1.2",
  "Installer Core|org.apache.sling.installer.core|3.8.12",
  "Installer Console|org.apache.sling.installer.console|1.0.2",
  "Installer Configuration Support|org.apache.sling.installer.factory.configuration|1.1.2",
  "Installer Health Checks|org.apache.sling.installer.hc|2.0.0",
  "Installer Subystems Support|org.apache.sling.installer.factory.subsystems|1.0.0",
  "Installer File Provider|org.apache.sling.installer.provider.file|1.1.0",
  "Installer JCR Provider|org.apache.sling.installer.provider.jcr|3.1.26",
  "javax activation|org.apache.sling.javax.activation|0.1.0",
  "JCR API|org.apache.sling.jcr.api|2.4.0",
  "JCR API Wrapper|org.apache.sling.jcr.jcr-wrapper|2.0.0",
  "JCR Base|org.apache.sling.jcr.base|3.0.4",
  "JCR ClassLoader|org.apache.sling.jcr.classloader|3.2.2",
  "JCR Compiler|org.apache.sling.jcr.compiler|2.1.0",
  "JCR Content Loader|org.apache.sling.jcr.contentloader|2.2.6",
  "JCR Content Parser|org.apache.sling.jcr.contentparser|1.2.6",
  "JCR DavEx|org.apache.sling.jcr.davex|1.3.10",
  "JCR Jackrabbit AccessManager|org.apache.sling.jcr.jackrabbit.accessmanager|3.0.0",
  "JCR Jackrabbit Server|org.apache.sling.jcr.jackrabbit.server|2.3.0",
  "JCR Jackrabbit UserManager|org.apache.sling.jcr.jackrabbit.usermanager|2.2.6",
  "JCR Oak Server|org.apache.sling.jcr.oak.server|1.2.0",
  "JCR Prefs|org.apache.sling.jcr.prefs|1.0.0",
  "JCR Registration|org.apache.sling.jcr.registration|1.0.6",
  "JCR Repoinit|org.apache.sling.jcr.repoinit|1.1.8",
  "JCR Resource|org.apache.sling.jcr.resource|3.0.16",
  "JCR Resource Security|org.apache.sling.jcr.resourcesecurity|1.0.2",
  "JCR Web Console Plugin|org.apache.sling.jcr.webconsole|1.0.2",
  "JMX Resource Provider|org.apache.sling.jmx.provider|1.0.2",
  "JCR WebDAV|org.apache.sling.jcr.webdav|2.3.8",
  "JUnit Core|org.apache.sling.junit.core|1.0.26",
  "JUnit Remote Tests Runners|org.apache.sling.junit.remote|1.0.12",
  "JUnit Scriptable Tests Provider|org.apache.sling.junit.scriptable|1.0.12",
  "JUnit Tests Teleporter|org.apache.sling.junit.teleporter|1.0.16",
  "JUnit Health Checks|org.apache.sling.junit.healthcheck|1.0.6",
  "Karaf repoinit|org.apache.sling.karaf-repoinit|0.2.0",
  "Launchpad API|org.apache.sling.launchpad.api|1.2.0",
  "Launchpad Base|org.apache.sling.launchpad.base|5.6.10-2.6.26",
  "Launchpad Base - Application Launcher|org.apache.sling.launchpad.base|5.6.10-2.6.26|app",
  "Launchpad Base - Web Launcher|org.apache.sling.launchpad.base|5.6.10-2.6.26|webapp|war",
  "Launchpad Installer|org.apache.sling.launchpad.installer|1.2.2",
  "Launchpad Integration Tests|org.apache.sling.launchpad.integration-tests|1.0.6",
  "Launchpad Test Fragment Bundle|org.apache.sling.launchpad.test-fragment|2.0.14",
  "Launchpad Test Bundles|org.apache.sling.launchpad.test-bundles|0.0.4",
  "Launchpad Testing|org.apache.sling.launchpad.testing|10",
  "Launchpad Testing WAR|org.apache.sling.launchpad.testing-war|10",
  "Launchpad Testing Services|org.apache.sling.launchpad.test-services|2.0.14",
  "Launchpad Testing Services WAR|org.apache.sling.launchpad.test-services-war|2.0.14||war",
  "Log Tracer|org.apache.sling.tracer|1.0.6",
  "Models API|org.apache.sling.models.api|1.3.6",
  "Models bnd Plugin|org.apache.sling.bnd.models|1.0.0",
  "Models Implementation|org.apache.sling.models.impl|1.4.8",
  "Models Jackson Exporter|org.apache.sling.models.jacksonexporter|1.0.8",
  "NoSQL Generic Resource Provider|org.apache.sling.nosql.generic|1.1.0",
  "NoSQL Couchbase Client|org.apache.sling.nosql.couchbase-client|1.0.2",
  "NoSQL Couchbase Resource Provider|org.apache.sling.nosql.couchbase-resourceprovider|1.1.0",
  "NoSQL MongoDB Resource Provider|org.apache.sling.nosql.mongodb-resourceprovider|1.1.0",
  "Oak Restrictions|org.apache.sling.oak.restrictions|1.0.0",
  "Path-based RTP sample|org.apache.sling.samples.path-based.rtp|2.0.4",
  "Pax Exam Utilities|org.apache.sling.paxexam.util|1.0.4",
  "Performance Test Utilities|org.apache.sling.performance.base|1.0.2",
  "Pipes|org.apache.sling.pipes|2.0.2",
  "Provisioning Model|org.apache.sling.provisioning.model|1.8.4",
  "Repoinit Parser|org.apache.sling.repoinit.parser|1.2.2",
  "Resource Access Security|org.apache.sling.resourceaccesssecurity|1.0.0",
  "Resource Builder|org.apache.sling.resourcebuilder|1.0.4",
  "Resource Collection|org.apache.sling.resourcecollection|1.0.0",
  "Resource Inventory|org.apache.sling.resource.inventory|1.0.8",
  "Resource Merger|org.apache.sling.resourcemerger|1.3.8",
  "Resource Presence|org.apache.sling.resource.presence|0.0.2",
  "Resource Resolver|org.apache.sling.resourceresolver|1.6.4",
  "Rewriter|org.apache.sling.rewriter|1.2.2",
  "Failing Server-Side Tests|org.apache.sling.testing.samples.failingtests|1.0.6",
  "Sample Integration Tests|org.apache.sling.testing.samples.integrationtests|1.0.6",
  "Sample Server-Side Tests|org.apache.sling.testing.samples.sampletests|1.0.6",
  "Scripting API|org.apache.sling.scripting.api|2.2.0",
  "Scripting Console|org.apache.sling.scripting.console|1.0.0",
  "Scripting Core|org.apache.sling.scripting.core|2.0.54",
  "Scripting EL API Wrapper|org.apache.sling.scripting.el-api|1.0.0",
  "Scripting Java|org.apache.sling.scripting.java|2.1.2",
  "Scripting JavaScript|org.apache.sling.scripting.javascript|3.0.4",
  "Scripting JSP|org.apache.sling.scripting.jsp|2.3.4",
  "Scripting JSP API Wrapper|org.apache.sling.scripting.jsp-api|1.0.0",
  "Scripting JSP Taglib|org.apache.sling.scripting.jsp.taglib|2.3.0",
  "Scripting JST|org.apache.sling.scripting.jst|2.0.6",
  "Scripting Groovy|org.apache.sling.scripting.groovy|1.0.2",
  "Scripting HTL Compiler|org.apache.sling.scripting.sightly.compiler|1.0.22-1.4.0",
  "Scripting HTL Java Compiler|org.apache.sling.scripting.sightly.compiler.java|1.0.26-1.4.0",
  "Scripting HTL Engine|org.apache.sling.scripting.sightly|1.0.54-1.4.0",
  "Scripting HTL JavaScript Use Provider|org.apache.sling.scripting.sightly.js.provider|1.0.26",
  "Scripting HTL Sling Models Use Provider|org.apache.sling.scripting.sightly.models.provider|1.0.6",
  "Scripting HTL REPL|org.apache.sling.scripting.sightly.repl|1.0.6",
  "Scripting Thymeleaf|org.apache.sling.scripting.thymeleaf|1.1.0",
  "Security|org.apache.sling.security|1.1.12",
  "Service User Mapper|org.apache.sling.serviceusermapper|1.4.0",
  "Service User WebConsole|org.apache.sling.serviceuser.webconsole|1.0.0",
  "Servlet Annotations|org.apache.sling.servlets.annotations|1.0.0",
  "Servlet Helpers|org.apache.sling.servlet-helpers|1.1.8",
  "Servlets Compat|org.apache.sling.servlets.compat|1.0.2",
  "Servlets Get|org.apache.sling.servlets.get|2.1.32",
  "Servlets Post|org.apache.sling.servlets.post|2.3.26",
  "Servlets Resolver|org.apache.sling.servlets.resolver|2.4.22",
  "Settings|org.apache.sling.settings|1.3.8",
  "Slf4j MDC Filter|org.apache.sling.extensions.slf4j.mdc|1.0.0",
  "Sling Query|org.apache.sling.query|4.0.2",
  "Starter Content|org.apache.sling.starter.content|1.0.0",
  "Starter Startup|org.apache.sling.starter.startup|1.0.6",
  "Superimposing Resource Provider|org.apache.sling.superimposing|0.2.0",
  "System Bundle Extension: Activation API|org.apache.sling.fragment.activation|1.0.2",
  "System Bundle Extension: WS APIs|org.apache.sling.fragment.ws|1.0.2",
  "System Bundle Extension: XML APIs|org.apache.sling.fragment.xml|1.0.2",
  "Tenant|org.apache.sling.tenant|1.1.0",
  "Testing Hamcrest|org.apache.sling.testing.hamcrest|1.0.2",
  "Testing JCR Mock|org.apache.sling.testing.jcr-mock|1.3.6",
  "Testing Logging Mock|org.apache.sling.testing.logging-mock|2.0.0",
  "Testing OSGi Mock Core|org.apache.sling.testing.osgi-mock.core|2.4.0",
  "Testing OSGi Mock JUnit 4|org.apache.sling.testing.osgi-mock.junit4|2.4.0",
  "Testing OSGi Mock JUnit 5|org.apache.sling.testing.osgi-mock.junit5|2.4.0",
  "Testing PaxExam|org.apache.sling.testing.paxexam|2.0.0",
  "Testing Resource Resolver Mock|org.apache.sling.testing.resourceresolver-mock|1.1.22",
  "Testing Sling Mock Core|org.apache.sling.testing.sling-mock.core|2.3.0",
  "Testing Sling Mock JUnit 4|org.apache.sling.testing.sling-mock.junit4|2.3.0",
  "Testing Sling Mock JUnit 5|org.apache.sling.testing.sling-mock.junit5|2.3.0",
  "Testing Sling Mock Jackrabbit|org.apache.sling.testing.sling-mock-jackrabbit|1.0.0",
  "Testing Sling Mock Oak|org.apache.sling.testing.sling-mock-oak|2.1.0",
  "Tooling Support Install|org.apache.sling.tooling.support.install|1.0.4",
  "Tooling Support Source|org.apache.sling.tooling.support.source|1.0.4",
  "Apache Sling Testing Clients|org.apache.sling.testing.clients|1.2.0",
  "Testing Email|org.apache.sling.testing.email|1.0.0",
  "Apache Sling Testing Rules|org.apache.sling.testing.rules|1.0.8",
  "Apache Sling Server Setup Tools|org.apache.sling.testing.serversetup|1.0.1",
  "URL Rewriter|org.apache.sling.urlrewriter|0.0.2",
  "Web Console Branding|org.apache.sling.extensions.webconsolebranding|1.0.2",
  "Web Console Security Provider|org.apache.sling.extensions.webconsolesecurityprovider|1.2.0",
  "XSS Protection|org.apache.sling.xss|2.0.12",
  "XSS Protection Compat|org.apache.sling.xss.compat|1.1.0"
]
                                                                      
def deprecated=[
  "Commons JSON|Replaced with Commons Johnzon|org.apache.sling.commons.json|2.0.20",
  "GWT Integration||org.apache.sling.extensions.gwt.servlet|3.0.0",
  "Launchpad Content|Replaced with Starter Content|org.apache.sling.launchpad.content|2.0.12",
  "Testing Tools|SLING-5703|org.apache.sling.testing.tools|1.0.16"
]

// ------------------------------------------------------------------------------------------------
// Utilities
// ------------------------------------------------------------------------------------------------
def downloadLink(label, artifact, version, suffix) {
	def sep = version ? "-" : ""
	def path = "sling/${artifact}${sep}${version}${suffix}"
	def digestsBase = "https://www.apache.org/dist/${path}"

	a(href:"[preferred]${path}", label)
	yield " ("
	a(href:"${digestsBase}.asc", "asc")
	yield ", "
	a(href:"${digestsBase}.sha1", "sha1")
	yield ")"
	newLine()
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
        tags : contents {
            include template: 'tags-brick.tpl'
        },
        lastModified: contents {
            include template : 'lastmodified-brick.tpl'
        },
        bodyContents: contents {

            div(class:"row"){
                div(class:"small-12 columns"){
                    section(class:"wrap"){
                        yieldUnescaped content.body

						h2("Sling Application")
						table(class:"table") {
							tableHead("Artifact", "Version", "Provides", "Package")
							tbody() {
								slingApplication.each { line ->
									tr() {
										def data = line.split("\\|")
										td(data[0])
										td(data[4])
										td(data[1])
										def artifact = "${data[2]}-${data[4]}${data[3]}"
										td(){
											downloadLink(artifact, artifact, "", "")
										}
									}
								}
							}
						}

						h2("Sling IDE Tooling")
						table(class:"table") {
							tableHead("Artifact", "Version", "Provides", "Update Site")
							tbody() {
								slingIDETooling.each { line ->
									tr() {
										def data = line.split("\\|")
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

						h2("Sling Components")
						table(class:"table") {
							tableHead("Artifact", "Version", "Binary", "Source")
							tbody() {
								bundles.each { line ->
									tr() {
										def data = line.split("\\|")
										td(data[0])
										td(data[2])
										def artifact = data[1]
										def version = data[2]
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

						h2("Maven Plugins")
						table(class:"table") {
							tableHead("Artifact", "Version", "Binary", "Source")
							tbody() {
								mavenPlugins.each { line ->
									tr() {
										def data = line.split("\\|")
										td(data[0])
										td(data[2])
										def artifact = data[1]
										def version = data[2]
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
    
						h2("Deprecated")
						table(class:"table") {
							tableHead("Artifact", "Replacement", "Version", "Binary", "Source")
							tbody() {
								deprecated.each { line ->
									tr() {
										def data = line.split("\\|")
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
        }
