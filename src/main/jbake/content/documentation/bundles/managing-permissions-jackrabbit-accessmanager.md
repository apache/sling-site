title=Managing permissions (jackrabbit.accessmanager)		
type=page
status=published
tags=security
~~~~~~


The `jackrabbit-accessmanager` bundle delivers a REST interface to manipulate users permissions in the JCR. After installing the `jackrabbit-accessmanager` bundle the REST services are exposed under the path of the node where you will manipulate the permissions for a user with a specific selector like `modifyAce`, `acl` and `deleteAce`.
[TOC]

## Privileges

| privilagename | description |
|---|---|
| jcr:read | the privilege to retrieve a node and get its properties and their values |
| jcr:readAccessControl | the privilege to get the access control policy of a node |
| jcr:modifyProperties | the privilege to create, modify and remove the properties of a node |
| jcr:addChildNodes | the privilege to create child nodes of a node |
| jcr:removeChildNodes | the privilege to remove child nodes of a node |
| jcr:removeNode | the privilege to remove a node |
| jcr:write | an aggregate privilege that contains: jcr:modifyProperties  jcr:addChildNodes  jcr:removeNode  jcr:removeChildNodes |
| jcr:modifyAccessControl | the privilege to modify the access control policies of a node |
| jcr:lockManagement | the privilege to lock and unlock a node | 
| jcr:versionManagement | the privilege to perform versioning operations on a node | 
| jcr:nodeTypeManagement | the privilege to add and remove mixin node types and change the primary node type of a node | 
| jcr:retentionManagement | the privilege to perform retention management operations on a node | 
| jcr:lifecycleManagement | the privilege to perform lifecycle operations on a node | 
| jcr:all | an aggregate privilege that contains all predefined privileges |

## Add or modify permissions

To modify the permissions for a node POST a request to `/<path-to-the-node>.modifyAce.<html or json>`. The following parameters are available:
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
* *numeric* - Place the target ACE at the specified numeric index. |


Responses:
| 200 | Success |
| 500  | Failure, HTML (or JSON) explains failure. |
Example with curl:

    curl -FprincipalId=myuser -Fprivilege@jcr:read=granted http://localhost:8080/test/node.modifyAce.html



## Delete permissions

To delete permissions for a node POST a request to `/<path-to-the-node>.deleteAce.<html or json>`. The following parameters are available:
  
  
  
  

Responses:
| 200 | Success |
| 500  | Failure, HTML (or JSON) explains failure. |
Example with curl:

    curl -F:applyTo=myuser http://localhost:8080/test/node.deleteAce.html


## Get permissions

### Bound Permissions

To get the permissions bound to a particular node in a json format for a node send a GET request to `/<path-to-the-node>.acl.json`. 

Example:

    http://localhost:8080/test/node.acl.json


### Effective Permissions

To get the permissions which are effective for a particular node in a json format for a node send a GET request to `/<path-to-the-node>.eacl.json`. 

Example:

    http://localhost:8080/test/node.eacl.json


<div class="note">
See section 16.3 of the JCR 2.0 specification for an explanation of the difference between bound and effective policies.
</div>