title=Authentication - Framework		
type=page
status=published
excerpt=The core piece of functionality with respect to authentication in Sling is contained in the Sling Auth Core bundle. This bundle provides the API for Sling and Sling applications to make use of authentication.
tags=core,authentication
~~~~~~

The core piece of functionality with respect to authentication in Sling is contained in the Sling Auth Core bundle. This bundle provides the API for Sling and Sling applications to make use of authentication.

This support encompasses three parts:

  * The `AuthenticationSupport` service provided by the `SlingAuthenticator` class. This service can be used by implementations of the OSGi `HttpContext` interface to delegate authentication.
  * The `Authenticator` service also provided by the `SlingAuthenticator` class. This service may be used by Sling applications to help clients login and logout.
  * The `AuthenticationHandler` service interface. These services may be implemented by extensions to support various ways for transporting credentials from clients to the Sling server.

This page describes how the `SlingAuthenticator` class provides the `AuthenticationSupport` and  `Authenticator` services. For a description of the `AuthenticationHandler` service interface and the interaction between the `SlingAuthenticator` and the `AuthenticationHandler` services refer to the [AuthenticationHandler](/documentation/the-sling-engine/authentication/authentication-authenticationhandler.html) page.

The `SlingAuthenticator` class is an internal class of the `org.apache.sling.auth.core` bundle and implements the `Authenticator` and `AuthenticationSupport` services.


## AuthenticationSupport

The `AuthenticationSupport` service interface defines a single method: `handleSecurity`. This method is intended to be called by the `handleSecurity` method of any `HttpContext` implementation wishing to make use of the Sling Authentication Framework.

The Sling Authenticator implementation selects an `AuthenticationHandler` service appropriate for the request and calls the `AuthenticationHandler.extractCredentials` method to extract the credentials from the request. If no credentials could be extracted, the Sling Authenticator either admits the request as an anonymous request or requests authentication from the client by calling its own `login` method.


The implementation follows this algorithm:

1. Select one or more `AuthenticationHandler` for the request according to the request URL's scheme and authorization part.
1. Call the `extractCredentials` method of each authentication handler, where the order of handler call is defined by the length of the registered path: handlers registered with longer paths are called before handlers with shorter paths. The goal is to call the handlers in order from longest request path match to shortest match. Handlers not matching the request path at all are not called.
1. The first handler returning a non-`null` `AuthenticationInfo` result "wins" and the result is used for authentication.
1. If any `AuthenticationInfoPostProcessor` services are registered, the `AuthenticationInfo` object is passed to their `postProcess()` method.
1. If no handler returns a non-`null` result, the request may be handled anonymously. In these cases, an empty `AuthenticationInfo` object is passed to any `AuthenticationInfoPostProcessor` services.
1. (Try to) log into the repository either with the provided credentials or anonymously.
1. If there were credentials provided and the login was successful, a login event is posted *if* the `AuthenticationInfo` object contains a non-null object with the key `$$auth.info.login$$` (`AuthConstants.AUTH_INFO_LOGIN`). This event is posted with the topic `org/apache/sling/auth/core/Authenticator/LOGIN`. (added in Sling Auth Core 1.1.0)
1. Set request attributes listed below.

Extracting the credentials and trying to login to the repository may yield the following results:

| Credentials | Login | Consequence |
|---|---|---|
| present | successful | Continue with an authenticated request |
| present | failed | Select `AuthenticationHandler` and call `requestCredentials` method |
| missing | anonymous allowed | Continue with a non authenticated request using anonymous access to the repository |
| missing | anonymous forbidden | Select `AuthenticationHandler` and call `requestCredentials` method |

<div class="note">
    Only one <code>AuthenticationHandler</code> is able to provide credentials for a given request. If the credentials provided by the handler cannot be used to login to the repository, authentication fails and no further <code>AuthenticationHandler</code> is consulted.
</div>


#### Request Attributes on Successful Login

The `handleSecurity` method gets credentials from the `AuthenticationHandler` and logs into the JCR repository using those credentials. If the login is successful, the `SlingAuthenticator` sets the following request attributes:

| Attribute | Description |
|---|---|
| `org.osgi.service.http.authentication.remote.user` | The user ID of the JCR Session. This attribute is used by the HTTP Service implementation to implement the `HttpServletRequest.getRemoteUser` method. |
| `org.osgi.service.http.authentication.type` | The authentication type defined by the `AuthenticationHandler`. This attribute is used by the HTTP Service implementation to implement the `HttpServletRequest.getAuthType` method. |
| `org.apache.sling.auth.core.ResourceResolver` | The `ResourceResolver` created from the credentials and the logged in JCR Session. This attribute may be used by servlets to access the repository. Namely the `SlingMainServlet` uses this request attribute to provide the `ResourceResolver` to handle the request. |
| `javax.jcr.Session` | The JCR Session. This attribute is for backwards compatibility only. *Its use is deprecated and the attribute will be removed in future versions*. |
| `org.apache.sling.auth.core.spi.AuthenticationInfo` | The `AuthenticationInfo` object produced from the `AuthenticationHandler`. |

**NOTE**: Do *NOT* use the `javax.jcr.Session` request attribute in your Sling applications. This attribute must be considered implementation specific to convey the JCR Session to the `SlingMainServlet`. In future versions of the Sling Auth Core bundle, this request attribute will not be present anymore. To get the JCR Session for the current request adapt the request's resource resolver to a JCR Session:


    Session session = request.getResourceResolver().adaptTo(Session.class);



#### Anonymous Login

The `SlingAuthenticator` provides high level of control with respect to allowing anonymous requests or requiring authentication up front:

* Global setting of whether anonymous requests are allowed or not. This is the boolean value of the *Allow Anonymous Access* (`auth.annonymous`) property of the `SlingAuthenticator` configuration. This property is supported for backwards compatibility and defaults to `true` (allowing anonymous access). Setting it to `true` is a shortcut for setting `sling.auth.requirements` to `-/`.
* Specific configuration per URL. The *Authentication Requirements* (`sling.auth.requirements`) property of the `SlingAuthenticator` configuration may provide a list of URLs for which authentication may be required or not: Any entry prefixed with a dash `-` defines a request path prefix for which authentication is not required. Any entry not prefixed with a dash or prefixed with a plus `+` defines a subtree for which authentication is required up front and thus anonymous access is not allowed. This list is empty by default.
* Any OSGi service may provide a `sling.auth.requirements` registration property which is used to dynamically extend the authentication requirements from the *Authentication Requirements* configuration. This may for example be set by `AuthenticationHandler` implementations providing a login form to ensure access to the login form does not require authentication. The value of this property is a single string, an array of strings or a Collection of strings and is formatted in the same way as the *Authentication Requirements* configuration property.

The values set on the *Authentication Requirements* configuration property or the `sling.auth.requirements` service registration property can be absolute paths or URLs like the `path` service registration property of `AuthenticationHandler` services. This allows the limitation of this setup to certain requests by scheme and/or virtual host address. The requests path (`HttpServletRequest.getServletPath()` + `HttpServletRequest.getPathInfo()`) is afterwards matched against the given paths. It matches if it starts with one of the given paths.


**Examples**

* The `LoginServlet` contained in the Sling Auth Core bundle registers itself with the service registration property `sling.auth.requirements = "-/system/sling/login"` to ensure the servlet can be accessed without requiring authentication (checks for `slash` or `dot` or `end of string`). The following request urls would work then without authentication:
    * /system/sling/login
    * /system/sling/login.html
    * /system/sling/login/somesuffix
    
  While the following request will still require authentication 
  
    * /system/sling/login-test 

* An authentication handler may register itself with the service registration property `sling.auth.requirements = "-/apps/sample/loginform"` to ensure the login form can be rendered without requiring authentication.



## Authenticator implementation

The implementation of the `Authenticator` interface is similar for both methods:

**`login`**

1. Select one or more `AuthenticationHandler` for the request according to the request URL's scheme and authorization part.
1. Call the `requestCredentials` method of each authentication handler, where the order of handler call is defined by the length of the registered path: handlers registered with longer paths are called before handlers with shorter paths. The goal is to call the handlers in order from longest request path match to shortest match. Handlers not matching the request path at all are not called.
1. As soon as the first handlers returns `true`, the process ends and it is assumed credentials have been requested from the client.

The `login` method has three possible exit states:

| Exit State | Description |
|---|---|
| Normal | An `AuthenticationHandler` could be selected to which the login request could be forwarded. |
| `NoAuthenticationHandlerException` | No `AuthenticationHandler` could be selected to forward the login request to. In this case, the caller can proceed as appropriate. For example a servlet, which should just login a user may send back a 403/FORBIDDEN status because login is not possible. Or a 404/NOT FOUND handler, which tried to login as a fallback, may continue and send back the regular 404/NOT FOUND response. |
| `IllegalStateException` | The response has already been committed and the login request cannot be processed. Normally to request login, the current response must be reset and a new response has to be prepared. This is only possible if the request has not yet been committed. |


**`logout`**

1. Select one or more `AuthenticationHandler` for the request according to the request URL's scheme and authorization part.
1. Call the `dropCredentials` method of each authentication handler, where the order of handler call is defined by the length of the registered path: handlers registered with longer paths are called before handlers with shorter paths. The goal is to call the handlers in order from longest request path match to shortest match. Handlers not matching the request path at all are not called.

Unlike for the `login` method in the `logout` method case all `AuthenticationHandler` services selected in the first step are called. If none can be selected or none can actually handle the `dropCredentials` request, the `logout` silently returns.

