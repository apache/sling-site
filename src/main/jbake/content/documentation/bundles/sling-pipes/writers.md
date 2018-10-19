title=Writers
type=page
status=published
tags=pipes
~~~~~~

those pipes all are using common sling (or other) APIs to modify content. You'll probably need some [reader](/documentation/bundles/sling-pipes/readers.html)
pipes and/or [logical](/documentation/bundles/sling-pipes/logical.html) pipes first to put you into the right context. 

##### Write Pipe (`write(conf)`)
writes given nodes and properties to current input resource

- `sling:resourceType` is `slingPipes/write`
- `conf` node tree that will be copied to the current input of the pipe, each property's names and value will be written to the input resource. Input resource will be outputed. Note that properties that will be evaluated (in an expression) as `null` for a given input resource will be removed from it. E.g. `./conf/some/node@prop=${null}` will add `./conf/some/node` structure if not in current input resource, but remove its `prop` property if any).
- `expr` used if no configuration node provided: path of a content tree this will write to the current destination (basically a deep copy)  

For most of the case where you just need to write properties, pipe builder API allows you to 
e.g.
 
        .echo('/content/foo')
        .write('foo1','bar1','foo2','bar2')
    
will write `@foo1=bar1` and `@foo2=bar2` in `/content/foo`. For more complicated cases where you need a structure to be written,
just use a JCR / Resource explorer to edit the persistence of the pipe, and create the given structured under conf.

Note that using `expr` you need configuration node _not_ to be here, and {{write}} shortcut creates one systematically.
So if you want to use pipe builder and that, you'd need something like

        .echo('/content/destination')
        .pipe("slingPipes/write").expr("/content/source")
        

##### MovePipe (`mv(expr)`)
JCR move of current input to target path (can be a node or a property)

- `sling:resourceType` is `slingPipes/mv`
- `expr` full target path, note that parent path must exists

        .echo("/content/foo/old/location")
        .mv("/content/bar/new/location")

##### RemovePipe (`rm()`)
removes the input resource, returns the parent, regardless of the resource being a node, or
a property

- `sling:resourceType` is `slingPipes/rm`
- `conf` node tree that will be used to filter relative properties & subtrees to the current resource to remove.
A subnode is considered to be removed if it has no property configured, nore any child.

more common usage is just without configuration node, removing incoming resource

        .echo("/content/foo/toRemove")
        .rm() 

##### PathPipe (`mkdir(expr)`)
get or create path given in expression. Uses [ResourceUtil.getOrCreateResource](https://sling.apache.org/apidocs/sling8/org/apache/sling/api/resource/ResourceUtil.html#getOrCreateResource-org.apache.sling.api.resource.ResourceResolver-java.lang.String-java.lang.String-java.lang.String-boolean-)

- `sling:resourceType` is `slingPipes/path`
- `nodeType` node type of the intermediate nodes to create
- `autosave` should save at each creation (will make things slow, but sometimes you don't have choice)

        .mkdir("/content/foo/bar")
        
will create a `/content/foo/bar` path of `sling:Folder` nodes

##### PackagePipe (`pkg(expr)`)
will create a package and add current resource as a filter. At the end of super pipe execution, will attempt to build the package
- `sling:resourceType` is `slingPipes/package`
- `expr` package path

This example searches for folders in a given location and package them up

        .echo("/content/foo/bar")
        .$("sling:Folder")
        .pkg("/etc/packages/foobar-folders.zip")

##### AuthorizablePipe (`auth(conf)`)
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

following will give bar-users authorizable the aggregate privilege(jcr:all) on /content/foo/bar
        .echo("/content/foo/bar")
        .allow("bar-users")

following will give bar-users authorizable the specific rights to read|write on /content/foo/bar
        .echo("/content/foo/bar")
        .allow("bar-users").with("jcr:privileges",[jcr:read,jcr:write]))

and following will deny bar-users authorizable to read on /content/foo/bar
        .echo("/content/foo/bar")
        .deny("bar-users")