title=Request Listeners		
type=page
status=published
~~~~~~

Sling provides the possibility to "listen" to a request processed by the Sling Engine (`SlingMainServlet`). To get notified you implement the service interface `org.apache.sling.api.request.SlingRequestListener`.

    #!java
    public interface SlingRequestListener {
    	
    	static final String SERVICE_NAME = "org.apache.sling.api.request.SlingRequestListener";	
    
    	/**
    	 * This method is called from the Sling application for every
    	 * <code>EventType</code> appearing during the dispatching of
    	 * a Sling request  
    	 * 
    	 * @param sre the object representing the event
    	 * 
    	 * @see org.apache.sling.api.request.SlingRequestEvent.EventType
    	 */
    	public void onEvent( SlingRequestEvent sre );
    }


There are no special properties to set. 

## Supported types of events

At the moment you will get two different types of `SlingRequestEvent`:

| events types (`SlingRequestEvent.EventType`) | point in time |
|--|--|
| EVENT_INIT | after entering the `service` method in `SlingMainServlet`. Note that this will be **after** the `handleSecurity` call. |
| EVENT_DESTROY | at the end of the `service` method in `SlingMainServlet` |
