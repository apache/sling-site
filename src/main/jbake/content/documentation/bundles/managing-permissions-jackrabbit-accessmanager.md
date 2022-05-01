title=Managing permissions (jackrabbit.accessmanager)		
type=page
status=published
tags=security
~~~~~~


The `jackrabbit-accessmanager` bundle delivers a REST interface to manipulate users permissions in the JCR. After installing the `jackrabbit-accessmanager` bundle the REST services are exposed under the path of the node where you will manipulate the permissions for a user with a specific selector like `modifyAce`, `acl`, `eacl` and `deleteAce`.
[TOC]

## Built-in Privileges

Name | Description 
--- | ---
``jcr:all`` | aggregate that contains all defined privileges
`` ┣━ jcr:read`` | aggregate to read the node and its properties
`` ┃   ┣━ rep:readNodes`` | read the children of the node
`` ┃   ┗━ rep:readProperties`` | read properties of the node
`` ┣━ rep:write`` | aggregate that contains full write privileges
`` ┃   ┣━ jcr:write`` | aggregate that simple write privileges
`` ┃   ┃   ┣━ jcr:addChildNodes`` | create child nodes of the node
`` ┃   ┃   ┣━ jcr:modifyProperties`` | aggregate to create, modify and remove the properties of the node
`` ┃   ┃   ┃   ┣━ rep:addProperties`` | add new properties to the node
`` ┃   ┃   ┃   ┣━ rep:alterProperties`` | alter existing properties of the node
`` ┃   ┃   ┃   ┗━ rep:removeProperties`` | remove existing properties of the node
`` ┃   ┃   ┣━ jcr:removeChildNodes`` | remove child nodes of the node
`` ┃   ┃   ┗━ jcr:removeNode`` | remove the node
`` ┃   ┗━ jcr:nodeTypeManagement`` | add and remove mixin node types and change the primary node type of the node
`` ┣━ jcr:readAccessControl`` | read the access control policy of the node
`` ┣━ jcr:modifyAccessControl`` | modify the access control policies of the node
`` ┣━ rep:indexDefinitionManagement`` | manage index definitions
`` ┣━ jcr:lifecycleManagement`` | perform lifecycle operations on the node
`` ┣━ jcr:lockManagement`` | lock and unlock the node
`` ┣━ jcr:namespaceManagement`` | managed namespaces
`` ┣━ jcr:nodeTypeDefinitionManagement`` | manage node type definitions
`` ┣━ rep:privilegeManagement`` | manage privilege definitions
`` ┣━ jcr:retentionManagement`` | retention management operations on the node
`` ┣━ rep:userManagement`` | manage users and groups
`` ┣━ jcr:versionManagement`` | perform versioning operations on the node 
`` ┗━ jcr:workspaceManagement`` | manage workspaces

## Built-in Restrictions

See [Restriction Management](https://jackrabbit.apache.org/oak/docs/security/authorization/restriction.html) or [Sling Oak Restrictions](https://sling.apache.org/documentation/bundles/sling-oak-restrictions.html) for details and examples.

Name | Since
--- | ---
``rep:glob`` | Oak 1.0
``rep:ntNames`` | Oak 1.0
``rep:prefixes`` | Oak 1.0
``rep:itemNames`` | Oak 1.3.8
``rep:current`` | Oak 1.42.0
``rep:globs`` | Oak 1.44.0
``rep:subtrees`` | Oak 1.44.0
``sling:resourceTypes`` | Sling Oak Restrictions 1.0.0
``sling:resourceTypesWithDescendants`` | Sling Oak Restrictions 1.0.0

## Add or modify permissions

To modify the permissions for a node POST a request to `/<path-to-the-node>.modifyAce.<html or json>`. The following parameters are available:

Name | Since | Description
--- | --- | ---
`principalId` | | The id of the user or group to modify the access rights for
`order` | | The position of the entry within the list (see below for details)
`privilege@[privilege_name]` | | One param for each privilege to modify.  The value must be either 'allow', 'deny' or 'none'.  For backward compatibility, 'granted' or 'denied' are accepted as aliases for 'allow' or 'deny'.
`restriction@[restriction_name]` | 3.0.4 | One param for each restriction value.  The same parameter name may be used again for multi-value restrictions.  The value is the target value of the restriction.
`restriction@[restriction_name]@Delete` | 3.0.4 | One param for each restriction to delete.  The parameter value is ignored and can be anything.
`privilege@[privilege_name]@Delete` | 3.0.12 | One param for each privilege to delete. The parameter value must be either 'allow', 'deny' or 'all' to specify which state to delete from.
`restriction@[privilege_name]@[restriction_name]@Allow` | 3.0.12 | One param for each restriction value to apply to the 'allow' privilege. The same parameter name may be used again for multi-value restrictions. The value is the target value of the restriction to be set.
`restriction@[privilege_name]@[restriction_name]@Deny` | 3.0.12 | One param for each restriction value to apply to the 'deny' privilege. The same parameter name may be used again for multi-value restrictions. The value is the target value of the restriction to be set.
`restriction@[privilege_name]@[restriction_name]@Delete` | 3.0.12 | One param for each restriction to delete. The parameter value must be either 'allow', 'deny' or 'all' to specify which state to delete from.

The `order` parameter may have the following values:

 Value | Description
--- | ---
`first` | Place the target entry as the first amongst its siblings
`last` | Place the target entry as the last amongst its siblings
`before *xyz*` | Place the target entry immediately before the sibling whose name is *xyz*
`after *xyz*` | Place the target entry immediately after the sibling whose name is *xyz*
numeric | Place the target entry at the indicated numeric place amongst its siblings where *0* is equivalent to `first` and *1* means the second place

#### Parameters Conflict Resolution
*since version 3.0.12 for [SLING-11243](https://issues.apache.org/jira/browse/SLING-11243)*

The request parameters may be ambiguous or create a conflict.  Below is the steps that are taken to resolve conflicts:

1. The already existing ACE state is loaded from the repository (if any).
2. All `privilege@[privilege_name]@Delete` parameters (if any) are processed to remove the specified privileges.
3. All `restriction@[restriction_name]@Delete` and `restriction@[privilege_name]@[restriction_name]@Delete` parameters (if any) are processed to remove the specified restrictions that still exist.
4. All `privilege@[privilege_name]` parameters (if any) are processed to allow, deny or remove the privilege based on the parameter value.  When there are multiple applicable parameters, they are sorted before processing based on the longest privilege depth.  For example, privilege "rep:addProperties" (depth=4) would be processed after "jcr:modifyProperties" (depth=3) as it is considered more specific.
5. All `restriction@[privilege_name]@[restriction_name]@[Allow|Deny]` parameters (if any) are processed to update the restriction for the allow or deny privilege based on the parameter value. When there are multiple applicable parameters, they are sorted before processing based on the longest depth of the privilege.  For example, privilege "rep:addProperties" (depth=4) would be processed after "jcr:modifyProperties" (depth=3) as it is considered more specific.  Also if the allow and deny restriction for a privilege have identical values, then the allow restriction wins and the deny restriction is discarded.
6. For any privileges remaining in the set, consolidate any aggregates that have all their contained privileges set.  For example, if "rep:readNodes" and "rep:readProperties" are both set with the same restrictions, then a "jcr:read" privilege will replace those two.

Responses:

Status Code | Description
--- | ---
200 | Success
500 | Failure, HTML (or JSON) explains failure.

Example with curl:

    curl -FprincipalId=myuser -Fprivilege@jcr:read=allow http://localhost:8080/test/node.modifyAce.html

Single value restriction example:

    curl -FprincipalId=myuser -Fprivilege@jcr:read=allow -Frestriction@rep:glob=child1 http://localhost:8080/test/node.modifyAce.html

Multi value restriction example:

    curl -FprincipalId=myuser -Fprivilege@jcr:read=allow -Frestriction@rep:itemNames=name1 -Frestriction@rep:itemNames=name2 http://localhost:8080/test/node.modifyAce.html

Remove existing restriction example:

    curl -FprincipalId=myuser -Frestriction@rep:glob@Delete=yes http://localhost:8080/test/node.modifyAce.html

Allow privilege with restrictions on descendant privilege example:

    curl -FprincipalId=myuser -Fprivilege@jcr:read=allow -Frestriction@rep:readProperties@rep:glob@Allow=glob1 http://localhost:8080/test/node.modifyAce.html


### Add or modify principal based permissions
*since version 3.0.12 for [SLING-11272](https://issues.apache.org/jira/browse/SLING-11272)*

To modify the principal based permissions for a node POST a request to `/<path-to-the-node>.modifyPAce.<html or json>`. The following parameters are available:

Name | Since | Description
--- | --- | ---
`principalId` | | The id of the service user to modify the access rights for
`privilege@[privilege_name]` | | One param for each privilege to modify.  The value must be 'allow' or 'none'.
`restriction@[restriction_name]` | 3.0.4 | One param for each restriction value.  The same parameter name may be used again for multi-value restrictions.  The value is the target value of the restriction.
`restriction@[restriction_name]@Delete` | 3.0.4 | One param for each restriction to delete.  The parameter value is ignored and can be anything.
`privilege@[privilege_name]@Delete` | 3.0.12 | One param for each privilege to delete. The parameter value must be 'allow'.
`restriction@[privilege_name]@[restriction_name]@Allow` | 3.0.12 | One param for each restriction value to apply to the 'allow' privilege. The same parameter name may be used again for multi-value restrictions. The value is the target value of the restriction to be set.
`restriction@[privilege_name]@[restriction_name]@Delete` | 3.0.12 | One param for each restriction to delete. The parameter value must be 'allow' to specify which state to delete from.

NOTE: The resource path for a principal based entry does not need to exist yet to be set.  Also, a special resource path of `/:repository` can be used for setting repo-level permissions.

Responses:

Status Code | Description
--- | ---
200 | Success
500 | Failure, HTML (or JSON) explains failure.

Example with curl:

    curl -FprincipalId=myServiceUserId -Fprivilege@jcr:read=allow http://localhost:8080/test/node.modifyPAce.html

Example for repo-level permissions not for a specific resource:

    curl -FprincipalId=myServiceUserId -Fprivilege@jcr:read=allow http://localhost:8080/:repository.modifyPAce.html


## Delete permissions

To delete permissions for a node POST a request to `/<path-to-the-node>.deleteAce.<html or json>`. The following parameters are available:
  
Parameter Name | Required | Description
--- | --- | --- 
`:applyTo` | yes | An array of ids of the user or group whose permissions are to be deleted.

Responses:

Status Code | Description
--- | ---
200 | Success
500 | Failure, HTML (or JSON) explains failure.

Example with curl:

    curl -F:applyTo=myuser http://localhost:8080/test/node.deleteAce.html

### Delete principal based permissions
*since version 3.0.12 for [SLING-11272](https://issues.apache.org/jira/browse/SLING-11272)*

To delete principal based permissions for a node POST a request to `/<path-to-the-node>.deletePAce.<html or json>`. The following parameters are available:
  
Parameter Name | Required | Description
--- | --- | --- 
`:applyTo` | yes | An array of ids of the service users whose permissions are to be deleted.

Responses:

Status Code | Description
--- | ---
200 | Success
500 | Failure, HTML (or JSON) explains failure.

Example with curl:

    curl -F:applyTo=myServiceUserId http://localhost:8080/test/node.deletePAce.html

Example for repo-level permissions not for a specific resource:

    curl -FprincipalId=myServiceUserId http://localhost:8080/:repository.deletePAce.html


## Get permissions

### Defined Permissions List

To get the permissions defined on a particular node in a json format, send a GET request to `/<path-to-the-node>.acl.json`. 

Example:

    http://localhost:8080/test/node.acl.json


### Effective Permissions List

To get the permissions which are effective for a particular node in a json format, send a GET request to `/<path-to-the-node>.eacl.json`. 

Example:

    http://localhost:8080/test/node.eacl.json

<div class="note">
See section 16.3 of the JCR 2.0 specification for an explanation of the difference between bound and effective policies.
</div>


### Defined Permissions Entry
*since version 3.0.12 for [SLING-11271](https://issues.apache.org/jira/browse/SLING-11271)*

To get the permissions bound to a particular node for a specific person in a json format, send a GET request to `/<path-to-the-node>.ace.json?pid=[principalId]`. 

Parameter Name | Required | Description
--- | --- | --- 
`pid` | yes | The id of the user or group whose permissions are to be retrieved.

Responses:

Status Code | Description
--- | ---
200 | Success
404 | No entry is defined for the specified principal id
500 | Failure, HTML (or JSON) explains failure.

Example:

    http://localhost:8080/test/node.ace.json?pid=everyone


### Effective Permissions Entry
*since version 3.0.12 for [SLING-11271](https://issues.apache.org/jira/browse/SLING-11271)*

To get the permissions which are effective for a particular node and for a specific person in a json format, send a GET request to `/<path-to-the-node>.eace.json?pid=[principalId]`. 

Parameter Name | Required | Description
--- | --- | --- 
`pid` | yes | The id of the user or group whose permissions are to be retrieved.

Responses:

Status Code | Description
--- | ---
200 | Success
404 | No entry is defined for the specified principal id
500 | Failure, HTML (or JSON) explains failure.

Example:

    http://localhost:8080/test/node.eace.json?pid=everyone


### Defined Principal Based Permissions Entry
*since version 3.0.12 for [SLING-11272](https://issues.apache.org/jira/browse/SLING-11272)*

To get the principal based permissions which are defined for a particular node and for a specific person in a json format, send a GET request to `/<path-to-the-node>.pace.json?pid=[principalId]`. 

Parameter Name | Required | Description
--- | --- | --- 
`pid` | yes | The id of the service user whose principal based permissions are to be retrieved.

Responses:

Status Code | Description
--- | ---
200 | Success
404 | No entry is defined for the specified principal id
500 | Failure, HTML (or JSON) explains failure.

Example:

    http://localhost:8080/test/node.pace.json?pid=serviceUserId


## Migration from 3.x version
*since version 3.0.12 for [SLING-11233](https://issues.apache.org/jira/browse/SLING-11233)*

In the previous versions, the restriction details in the ACL json output could be ambiguous in some situations.  For [SLING-11233](https://issues.apache.org/jira/browse/SLING-11233) the 
JSON output structure was changed. The previous "granted/denied/restrictions" items in each ACE were replaced with a "privileges" structure whose items are the allow or deny privileges.  Each privilege now has a "deny" and/or "allow" child whose value is either true (no restrictions) or an array of restrictions + values.

Any code that was expecting the previous JSON structure will need to be adjusted to compensate for the new structure.

For example:

    {
      "user1":{
        "principal":"user1",
        "order":0,
        "privileges":{
          "jcr:read":{
            "allow":{
              "rep:glob":"glob1"
            }
          },
          "jcr:readAccessControl":{
            "allow":{
              "rep:itemNames":[
                "name1",
                "name2"
              ]
            }
          },
          "rep:write":{
            "deny":true
          }
        }
      }
    } 
