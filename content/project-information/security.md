title=TODO title for security.md 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: Security

# Reporting New Security Problems with Apache Sling

The Apache Software Foundation takes a very active stance in eliminating security problems and denial of service attacks against Apache Sling.

We strongly encourage folks to report such problems to our private security mailing list first, before disclosing them in a public forum.

*Please note that the security mailing list should only be used for reporting undisclosed security vulnerabilities in Apache Sling and managing the process of fixing such vulnerabilities. We cannot accept regular bug reports or other queries at this address. All mail sent to this address that does not relate to an undisclosed security problem in the Apache Sling source code will be ignored.*

If you need to report a bug that isn't an undisclosed security vulnerability, please use our [public issue tracker](https://issues.apache.org/jira/browse/SLING).

Questions about:

* how to configure Sling securely
* whether a published vulnerability applies to your particular application
* obtaining further information on a published vulnerability
* availability of patches and/or new releases

should be addressed to our public users mailing list. Please see the [Project Information](/project-information.html) page for details of how to subscribe.

The private security mailing address is: security(at)sling.apache.org.

Note that all networked servers are subject to denial of service attacks, and we cannot promise magic workarounds to generic problems (such as a client streaming lots of data to your server, or re-requesting the same URL repeatedly). In general our philosophy is to avoid any attacks which can cause the server to consume resources in a non-linear relationship to the size of inputs.

For more information on handling security issues at the Apache Software Foundation please refer to the [ASF Security Team](http://www.apache.org/security/) page and to the [security process description for committers](http://www.apache.org/security/committers.html).

# Errors and omissions

Please report any errors or omissions to security(at)sling.apache.org.
