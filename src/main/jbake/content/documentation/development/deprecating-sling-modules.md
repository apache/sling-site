title=Deprecating Sling Modules
type=page
status=published
tableOfContents=false
tags=development,pmc,deprecation,github
~~~~~~

The following procedure is recommended to deprecate Sling Git repositories, indicating that they
should no longer be used.

 * Get consensus on our dev list or do a PMC vote, depending on the importance of the module
 * Create a branch named `maintenance` with the last version before deprecation.
 * Empty the `master` branch, keeping just `README.md` file.
 * Add the `deprecated` GitHub topic to the module, using a [.asf.yaml](https://cwiki.apache.org/confluence/display/INFRA/.asf.yaml+features+for+git+repositories) file in the `master` branch.
 
Deprecated modules can then be found with a GitHub query, see below.

The reasoning is that keeping just a `README` file makes it obvious that the repository is deprecated, and having the `maintenance` branch makes
it easy to get the deprecated code and even make maintenance releases if desired.

A deprecated module can be un-deprecated if the Sling PMC agrees to do that, technically it just means reverting the changes made by this procedure.

## README file contents for deprecated repositories

The `README` file should contain:

  * The Sling logo.
  * A link to [sling.apache.org](https://sling.apache.org).
  * The module name with the _(deprecated)_ mention.
  * A link to the replacement module(s) if any.
  * A mention of the `maintenance` branch, optionally with a link to it, but make sure that link is correct if copying
the `README` from another module.

For examples, see the list of deprecated repositories below.

## See Also

 * [List of deprecated Sling repositories](https://github.com/search?q=topic%3Asling+topic%3Adeprecated+org%3Aapache) based on a GitHub query.
 * [Using Git with Sling boilerplate files](https://cwiki.apache.org/confluence/display/SLING/Using+Git+with+Sling#UsingGitwithSling-Boilerplatefiles).
 * The previously used [svn attic](https://svn.apache.org/repos/asf/sling/attic/) is where older deprecated modules are found.

