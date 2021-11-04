title=Resource Access Security		
type=page
status=published
tags=security
~~~~~~

# Summary

The `ResourceAccessSecurity` service allows to restrict access to resources. The access can be granted or denied for read, create, update, delete and order resources actions.

The `ResourceAccessSecurity` interface defines a service API which is used in two different context: 

1. for securing resource providers which have no own access control and 
2. on the application level to further restrict the access to resources in general. 

A resource access security service is registered with the service property `context`. Allowed values are `application` and `provider`. If the value is missing or invalid, the service will be ignored. 

In the context of resource providers, this service might be used for those  providers where the underlying persistence layer does not implement access control. The goal is to make it easy to implement a lightweight access control for such providers. On the other hand a JCR resource providers should not use the provider context resource access security - in a JCR context, security is fully delegated to the underlying repository, and mixing security models would be a bad idea. 

In the context of the application, this service might be used to add additional or temporary constraints across the whole resource tree. It is automatically called by the Resource Resolver implementation.

# Default Implementation

To use the `ResourceAccessSecurity` service just rely on the default implementation provided by the [`resourceaccesssecurity `bundle][resourceaccesssecurity]. This adds an implementation of the `ResourceAccessSecurity` service for the provider context (`provider`) and also the application context (`application`).

Furthermore this implementation of `ResourceAccessSecurity` defines a service provider interface (SPI) named `ResourceAccessGate`. This is the service interface which you can implement and register to control the access to particular resources.

The `ResourceAccessGate` interface defines an SPI which can be used to make some restrictions for accessing resources. Implementations of this service interface must be registered like `ResourceProvider`s with a path (like `provider.roots` but with the property name `path`). If multiple `ResourceAccessGate` services match a path, not only the `ResourceAccessGate` with the longest path will be called, but all of them. That is different from the ResourceProvider logic, but in this case more logical (and more secure!). The access gates also must be registered with a context (`application` or `provider`), without a given context, the service will be ignored by ResourceAccessSecurity. The gates will be called in the order of the service ranking (from highest to lowest). If one of the gates grants access for a given operation access will be granted. An exception are the gates which are registered for `finaloperations`. If such a gate denies resource access no further gate will be asked and access will be ultimately denied (except a gate with higher service ranking has granted access).

## Service properties for `ResourceAccessGate` services

Name     |  Description | Default 
----------------- | -------------| ----- 
`path`              | Regular expression to restrict on which paths the service should be called | `.*` 
`operations`        | Set of operations on which the service should be called. Allowed string values: `read`,`create`,`update`,`delete`,`execute`,`order-children`. The value `order-children` is only supported since version 1.1.0 ([SLING-7975](https://issues.apache.org/jira/browse/SLING-7975)) | `{ "read","create","update","delete","execute","order-children"}` (all operations)
`finaloperations`   | Set of operations on which the service answer is final and no further service should be called, except the GateResult is GateResult.CANT_DECIDE. Allows the same values as `operations`. | (none)
`context`          | The resource access gate can either have the context `provider` in which case the gate is only applied to resource providers requesting the security checks or the context `application` in which case the access gate is invoked for the whole resource tree. If the property is missing or invalid, the service is ignored. | (none)

## How to implement `ResourceAccessGate`

The implementation is straightforward: The easiest way is to extend ` AllowingResourceAccessGate ` which is exported by the `resourceaccesssecurity` bundle and does not deny any access. So if you want to restrict access on resources for read operations you have to implement to following two methods:

	::java
	@Override
	public boolean hasReadRestrictions(final ResourceResolver resourceResolver) {
		return true;
	}
	
	@Override
	public GateResult canRead(final Resource resource) {
		GateResult returnValue = GateResult.CANT_DECIDE;
		if( whatever-condition ) {
			returnValue = GateResult.GRANTED;
		}
		else {
			returnValue = GateResult.DENIED;
		}
	  
		return returnValue;
	}
	
You have to register the `ResourceAccessGate` with service properties outlined above.

Tip: We do not recommend to mix up application and provider context in the same application. This can lead to confusing configurations in the ResourceAccessGate implementations.

## GateResult

GateResult does have three states:

  1. `GateResult.GRANTED`
  2. `GateResult.DENIED`
  3. `GateResult.CANT_DECIDE`

The first two of them are self-explanatory. `CANT_DECIDE` means that the actual gate neither can grant nor deny the access. If no other gate does return `GRANTED` or `DENIED` the access to the resource will be denied for security reasons. `CANT_DECIDE` comes handy if you declare `finaloperations` (where no other gate will be called after this gate). If such a gate returns `CANT_DECIDE`, further gates will be called regardless of the `finaloperations` property.

## `ResourceAccessGates` Implementations

There is an implementation of `ResourceAccessGate` provided by [bundle `org.apache.sling.jcr.resourcesecurity`][jcr-resourcesecurity] which grants/denies access based on the permissions set on a JCR node. *This should only be used for paths not provided by the JCR Resource Provider*. It is implemented as service factory so each OSGi configuration provides a dedicated `ResourceAccessGate` service.

## Limitations

By now the implementation is complete for securing access on resource level for CRUD operations. It is not yet ready to allow fine granular access rights on properties/values of a resource. So at the moment the `canReadValue, canUpdateValue, canDeleteValue` and `canCreateValue` on `ResourceAccessGate` methods are ignored ([SLING-10906](https://issues.apache.org/jira/browse/SLING-10906)).


[jcr-resourcesecurity]: https://github.com/apache/sling-org-apache-sling-jcr-resourcesecurity
[resourceaccesssecurity]: https://github.com/apache/sling-org-apache-sling-resourceaccesssecurity