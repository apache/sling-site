title=How to Manage Jobs in Sling
type=page
status=published
tags=jobs
~~~~~~

Apache Sling supports the execution of jobs with the guarantee of processing the job at least once. This can be seen as an extensions of the OSGi event admin, although jobs are not started or processed by OSGi events leveraging the OSGi event admin.

For more details please refer to the following resources:

* [Eventing and Job Handling](/documentation/bundles/apache-sling-eventing-and-job-handling.html) to get detailed information on the eventing mechanisms in Sling.
* Package [org.osgi.service.event](https://www.osgi.org/javadoc/r4v42/org/osgi/service/event/package-summary.html) of the OSGI API.
* Package [org.apache.sling.event](/apidocs/sling6/org/apache/sling/event/package-summary.html) of the Sling API.

This page drives you through the implementation of two services that rely on the Sling job mechanism. The services implement the following use case: whenever a file is uploaded to a temporary location in your web application, the file is moved to a specific location according to its MIME type.

## Introduction

You will now implement the logic to listen to files posted to */tmp/dropbox* and to move them to the appropriate locations depending on the MIME type:

* images (.png) are moved to **/dropbox/images/**
* music (.mp3) are moved to **/dropbox/music/**
* movies (.avi) are moved to **/dropbox/movies/**
* otherwise the files are moved to **/dropbox/other/**

To do that, you will implement two services. The first one, called **DropBoxService**:

* Listens to specific OSGi events (Sling resource added events)
* Starting a job event if a resource has been added to **/tmp/dropbox**.

The second one, called **DropBoxEventHandler**:

* Processes the former jobs
* Moves the file according to its extension.

## Listening to OSGI Events
To listen to OSGi events in Sling you just need to register an **org.osgi.service.event.EventHandler** service with
an **event.topics** property that describes which event topics the handler is interested in.

To listen to a Sling **resource added** events, for example, you'll set the *event.topics* property to
**org.apache.sling.api.SlingConstants.TOPIC_RESOURCE_ADDED** in the class annotations:

     ::java
     @Property(name=org.osgi.service.event.EventConstants.EVENT_TOPIC,
        value=org.apache.sling.api.SlingConstants.TOPIC_RESOURCE_ADDED)


The javadocs of the TOPIC_ constants in the [org.apache.sling.api.SlingConstants](/apidocs/sling6/org/apache/sling/api/SlingConstants.html)
class lists and explains the available event topics available in Sling.

## Starting a job

To start a job, the *JobManager* service can be used. It needs a job topic and a payload. In our case we define our dropbox job topic and give the resource path as the payload:

    ::java
        final String resourcePath = ...; // path to the resource to handle
	    final Map<String, Object> payload = new HashMap<String, Object>();
        payload.put("resourcePath", resourcePath);
        // start job
        this.jobManager.addJob(JOB_TOPIC, payload);

To receive the resource event, the service needs to implement the **org.osgi.service.event.EventHandler** interface and register it as an EventHandler service:

    ::java
    @Component(immediate=true) // immediate should only be used in rare cases (see below)
    @Service(value=EventHandler.class)
    public class DropBoxService implements EventHandler {
        ...
    }

Usually a service should be lazy and therefore not declare itself to be immediate (in the Component annotation). However as this service is an event handler and might receive a lot of events even concurrently, it is advised to set the immediate flag to true on the component. Otherwise our event handler would be created and destroyed with every event coming in.

To start the job we need a reference to the JobManager:

    ::java
    @Reference
    private JobManager jobManager;


The job topic for dropbox job events needs to be defined:

    ::java
    /** The job topic for dropbox job events. */
    public static final String JOB_TOPIC = "com/sling/eventing/dropbox/job";


The **org.osgi.service.event.EventHandler#handleEvent(Event event)** method needs to be implemented:

Its logic is as follows:

* The OSGI event is analyzed.
* If the event is a file that has been added to */tmp/dropbox*:
    * An job is created with 1 property:
        * A property for the file path.
    * The job is started

For example:

    ::java
    public void handleEvent(final Event event) {
        // get the resource event information
        final String propPath = (String) event.getProperty(SlingConstants.PROPERTY_PATH);
        final String propResType = (String) event.getProperty(SlingConstants.PROPERTY_RESOURCE_TYPE);

        // a job is started if a file is added to /tmp/dropbox
        if ( propPath.startsWith("/tmp/dropbox") && "nt:file".equals(propResType) ) {
            // create payload
            final Map<String, Object> payload = new HashMap<String, Object>();
            payload.put("resourcePath", propPath);
            // start job
            this.jobManager.addJob(JOB_TOPIC, payload);
            logger.info("the dropbox job has been started for: {}", propPath);
        }
	}

The complete code for the **DropBoxService** service is available [here](DropBoxService.java).

## Consuming Job Events

Now that you have implemented a service that starts a job when a file is uploaded to **/tmp/dropbox**, you will implement the service **DropBoxEventHandler** that processes those jobs and moves the files to a location according to their MIME types.

To process to the job that have been defined before the property **job.topics** needs to be set to **DropBoxService.JOB_TOPIC** in the class annotations:

    ::java
    @Property(name="job.topics",
        value=DropBoxService.JOB_TOPIC)

In addition the service needs to implement the **org.apache.sling.event.jobs.consumer.JobConsumer** interface:


    ::java
    public class DropBoxEventHandler implements JobConsumer {


Some class fields need to be defined:

* The default logger.
* The references to the ResourceResolverFactory services, which are used in the implementation.
* The destination paths of the files.

For example:

    ::java
    /** Default log. */
    protected final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Reference
    private ResourceResolverFactory resolverFactory;

    private final static String IMAGES_PATH = "/dropbox/images/";
    private final static String MUSIC_PATH = "/dropbox/music/";
    private final static String MOVIES_PATH = "/dropbox/movies/";
    private final static String OTHER_PATH = "/dropbox/other/";


The **org.apache.sling.event.jobs.consumer.JobConsume#process(Job job)** method needs to be implemented:


Its logic is as follows:

* The resource path is extracted from the job.
* The resource is obtained from the resource path.
* If the resource is a file, the destination path is defined based on the file MIME type.
* The file is moved to the new location by using a JCR session (as the Sling Resource API doesn't support move atm)

or in Java Code:

    ::java
    public JobResult process(final Job job) {
		ResourceResolver adminResolver = null;
		try {
            adminResolver = resolverFactory.getAdministrativeResourceResolver(null);

            final String resourcePath = (String) job.getProperty("resourcePath");
			final String resourceName = resourcePath.substring(resourcePath.lastIndexOf("/") + 1);

			final Resource res = adminResolver.getResource(resourcePath);
			if ( res.isResourceType("nt:file") ) {
	        	final String mimeType = res.getResourceMetadata().getContentType();
	        	String destDir;
	        	if (mimeType.equals("image/png")) {
	        		destDir = IMAGES_PATH;
	        	}
	        	else if (mimeType.equals("audio/mpeg")) {
	        		destDir = MUSIC_PATH;
	        	}
	        	else if (mimeType.equals("video/x-msvideo")) {
	        		destDir = MOVIES_PATH;
	        	}
	        	else {
	        		destDir = OTHER_PATH;
	        	}
	        	final Session adminSession = adminResolver.adaptTo(Session.class);
        		adminSession.move(resourcePath, destDir + resourceName);
	        	adminSession.save();
	        	logger.info("The file {} has been moved to {}", resourceName, destDir);
	        }
	        return JobResult.OK;
		} catch (final Exception e) {
			logger.error("Exception: " + e, e);
			return JobResult.FAILED;
        } finally {
            if (adminResolver != null) {
                adminResolver.close();
            }
        }
	}

The complete code for the **DropBoxEventHandler** service is available [here](DropBoxEventHandler.java).
