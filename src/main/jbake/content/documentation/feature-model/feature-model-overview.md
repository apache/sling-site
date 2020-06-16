title=Feature Model
type=page
status=published
tags=feature model,osgi,project,guide,howtos
~~~~~~

## A How-To Guide to Feature Models

The Sling Feature Model provides a new approach for assembling applications and is intended to replace the Sling Provisioning Model. 
Both approaches accomplish the same goal of defining and assembling OSGi-based applications, however, the Feature Model 
is more robust and is not coupled to Sling. It addresses application packaging concerns by allowing all aspects of an application 
(e.g., bundles, configuration, framework properties, capabilities, requirements and custom artifacts) to be defined declaratively.

### Key Concepts

* Features - Central entity of the Feature Model used to logically group metadata, configuration, bundles and 
  extensions to represent a system module or subsystem. 
* Feature Extension - An extension point for adding new capabilities to the Feature Model. 
* Feature Archives - Packages one or more features and dependencies to simplify the distribution of an application.
* Feature Reference Files - A text descriptor file with a list of features.
* Feature Aggregation - A method for packaging multiple features into a single feature.

### About this How-To

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00;">

This how-to is designed to be a progressive tutorial in which each how-to builds on the previous. It's recommended
that you start on the first and work your way through them consecutively. 
</div>


## Exploring Feature Models by Example

* [How To Start Sling with the Kickstarter](/documentation/feature-model/howtos/kickstart.html)
* [How to Create a Custom Feature Model Project](/documentation/feature-model/howtos/sling-with-custom-project.html)
* [How to Create a Sling Composite Node Store](/documentation/feature-model/howtos/create-sling-composite.html)
* [How to Convert a Provisioning Model to a Feature Model](/documentation/feature-model/howtos/create-sling-fm.html)

## Advanced Reading

Want to know more? Take a look at the README files for the projects in the Feature Model ecosystem.

* [Feature Model](https://github.com/apache/sling-org-apache-sling-feature/blob/master/readme.md)
* [Feature Docs](https://github.com/apache/sling-org-apache-sling-feature/blob/master/docs/features.md)
* [Feature Extensions](https://github.com/apache/sling-org-apache-sling-feature/blob/master/docs/extensions.md)
* [Feature Archive](https://github.com/apache/sling-org-apache-sling-feature/blob/master/docs/feature-archives.md)
* [Feature References](https://github.com/apache/sling-org-apache-sling-feature/blob/master/docs/feature-ref-files.md)
* [Feature Aggregation](https://github.com/apache/sling-org-apache-sling-feature/blob/master/docs/aggregation.md)
* [SlingFeature Maven Plugin](https://github.com/apache/sling-slingfeature-maven-plugin)
* [Feature Launcher](https://github.com/apache/sling-org-apache-sling-feature-launcher)
* [Kickstarter](https://github.com/apache/sling-org-apache-sling-kickstart/blob/master/Readme.md)
