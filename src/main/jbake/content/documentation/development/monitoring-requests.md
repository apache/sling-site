title=Monitoring Requests		
type=page
status=published
~~~~~~

Sling provides a simple OSGi console plugin to monitor recent requests. This is quite useful when debugging and to understand how things work, though it's obviously not a replacement for full-blown HTTP trafic monitoring tools.

The console plugin is available at /system/console/requests, listed as *Recent Requests* in the console menu.

The plugin keeps track of the latest 20 requests processed by Sling, and displays the information provided by the RequestProgressTracker, for the selected request. The screenshot below shows an example.

Any information that's added to the RequestProgressTracker (which is available from the SlingHttpServletRequest object) during request processing will be displayed by this plugin.

![](sling-requests-plugin.jpg)
