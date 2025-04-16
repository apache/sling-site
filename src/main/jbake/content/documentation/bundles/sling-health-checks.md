title=Custom Sling Health Checks
type=page
status=published
tags=healthchecks,operations
~~~~~~

Custom Sling Health Checks run on the [Felix Health Checks](https://felix.apache.org/documentation/subprojects/apache-felix-healthchecks.html) runtime.

# Best location for Health Checks

It is best practice to place health check next to the functionality they check. Also documentation of those check should be provided along with the documentation of the functionality.

The below checks are exceptions to that rule as they are generic in what they check (but still require Sling features, that's whey they are not in Apache Felix).

# Apache Sling Health Check Support Bundle

Check | PID | Factory | Description
--- | --- | --- | ---
Default Logins Check | org.apache.sling.hc.support.DefaultLoginsHealthCheck | yes | Set a list of default logins in config array `logins` separated by `:`, e.g. `author:author`
Scripted Check | org.apache.sling.hc.support.impl.ScriptedHealthCheck | yes | Allows to run an arbitrary script in the same way as the Scripted Check `org.apache.felix.hc.generalchecks.ScriptedHealthCheck` from Apache Felix bundle [general checks](https://github.com/apache/felix-dev/blob/master/healthcheck/README.md#general-purpose-health-checks-available-out-of-the-box), except that this check allows to use files being loaded from JCR by using a `scriptUrl` with prefix `jcr:`, e.g. `jcr:/apps/ops/my-custom-check.groovy`
Request Status Health Check | *Deprecated* |  | Use instead the corresponding check from [general checks](https://github.com/apache/felix-dev/blob/master/healthcheck/README.md#general-purpose-health-checks-available-out-of-the-box)

# Health Checks as server-side JUnit tests
The `org.apache.sling.hc.junit.bridge` bundle makes selected Health Checks available as server-side JUnit tests.

It requires the `org.apache.sling.junit.core bundle` which provides the server-side JUnit tests infrastructure.

The idea is to implement the smoke tests of your system, for example, as health checks. You can then run them
as part of integration testing, using the  [Sling Testing Tools](/documentation/development/sling-testing-tools.html)
remote testing utilities, and also as plain Health Checks for monitoring or troubleshooting Sling instances.

To use this module, configure sets of tags at `/system/console/configMgr/org.apache.sling.hc.junitbridge.HealthCheckTestsProvider`
using the standard `includeThisTag,-omitThatTag` syntax, and JUnit tests will be available at /system/sling/junit/HealthChecks.html
to run the corresponding Health Checks.

