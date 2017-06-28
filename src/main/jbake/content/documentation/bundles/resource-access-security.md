title=Resource Access Security		
type=page
status=published
~~~~~~
Notice:    Licensed to the Apache Software Foundation (ASF) under one
           or more contributor license agreements.  See the NOTICE file
           distributed with this work for additional information
           regarding copyright ownership.  The ASF licenses this file
           to you under the Apache License, Version 2.0 (the
           "License"); you may not use this file except in compliance
           with the License.  You may obtain a copy of the License at
           .
             http://www.apache.org/licenses/LICENSE-2.0
           .
           Unless required by applicable law or agreed to in writing,
           software distributed under the License is distributed on an
           "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
           KIND, either express or implied.  See the License for the
           specific language governing permissions and limitations
           under the License.

## Summary
The ResourceAccessSecurity service allows it to restrict access to resources. The access can be granted or denied for read, create, update and delete actions.

The ResourceAccessSecurity defines a service API which is used in two different context: for securing resource providers which have no own access control and on the application level to further restrict the access to resources in general. 

A resource access security service is registered with the service property “context”. Allowed values are “application” and “provider”. If the value is missing or invalid, the service will be ignored. 

In the context of resource providers, this service might be used for implementations of resource providers where the underlying persistence layer does not implement access control. The goal is to make it easy to implement a lightweight access control for such providers. For example, a JCR resource providers should not use the provider context resource access security - in a JCR context, security is fully delegated to the underlying repository, and mixing security models would be a bad idea. 

In the context of the application, this service might be used to add additional or temporary constraints across the whole resource tree. 

## How to use ResourceAccessSecurity
To use the ResourceAccessSecurity service you don’t have to implement the interface ResourceAccessSecurity. Simply add the resourceaccesssecurity bundle to your sling instance. This adds an implementation of the ResourceAccessSecurity service for the provider context (“provider”) and also the application context (“application”).

Furthermore the implementation of ResourceAccessSecurity defines a service provider interface named ResourceAccessGate. This is the service interface which you can implement and register to control the access to the resources.

The ResourceAccessGate defines a service API which can be used to make some restrictions to accessing resources. Implementations of this service interface must be registered like ResourceProvider with a path (like provider.roots but with the property name “path”). If different ResourceAccessGate services match a path, not only the ResourceAccessGate with the longest path will be called, but all of them, that's in contrast to the ResourceProvider, but in this case more logical (and secure!). The access gates also must be registered with a context (“application” or “provider”), without a given context, the service will be ignored by ResourceAccessSecurity. The gates will be called in the order of the service ranking. If one of the gates grants access for a given operation access will be granted. An exception are the gates which are registered for “finaloperations”. If such a gate denies resource access no further gate will be asked and access denied (except a gate with higher service ranking has granted access).

### Service properties

Property name     |  description
----------------- | ----------------------- 
Path              | regexp to define on which paths the service should be called (default .*) 
operations        | set of operations on which the service should be called ("read,create,update,delete,execute", default all of them) 
finaloperations   | set of operations on which the service answer is final and no further service should be called (default none of them), except the GateResult is GateResult.CANT_DECIDE 
context           | “provider” or “application”. The resource access gate can either have the context “provider”, in this case the gate is only applied to resource providers requesting the security checks. Or the context can be “application”. In this case the access gate is invoked for the whole resource tree. This is indicated by the required service property “context”. If the property is missing or invalid, the service is ignored.

### How to implement ResourceAccessGate
The implementation is straightforward. The easiest way is to extend ` AllowingResourceAccessGate ` which is exported by the resourceaccesssecurity bundle and does not deny any access. So if you wan’t restrict access on resources for read operations you have to implement to following two methods:

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
	
And you have to register the ResourceAccessGate with the path where you wan’t to restrict access and the operation property set to “read”. Furthermore you have to decide if the ResourceAccessGate should operate on all resource providers (context=”application”) or only on the resourceproviders flagged with the property useResourceAccessSecurity=true (context=”provider”).

Tip: We do not recommend to mix up application and provider context in the same application. This can lead to confusing configurations in the ResourceAccessGate implementations.

### GateResult
GateResult does have three states:

  - GateResult.GRANTED
  - GateResult.DENIED
  - GateResult.CANT_DECIDE

The first two of them are self-explanatory. CANT_DECIDE means that the actual gate neither can grant nor deny the access. If no other gate does return GRANTED or DENIED the access to the resource will be denied for security reasons. CANT-DECIDE comes handy if you declare finaloperations (where no other gate will be called after this gate). If such a gate returns CANT_DECIDE, further gates will be called regardless of the setted finaloperations property.

## Actual state of ResourceAccessSecurity
By now the implementation is complete for securing access on resource level for CRUD operations. It is not yet ready to allow fine granular access rights on values of a resource. So at the moment the `canReadValue, canUpdateValue, canDeleteValue` and `canCreateValue` on `ResourceAccessGate` methods are ignored.
