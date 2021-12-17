title=Apache Sling advisory regarding CVE-2021-44228 and LOGBACK-1591
type=page
status=published
tags=security
tableOfContents=false
~~~~~~

On 9th December 2021, a new zero-day vulnerability for [Apache Log4j 2](https://logging.apache.org/log4j/2.x/index.html) was reported. It is tracked under [CVE-2021-44228](
https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-44228) and affects Log4j versions from 2.0.1 (inclusive) to 2.15.0
(exclusive). It is also known under the *Log4Shell* name.

Apache Sling modules use the [Simple Logging Facade for Java](http://www.slf4j.org) (slf4j) for logging, backed by the [Sling Commons Log
bundle](https://github.com/apache/sling-org-apache-sling-commons-log/). There are no Sling modules using versions of Log4j
affected by *Log4Shell*. The Sling Starter and Sling CMS applications do not include any vulnerable version of the Log4j library.

Applications built on top of Apache Sling are not impacted by CVE-2021-44228, provided they do not deploy
a vulnerable version of Log4j themselves.

The Sling Commons Log bundle wraps `logback-core` and `logback-classic`, but does not allow arbitrary modifications to
the `logback.xml` file and is therefore not vulnerable to the attack described in [LOGBACK-1591](https://jira.qos.ch/browse/LOGBACK-1591).

The Apache Sling PMC recommends that developers and operators of applications built on top of Apache Sling review the libraries they
deploy to ensure that they do not include vulnerable versions of Log4j.
