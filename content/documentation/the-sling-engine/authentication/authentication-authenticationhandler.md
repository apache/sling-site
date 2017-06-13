Title=TODO add front matter 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: Authentication - AuthenticationHandler
Excerpt: The `AuthenticationHandler` interface defines the service API which may be implemented by authentication handlers registered as OSGi services.

The `AuthenticationHandler` interface defines the service API which may be implemented by authentication handlers registered as OSGi services.

`AuthenticationHandler` services have a single required service registration property which is used to identify requests to which the `AuthenticationHandler` service is applicable:

| Property | Description |
|-|-|
| `path` | One or more (array or vector) string values indicating the request URLs to which the `AuthenticationHandler` is applicable. |
| `authtype` | The authentication type implemented by this handler. This is a string value property and should be the same as will be used as the authentication type of the `AuthenticationInfo` object provided by the `extractCredentials` method. If this property is set, the `requestCredentials` method of the authentication handler is only called if the `sling:authRequestLogin` request parameter is either not set or is set to the same value as the `authtype` of the handler. This property is optional. If not set, the `requestCredentials` method is always called regardless of the value of the `sling:authRequestLogin` request parameter. |

Each path may be an absolute URL, an URL with just the host/port and path or just a plain absolute path:

| URL part | Scheme | Host/Port | Path |
|-|-|-|-|
| Absolute URL | must match | must match | request URL path is prefixed with the path |
| Host/Port with Path | ignored | must match | request URL path is prefixed with the path |
| Path | ignored | ignored | request URL path is prefixed with the path |

When looking for an `AuthenticationHandler` the authentication handler is selected whose path is the longest match on the request URL. If the service is registered with Scheme and Host/Port, these must exactly match for the service to be eligible. If multiple `AuthenticationHandler` services are registered with the same length matching path, the handler with the higher service ranking is selected[^ranking].

[^ranking]: Service ranking is defined by the OSGi Core Specification as follows: *If multiple qualifying service interfaces exist, a service with the highest `service.ranking` number, or when equal to the lowest `service.id`, determines which service object is returned by the Framework*.

The value of `path` service registration property value triggering the call to any of the `AuthenticationHandler` methods is available as the `path` request attribute (for the time of the method call only). If the service is registered with multiple path values, the value of the `path` request attribute may be used to implement specific handling.


### Implementations provided by Sling

* [Form Based AuthenticationHandler]({{ refs.form-based-authenticationhandler.path }})
* [OpenID AuthenticationHandler]({{ refs.openid-authenticationhandler.path }})

### Sample implementations


#### HTTP Basic Authentication Handler

* `extractCredentials` -- Get user name and password from the `Authorization` HTTP header
* `requestCredentials` -- Send a 401/UNAUTHORIZED status with `WWW-Authenticate` response header setting the Realm
* `dropCredentials` -- Send a 401/UNAUTHORIZED status with `WWW-Authenticate` response header setting the Realm

Interestingly the `dropCredentials` method is implemented in the same way as the `requestCredentials` method. The reason for this is, that HTTP Basic authentication does not have a notion of login and logout. Rather the request is accompanied with an `Authorization` header or not. The contents of this header is usually cached by the client browser. So logout is actually simulated by sending a 401/UNAUTHORIZED status thus causing the client browser to clear the cache and ask for user name and password.


#### Form Based Authentication Handler


* `extractCredentials` -- Get user name and password with the help of a special cookie (note, that of course the cookie should not contain this data, but refer to it in an internal store of the authentication handler). If the cookie is not set, check for specific login parameters to setup the cookie.
* `requestCredentials` -- Send the login form for the user to provide the login parameters.
* `dropCredentials` -- Clear the authentication cookie and internal store.


///Footnotes Go Here///
