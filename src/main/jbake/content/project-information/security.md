title=Security
type=page
status=published
tags=security,pmc
~~~~~~

# Reporting New Security Problems with Apache Sling

The Apache Software Foundation takes a very active stance in eliminating security problems and denial of service attacks against Apache Sling.

We strongly encourage folks to report such problems to our private security mailing list first, before disclosing them in a public forum.

*Please note that the security mailing list should only be used for reporting undisclosed security vulnerabilities in Apache Sling and managing the process of fixing such vulnerabilities. We cannot accept regular bug reports or other queries at this address. All mail sent to this address that does not relate to an undisclosed security problem in the Apache Sling source code will be ignored.*

In Sling OSGi bundles we have long had a policy of depending on the lowest possible version of a library/API, to ensure that our bundles are deployable in the widest possible range of environments. Therefore the responsibility of
ensuring that the environment is secure lies with the assembler and/or deployer of the application, which should make sure that the OSGi bundles they deploy are secure. As such, **we don't consider vulnerable dependencies of our bundles as security issues** by themselves. Usually the dependencies used by Sling [are semantically versioned](https://docs.osgi.org/whitepaper/semantic-versioning/index.html) and therefore security related version updates are fully binary backwards-compatible.
Further detail and some exceptions from that policy are outlined in [our wiki](https://cwiki.apache.org/confluence/display/SLING/Dependabot).

If you need to report a bug that isn't an undisclosed security vulnerability, please use our [public issue tracker](https://issues.apache.org/jira/browse/SLING).

Questions about:

* how to configure Sling securely
* whether a published vulnerability applies to your particular application
* obtaining further information on a published vulnerability
* availability of patches and/or new releases

should be addressed to our public users mailing list. Please see the [Project Information](/project-information.html) page for details of how to subscribe.

The private security mailing address is: security(at)sling.apache.org.

Note that all networked servers are subject to denial of service attacks, and we cannot promise magic workarounds to generic problems (such as a client streaming lots of data to your server, or re-requesting the same URL repeatedly). In general our philosophy is to avoid any attacks which can cause the server to consume resources in a non-linear relationship to the size of inputs.

For more information on handling security issues at the Apache Software Foundation please refer to the [ASF Security Team](https://www.apache.org/security/) page and to the [security process description for committers](https://www.apache.org/security/committers.html).

# Errors and omissions

Please report any errors or omissions to security(at)sling.apache.org.
