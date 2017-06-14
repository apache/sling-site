title=Authentication - Tasks		
type=page
status=published
~~~~~~
Excerpt: Authentication of HTTP Requests is generally a two-step process: First the credentials must be extracted from the request and second the credentials must be validated. In the case of Sling this means acquiring a JCR Session.

Authentication of HTTP Requests is generally a two-step process: First the credentials must be extracted from the request and second the credentials must be validated. In the case of Sling this means acquiring a JCR Session.

## Extract Credentials from the Request

* Implemented and controlled by the Sling Auth Core bundle
* Takes `HttpServletRequest`
* Provides credentials for futher processing (basically JCR `Credentials` and Workspace name)
* Extensible with the help of `AuthenticationHandler` services


## Login to the JCR Repository

* Implemented and controlled by the JCR Repository
* Takes JCR `Credentials` and Workspace name
* Provides a JCR `Session`
* Implementation dependent process. Jackrabbit provides extensibility based on `LoginModules`; Sling's Embedded Jackrabbit Repository bundle provides extensibility with `LoginModulePlugin` services.

Currently the credentials are always verified by trying to login to the JCR repository. Once an [ResourceResolverFactory](http://cwiki.apache.org/SLING/add-resourceresolverfactory-service-interface.html) API has been added, the process of validating the credentials and logging in is actualy replaced by a process of requesting a `ResourceResolver` from the `ResourceResolverFactory`. Of course, the JCR Repository will still be the main underlying repository and as such be used to validate the credentials and get a JCR Session.
