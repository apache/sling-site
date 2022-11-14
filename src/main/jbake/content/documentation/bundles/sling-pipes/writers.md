title=Writers
type=page
status=published
tags=pipes
~~~~~~

those pipes all are using common sling (or other) APIs to modify content. You'll probably need some [reader](/documentation/bundles/sling-pipes/readers.html)
pipes and/or [logical](/documentation/bundles/sling-pipes/logical.html) pipes first to put you into the right context. 

##### Write Pipe (`write <...>`)
writes given nodes and properties to current input resource
 
        echo /content/foo | write foo1=bar1 foo2=2 foo3=true foo4=one.old foo5=timeutil.of('2018-05-05T11:50:55+02:00')
    
will write `@foo1='bar1'`, `@foo2=2`, `@foo3=true`, [`@foo4=${one.old}`](/documentation/bundles/sling-pipes/bindings.html),
 and @foo5 being a Date property in `/content/foo`. 
 
Another handy usage is to copy whole tree sections, using the expr configuration

        echo /content/tree/to/copy/to | write @ expr /content/tree/to/copy/from

Finally, for more complicated cases where you need a structure to be written, you can use  JCR / Resource explorer to edit the 
"compiled" persistence of the pipe, and create the given structured under conf.
- `sling:resourceType` is `slingPipes/write`
- `conf` node tree that will be copied to the current input of the pipe, each property's names and value will be written to the input resource. Input resource will be outputed. Note that properties that will be evaluated (in an expression) as `null` for a given input resource will be removed from it. E.g. `./conf/some/node@prop=${null}` will add `./conf/some/node` structure if not in current input resource, but remove its `prop` property if any).  

Note that you can use expressions in that node tree, and specifically, for a node name, parent of a tree you want to
be conditionally written, use `$if${...}nodename` syntax, that will basically only create such tree if the expression is true.
        
##### MovePipe (`mv <expr>`)
JCR move of current input to target path (can be a node or a property)

        echo /content/foo/old/location | mv /content/bar/new/location

following will move resource at `/content/foo/old/oldlocation` to under `/content/bar/new` before `newlocation`

        echo /content/foo/old/oldlocation | mv /content/bar/new/newlocation @ with orderBeforeTarget=true

following will move resource at `/content/foo/old/oldlocation` to `/content/bar/new/newlocation` and overwrite `newlocation`

        echo /content/foo/old/oldlocation | mv /content/bar/new/newlocation @ with overwriteTarget=true

##### RemovePipe (`rm`)
removes the input resource, returns the parent, regardless of the resource being a node, 

        echo /content/foo/nodeToRemove | rm 

or a property
    
        echo /content/foo/node/propertyToRemove | rm

for more complex use cases, where you need to remove several resources in a row, at different level of a subtree,
you can use the "compiled" persistence, where
- `sling:resourceType` is `slingPipes/rm`
- `conf` node tree that will be used to filter relative properties & subtrees to the current resource to remove.
A subnode is considered to be removed if it has no property configured, nore any child.

##### PathPipe (`mkdir <expr>`)
get or create path given in expression. Uses [ResourceUtil.getOrCreateResource](https://sling.apache.org/apidocs/sling8/org/apache/sling/api/resource/ResourceUtil.html#getOrCreateResource-org.apache.sling.api.resource.ResourceResolver-java.lang.String-java.lang.String-java.lang.String-boolean-)

        mkdir /content/folders/to/create

will create a `/content/folders/to/create` path of `sling:Folder` nodes

        echo /content/folders/to/create | mkdir childWithDifferentType @ with nodeType=nt:unstructured        

will create a child with `nt:unstructured` node type.

##### PackagePipe (`pkg <expr>`)
will create a package and add current resource as a filter. At the end of super pipe execution, will attempt to build the package

This example searches for folders in a given location and package them up

        echo /content/foo/bar | $ sling:Folder | pkg /etc/packages/foobar-folders.zip

##### AuthorizablePipe (`auth (conf)`)
retrieve authorizable resource corresponding to the id passed in expression, or if not found (or void expression),
from the input path, output the found authorizable's resource
caution this pipe **can modify content** in case additional configuration is added (see below)

- `sling:resourceType` is `slingPipes/authorizable`
- `expr` should be an authorizable id, or void (but then input should be an authorizable)
- `autoCreateGroup` (boolean) if autorizable id is here, but the authorizable not present, then create group with given id (in that case, considered as a write pipe)
- `addMembers` (stringified json array) if authorizable is a group, add instanciated members to it (in that case, considered as a write pipe)
- `addToGroup` (expression) add found authorizable to instanciated group (in that case, considered as a write pipe)
- `bindMembers` (boolean) if found authorizable is a group, bind the members (in that case, considered as a write pipe)

This example creates a group
        
        .auth("createGroup", true).expr("foo-bar")

This example searches for users in a given location and add them to `foo-bar` group

        .echo("/home/users/foo")
        .$("rep:User")
        .auth("addToGroup", "foo-bar")

In this example, auth is not writing anything but makes use of bind members and json to create one content tree per admin

        .auth("bindMembers",true).expr("administrators")
        .json('${one}')
        .mkdir('/content/admin-users/${two}')
        
##### ACLPipe (`acls(), allow(expr), deny(expr)`)
either output ACL of current resource in the output bindings, or allow / deny default or configured privileges for the authorizable
passed as the expression

- `sling:resourceType` is `slingPipes/acl`
- `expr` should be an authorizable id, or void
- `allow` (boolean) to allow some privileges for configured authorizable
- `deny` (boolean) to deny some privileges for configured authorizable

following will give bar-users authorizable the aggregate privilege (jcr:all) on /content/foo/bar

        echo /content/foo/bar | allow bar-users

following will give bar-users authorizable the specific rights to read|write on /content/foo/bar

        .echo("/content/foo/bar")
        .allow("bar-users").with("jcr:privileges",[jcr:read,jcr:write]))

and following will deny bar-users authorizable to read on /content/foo/bar

        echo /content/foo/bar | deny bar-users