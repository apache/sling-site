title=Managing users and groups (jackrabbit.usermanager)		
type=page
status=published
~~~~~~

The `jackrabbit-usermanager` bundle delivers a REST interface to create, update and delete users and groups in the JCR. After installing the `jackrabbit-usermanager` bundle all REST services are exposed under the path `/system/userManager`. Its interface for modifing/creating authorizables is similar to the [SlingPostServlet](/documentation/bundles/manipulating-content-the-slingpostservlet-servlets-post.html).

For getting information about existing authorizables it provides all authorizables as Sling resources through its `AuthorizableResourceProvider` below `/system/userManager/user` and `/system/userManager/group`. Those resources can be exposed via the [Default GET Servlet](/documentation/bundles/rendering-content-default-get-servlets.html).

[TOC]

## List users

To list existing users a GET request to the `/system/userManager/user` resource can be issued. Depending on the configuration of the [Default GET Servlet](/documentation/bundles/rendering-content-default-get-servlets.html)
 and/or the availability of a Servlet or Script handling the `sling/users` resource type, a result may be delivered/

Example with curl and the default JSON rendering:

    $ curl http://localhost:8080/system/userManager/user.tidy.1.json
    {
      "admin": {
        "memberOf": [],
        "declaredMemberOf": []
      },
      "anonymous": {
        "memberOf": [],
        "declaredMemberOf": []
      }
    }


## Get user
*since version 2.0.8*
The properties of a single user can be retrieved by sending a GET request to the user's resource at `/system/userManager/user/<username>` where `<username>` would be replaced with the name of the user.  Depending on the configuration of the [Default GET Servlet](/documentation/bundles/rendering-content-default-get-servlets.html) and/or the availability of a Servlet or Script handling the `sling/user` resource type, a result may be delivered.

Example with curl and the default JSON rendering:

    $ curl http://localhost:8080/system/userManager/user/admin.tidy.1.json
    {
        "memberOf": [],
        "declaredMemberOf": []
    }


If a non-existing user is requested a `404/NOT FOUND` status is sent back.


## Create user

To create a new user POST a request to `/system/userManager/user.create.<html or json>`. The following parameters are available:
  
Parameter Name | Required | Description
--- | --- | --- 
`:name` | yes | The name of the new user
`pwd` | yes | The password of the new user
`pwdConfirm` | yes | The password of the new user (must be equal to the value of `pwd`)  
`<anyproperty>` | no | Additional parameters will be stored as node properties in the JCR. Nested properties are supported since 2.2.6 ([SLING-6747](https://issues.apache.org/jira/browse/SLING-6747)).
  
Responses:

Status Code | Description
--- | ---
200 | Success, a redirect is sent to the users resource locator with HTML (or JSON) describing status.
500 | Failure, including user already exists. HTML (or JSON) explains failure.

Example with curl:

    curl -F:name=myuser -Fpwd=password -FpwdConfirm=password -Fanyproperty1=value1 \
        http://localhost:8080/system/userManager/user.create.html



## Update user

To update an existing user POST a request to `/system/userManager/user/username.update.<html or json>`. You can NOT update the username or the password (see Change Password below) only the additional properties are updateable through this URL. The following parameters are available:
  
Parameter Name | Required | Description
--- | --- | --- 
`:disabled` | no | (since version 2.1.1) If `true` disables the user to block further login attempts. If `false` enables a disabled user.
`:disabledReason` | no | Specifies the reason why a user has been disabled.  
`<anyproperty>` | no | Additional parameters will be stored as node properties in the JCR. Nested properties are supported since 2.2.6 ([SLING-6747](https://issues.apache.org/jira/browse/SLING-6747)). 
`<anyproperty>@Delete` | no | Properties with @Delete at the end of the name will be deleted in the JCR. Nested properties are supported since 2.2.6 ([SLING-6747](https://issues.apache.org/jira/browse/SLING-6747)). 
  
Responses:

Status Code | Description
--- | ---
200 | Success, a redirect is sent to the users resource locator with HTML (or JSON) describing status.
404 | User was not found.
500 | Any other failure. HTML (or JSON) explains failure.
  
Example

    curl -Fanyproperty1@Delete -Fproperty2=value2 \
        http://localhost:8080/system/userManager/user/myuser.update.html


## Change password

To change a password of an existing user POST a request to `/system/userManager/user/username.changePassword.<html or json>`. NOTE: since version 2.1.1, the oldPwd is optional if the current user is a user administrator.  The following parameters are available:
  
Parameter Name | Required | Description
--- | --- | --- 
`oldPwd` | yes | Old password.
`newPwd` | yes | New password.
`newPwdConfirm` | yes | New password (must be equal to the value of `newPwd`).
  
Responses:

Status Code | Description
--- | ---
200 | Success, no body.
404 | User was not found.
500 | Any other failure. HTML (or JSON) explains failure.  
  
Example

    curl -FoldPwd=oldpassword -FnewPwd=newpassword -FnewPwdConfirm=newpassword \
        http://localhost:8080/system/userManager/user/myuser.changePassword.html


## Delete user

To delete an existing user POST a request to `/system/userManager/user/username.delete.<html or json>`. The following parameters are available:
  
Parameter Name | Required | Description
--- | --- | --- 
`:applyTo` | no | An array of relative resource references to users to be deleted. If this parameter is present, the username from the URL is ignored and all listed users are removed.
  
Responses:

Status Code | Description
--- | ---
200 | Success, no body.
404 | User(s) was/were not found.
500 | Any other failure. HTML (or JSON) explains failure.    
  
Example

    curl -Fgo=1 http://localhost:8080/system/userManager/user/myuser.delete.html


## List groups

To list existing groups a GET request to the `/system/userManager/group` resource can be sent. Depending on the configuration of the [Default GET Servlet](/documentation/bundles/rendering-content-default-get-servlets.html) and/or the availability of a Servlet or Script handling the `sling/groups` resource type, a result may be delivered.

Example with curl and the default JSON rendering:

    $ curl http://localhost:8080/system/userManager/group.tidy.1.json
    {
      "UserAdmin": {
        "members": [],
        "declaredMembers": [],
        "memberOf": [],
        "declaredMemberOf": []
      },
      "GroupAdmin": {
        "members": [],
        "declaredMembers": [],
        "memberOf": [],
        "declaredMemberOf": []
       },
      "administrators": {
        "members": [],
        "declaredMembers": [],
        "memberOf": [],
        "declaredMemberOf": []
    }
    }


## Get group

The properties of a single group can be retrieved by sending a GET request to the group's resource at `/system/userManager/group/groupname` where *groupname* would be replaced with the name of the group.  Depending on the configuration of the [Default GET Servlet](/documentation/bundles/rendering-content-default-get-servlets.html) and/or the availability of a Servlet or Script handling the `sling/group` resource type, a result may be delivered.

Example with curl and the default JSON rendering:

    $ curl http://localhost:8080/system/userManager/group/administrators.tidy.1.json
    {
        "members": [],
        "declaredMembers": [],
        "memberOf": [],
        "declaredMemberOf": []
    }


If a non-existing group is requested a 404/NOT FOUND status is sent back.


## Create group

To create a new group POST a request to `/system/userManager/group.create.<html or json>`. The following parameters are available:
  
  
Parameter Name | Required | Description
--- | --- | --- 
`:name` | yes | The name of the new group 
`<anyproperty>` | no | Additional parameters will be stored as node properties in the JCR. Nested properties are supported since 2.2.6 ([SLING-6747](https://issues.apache.org/jira/browse/SLING-6747)).
  
Responses:

Status Code | Description
--- | ---
200 | Success, a redirect is sent to the group resource locator with HTML (or JSON) describing status
500 | Failure including group already exists. HTML (or JSON) explains failure.   
  
  
Example with curl:

    curl -F:name=mygroup -Fanyproperty1=value1 \
        http://localhost:8080/system/userManager/group.create.html


## Update group

To update an existing group POST a request to `/system/userManager/group/groupname.update.<html or json>`. You can NOT update the name of the group only the additional properties are updateable. The following parameters are available:
  
Parameter Name | Required | Description
--- | --- | --- 
`:member` | no | user(s) (name or URI) to add to the group as a member. Can also be an array of users.
`:member@Delete` | no | user(s) (name or URI) to remove from the group. Can also be an array of users. 
`<anyproperty>` | no | Additional parameters will be stored as node properties in the JCR. Nested properties are supported since 2.2.6 ([SLING-6747](https://issues.apache.org/jira/browse/SLING-6747)).
`<anyproperty>@Delete` | no | Properties with @Delete at the end of the name will be deleted in the JCR. Nested properties are supported since 2.2.6 ([SLING-6747](https://issues.apache.org/jira/browse/SLING-6747)). 
  
Responses:

Status Code | Description
--- | ---
200 | Success, a redirect is sent to the group resource locator with HTML (or JSON) describing status.
404 | Group was not found.
500 | Any other failure. HTML (or JSON) explains failure.       
  
  
Example

    curl -Fanyproperty1@Delete -Fproperty2=value2 -F ":member=/system/userManager/user/myuser" \
        http://localhost:8080/system/userManager/group/mygroup.update.html


## Delete group

To delete an existing group POST a request to `/system/userManager/group/groupname.delete.<html or json>`. The following parameters are available:

Parameter Name | Required | Description
--- | --- | --- 
`:applyTo` | no | An array of relative resource references to groups to be deleted. If this parameter is present, the name of the group from the URL is ignored and all listed groups are removed. 
  
Responses:

Status Code | Description
--- | ---
200 | Success, sent with no body.
404 | Group(s) was/were not found.
500 | Any other failure. HTML (or JSON) explains failure.   
  
Example

    curl -Fgo=1 http://localhost:8080/system/userManager/group/mygroup.delete.html


## Automated Tests

The [launchpad/testing](http://svn.apache.org/repos/asf/sling/trunk/launchpad/testing/src/test/java/org/apache/sling/launchpad/webapp/integrationtest/accessManager/) module contains test classes for various operations of the `jackrabbit-usermanager`. Such tests run as part of our continuous integration process, to demonstrate and verify the behavior of the various operations, in a way that's guaranteed to be in sync with the actual Sling core code. If you have an idea for additional tests, make sure to let us know\!

## Permissions checking from scripts

*Since Version 2.0.6*

When developing scripts that will perform user or group updates, you may want to know what actions the current user is provisioned to do.  This information can be used to conditionally render parts of your page differently based on the user rights.

The jackrabbit.usermanager bundle provides a service (AuthorizablePrivilegesInfo) you can utilize to do help with this permission checking.

The AuthorizablePrivilegesInfo provides methods for checking the following actions

| Method | Description |
|---|---|
| `canAddUser(jcrSession)` | Checks if the current user may add new users |
| `canAddGroup(jcrSession)` | Checks if the current user may add new groups |
| `canUpdateProperties(jcrSession, principalId)` | Checks if the current user may update the properties of the specified principal |
| `canRemove(jcrSession, principalId)` | Checks if the current user may remove the specified user or group |
| `canUpdateGroupMembers(jcrSession, groupId)` | Checks if the current user may modify the membership of the specified group |


Example:

    <%
        // lookup the service
        var privilegesInfo = sling.getService(Packages.org.apache.sling.jackrabbit.usermanager.AuthorizablePrivilegesInfo);
    
        if (privilegesInfo.canAddUser(currentSession)) {
            //TODO: render the UI that allows the user to add a user here
        }
    
        if (privilegesInfo.canAddGroup(currentSession)) {
            //TODO: render the UI that allows the user to add a group here
        }
    
        if (privilegesInfo.canUpdateProperties(currentSession, "someUserId")) {
            //TODO: render the UI that allows the user to update the properties of the user here
        }
    
        if (privilegesInfo.canRemove(currentSession, "someUserId")) {
            //TODO: render the UI that allows the user to remove the user here
        }
    
        if (privilegesInfo.canUpdateGroupMembers(currentSession, "GroupName")) {
            //TODO: draw your UI that allows the user to update the group memebership here
        }
    %>



## Sample User Interface Implementation

*Since Version 2.1.1*

A sample implementation of ui pages for user/group management is provided @ [http://svn.apache.org/viewvc/sling/trunk/samples/usermanager-ui/](http://svn.apache.org/viewvc/sling/trunk/samples/usermanager-ui/).
