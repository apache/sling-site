title=Embedding Sling		
type=page
status=published
~~~~~~
translation_pending: true

The Sling Launchpad Launcher can be used to embed the OSGi Framework startup in your own Java application. This functionality is implemented in the [Sling Launchpad Base project](http://svn.apache.org/repos/asf/sling/trunk/launchpad/base). This project has the following features:

* Builds three artifacts:
    * A standalone Java Application with the artifact qualifier *app*; e.g. `org.apache.sling.launchpad.base-2.3.1-SNAPSHOT-app.jar`
    * A Web Application with the artifact qualifier *webapp*; e.g `org.apache.sling.launchpad.base-2.3.1-SNAPSHOT-wepabb.war`
    * The primary artifact without an artifact qualifier; e.g. `org.apache.sling.launchpad.base-2.3.1-SNAPSHOT.jar`
* Embeds the OSGi Framework (Apache Felix) in the primary artifact
* Encapsulates the OSGi Framework in its own `URLClassLoader`
* Supports Framework restart
* Allows propagation of core setup functionality depending on the environment

This page is about the internal details of the Sling Launchpad Base module. To get an outside overview of the Sling Launchpad you might want to refer to [The Sling Launchpad](/documentation/the-sling-engine/the-sling-launchpad.html) page.

# Structure

The Launcher is based on three parts:

1. The external part which is for example the standalone Java application's main class or the servlet deployed into the servlet container
1. The internal part which is the OSGi framework plus helper classes to control the framework and run initial installations
1. The bridging part, which contains API common to the external and internal part.

The external part uses the bridging part to create the class loader into which the internal part is loaded. The bidirectional communication between the external and internal part is implement based on two interfaces:

* The `Launcher` interface is implemented by a class in the internal part which is loaded through the bridge class loader. This interface allows setting, starting and stopping of the framework.
* The `Notifiable` interface is implemented by a class in the external part which instance is handed to the `Launcher` instance. This interface allows the internal part to communicate back to the external part, most notably to indicate that the framework has been stopped from within or that the framework has been updated and must be restarted.


# The Bridging Part

The bridging part is provided in the `org.apache.sling.launchpad.base.shared` package:

| Class | Description |
|--|--|
| Launcher | The interface implemented by the internal class matching the external class being called to start/stop the framework. |
| LauncherClassLoader | `URLClassLoader` implementing the class loader to load the internal part (along with the OSGi framework). This class loader only delegates to the parent class loader any packages not contained in the launchpad library (primary artifact of the Launchpad Base project). |
| Loader | Helper class to find the launchpad library and to create the `LauncherClassLoader` with that library. This class is also used to actually load the `Launcher` implementation to be called from the external launcher class. |
| Notifiable | The interface implemented in the external part and handed over to the internal part. |
| SharedConstants | Constants naming various properties and classes. |


# The Internal Part

The main class from the internal class directly used is [`Sling`](http://svn.apache.org/repos/asf/sling/trunk/launchpad/base/src/main/java/org/apache/sling/launchpad/base/impl/Sling.java) which instantiated to start the OSGi Framework. This class is responsible for setting up the environment to finally start the OSGi Framework:

* Read the `sling.properties` file
* Ensure the presence of the JMX MBeanServer service
* Execute the bootstrap installations, updates and uninstallations

The [`SlingFelix`](http://svn.apache.org/repos/asf/sling/trunk/launchpad/base/src/main/java/org/apache/sling/launchpad/base/impl/SlingFelix.java) class extends the Apache Felix `Felix` class which is the actual OSGi framework implementation. We extend the class to be able to notify the `Notifiable` implementation and update the OSGi framework from within the OSGi framework by updating the system bundle.


## The External Part

The external part is comprised of a main class started from the environment -- main class of the Java applicaction or the servlet deployed in the servlet container -- and a corresponding delegate class located inside of the launchpad base library. This delegate class is instantiated by the `Loader` loading from the `LauncherClassLoader`.


### Standalone Java Application

The standalone Java Application makes use of three classes:

| Class | Description |
|--|--|
| Main | This is the main class whose `main` method is called by the Java VM. This class is itself the `Notifiable` and finds the `sling.home` location from the environment (command line parameter, system property, or environment variable). |
| MainDelegate | This class is loaded by the `Loader` from the `LauncherClassLoader` to actually complete the initial setup before creating the `Sling` class to start the framework. |
| ControlListener | This class is used by the `Main` class to open a server socket to be able to start and stop Sling as a server. This class allows for starting (opening the server socket), status check (connecting to the socket asking for status), and shutdown (connecting to the socket asking for shutdown). |

At the moment these classes are not directly suitable to be embedded in an existing application (or custom application launcher framework) unless that embedding prepares command line arguments in a `String[]({{ refs..path }})` and calls the `Main.main` method. To allow for custom embeddings or extensions, the work distributions between the three classes should be refactored.

### Embedding the Standalone Java Application

<div class="info">
This work is being done as part of [SLING-2225](https://issues.apache.org/jira/browse/SLING-2225) and will be officially available with the Sling Launchpad Base release 2.4.0. If you want to use the embedding before the release, you have to checkout the source from [SVN|http://svn.apache.org/repos/asf/sling/trunk/launchpad/base] and build yourself.
</div>

To embedd the Sling Launcher in an application, the `Main` class is extended from. To manage the launcher, the following API is available:

| Method | Description |
|--|--|
| `Main(Map<String, String> properties)` | Instantiates the Main class with the given configuration properties. These are properties which are used directly as overwrites to the configurations in the `sling.properties` file. There is no more conversion applied. |
| `doControlCommand()` | Before starting the application for the first time, this method can be called to handle any control command action. |
| `doStart()` | Starts the Sling Application using the provided configuration properties as overwrites. Also these properties (or the `sling.home` system property or the `SLING_HOME` environment variable are analyzed to get the value for the `sling.home` setting. |
| `doStop()` | Stops the application started by the `doStart()` method. |


#### External Control of the Sling Application

By using control actions, the Sling Launcher may open or connect to a control port to communicate. The `doControlAction()` method together with the `sling.control.action` and `sling.control.socket` properties is able to setup this communication.

The `sling.control.socket` is either a normal port number, in which case the connection is opened on the `localhost` interface (usually 127.0.0.1). Otheriwse, it may also be a value of the form *host:port* where *host* is the name or IP address of the interface to connect to and port is the port number. For security reasons it is suggested to not use an interface which is available remotely. So the default of `localhost` is usually the best choice.

The `sling.control.action` takes either of three values:

| Value | Description |
|--|--|
| `start` | Starts a server socket as specified by the `sling.control.socket` property. If the socket cannot be bound to (because the port is in use) an error message is printed. Using the `start` action only makes sense when starting the application. |
| `stop` | The `stop` action is used to stop a running application. For that a connection is opened to the server running on the socket specified by the `sling.control.socket` property. On this connection the server is instructed to shut down. After executing the `stop` action, the Java application should be terminated. |
| `status` | The `status` action is used to check the status of a running application. For that a connection is opened to the server running on the socket specified by the `sling.control.socket` property. On this connection the server is queried on its status. After executing the `stop` action, the Java application should be terminated. |


#### Conversion of Commandline Arguments to Properties

When calling the Main class through the JVM startup the `Main.main(String[]({{ refs..path }}) args)` methods is called which reads the command line arguments and converts them into a `Map<String, String>` suitable for the constructore as follows:

| Command Line Argument | Properties Entry |
|--|--|
| start | sling.control.action = "start" |
| status | sling.control.action = "status" |
| stop | sling.control.action = "stop" |
| -c slinghome | sling.home = slinghome |
| -l loglevel | org.apache.sling.commons.log.level = loglevel |
| -f logfile | org.apache.sling.commons.log.file = logfile |
| -a address | This command line argument is not supported yet and thus ignored |
| -p port | org.osgi.service.http.port = port |
| -j [ host ":" ] port | sling.control.socket = [ host ":" ] port |
| -h | This command line option is handled directly and not converted into the map |


### Web Application

The web application makes use of 5 classes:

| Class | Description |
|--|--|
| SlingServlet | This is the servlet registered in the `web.xml` descriptor and loaded by the servlet container into which Sling is deplyoed. This class locates the `sling.home` folder and loads the `SlingServletDelagate` to actually launch the framework. |
| SlingSessionListener | This -- somewhat inappropriately named -- class is registered as a listener by the Sling `web.xml` descriptor. It is called by the servlet container and forwards events to the `SlingHttpSessionListenerDelegate` which in turn forwards the events to the respective Servlet API listener services registered in the OSGi Framework. |
| SlingBridge | Simple extension of the `Sling` class which registers the system bundle's `BundleContext` as a servlet context attribute of the Sling web application. This allows Servlet Container bridging to properly work. |
| SlingHttpSessionListenerDelegate | This class is loaded by the `LauncherClassLoader` called from the `SlingSessionListener`. It is called by the `SlingSessionListener` to forward servlet container events to registered Servlet API listener services. |
| SlingServletDelegate | This class is loaded by the `Loader` from the `LauncherClassLoader` to actually complete the initial setup before creating the `SlingBridge` class to start the framework. |

At the moment these classes, particularly the `SlingServlet` class, are not particularly well suited to be extended by a servlet slightly modifying the launcher.
