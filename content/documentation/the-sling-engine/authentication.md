title=Authentication		
type=page
status=published
excerpt=How requests are authenticated.
~~~~~~


This section describes the framework provided by Sling to authenticate HTTP requests.

Let's look at generic request processing of Sling: Sling is linked into the outside world by registering the Sling Main Servlet &ndash; implemented by the `SlingMainServlet` class in the Sling Engine bundle &ndash; with an OSGi `HttpService`. This registration is accompanyied with an implementation instance of the OSGi `HttpContext` interface, which defines a method to authenticate requests: `handleSecurity`.

This method is called by the OSGi HTTP Service implementation after the servlet has been selected to handle the request but before actually calling the servlet's `service` method.

<a href="authentication.png" style="float:left;padding-right:5%">
    <img src="authentication.png" title="Authentication Flow" alt="Authentication Flow" />
</a>

1. First the OSGi HTTP Service implementation is analyzing the request URL to find a match for a servlet or resource registered with the HTTP Service.
1. Now the HTTP Service implementation has to call the `handleSecurity` method of the `HttpContext` object with which the servlet or resource has been registered. This method returns `true` if the request should be serviced. If this method returns `false` the HTTP Service implementation terminates the request sending back any response which has been prepared by the `handleSecurity` method. Note, that the `handleSecurity` method must prepare the failure response sent to the client, the HTTP Service adds nothing here. If the `handleSecurity` method is successful, it must add two (or three) request attributes described below.
1. When the `handleSecurity` method returns `true` the HTTP Service either calls the `Servlet.service` method or sends back the requested resource depending on whether a servlet or a resource has been selected in the first step.

The important thing to note here is, that at the time the `handleSecurity` method is called, the `SlingMainServlet` is not yet in control of the request. So any functionality added by the `SlingMainServlet`, notably the `SlingHttpServletRequest` and `SlingHttpServletResponse` objects are not available to the implementation of the `handleSecurity` method.

The following pages describe the full details of request authentication in Sling in full detail:

* [Tasks](/documentation/the-sling-engine/authentication/authentication-tasks.html): Authentication tasks 
* [Actors](/documentation/the-sling-engine/authentication/authentication-actors.html): Authentication actors and process
* [Framework](/documentation/the-sling-engine/authentication/authentication-framework.html): Authentication Framework, Auth Core bundle etc.
* [AuthenticationHandler](/documentation/the-sling-engine/authentication/authentication-authenticationhandler.html): Authentication Handler service API.
