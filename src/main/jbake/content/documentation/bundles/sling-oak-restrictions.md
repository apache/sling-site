title=Sling Oak Restrictions		
type=page
status=published
~~~~~~
[TOC]


## Introduction
Oak introduced plugability of restrictions as described in [Oak Restriction Management](https://jackrabbit.apache.org/oak/docs/security/authorization/restriction.html#Pluggability). The bundle sling-oak-restrictions provides additional restrictions that generally make sense for sling applications. Currently sling restrictions for exact resource type match and resource type match including all descendants are supplied.

**Important:** Using the sling restrictions (as well as standard oak restrictions) is not as performant as simple path based ACE entries without any restrictions. Permission setups should always mostly work with path based ACEs and only use ACEs with restrictions for special cases. 

## Restriction sling:resourceTypes
This restriction allows to match against a sling resource type of a node and works much like the oak standard restriction `rep:ntNames`. Only resources that have one of the supplied resource types are matched, child and parent resources with other resource types are not matched. 

The following example allows `myAuthorizable` to write to all nodes that have either resource type `myproj/comp1` or `myproj/comp2`:

    - /content/myprj/mynode 
       - rep:policy (rep:ACL)
         - allow (rep:GrantACE)
           + principalName (String) = "myAuthorizable"
           + rep:privileges (Name[]) = "rep:write"
           - rep:restrictions (rep:Restrictions)
              + sling:resourceTypes (String[]) = [myproj/comp1,myproj/comp2]


Assuming the following structure

    - /content/myprj 
       + sling:resourceType (String) = "myproj/siteroot"
       - mynode
         + sling:resourceType (String) = "myproj/comp1"
         - mysubnode 
           + sling:resourceType (String) = "myproj/comp3"


the rule from above will match `/content/myprj/mynode` and not `/content/myprj` (parent) nor `/content/myprj/mynode/mysubnode` (child).

Naturally (as with any oak restrictions), the rule is limited to its base path. In case the node `/content/myprj/othernode` is of resource type `myproj/comp1`, it will still not match.

## Restriction sling:resourceTypesWithDescendants
This restriction matches against resource types in the same way as [sling:resourceTypes](#restriction-slingresourcetypes), except that it will also match all descendants of a matched node.

The following example allows `myAuthorizable` to write to all nodes that have either resource type `myproj/comp1` or `myproj/comp2` **or are a child of a node, that has one of these resource types**:

    - /content/myprj/mynode 
       - rep:policy (rep:ACL)
         - allow (rep:GrantACE)
           + principalName (String) = "myAuthorizable"
           + rep:privileges (Name[]) = "rep:write"
             - rep:restrictions (rep:Restrictions)
               + sling:resourceTypesWithDescendants (String[]) = [myproj/comp1,myproj/comp2]


Assuming the structure example as mentioned in [sling:resourceTypes](#restriction-slingresourcetypes), the rule from above will match `/content/myprj/mynode` and `/content/myprj/mynode/mysubnode` (and any other subnodes of `/content/myprj/mynode` with arbitrary resource types), but not `/content/myprj`.

## Advanced Path Matching
Both [sling:resourceTypes](#restriction-slingresourcetypes) and [sling:resourceTypesWithDescendants](#restriction-slingresourcetypeswithdescendants) support advanced path matching by using `resourcetype@path`. That way instead of checking the resource type of the current node, the resource type of node at the relative path is checked. For instance this is useful for the case where page content is stored in a `jcr:content` subnode of a hierarchy, the permission however is required to become effective on the parent node of `jcr:content`. 

The following example allows `myAuthorizable` to write to all nodes that have a subnode `jcr:content` with resource type `myproj/comp1` or `myproj/comp2` including their descendants:

    - /content/myprj/mynode 
       - rep:policy (rep:ACL)
         - allow (rep:GrantACE)
           + principalName (String) = "myAuthorizable"
           + rep:privileges (Name[]) = "rep:write"
           - rep:restrictions (rep:Restrictions)
              + sling:resourceTypesWithDescendants (String[]) = [myproj/comp1@jcr:content,myproj/comp2@jcr:content]

Assuming the following structure

    - /content/myprj 
       - jcr:content 
          + sling:resourceType (String) = "myproj/siteroot"
       - mynode1
         - jcr:content 
            + sling:resourceType (String) = "myproj/comp1"
         - mysubnode1 
           - jcr:content 
              + sling:resourceType (String) = "myproj/comp3"
              - contentsubnode1 
                + sling:resourceType (String) = "myproj/comp4"
              - contentsubnode2
                + sling:resourceType (String) = "myproj/comp5"
         - mysubnode2 
           - jcr:content 
              + sling:resourceType (String) = "myproj/comp3"
       - mynode2
         - jcr:content 
            + sling:resourceType (String) = "myproj/comp7"

the rule from above will match 

* `/content/myprj/mynode1` (because of the `@jcr:content` part of `myproj/comp1@jcr:content`)
* `/content/myprj/mynode1/jcr:content` (it will check for `/content/myprj/mynode1/jcr:content/jcr:content` that does not exist, but since the parent `/content/myprj/mynode1` is already a match this matches because of `sling:resourceTypesWithDescendants`)
* `/content/myprj/mynode1/contentsubnode1` (because of `sling:resourceTypesWithDescendants`)
* `/content/myprj/mynode1/contentsubnode1` (because of `sling:resourceTypesWithDescendants`)

and not match

* `/content/myprj` 
* `/content/myprj/mynode2` 

