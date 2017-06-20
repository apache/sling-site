title=Web Console Extensions		
type=page
status=published
~~~~~~

The Apache Sling project provides two extensions to the [Apache Felix Web Console](http://felix.apache.org/site/apache-felix-web-console.html) (in addition to a number of plugins, of course):

[TOC]

## Branding (org.apache.sling.extensions.webconsolebranding)

The Apache Sling Web Console Branding provided by Apache Sling is currently just for the product logo displayed in the upper right corner of the Web Console and some titles and strings.

This bundle will attach as a fragment bundle to the Apache Felix Web Console bundle. To enable it after installation into a running system, you might have to refresh the package imports of the Apache Felix Web Console bundle. If you install using the Apache Felix Web Console bundle installation functionality, this will be taken care of by the Web Console.


## Security Provider (org.apache.sling.extensions.webconsolesecurityprovider)

The Apache Sling Web Console Security Provider implements the Apache Felix Web Console `WebConsoleSecurityProvider` and `WebConsoleSecurityProvider2` interface for authenticating Web Console users against the JCR repository. Each username and password presented is used to login to the JCR repository and to check the respective session.

1. Ensure the username and password can be used to login to the default workspace. If not, access is denied
1. If the username presented is one of the user names configured with the `users` configuration property, access is granted.
1. Otherwise if the user is a (direct or indirect) member of one of the groups configured with the `groups` configuration property, access is granted.

Access is denied if the username and password cannot be used to login to the default workspace or if the user is neither one of the configured allowed users nor in any of the configured groups.

### Configuration

The Security Provider is configured with the configuration PID `org.apache.sling.extensions.webconsolesecurityprovider.internal.SlingWebConsoleSecurityProvider` supporting the following properties:

| Property | Type | Default Value | Description
|--|--|--|
| `users` | `String`, `String[]` or `Vector<String>` | admin | The list of users granted access to the Web Console |
| `groups`| `String`, `String[]` or `Vector<String>` | --- | The list of groups whose (direct or indirect) members are granted access to the Web Console |

Note, that while the default value explicitly grants the *admin* user to access the Web Console it is suggested that system administrators define a special group and assign users with Web Console access to this group.

### Authentication Handling

As long as the web console security provider bundle is not activate and has not installed one of the above mentioned services, the default authentication of the web console is used. Once the bundle is active and a JCR repository service is available, the repository is used for authentication as explained above. But still the login form of the web console is used which is usually basic authentication.
Once startup is finished and a Sling authentication service is available as well, the security provider replaces the JCR repository based auth provider with a Sling based auth provider. Both authenticate against the JCR repository, however the Sling based one using Sling to render the login form. Therefore, this provider is not registered until startup is finished
