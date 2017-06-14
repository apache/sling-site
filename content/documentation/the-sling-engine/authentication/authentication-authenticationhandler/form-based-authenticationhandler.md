title=TODO title for form-based-authenticationhandler.md 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: Form Based AuthenticationHandler

[TOC]

The Form Based AuthenticationHandler has two authentication phases: The first phase is presenting a login form to the user and passing the entered user name and password to the server. The second phase is storing successful authentication in a Cookie or an HTTP Session.

The implementation of the Form Based Authentication Handler follows the guidelines of the Servlet API 2.4 specification for *Form Based Authentication* in section SRV.12.5.3. Specifically the following requirements are implemented:

* For the initial form submission, the request URL must end with `/j_security_check` and the user name and password names must be `j_username` and `j_password`, resp.
* The authentication type as returned by `HttpServletRequest.getAuthType()` is set to `HttpServletRequest.FORM_AUTH`.

The Form Based Authentication Handler is maintained in the [Sling SVN](http://svn.apache.org/repos/asf/sling/trunk/bundles/auth/form)


### AuthenticationHandler implementation


* `extractCredentials` -- Prepares credentials for the form entered data or from the Cookie or HTTP Session attribute. Returns `null` if neither data is provided in the request
* `requestCredentials` -- Redirects the client (browser) to the login form
* `dropCredentials` -- Remove the Cookie or remove the HTTP Session attribute


### AuthenticationFeedbackHandler implementation

* `authenticationFailed` -- Remove the Cookie or remove the HTTP Session attribute
* `authenticationSucceeded` -- Set (or update) the Cookie or HTTP Session attribute


### Phase 1: Form Submission


The login form submitted in phase 1 to validate the user name and password must be provided in an HTTP `POST` request to an URL whose last segment is `j_security_check`. The request is ignored as a form submission if either the method is not `POST` or the last segment is no `j_security_check`.

The form is rendered by redirecting the client to the URL indicated by the `form.login.form` configuration parameter. This redirection request may accompanyied by the following parameters:

* `resource` -- The resource to which the user should be redirected after successful login. This request parameter should be submitted back to the server as the `resource` parameter.
* `j_reason` -- This parameter indicates the reason for rendering the login form. If this parameter is set, it is set to `INVALID_CREDENTIALS` indicating a previous form submission presented invalid username and password or `TIMEOUT` indicating a login session has timed out. The login form servlet/script can present the user with an appropriate message.

The Form Based Authentication Handlers supports the following request parameters submitted by the HTML form:

* `j_username` -- Name of the user to authenticate
* `j_password` -- Password to authenticate the user
* `j_validate` -- Flag indicating whether to just validate the credentials
* `resource` -- The location to go to on successful login
* `sling.auth.redirect` -- The location to redirect to on successful login

The `j_username` and `j_password` parameters are used to create a JCR `SimpleCredentials` object to log into the JCR Repository.

The `j_validate` parameter may be used to implement login form submission using AJAX. If this parameter is set to `true` (case-insensitive) the credentials are used to login and after success or failure to return a status code:

| Status | Description |
|--|--|
| `200 OK` | Authentication succeeded; credentials are valid for login; the Cookie or HTTP Session attribute is now set |
| `403 FORBIDDEN` | Authentication failed; credentials are invalid for login; the Cookie or HTTP Session attribute is not set (if it was set, it is now cleared) |

If the `j_validate` parameter is not set or is set to any value other than `true`, the request processing depends on authentication success or failure:

| Authentication | Description |
|--|--|
| Success | Client is redirected to the authenticated resource; the Cookie or HTTP Session attribute is now set. |
| Failure | The request is redirected to the login form again; the Cookie or HTTP Session attribute is not set (if it was set, it is now cleared) |

The `resource` and `sling.auth.redirect` parameters provide similar functionality but with differing historical backgrounds. The `resource` parameter is based on the `resource` request attribute which is set by the login servlet to indicate the original target resource the client desired when it was forced to authenticate. The `sling.auth.redirect` parameter can be used by clients (applications like cURL or plain HTML forms) to request being redirected after successful login. If both parameters are set, the `sling.auth.redirect` parameter takes precedence.

The Form Based Authentication Handler contains a [default form servlet](http://svn.apache.org/repos/asf/sling/trunk/bundles/auth/form/src/main/java/org/apache/sling/auth/form/impl/AuthenticationFormServlet.java) and [HTML form template](http://svn.apache.org/repos/asf/sling/trunk/bundles/auth/form/src/main/resources/org/apache/sling/auth/form/impl/login.html).


### Phase 2: Authenticated Requests


After the successful authentication of the user in phase 1, the authentication state is stored in a Cookie or an HTTP Session. The stored value is a security token with the following contents:


    HmacSHA1(securetoken, <securetokennumber><expirytime>@<userID>)@<securetokennumber><expirytime>@<userID>


The `securetoken` and `securetokennumber` are related in that an table of secure tokens is maintained where the `securetoken` is an entry in the table and the `securetokennumber` is the index in of the token in the table.

The secure tokens are refreshed periodically causing the authentication state stored in the Cookie or the HTTP Session to be updated peridocally. This periodic update has two advantages:

  * Login sessions time out after some period of inactivity: If a request is handled for an authentication state whose expiry time has passed, the request is considered unauthenticated.
  * If a Cookie would be stolen or an HTTP Session be hijacked, the authentication state expires within a reasonable amount of time to try to prevent stealing the authentication.

The authentication state may be transmitted with a Cookie which is configured as follows:

* *Cookie Path* -- Set to the servlet context path
* *Domain* -- See below
* *Age* -- Set to -1 to indicate a session Cookie
* *Secure* -- Set to the value returned by the `ServletRequest.isSecure()` method

If the authentication state is kept in an HTTP Session the setup of the session ID cookie is maintained by the servlet container and is outside of the control of the Form Based AuthenticationHandler.


### Configuration

The Form Based Authentication Handler is configured with configuration provided by the OSGi Configuration Admin Service using the `org.apache.sling.formauth.FormAuthenticationHandler` service PID.

| Parameter | Default | Description |
|--|--|--|
| `form.login.form` | `/system/sling/form/login` | The URL (without any context path prefix) to redirect the client to to present the login form. |
| `form.auth.storage` | `cookie` | The type of storage used to provide the authentication state. Valid values are `cookie` and `session`. The default value also applies if any setting other than the supported values is configured. |
| `form.auth.name` | `sling.formauth` | The name of the Cookie or HTTP Session attribute providing the authentication state. |
| `form.auth.timeout` | `30` |The number of minutes after which a login session times out. This value is used as the expiry time set in the authentication data. |
| `form.credentials.name` | `sling.formauth` | The name of the `SimpleCredentials` attribute used to provide the authentication data to the `LoginModulePlugin`. |
| `form.token.file` | `cookie-tokens.bin` | The name of the file used to persist the security tokens. |
| `form.default.cookie.domain` | | The domain on which cookies will be set, unless overridden in the `AuthenticationInfo` object. |

*Note:* The `form.token.file` parameter currently refers to a file stored in the file system. If the path is a relative path, the file is either stored in the Authentication Handler bundle private data area or -- if not possible -- below the location indicated by the `sling.home` framework property or -- if `sling.home` is not set -- the current working directory. In the future this file may be store in the JCR Repository to support clustering scenarios.


### Security Considerations

Form Based Authentication has some limitations in terms of security:

1. User name and password are transmitted in plain text in the initial form submission.
1. The Cookie used to provide the authentication state or the HTTP Session ID may be stolen.

To prevent eavesdroppers from sniffing the credentials or stealing the Cookie a secure transport layer should be used such as TLS/SSL, VPN or IPSec.
