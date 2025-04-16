title=Sling Health Checks Migration Guide to Felix Health Checks
type=page
status=published
tags=healthchecks,operations
~~~~~~

**The Sling Health Check Runtime is deprecated** and superseded by [Felix Health Checks](https://felix.apache.org/documentation/subprojects/apache-felix-healthchecks.html). See [Sling Health Check Tools (deprecated)](sling-health-check-tool-deprecated.html) for documentation prior to deprecation and [Sling Health Checks](sling-health-checks.html) for checks implemented against the Felix Health Checks Runtime.

## Migrate custom checks

### Adjust maven dependencies

* Remove dependencies for `org.apache.sling:org.apache.sling.hc.api` and `org.apache.sling:org.apache.sling.hc.annotations` (if used)
* Add the following new dependencies:

        <dependency>
            <groupId>org.apache.felix</groupId>
            <artifactId>org.apache.felix.healthcheck.api</artifactId>
            <version>2.0.4</version>
            <scope>provided</scope>
        </dependency>

        <dependency>
            <groupId>org.apache.felix</groupId>
            <artifactId>org.apache.felix.healthcheck.annotation</artifactId>
            <version>2.0.0</version>
            <scope>provided</scope>
        </dependency>

### Adjust Health Check Code

Typically necessary steps:

* Use the `Organize Imports` functionality of your IDE to fix the imports (mostly it is just replacing `org.apache.sling.hc.api` with `org.apache.felix.hc.api`, however the commonly used class `FormattingResultLog` has been moved from `org.apache.sling.hc.util` to `org.apache.felix.hc.api`)
* For the case the annotation `@SlingHealthCheck` is used, replace that one with the new Felix annotations from [org.apache.felix.healthcheck.annotation](https://github.com/apache/felix-dev/blob/master/healthcheck/)
* There is no `util` package in the api bundle anymore, apart from `FormattingResultLog` the other classes in the package were rarely used. The class `SimpleConstraintChecker` has moved to `org.apache.felix.hc.generalchecks.util` in bundle `generalchecks` (maven dependency to `org.apache.felix.healthcheck.generalchecks` needs to be added for that case). For the other classes there is no replacement.

Only necessary if the the respective feature is used:

* For Health Checks using property `hc.warningsStickForMinutes`, this has been renamed to `hc.keepNonOkResultsStickyForSec` - here the unit has changed from min to sec in order to allow for second-magnitude values that can be useful for deployment scenarios
* For the case the property `hc.async.cronExpression` is used, the bundle `org.apache.servicemix.bundles.quartz` may be added to use quartz for cron expressions (in the same way as it was the case for the Sling Health Checks). If the bundle is not present, a simple cron trigger implementation included in `org.apache.felix.healthcheck.core` will be used instead, see [FELIX-6265](https://issues.apache.org/jira/browse/FELIX-6265) for details.


## Migrate a runtime

* `org.apache.sling.hc.api` - keep to ensure bundles with checks that are not yet migrated work (can be removed once all bundles are migrated to new API)
* `org.apache.sling.hc.core` - remove
* `org.apache.sling.hc.webconsole` - remove
* `org.apache.sling.hc.support` - keep, Sling specific health checks that don't fit anywhere else go there
* `org.apache.felix.healthcheck.api` - add
* `org.apache.felix.healthcheck.core` - add (also runs checks implemented against `org.apache.sling.hc.api` by default)
* `org.apache.felix.healthcheck.webconsoleplugin` - add
* `org.apache.felix.healthcheck.generalchecks` - add (optional but recommended)