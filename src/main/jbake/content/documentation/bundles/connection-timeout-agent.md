title=Connection Timeout Agent		
type=page
status=published
expandVariables=true
~~~~~~
[TOC]

## Connection Timeout Agent

This module provides a java agent that uses the [instrumentation API](https://docs.oracle.com/javase/7/docs/api/java/lang/instrument/package-summary.html) to add connect and read timeouts to connections made via HTTP or HTTPs. It only applies these timeouts if none were set explicitly.

The agent is intended as an additional layer of control to use when running untrusted client code that may make calls without explicitly setting timeouts. It is always recommended to set timeouts in client code, rather than relying on this agent.

It currently supports setting timeouts for HTTP connections done using:

* [java.net.URL](https://docs.oracle.com/javase/7/docs/api/java/net/URL.html) and/or [java.net.URLConnection](https://docs.oracle.com/javase/7/docs/api/java/net/URLConnection.html)
* [Apache Commons HttpClient 3.x](https://hc.apache.org/httpclient-3.x/)
* [Apache HttpComponents Client 4.x](https://hc.apache.org/httpcomponents-client-ga/)
* [OK Http](https://square.github.io/okhttp/)
* [JDK HttpClient](https://docs.oracle.com/en/java/javase/21/docs/api/java.net.http/java/net/http/HttpClient.html)

## Usage

The agent can be loaded using the standard Java CLI invocation, by using the `-javaagent:...` argument.

    java -javaagent:org.apache.sling.connection-timeout-agent-jar-with-dependencies.jar=<agent-connect-timeout>,<agent-read-timeout>[,<logspec>] -jar org.apache.sling.starter-${sling_releaseVersion}.jar

It support two mandatory arguments and an optional one:

 - `<agent-connect-timeout>` - connection timeout in milliseconds to apply via the agent
 - `<agent-read-timeout>`- read timeout in milliseconds to apply via the agent
 - `<logspec>` - if set to `v`, it will enter verbose mode and print additional information to `System.out`
 
If started in verbose mode, output similar to the following will be printed


	[AGENT] Preparing to install URL transformers. Configured timeouts - connectTimeout : 1000, readTimeout: 1000 
	[AGENT] All transformers installed 
	[AGENT] JavaNetTimeoutTransformer asked to transform sun/net/www/protocol/https/AbstractDelegateHttpsURLConnection 
	[AGENT] Transformation of sun/net/www/protocol/https/AbstractDelegateHttpsURLConnection complete 
	[AGENT] JavaNetTimeoutTransformer asked to transform sun/net/www/protocol/http/HttpURLConnection 
	[AGENT] Transformation of sun/net/www/protocol/http/HttpURLConnection complete 


Note that classes will be transformed when they are loaded. It is expected for a transformer for class _A_ to be active but the class not to be transformed until it is actually used.

## JMX

Various runtime information is exposed through a JMX MBean registered at `org.apache.sling.cta;ObjectType=Agent`. 

![JMX MBeans](/documentation/bundles/connection-timeout-agent/jmx-mbeans.png)

## Alternatives

It is always recommended to set timeouts in the client code directly. The agent carries some risks, namely:

- it is not transparent why and where timeouts are set and can lead to hard-to-debug scenarios
- it only sets one timeout for the whole JVM, whereas various services may need different timeouts

All HTTP client libraries offer a way of setting connect and read timeouts, and it strongly recommended to do so. Alternatively, various bundles offer a way of centrally defining timeouts, amongst them:

* [Code Distillery - OSGi Configuration Support for Apache HttpComponents Client](https://github.com/code-distillery/httpclient-configuration-support)
* [WCM.io Caravan - Commons HTTP Client](https://caravan.wcm.io/commons/httpclient/)


## Tested platforms for version 1.0.4

* openjdk version "1.8.0_423"
* openjdk version "11.0.25" 2024-10-15
* openjdk version "17.0.13" 2024-10-15
* openjdk version "21.0.5" 2024-10-15
* commons-httpclient 3.1
* httpclient 4.5.4
* okhttp 3.14.2
