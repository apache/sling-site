title=TODO title for issue-tracker.md 
date=1900-01-01
type=post
tags=blog
status=published
~~~~~~
Title: Issue Tracker

Apache Sling uses Jira for tracking bug reports and requests for improvements, new features, and other changes.

The issue tracker is available at [https://issues.apache.org/jira/browse/SLING](https://issues.apache.org/jira/browse/SLING) and is readable by everyone. A Jira account is needed to create new issues and to comment on existing issues. Use the [registration form](https://issues.apache.org/jira/secure/Signup!default.jspa) to request an account if you do not already have one.

See below for guidelines on creating and managing issues.


## Issue type

When creating a new issue, select the issue type based as follows:

| Issue type     | Description |
|--|--|
|  *Bug*          |  Bug reports are used for cases where Sling fails not function as it should (as defined by some documentation). If you are not certain whether the issue you've found is actually a bug, please ask the [Sling mailing lists](/project-information.html#mailing-lists) first for help. |
|  *New Feature*  |  Use a feature request when Sling does not have some functionality you need. |
|  *Improvement*  |  Use an improvement request to suggest improvements to existing features. Typical improvement requests are about updating documentation, increasing stability and performance, simplifying the implementation, or other such changes that make Sling better without introducing new features or fixing existing bugs. |
|  *Test*         |  Use this type when contributing test cases for existing features. Normally test cases should be contributed as a part of the original feature request or as regression tests associated with bug reports, but sometimes you just want to extend test coverage by introducing new test cases. This issue type is for such cases. |
|  *Task*         |  Used only for issues related to project infrastructure. |


## Summary

The issue summary should be a short and clear statement that indicates the scope of the issue. You are probably being too verbose if you exceed the length of the text field. Use the Environment and Description fields to provide more detailed information.


## Issue priority

Issue priority should be set according to the following:

| Issue priority | Description |
|--|
|  *Blocker*      |  Legal or other fundamental issue that makes it impossible to release Jackrabbit code |
|  *Critical*     |  Major loss of functionality that affects many Slingusers |
|  *Major*        |  Important issue that should be resolved soon |
|  *Minor*        |  Nice to have issues |
|  *Trivial*      |  Trivial changes that can be applied whenever someone has extra time |



## Issue States

Sling issues can transition through a number of states while being processed:

| State | Description | Next States in Workflow |
|--|--|--|
| *Open* | The issue has just been created | *In Pogress* |
| *In Progress* | Work has started on the issue | *Documentation Required*, *Testcase Required*, *Documentation/Testcase required*, *Resolved*, *Open* |
| *Documentation Required* | Implementation work has finished for this issue. To complete it documentation must be created and/or updated. | *Resolved* |
| *Testcase Required* | Implementation work has finished for this issue. To complete it test cases must be created and/or updated. | *Resolved* |
| *Documentation/Testcase Required* | Implementation work has finished for this issue. To complete it documentation and test cases must be created and/or updated. | *Resolved*, *Documentation Required*, *Testcase Required* |
| *Resolved* | The issue has been resolved from the developers point of view. Documentation and Testcases have been created and updated as required. Issue is ready for release. | *Reopened*, *Closed* |
| *Reopened* | A resolved issue has been recognized to contain bugs or to be incomplete and thus has been reopened. | *In Progress*, *Resolved* |
| *Closed* | Work on this issue has finished and it is included in the release. | -- |

Users generally create issues and provide feedback while work on the issue is in progress. When the developer thinks the issue has been resolved, he resolves the issue. At this point, the user may test the resolution and reopen the issue if it has not really be solved. Otherwise the user may just acknowledge the fix.

Developers transition the issue through the workflow while working on it. When done with the issue, they mark the issue resolved with the appropriate resolution and ask the reporting user to confirm.

Issues are closed once the project against which it has been reported has been released. Issues once closed cannot be opened again. Rather new issues should be created against the new release to have broken implementations fixed or extended.



## Patches

When reporting a bug, requesting a feature or propose an improvement, it is a good thing to attach a patch to the issue. This may speed up issue processing and helps you being recognized as a good community member leading to closer involvement with Sling.
