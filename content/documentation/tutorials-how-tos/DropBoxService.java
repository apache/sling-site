
package mypackage;

import java.util.HashMap;
import java.util.Map;

import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Property;
import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.Service;
import org.apache.sling.api.SlingConstants;
import org.apache.sling.event.jobs.JobManager;
import org.osgi.service.event.Event;
import org.osgi.service.event.EventConstants;
import org.osgi.service.event.EventHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * The <code>DropBoxService</code> is listening content added to /tmp/dropbox by using OSGI events
 *
 */
@Component(immediate=true)
@Service(value=EventHandler.class)
@Property(name=EventConstants.EVENT_TOPIC, value=SlingConstants.TOPIC_RESOURCE_ADDED)
public class DropBoxService implements EventHandler {

    /** Default logger. */
    protected final Logger logger = LoggerFactory.getLogger(this.getClass());

    /** The job manager for starting the jobs. */
    @Reference
    private JobManager jobManager;

    /** The job topic for dropbox job events. */
    public static final String JOB_TOPIC = "com/sling/eventing/dropbox/job";

	@Override
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
}
