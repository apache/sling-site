title=TODO title for sling-settings-org-apache-sling-settings.md 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: Sling Settings and Run Modes (org.apache.sling.settings)

# Overview

The Sling Settings Bundle exposes the `SlingSettingsService` which allows access to the following information pertinent to a Sling instance:

| Method | Bundle Context Property | Description |
|--|--|--|
| `String getSlingId()` | --- | A unique identifier of the running Sling instance. This value is created when Sling is first started and may be used to identify the instance, for example if multiple Sling instances are running on top of a Jackrabbit Repository Cluster |
| `String getSlingHomePath()` | `sling.home` | The absolute filesystem path to the directory where Sling stores all its content |
| `URL getSlingHome()` | `sling.home.url` | The Sling Home path as an `java.net.URL` instance |
| `Set<String> getRunModes()` | `sling.run.modes` | The active Run Modes of the running Sling instance |

The new Sling Settings Bundle replaces the former [Run Modes (org.apache.sling.runmode)]({{ refs.run-modes-org-apache-sling-runmode.path }}) Bundle and the `SlingSettingsService` previously provided by the Sling Engine bundle, as it also implements the run modes logic.

## Selecting the active run modes
The run modes are selected based on the `sling.run.modes` property (the "selection property"), specified in the Sling settings file or as a command-line parameter (which takes precedence), out of the valid run modes defined by the properties described below. The value is a String which contains a list of comma-separated run modes. If a run mode is given here which is not contained in any group of valid run modes (given in `sling.run.mode.install.options` or `sling.run.mode.options`) it is always active, on the other hand run modes which are contained in any of the predefined groups may be modified/removed (see below for the details).

Using `-Dsling.run.modes=foo,bar` on the JVM command-line, for example, activates the *foo* and *bar* run modes if that combination is valid.

The absolute truth about run modes definition and selection is found in the [RunModeImplTest](https://svn.apache.org/repos/asf/sling/trunk/bundles/extensions/settings/src/test/java/org/apache/sling/settings/impl/RunModeImplTest.java) which should be self-explaining.

## Defining valid run modes
Since [SLING-2662](https://issues.apache.org/jira/browse/SLING-2662) the valid run modes are defined by the `sling.run.mode.options` and `sling.run.mode.install.options` configuration properties, usually defined in the `sling.properties` file or in the provisioning model of a Sling Launchpad instance.

The `sling.run.mode.install.options` property is only used on the first startup on the Sling instance and the run modes that it defines cannot be changed later.

The `sling.run.mode.options` property on the other hand is used at each startup, so the run modes that it defines can be changed between executions of a given Sling instance.

The value of the both these properties is a string which looks like:

    red,green,blue|one|moon,mars

where *comma-separated run modes form a group*. The individual groups are separated by a pipe character (`|`, which is not an OR operation, it's just as separator). A group defines a number of run modes which are **mutually exclusive**. It means once a group is defined, exactly one run mode will be active from that group.

The example from above consists out of 3 different groups

1. `red,green,blue`
2. `one`
3. `moon,mars`

The rules for determining the active run modes from the selected run mode (`sling.run.modes`) and the run mode options (`sling.run.mode.install.options` and `sling.run.mode.options`) are as follows : 

1. If none of the run modes in the options are selected, the first one from each group in the options is activated by default. 
1. If one is selected from a group in the options, this is active.
1. If several are selected from one group in the options, the first one from the list of valid run modes is used.
1. If the selected run mode is not mentioned in any of the option groups it is active

Examples

    sling.run.mode.options=a,b|c,d,e

User defined run modes (e.g. via property `sling.run.modes`) | Effectively active run modes
--- | ---
(none) | `a,c`
`a` | `a,c`
`b` | `b,c`
`a,b` | `a,c`
`a,d` | `a,d`
`a,e,f` | `a,e`

Remember to look at the `RunModeImplTest` mentioned above for details, and feel free to enhance it with useful examples.

### Getting the Run Modes of the Sling instance

The `SlingSettings` service provides the Run Modes of the running Sling instance as in this example:

    :::java
    SlingSettings settings = ...get from BundleContext...
    Set<String> currentRunModes = settings.getRunModes();
    
    Set<String> expectedRunModes = new HashSet<String>(){{ add("foo");add("wii"); }};
    if(expectedRunModes.removeAll(currentRunModes)) {
      // at least one of (foo,wii) run modes
      // is active
    }
	
Getting run modes in this way is usually not needed, it's better to define bundles or configurations that are only valid in specific run modes, rather than making decisions in code based on run modes.
