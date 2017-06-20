title=TODO title for authentication-actors.md 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: Authentication - Actors
Excerpt: The authentication process involves a number of actors contributing to the concepts, the API and the particular implementations.

The authentication process involves a number of actors contributing to the concepts, the API and the particular implementations.


## OSGi Http Service Specification

The main support for authentication is defined by the OSGi Http Service specification. This specification defines how an OSGi application can register servlets and resources to build web applications. As part of the servlet and/or resource registration a `HttpContext` may be provided, which allows for additional support.

The main method of interest to the authentication process is the `handleSecurity` method. This is called by the OSGi Http Service implementation before the registered servlet is called. Its intent is to authenticate the request and to provide authentication information for the request object: the authentication type and the remote user name.

The Sling Auth Core bundle provides the `AuthenticationSupport` service which may be used to the implement the `HttpContext.handleSecurity` method.


## Sling Engine

The Sling Engine implements the main entry point into the Sling system by means of the `SlingMainServlet`. This servlet is registered with the OSGi Http Service and provides a custom `HttpContext` whose `handleSecurity` method is implemented by the `AuthenticationSupport` service.

When the request hits the `service` method of the Sling Main Servlet, the resource resolver provided by the `AuthenticationSupport` service is retrieved from the request attributes and used as the resource resolver for the request.

That's all there is for the Sling Engine to do with respect to authentication.


## Sling Auth Core

The support for authenticating client requests is implemented in the Sling Auth Core bundle. As such this bundle provides three areas of support

 * `AuthenticationHandler` service interface. This is implemented by services providing functionality to extract credentials from HTTP requests.
 * `Authenticator` service interface. This is implemented by the `SlingAuthenticator` class in the Sling Auth Core bundle and provides applications with entry points to login and logout.
 * `AuthenticationSupport` service interface. This is implemented by the `SlingAuthenticator` class in the Sling Auth Core bundle and allows applications registering with the OSGi HTTP Service to make use of the Sling authentication infrastructure.


## JCR Repository

The actual process of logging into the repository and provided a `Session` is implementation dependent. In the case of Jackrabbit extensibility is provided by configuration of the Jackrabbit repository by means of an interface and two helper classes:

  * `LoginModule` -- The interface to be implemented to provide login processing plugins
  * `AbstractLoginModule` -- A an abstract base class implementation of the `LoginModule` interface.
  * `DefaultLoginModule` -- The default implementation of the `AbstractLoginModule` provided by Jackabbit. This login module takes `SimpleCredentials` and uses the repository to lookup the users, validate the credentials and providing the `Principal` representing the user towards the repository.

The Sling Jackrabbit Embedded Repository bundle provides additional plugin interfaces to extend the login process dynamically using OSGi services. To this avail the bundle configures a `LoginModule` with the provided default Jackrabbit configuration supporting these plugins:

  * `LoginModulePlugin` -- The main service interface. Plugins must implement this interface to be able to extend the login process. See for example the [Sling OpenID authentication handler](http://svn.apache.org/repos/asf/sling/trunk/bundles/auth/openid/), which implements this interface to support OpenID authentication.
  * `AuthenticationPlugin` -- Helper interface for the `LoginModulePlugin`.


## Sling Applications

Sling Applications requiring authenticated requests should not care about how authentication is implemented. To support such functionality the `Authenticator` service is provided with two methods:

  * `login` -- allows the application to ensure requests are authenticated. This involves selecting an `AuthenticationHandler` to request credentials for authentication.

  * `logout` -- allows the application to forget about any authentication. This involves selecting an `AuthenticationHandler` to forget about credentials in the request.

Sling Applications should never directly use any knowledge of any authentication handler or directly call into an authentication handler. This will certainly break the application and cause unexpected behaviour.

<div class="info">
If you want to know whether a request is authenticated or not, you can inspect the result of the <code>HttpServletRequest.getAuthType</code> method: If this method returns <code>null</code> the request is not authenticated.
</div>
