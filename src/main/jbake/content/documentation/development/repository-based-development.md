title=Repository Based Development		
type=page
status=published
tags=development,repository
~~~~~~

[TOC]

# WebDAV Support

WebDAV support in Sling is based on the [Simple WebDAV](http://jackrabbit.apache.org/jcr/components/jackrabbit-jcr-server.html#Simple_Webdav_Server) implementation of Apache Jackrabbit which is integrated in the `jcr/webdav` project. This bundle provides WebDAV access to Sling's repository in two flavours: 

1. Access to all workspaces of the repository on a separate URI space -- by default rooted at `/dav` in the Sling context -- and 
2. access to the workspace used by Sling itself at the root of the Sling context.


## Example

Consider Sling be installed on a Servlet container in the `/sling` context on `some.host.net:8080`. Here you would access the Sling workspace by directing your WebDAV client to the URL `http://some.host.net:8080/sling`. To access the `sample` workspace, which is not used by Sling itself, you would direct your WebDAV client to the URL `http://some.host.net:8080/sling/dav/sample`.

Please note that accessing the repository in the separate URI space is actually faster, since requests do not pass the Sling resource and script resolution framework but instead hit the Jackrabbit Simple WebDAV Servlet directly.


## Separate URI Space WebDAV 

When accessing the repository through WebDAV in its separate URI Space, the URLs have the following generic structure:

    <slingroot>/<prefix>/<workspace>/<item>


   * `slingroot` is the URL of the Sling web application context. In the above example, this would `http://some.host.net:8080/sling`.
   * `prefix` is the URL prefix to address the WebDAV servlet. By default this is set to `/dav` but may be configured to any valid path.
   * `workspace` is the name of the workspace to be accessed through WebDAV.
   * `item` is the path to the JCR Item to access.

If you access the WebDAV server at the prefix path -- e.g. `http://localhost:8080/dav` -- you will be redirected to the default workspace with a temporary redirect status 302. Some clients, such as the Linux *davfs*, do not like this redirection and must be configured to explicitly address the default workspace.


## Configuration

The Jackrabbit Simple WebDAV support in Sling has the following configuration options:

Property | Default | Description
---- | ---- | ----
Root Path | `/dav` | The root path at which the Simple WebDAV Servlet is accessible. Access to the repository is provided in two ways. You may connect your WebDAV client directly to the root of the Sling web application to access the workspace of Sling directly. The other way is required if you want to connect your WebDAV client to any other workspace besides the Sling workspace. In this case you connect your WebDAV client to another a path comprised of this root path plus the name of the workspace. For example to connect to the `some*other` workspace, you might connect to `http://slinghost/dav/some*other`.
Authentication Realm | `Sling WebDAV` | The name of the HTTP Basic Authentication Realm presented to the client to ask for authentication credentials to access the repository.
Non Collection Node Types | `nt:file`, `nt:resource` | The JCR Node Types considered being non-collection resources by WebDAV. Any node replying `true` to `Node.isNodeType()` for one of the listed types is considered a non-collection resource. Otherwise the respective node is considered a collection resource.
Filter Prefixes | `jcr`, `rep` | A list of namespace prefixes indicating JCR items filtered from being reported as collection members or properties. The default list includes jcr and rep (Jackrabbit internal namespace prefix) items. Do not modify this setting unless you know exactly what you are doing.
Filter Node Types | -- | Nodetype names to be used to filter child nodes. A child node can be filtered if the declaring nodetype of its definition is one of the nodetype names specified in the nodetypes Element. E.g. defining rep:root as filtered nodetype would result in `jcr:system` being hidden but no other child node of the root node, since those are defined by the nodetype nt:unstructered. The default is empty. Do not modify this setting unless you know exactly what you are doing.
Filter URIs | -- | A list of namespace URIs indicating JCR items filtered from being reported as collection members or properties. The default list is empty. Do not modify this setting unless you know exactly what you are doing.
Collection Primary Type | `sling:Folder` | The JCR Primary Node Type to assign to nodes created to reflect WebDAV collections. You may name any primary node type here, provided it allows the creation of nodex of this type and the defined Non-Collection Primary Type below it.
Non-Collection Primary Type | `nt:file` | The JCR Primary Node Type to assign to nodes created to reflect WebDAV non-collection resources. You may name any primary node type here, provided the node type is allowed to be created below nodes of the type defined for the Collection Primary Type and that a child node with the name `jcr:content` may be created below the non-collection resource whose type is defined by the Content Primary Type.
Content Primary Type | `nt:resource` | The JCR Primary Node Type to assign to the jcr:content child node of a WebDAV non-collection resource. You may name any primary node type here, provided the node type is allowed to be created as the jcr:content child node of the node type defined by the Non-Collection Primary Type. In addition the node type must allow at least the following properties: jcr:data (binary), jcr:lastModified (date), and jcr:mimeType (string).

## Advanced Technical Details

Since the Jackrabbit Simple WebDAV Servlet is originally configured using an XML configuration file, which provides a great deal of flexibility, the integration into Sling had to assume some simplifications, of which some of the above parameters are part:

### IOManager

This implementation uses the standard `org.apache.jackrabbit.server.io.IOManagerImpl` class and adds the `org.apache.jackrabbit.server.io.DirListingExportHandler` and `org.apache.jackrabbit.server.io.DefaultHandler` IO handlers as its only handlers. The `DefaultHandler` is configured from the three node types listed as configuration parameters above (collection, non-collection, and content primary node types).

### PropertyManager

This implementation uses the standard `org.apache.jackrabbit.server.io.PropertyManagerImpl` and adds the same `DirListingExportHandler` and `DefaultHanlder` instances as its own handlers as are used by the IO Manager.

### ItemFilter

This implementation uses the standard `org.apache.jackrabbit.webdav.simple.DefaultItemFilter` implementation as its item filter and configures the filter with the namespace prefixes and URIs as well as the node types configured as parameters.

### Collection Node Types

This implementation only supports listing node types which are considered representing non-collection resources. All nodes which are instances of any of the configured node types are considered non-collection resources. All other nodes are considere collection resources.

# DavEx Support

[DavEx](https://wiki.apache.org/jackrabbit/RemoteAccess) (WebDAV with JCR Extensions) allows to remotely access a JCR repository. Sling provides support based on the [JCR WebDAV Server](http://jackrabbit.apache.org/jcr/components/jackrabbit-jcr-server.html#JCR_Webdav_Server) implementation of Apache Jackrabbit which is integrated in the `jcr/davex` project. By default the server listens on request urls starting with `/server`.


# Eclipse plugin for JCR

see [Sling IDE Tooling](/documentation/development/ide-tooling.html)
