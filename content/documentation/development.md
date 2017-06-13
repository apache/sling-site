Title=TODO add front matter 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: Development

Welcome to the wonderful world of extending Sling. Refer to these pages to find out how we envision the extension of Sling and how to do it.


## Using Sling as your Development Framework

Look here for more information on developper support when your are using Sling to build your own applications.

* [Getting and Building Sling]({{ refs.getting-and-building-sling.path }})
* [Defining and Launching a Sling based Application]({{ refs.slingstart.path }})
* [Embedding Sling]({{ refs.embedding-sling.path }})
* [Logging]({{ refs.logging.path }})
* [Client Request Logging]({{ refs.client-request-logging.path }})
* [Monitoring Requests]({{ refs.monitoring-requests.path }})
* [Repository Based Development]({{ refs.repository-based-development.path }})
* [Sling IDE Tooling]({{ refs.ide-tooling.path }})
* [Leveraging JSR-305 null annotations]({{ refs.jsr-305.path }})


## Testing Sling-based Applications
* [Testing Sling-based Applications]({{ refs.testing-sling-based-applications.path }})
* [Junit Server-Side Tests Support]({{ refs.org-apache-sling-junit-bundles.path }})
* [Resource Resolver Mock]({{ refs.resourceresolver-mock.path }})
* [Sling Mocks]({{ refs.sling-mock.path }})
* [OSGi Mocks]({{ refs.osgi-mock.path }})
* [JCR Mocks]({{ refs.jcr-mock.path }})
* [Hamcrest integration]({{ refs.hamcrest.path }})


## Maven Stuff

Sling is using Apache Maven 3 as its build system. Over time we have created a number of Maven 3 plugins and gathered a whole range of knowledge about using Maven.

* [Maven Sling Plugin](http://sling.apache.org/components/maven-sling-plugin/)
* [HTL Maven Plugin](http://sling.apache.org/components/htl-maven-plugin/)
* [SlingStart Maven Plugin](http://sling.apache.org/components/slingstart-maven-plugin/)
* [Maven Launchpad Plugin]({{ refs.maven-launchpad-plugin.path }})
* [JspC Maven Plugin](http://sling.apache.org/components/jspc-maven-plugin/)
* [Maven Archetypes]({{ refs.maven-archetypes.path }})
* [Maven Tips & Tricks]({{ refs.maventipsandtricks.path }})


## Sling Development

Last but not least, here is some more information on how we ourselves are working on Sling

* [Dependency Management]({{ refs.dependency-management.path }})
* [Version Policy]({{ refs.version-policy.path }})
* [Issue Tracker]({{ refs.issue-tracker.path }})
* [Release Management]({{ refs.release-management.path }})
* [Maven Usage]({{ refs.maven-usage.path }})
* To run our integration tests suite see the [launchpad/testing module README](http://svn.apache.org/repos/asf/sling/trunk/launchpad/testing/README.txt) and the [launchpad/integration-tests README](http://svn.apache.org/repos/asf/sling/trunk/launchpad/integration-tests/README.txt) for how to run individual integration tests. We use the [sling-IT](https://issues.apache.org/jira/issues/?jql=labels%20%3D%20sling-IT) label in JIRA for known issues with our integration tests.
* A Sonar analysis is available on the [analysis.apache.org](https://analysis.apache.org/dashboard/index/org.apache.sling:sling-builder) server.
