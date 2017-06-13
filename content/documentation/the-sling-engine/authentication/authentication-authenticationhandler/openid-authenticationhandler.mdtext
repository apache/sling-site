Title: OpenID AuthenticationHandler

[TOC]

The OpenID Authentication Handler supports authentication of request users using the [OpenID](http://www.openid.net) authentication protocol. If the user has successfully authenticated with his OpenID provider a signed OpenID identity is further used to identify the user.

Since generally an OpenID identity is an URL and URLs may not be used as JCR user names, an association mechanism is used by the OpenID authentication handler to associate an OpenID identity with an existing JCR user: The OpenID identity URL is set as the value of a JCR user property. When a user authenticates with his OpenID identity the matching user searched for by looking for a match in this property.

*NOTE:* This association currently only works with Jackrabbit (or Jackrabbit based repositories) because user management is not part of the JCR 2 specification and the OpenID authentication handler uses the Jackrabbit `UserManager` to find users by a user property value.

The OpenID Authentication Handler is maintained in the [Sling SVN](http://svn.apache.org/repos/asf/sling/trunk/bundles/auth/openid/)


### Credentials Extraction

Theoretically each request with the `openid_identifier` request parameter set may initiate an OpenID authentication process which involves resolving the OpenID provider for the identifier and subsequently authentication with the provider authorizing the Sling instance to use the OpenID identity.

This initiation, though, is not possible if the request already contains a valid and validated OpenID identifier either set as a request attribute or set in the HTTP Session or the OpenID cookie. In these situations, the current association of a client with an OpenID identity must first be removed by logging out, e.g. by requesting `/system/sling/logout.html` which causes the current OpenID user data to be removed by either removing it from the HTTP Session or by clearing the OpenID cookie.


### Phase 1: Form Submission

Requesting an OpenID identifier is initiated by the Sling Authenticator deciding, that authentication is actually required to process a request and the OpenID Authentication Handler being selected to request credentials with.

In this case the OpenID authenticator causes a form to be rendered by redirecting the client to the URL indicated by the `form.login.form` configuration parameter. This redirection request may accompanied by the following parameters:

| Request Parameter | Description |
|--|--|
| `resource` | The location to which the user initially requested access and that caused the `requestCredentials` method to be called. This may not be set (or be set to an empty string). |
| `j_reason` | The reason why an earlier attempt at authentication with the OpenID authentication handler failed. This request parameter is only set if the same named request attribute has been set by the `extractCredentials` or the `authenticationFailed` method. The value of the parameter is the name of one of the `OpenIDFailure` constants. |
| `j_openid_identity` | The OpenID identity which could not successfully be associated with an existing JCR user. This request parameter is only set if the `authenticationFailed` method has been called due to inability to associate an existing and validated OpenID identity with an existing JCR user. |

The OpenID Authentication handlers supports the following request parameters submitted by the HTML form:

* `openid_identifier` -- OpenID Claimed Identifier. This may be any actual OpenID identity URL or the URL of OpenID Provider such as https://www.google.com/accounts/o8/id, https://me.yahoo.com, or https://www.myopenid.com.
* `sling:authRequestLogin` -- This request parameter is recommended to be set with a hidden field to the value *OpenID* to ensure the request is handled by the OpenID Authentication Handler.
* `resource` -- The `resource` request parameter should be sent back to ensure the user is finally redirected to requested target resource after successful authentication. If this request parameter is not set, or is set to an empty string, it is assumed to be the request context root path.

The OpenID Authentication Handler provides a default login form registered at `/system/sling/openid/login`.


### Configuration

The OpenID AuthenticationHandler is configured with configuration provided by the OSGi Configuration Admin Service using the `org.apache.sling.openidauth.OpenIdAuthenticationHandler` service PID.

| Parameter | Default | Description |
|--|--|--|
| `path` | -- | Repository path for which this authentication handler should be used by Sling. If this is empty, the authentication handler will be disabled. |
| `openid.login.form` | `/system/sling/openid/login` | This should provide a way to capture the user's OpenID identifier.  This is not the OpenID Provider's login page, however, it does not have to be a local URL. If it is a local Sling URL, it must be accessible by the anonymous user. The user is HTTP Redirect'ed to this URL.  This page should POST back the user's OpenID identifier (as named by the "OpenID identifier form field" property) to the originally requested URL set in the "resource" request parameter. |
| `openid.login.identifier` | `openid_identifier` | The name of the form parameter that provides the user's OpenID identifier. By convention this is `openid_identifier`. Only change this if you have a very good reason to do so. |
| `openid.external.url.prefix` | -- | The prefix of URLs generated for the `ReturnTo` and `TrustRoot` properties of the OpenID request to the OpenID provider. Thus this URL prefix should bring back the authenticated user to this Sling instance. Configuring this property is usually necessary when running Sling behind a proxy (like Apache) since proxy mapping is not performed on the OpenID ReturnTo and TrustRoot URLs as they are sent to the OpenID Provider as form parameters.  If this property is empty, the URLs are generated using the hostname found in the original request.|
| `openid.use.cookie` | `true` |  Whether to use a regular Cookie or an HTTP Session to cache the OpenID authentication details. By default a regular cookie is used to prevent use of HTTP Sessions. |
| `openid.cookie.domain` | -- | Domain of cookie used to persist authentication. This defaults to the host name of the Sling server but may be set to a different value to share the cookie amongst a server farm or if the server is running behind a proxy. Only used if 'Use Cookie' is checked. |
| `openid.cookie.name` | `sling.openid` | Name of cookie used to persist authentication. Only used if 'Use Cookie' is checked. |
| `openid.cookie.secret.key` | `secret` | Secret key used to create a signature of the cookie value to prevent tampering. Only used if 'Use Cookie' is true. |
| `openid.user.attr` | `openid.user` | Name of the JCR SimpleCredentials attribute to to set with the OpenID User data. This attribute is used by the OpenID LoginModule to validate the OpenID user authentication data. |
| `openid.property.identity` | `openid.identity` |  The name of the JCR User attribute listing one or more OpenID Identity URLs with which a user is associated. The property may be a multi- or single-valued. To resolve a JCR user ID from an OpenID identity a user is searched who lists the identity in this property. |



### AuthenticationHandler implementation


#### extractCredentials

To extract authentication information from the request, the Sling OpenID Authentication handler considers the following information in order:

1. The OpenID credentials cookie or OpenID User data in the HTTP Session (depending on the `openid.use.cookie` configuration)
1. Otherwise the `openid_identifier` request parameter (or a different request parameter depending on the `openid.login.identifier` configuration)

If the OpenID credentials already exist in the request, they are validated and returned if valid

If the existing credentials fail to validate, authentication failure is assumed and the credentials are removed from the request, either by clearing the OpenID cookie or by removing the OpenID User data from the HTTP Session.

If no OpenID credentials are found in the request, the request parameter is considered and if set is used to resolve the actual OpenID identity of the user. This involves redirecting the client to the OpenID provider resolved from the OpenID identifier supplied.

If the supplied OpenID identifier fails to resolve to an OpenID provider or if the identifier fails to be resolved to a validated OpenID identity, authentication fails.


#### requestCredentials

If the `sling:authRequestLogin` parameter is set to a value other than `OpenID` this method immediately returns `false`.

If the parameter is not set or is set to `OpenID` this method continues with first invalidating any cached OpenID credentials (same as `dropCredentials` does) and then redirecting the client to the login form configured with the `openid.login.form` configuration property. The redirect is provided with up to three request parameters:

| Request Parameter | Description |
|--|--|
| `resource` | The location to which the user initially requested access and that caused the `requestCredentials` method to be called. |
| `j_reason` | The reason why an earlier attempt at authentication with the OpenID authentication handler failed. This request parameter is only set if the same named request attribute has been set by the `extractCredentials` or the `authenticationFailed` method. The value of the parameter is the name of one of the `OpenIDFailure` constants. |
| `j_openid_identity` | The OpenID identity which could not successfully be associated with an existing JCR user. This request parameter is only set if the `authenticationFailed` method has been called due to inability to associate an existing and validated OpenID identity with an existing JCR user. |



#### dropCredentials

Invalidates the OpenID identity currently stored with the request. This means to either remove the OpenID cookie or to remove the OpenID information from the HTTP Session. This method does not write to the response (except setting the `Set-Cookie` header to remove the OpenID cookie if required) and does not commit the response.


### AuthenticationFeedbackHandler implementation

#### authenticationFailed

This method is called, if the Credentials provided by the Authentication Handler could not be validated by the Jackrabbit authentication infrastructure. One cause may be that the integration with Jackrabbit has not been completed (see *Integration with Jackrabbit* below). Another, more probably cause, is that the validated OpenID identifier cannot be associated with an existing JCR user.

The OpenID Authentication Handler implementation of the `authenticationFailed` method sets the `j_reason` request attribute to `OpenIDFailure.REPOSITORY` and sets the `j_openid_identity` request attribute to the OpenID identity of the authenticated user.

A login form provider may wish to act upon this situation and provide a login form to the user to allow to his OpenID identity with an existing JCR user.

In addition, the current OpenID identity is invalidated thus the cached OpenID information is removed from the HTTP Session or the OpenID cookie is cleaned. This will allow the user to present a different OpenID identifier to retry or it will require the OpenID identity to be revalidated with the OpenID provider if the identity is associated with a JCR user.

#### authenticationSucceeded

The OpenID Authentication Handler implementation of the `authenticationSucceeded` method just calls the `DefaultAuthenticationFeedbackHandler.handleRedirect` method to redirect the user to the initially requested location.


### Integration with Jackrabbit

The OpenID authentication handler can be integrated in two ways into the Jackrabbit authentication mechanism which is based on JAAS `LoginModule`. One integration is by means of a `LoginModulePlugin` which plugs into the extensible `LoginModule` architecture supported by the Sling Jackrabbit Embedded Repository bundle.

The other integration option is the `trusted_credentials_attribute` mechanism supported by the Jackrabbit `DefaultLoginModule`. By setting the `trusted_credentials_attribute` parameter of the Jackrabbit `DefaultLoginModule` and the `openid.user.attr` configuration property of the OpenID Authentication Handler to the same value, the existence of an attribute of that name in the `SimpleCredentials` instance provided to the `Repository.login` method signals pre-authenticated credentials, which need not be further checked by the `DefaultLoginModule`.


### Security Considerations

OpenIDAuthentication has some limitations in terms of security:

1. User name and password are transmitted in plain text in the initial form submission.
1. The Cookie used to provide the authentication state or the HTTP Session ID may be stolen.
1. When using the `trusted_credentials_attribute` mechanism, any intruder knowing the attribute name may log into the repository as any existing JCR user. The better option is to be based on the `LoginModulePlugin` mechanism.

To prevent eavesdroppers from sniffing the credentials or stealing the Cookie a secure transport layer should be used such as TLS/SSL, VPN or IPSec.
