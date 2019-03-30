title=Sling Health Checks Migration Guide to Felix Health Checks		
type=page
status=published
tags=healthchecks,operations
~~~~~~

**Sling Health Checks are deprecated** and superseded by [Felix Health Checks](http://felix.apache.org/documentation/subprojects/apache-felix-healthchecks.html). See [Sling Health Check Tools (deprecated)](sling-health-check-tool-deprecated.html) for documentation prior to deprecation.

## Migrate custom checks

### Adjust maven dependencies

* Remove dependencies for `org.apache.sling:org.apache.sling.hc.api` and `org.apache.sling:org.apache.sling.hc.annotations` (if used)
* Add the following new dependencies:

        <dependency>
            <groupId>org.apache.felix</groupId>
            <artifactId>org.apache.felix.healthcheck.api</artifactId>
            <version>2.0.0</version>
            <scope>provided</scope>
        </dependency>

        <dependency>
            <groupId>org.apache.felix</groupId>
            <artifactId>org.apache.felix.healthcheck.annotation</artifactId>
            <version>2.0.0</version>
            <scope>provided</scope>
        </dependency>
        
### Adjust Health Check Code

* Use the `Organize Imports` functionality of your IDE to fix the imports (mostly it is just replacing `org.apache.sling.hc.api` with `org.apache.felix.hc.api`, however the commonly used class `FormattingResultLog` has been moved from `org.apache.sling.hc.util` to `org.apache.felix.hc.api`)
* For the case the annotation `@SlingHealthCheck` is used, replace that one with the new Felix annotations from [org.apache.felix.healthcheck.annotation](http://svn.apache.org/viewvc/felix/trunk/healthcheck/annotation/src/main/java/org/apache/felix/hc/annotation/)
* There is no `util` package in the api bundle anymore, apart from `FormattingResultLog` the other classes in the package were rarely used. The class `SimpleConstraintChecker` has moved to `org.apache.felix.hc.generalchecks.util` in bundle `generalchecks` (maven dependency to `org.apache.felix.healthcheck.generalchecks` needs to be added for that case). For the other classes there is no replacement.
* For the case the property `hc.async.cronExpression` is used, the bundle `org.apache.servicemix.bundles.quartz` needs to be available at runtime (as alternative it is possible to use `hc.async.intervalInSec` now)
* For Health Checks using property `hc.warningsStickForMinutes`, this has been renamed to `hc.keepNonOkResultsStickyForSec` - here the unit has changed from min to sec in order to allow for second-magnitude values that can be useful for deployment scenarios


## Migrate a runtime

* `org.apache.sling.hc.api` - keep to ensure bundles with checks that are not yet migrated work
* `org.apache.sling.hc.core` - remove
* `org.apache.sling.hc.webconsole` - remove
* `org.apache.sling.hc.support` - keep, Sling specific health checks that don't fit anywhere else go there
* `org.apache.felix.healthcheck.api` - add
* `org.apache.felix.healthcheck.core` - add (also runs checks implemented against `org.apache.sling.hc.api` by default)
* `org.apache.felix.healthcheck.webconsoleplugin` - add
* `org.apache.felix.healthcheck.generalchecks` - add (optional but recommended)