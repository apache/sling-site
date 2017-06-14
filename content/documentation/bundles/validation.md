title=Sling Validation		
type=page
status=published
~~~~~~

[TOC]

Many Sling projects want to be able to validate both Resources and request parameters. Through the Sling Validation framework this is possible with the help of validation model resources which define validation rules for a certain resourceType.

# Prerequisites
To use this validation framework the following bundles need to be deployed

1. `org.apache.sling.validation.api`
1. `org.apache.sling.validation.core`

In addition a [service resolver mapping](/documentation/the-sling-engine/service-authentication.html) needs to be configured for the service name `org.apache.sling.validation.core`. The bound service user needs to have at least read access to all resources within the resource resolver's search paths (usually `/apps` and `/libs`).

# Basic Usage
To validate a resource one first needs to get a `ValidationModel` and then validate the resource with that model. Both functionalities are provided by the `ValidationService` OSGi service:

::java
try {
ValidationModel validationModel = validationService.getValidationModel(resource, true);
if (validationModel != null) {
ValidationResult result = validationService.validate(resource, validationModel);
if (!result.isValid()) {
// give out validation messages from result.get
}
}
} catch (IllegalStateException e) {
// give out error message that the validation model is invalid!
}

Apart from that it is also possible to validate resources including all child resources having their own validation model (i.e. a merged view of the validation models is applied). The appropriate validation model is being looked up by getting the resource type for each node. Since by default the JCR will return the primary type in case there is no `sling:resourceType` property found on the node, either the 2nd parameter `enforceValidation` should be set to `false` or some resource types must be explicitly ignored by the given filter in the 3rd parameter `filter` to also properly support validation models which have children resources on their own.

::java
try {
final Predicate ignoreResourceType1Predicate = new Predicate<Resource>() {
@Override
public boolean test(final Resource resource) {
return !"resourcetype1".equals(resource.getResourceType());
}
};
ValidationResult result = validationService.validateResourceRecursively(resource, false, ignoreResourceType1Predicate, false);
if (!result.isValid()) {
// give out validation messages from result.getFailureMessages()
}

} catch (IllegalStateException e) {
// give out error message that an invalid validation model for at least one sub resource was found
} catch (IllegalArgumentException e) {
// one of the resource types is absolute or there was no validation model found for at least one sub resource
}

All methods to retrieve a validation model support a boolean parameter `considerResourceSuperTypeModels`. If this is set to true, the validation model is not only being looked up for exactly the given resource type but also for all its resource super types. The returned model is then a merged model of all found validation model along the resource type hierarchy.

## ValidationResult
The `ValidationResult` indicates whether a given `Resource` or `ValueMap` is valid or invalid according to a given validation model. In the latter case it aggregates one or more `ValidationFailure`s. Each `ValidationFailure` is encapsulating an error message and a severity. The severity may be set on the following locations (where locations on top may overwrite severity from locations below):

1. validation model (per use case of a `Validator`)
1. severity defined on the `Validator`
1. the default severity (may be set through the OSGi configuration for PID `org.apache.sling.validation.impl.ValidationServiceImpl`, is 0 by default)

You have to use a `ResourceBundle` ([Internationalization Support](/documentation/bundles/internationalization-support-i18n.html)) to resolve the message for a specific locale. By default Sling Validation comes only with English failure messages.

# Validation Model Resources
The `ValidationModel` is constructed from resources with the resourceType **sling/validation/model**. Those resources are considered validation model resources if they are located below the Sling ResourceResolver search paths (*/apps* and */libs*).

The resources should have the following format:

Property/Resource Name      | Property or Resource |  Type   |  Description   |  Mandatory   |  Example
-------------------- | ------- | -------------- | -------------| --------- | ------
`sling:resourceType` | Property | `String` | Always `sling/validation/model`, otherwise model will never be picked up by Sling Validation. | yes | `sling/validation/model`
`validatingResourceType` | Property | `String` | The resource type of the resource for which this validation model should be applied. Must always be relative to the resource resolver's search path (i.e. not start with a "/"). | yes | `my/own/resourcetype`
`applicablePaths` | Property |  `String[]` | Path prefixes which restrict the validation model to resources which are below one of the given prefixes. No wildcards are supported. If not given, there is no path restriction. If there are multiple validation models registered for the same resource type the one with the longest matching applicablePath is chosen. | no | `/content/mysite`
`properties<propertyName>` | Resource | - | This resource ensures that the property with the name `<propertyName>` is there. The resource name has no longer a meaning if the property `nameRegex` is set on this node. | no | `false`
`properties<propertyName>optional` | Property | `Boolean` | If `true` it is not an error if there is no property with the given `<propertyName>` or none matching the  `nameRegex`. If not set or `false` the property must be there.  | no | `false`
`properties<propertyName>propertyMultiple` | Property | `Boolean` | If `true` only multivalue properties are allowed with the name `<propertyName>` or matching the `nameRegex`. If not set or `false`, multi- and single-value properties are accepted.  | no | `false`
`properties<propertyName>nameRegex` | Property | `String` | If set the `<propertyName>` has no longer a meaning. Rather all properties which match the given regular expression are considered. At least one match is required, otherwise the validated resource/valuemap is considered invalid. | no | `property[0-8]`
`properties<propertyName>validators<validatorId>` | Resource | - | The `<validatorId>` must be the id of a validator. The id is given by the OSGi service property `validator.id` set in the validator. Each validators node might have arbitrarily many child resources (one per validator).  | no | `false`
`properties<propertyName>validators<validatorId>validatorArguments` | Property | `String[]` | The parametrization for the validator with the id  `<validatorId>`. Each value must have the pattern `key=value`. The parametrization differs per validator. | no | `regex=^[a-z]*$`
`properties<propertyName>validators<validatorId>severity` | Property | `Integer` | The severity which should be set on all emitted validation failures by this validator. | no | `0`
`children<resourceName>` | Resource | - | This resource ensures that the resource with the name `<resourceName>` is there. The resource name has no longer a meaning if the property `nameRegex` is set on this node. | no | `child1`
`children<resourceName>nameRegex` | Property | `String` | If set the `<resourceName>` has no longer a meaning. Rather all resources whose name match the given regular expression are considered. At least one match is required, otherwise the validated resource/valuemap is considered invalid. | no | `child[1-9]`
`children<resourceName>optional` | Property | `Boolean` | If `true` it is not an error if there is no resource with the given `<resourceName>` or none matching the  `nameRegex`. If not set or `false` the resource must be there. | no | `false`
`children<resourceName>properties` | Resource | - | The properties can be configured on the child level in the same way as on the root level. | no | -

## Validation Model Inheritance
Sling Validation optionally supports the inheritance of Sling Validation Models. This means not only the model for exactly the given resource type is considered, but also the models for all resource super types.
To overwrite some property or child from one of the super type models, just define a property/child on the same level and with the same name in a model for a resource type which is more specific. That way the property/child on the super validation model is no longer effective.

## Precedence of Validation Models
In case there are multiple validation models registered for the same resource type the one gets chosen which has the longest matching applicablePath. In case even that does not resolve to a single model the one in the first resource resolver's search path is chosen (models below `/apps` before the ones below `/libs`). If even that does not resolve to a single validation model any of the equally ranked models might be picked.

# Usage in [Sling Models](/documentation/bundles/models.html)
## Since Sling Models 1.2.0
See [Sling Models validation](/documentation/bundles/models.html#validation)

## Before Sling Models 1.2.0
One needs to call the validate method within the PostConstruct method of the according Sling Model

::java
@SlingObject
protected Resource resource;

@OSGiService
protected ValidationService validation;

@PostConstruct
public void validate() {
try {
ValidationModel validationModel = validation.getValidationModel(resource);
if (validationModel == null) {
LOG.warn("No validation defined for resource '{}' with type '{}'", resource.getPath(), resource.getResourceType());

} else {
ValidationResult result = validation.validate(resource, validationModel);
if (!result.isValid()) {
// give out the validation result
}
}
} catch (IllegalStateException e) {
LOG.warn("Invalid validation model for resource '{}' with type '{}'", resource.getPath(), resource.getResourceType());
}
}

# Validators

Validator ID | Description | Parameters | Since
---------------|-------------|------------|-------
[`org.apache.sling.validation.core.RegexValidator`](https://svn.apache.org/repos/asf/sling/trunk/bundles/extensions/validation/core/src/main/java/org/apache/sling/validation/impl/validators/RegexValidator.java) | Validates that a property value matches a given regular expression | `regex`, mandatory parameter giving a regular expression according to the pattern described in [java.util.regex.Pattern](http://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html). Only if the property value matches this expression it is considered valid. | 1.0.0

# Writing Validators
To write a validator one needs to implement the [`org.apache.sling.validation.spi.Validator`](https://svn.apache.org/repos/asf/sling/trunk/bundles/extensions/validation/api/src/main/java/org/apache/sling/validation/spi/Validator.java) interface in an OSGi service (look at [`org.apache.sling.validation.core.RegexValidator`](https://svn.apache.org/repos/asf/sling/trunk/bundles/extensions/validation/core/src/main/java/org/apache/sling/validation/impl/validators/RegexValidator.java) for an example).
That interface defines the method `validate`. That is called for each property which is bound to the validator through the validation model.
Each validator needs to specify one type parameter which defines upon which classes the validator can act (usually `String`). Array types are also supported here. Collection types are not supported. If a property value cannot be converted to the requested type from the validator (through `ValueMap.get(name, type)`), validation will fail.

In addition the OSGi service must expose a String property named `validation.id`. The value of this property should always start with the providing bundle's symbolic name. Only through this value the validator can be referenced from validation models. If multiple validators have the same `validation.id` value the one with the highest service ranking gets always chosen.

A validator may also expose a service property named `validation.severity` with an Integer value. This defines the default severity of the Validator (which may be overwritten in the validation model).

# References
1. [Apache Sling Generic Validation Framework, adaptTo 2014](http://www.slideshare.net/raducotescu/apache-sling-generic-validation-framework)

