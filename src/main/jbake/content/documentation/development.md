title=Development		
type=page
status=published
tags=development,pmc
~~~~~~

Welcome to the wonderful world of extending Sling. Refer to these pages to find out how we envision the extension of Sling and how to do it.


## Using Sling as your Development Framework

Look here for more information on developper support when your are using Sling to build your own applications.

* [Getting and Building Sling](/documentation/development/getting-and-building-sling.html)
* [Defining and Launching a Sling based Application](/documentation/development/slingstart.html)
* [Embedding Sling](/documentation/development/embedding-sling.html)
* [Logging](/documentation/development/logging.html)
* [Client Request Logging](/documentation/development/client-request-logging.html)
* [Monitoring Requests](/documentation/development/monitoring-requests.html)
* [Repository Based Development](/documentation/development/repository-based-development.html)
* [Sling IDE Tooling](/documentation/development/ide-tooling.html)
* [Leveraging JSR-305 null annotations](/documentation/development/jsr-305.html)


## Testing Sling-based Applications
* [Testing Sling-based Applications](/documentation/tutorials-how-tos/testing-sling-based-applications.html)
* [Junit Server-Side Tests Support](/documentation/bundles/org-apache-sling-junit-bundles.html)
* [Resource Resolver Mock](/documentation/development/resourceresolver-mock.html)
* [Sling Mocks](/documentation/development/sling-mock.html)
* [OSGi Mocks](/documentation/development/osgi-mock.html)
* [JCR Mocks](/documentation/development/jcr-mock.html)
* [Hamcrest integration](/documentation/development/hamcrest.html)


## Maven Stuff

Sling is using Apache Maven 3 as its build system. Over time we have created a number of Maven 3 plugins and gathered a whole range of knowledge about using Maven.

* [Maven Sling Plugin](http://sling.apache.org/components/maven-sling-plugin/)
* [HTL Maven Plugin](http://sling.apache.org/components/htl-maven-plugin/)
* [SlingStart Maven Plugin](http://sling.apache.org/components/slingstart-maven-plugin/)
* [Maven Launchpad Plugin](/documentation/development/maven-launchpad-plugin.html)
* [JspC Maven Plugin](http://sling.apache.org/components/jspc-maven-plugin/)
* [Maven Archetypes](/documentation/development/maven-archetypes.html)
* [Maven Tips & Tricks](/documentation/development/maventipsandtricks.html)


## Sling Development

Last but not least, here is some more information on how we ourselves are working on Sling

* [Dependency Management](/documentation/development/dependency-management.html)
* [Version Policy](/documentation/development/version-policy.html)
* [Issue Tracker](/documentation/development/issue-tracker.html)
* [Release Management](/documentation/development/release-management.html)
* [Maven Usage](/documentation/development/maven-usage.html)
* To run our integration tests suite see the [launchpad/testing module README](https://github.com/apache/sling-org-apache-sling-launchpad-testing/blob/master/README.md) and the [launchpad/integration-tests README](https://github.com/apache/sling-org-apache-sling-launchpad-integration-tests/blob/master/README.md) for how to run individual integration tests. We use the [sling-IT](https://issues.apache.org/jira/issues/?jql=labels%20%3D%20sling-IT) label in JIRA for known issues with our integration tests.
* A Sonar analysis is available on the [analysis.apache.org](https://analysis.apache.org/dashboard/index/org.apache.sling:sling-builder) server.
