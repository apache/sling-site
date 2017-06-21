
package mypackage;

import javax.jcr.Session;

import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Property;
import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.Service;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ResourceResolver;
import org.apache.sling.api.resource.ResourceResolverFactory;
import org.apache.sling.event.jobs.Job;
import org.apache.sling.event.jobs.consumer.JobConsumer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * The <code>DropBoxEventHandler</code> moves files posted to /tmp/dropbox to the appropriate locations:
 * images (MIME type: image/png) to /dropbox/images/
 * music (MIME type: audio/mpeg) to /dropbox/music/
 * movies (MIME type: video/x-msvideo) to /dropbox/movies/
 * otherwise to /dropbox/other/
 *
 */
@Component
@Service(value=JobConsumer.class)
@Property(name=JobConsumer.PROPERTY_TOPICS, value=DropBoxService.JOB_TOPIC)
public class DropBoxEventHandler implements JobConsumer {

    /** Default logger. */
    protected final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Reference
    private ResourceResolverFactory resolverFactory;

    private final static String IMAGES_PATH = "/dropbox/images/";
    private final static String MUSIC_PATH = "/dropbox/music/";
    private final static String MOVIES_PATH = "/dropbox/movies/";
    private final static String OTHER_PATH = "/dropbox/other/";

	@Override
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
}
