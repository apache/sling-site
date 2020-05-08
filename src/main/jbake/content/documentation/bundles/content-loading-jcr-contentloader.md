title=Content Loading and Nodetype Support (jcr.contentloader)		
type=page
status=published
tags=contentloading,nodetypes
~~~~~~

Apache Sling provides support for initial content loading into a repository and for registering node types. The `sling-jcr-contentloader` bundle provides loading of content from a bundle into the repository and the `sling-jcr-base` bundle provides node type registration. See [Content-Package based development](/documentation/development/content-packages.html) for an alternative for deploying content to the repository.

## Initial Content Loading

Bundles can provide initial content, which is loaded into the repository when the bundle has entered the *started* state. Such content is expected to be contained in the bundles accessible through the Bundle entry API methods. Content to be loaded is declared in the `Sling-Initial-Content` bundle manifest header. This header takes a comma-separated list of bundle entry paths. Each entry and all its child entries are accessed and entered into starting with the child entries of the listed entries.

Adding this content preserves the paths of the entries as shown in this table, which assumes a `Sling-Initial-Content` header entry of `SLING-INF/content` (with no further directives):

| Source Entry Paths in Bundle | Target Repository Path |
|---|---|
| `SLING-INF/content/home` | `/home` |
| `SLING-INF/content/content/playground/en/home` | `/content/playground/en/home` |
| `SLING-INF/someothercontent/playground/en/home` | not installed at all, because not below the `Sling-Initial-Content` header entry | 

Bundle entries are installed as follows:

| Entry Type | Installation method |
|---|---|
| Directory | Created as a node of type `sling:Folder` unless a content definition file of the same name exists in the same directory as the directory to be installed. Example: A directory `SLING-INF/content/dir` is installed as node `/dir` of type `nt:folder` unless a `SLING-INF/content/dir.xml` or `SLING-INF/content/dir.json` file exists which defines the content for the `/dir` node. |
| File | Unless the file is a content definition file (see below) an `nt:file` node is created for the file and an `nt:resource` node is created as its `jcr:content` child node to take the contents of the bundle file. The properties of the `nt:resource` node are set from file information as available. If a content definition file exists with the same name as the file plus `.json` or `.xml` these properties are set additionally on the imported file. See below for the content definition file specification. |

It is possible to modify the intial content loading default behaviour by using certain optional directives. Directives should be specified separated by semicolon. They are defined as follows:

| Directive | Definition | Default value | Description |
|---|---|---|---|
| `overwrite` | <code>overwrite:=(true&#124;false)<code> | `false` | The overwrite directive specifies if content nodes should be overwritten (at the target repository path, which is "/" by default) or just initially added.  If this is true, existing nodes are deleted and a new node is created in the same place. This directive should be used together with the `path` directive to limit overwriting. |
| `overwriteProperties` | <code>overwriteProperties:=(true&#124;false)</code> | `false` | The overwriteProperties directive specifying if content properties should be overwritten or just initially added (at the target repository path, which is "/" by default). This directive should be used together with the `path` directive to limit overwriting. |
| `uninstall` | <code>uninstall:=(true&#124;false)</code> | value from `overwrite` | The uninstall directive specifies if content should be uninstalled when bundle is unregistered. This value defaults to the value of the `overwrite` directive. |
| `path` | <code>path:=*/target/location*</code> | `/` | The path directive specifies the target node where initial content will be loaded. If the path does not exist yet in the repository, it is created by the content loader. The intermediate nodes are of type `sling:Folder`. |
| `checkin` | <code>checkin:=(true&#124;false)</code> | `false` | The checkin directive specifies whether versionable nodes should be checked in. |
| `ignoreImportProviders` | `ignoreImportProviders:=list of extensions` | `empty` | This directive can be used to not run one of the configured extractors (see below). |

Examples of these directives within `Sling-Initial-Content` header entries:

| `Sling-Initial-Content` header entry | Behaviour |
|---|---|
| `SLING-INF/content/home;overwrite:=true;path:=/home` | Overwrites already existing content in */home* and uninstalls the content when the bundle is unregistered. |
| `SLING-INF/content/home;overwriteProperties:=true;path:=/home` | Overwrites properties of existing content in */home*. |
| `SLING-INF/content/home;path:=/sites/sling_website` | This loads the content given in *SLING-INF/content/home* into */sites/sling_website*. |
| `SLING-INF/content/home;checkin:=true` | After content loading, versionable nodes are checked in. |

## Loading initial content from bundles

Repository items to be loaded into the repository, when the bundle is first installed, may be defined in four ways:

1. Directories
1. Files
1. XML descriptor files
1. JSON descriptor files

Depending on the bundle entry found in the location indicated by the Sling-Initial-Content bundle manifest header, nodes are created (and/or updated) as follows:

### Directories

Unless a node with the name of the directory already exists or has been defined in an XML or JSON descriptor file (see below) a directory is created as a node with the primary node type "nt:folder" in the repository.

### Files

Unless a node with the name of the file already exists or has been defined in an XML or JSON descriptor file (see below) a file is created as two nodes in the repository. The node bearing the name of the file itself is created with the
primary node type "nt:file". Underneath this file node, a resource node with the primary node type "nt:resource" is created, which is set to the contents of the file.

The MIME type is derived from the file name extension by first trying to resolve it from the Bundle entry URL. If this does not resolve to a MIME type, the Sling MIME type resolution service is used to try to find a mime type. If all fals, the MIME type is defaulted to "application/octet-stream".&nbsp;&nbsp;

### XML Descriptor Files

Nodes, Properties and in fact complete subtrees may be described in XML files using either the JCR SystemView format, or the format described below. In either case, the file must have the .xml extension.

    <node>
        <!--
           optional on top level, defaults to XML file name without .xml extension
           required for child nodes
        -->
        <name>xyz</name>
    
        <!--
            optional, defaults to nt:unstructured
        -->
        <primaryNodeType>nt:file</primaryNodeType>
    
        <!--
            optional mixin node type
            may be repeated for multiple mixin node types
        -->
        <mixinNodeType>mix:versionable</mixinNodeType>
        <mixinNodeType>mix:lockable</mixinNodeType>
    
        <!--
            Optional properties for the node. Each <property> element defines
            a single property of the node. The element may be repeated.
        -->
        <property>
            <!--
                required property name
            -->
            <name>prop</name>
    
            <!--
                value of the property.
                For multi-value properties, the values are defined by multiple
                <value> elements nested inside a <values> element instead of a
                single <value> element
            -->
            <value>property value as string</value>
    
            <!--
                Optional type of the property value, defaults to String.
                This must be one of the property type strings defined in the
                JCR PropertyType interface.
            -->
            <type>String</type>
        </property>
    
        <!--
            Additional child nodes. May be further nested.
        -->
        <node>
        ....
        </node>
    </node>


#### Using a custom XML format

By writing an XSLT stylesheet file, you can use whatever XML format you prefer. The XML file references an XSLT stylesheet by using the xml-stylesheet processing instruction: 

    <?xml version="1.0" encoding="UTF-8"?>
    <?xml-stylesheet href="my-transform.xsl" type="text/xsl"?> <!-- The path to my-transform.xsl is relative to this file -->
    
    <your_custom_root_node>
       <your_custom_element>
       ...
       </your_custom_element>
    ...
    </your_custom_root_node>


The my-transform.xsl file is then responsible for translating your format into one of the supported XML formats:


    
    <xsl:stylesheet version="1.0" xmlns:jcr="http://www.jcp.org/jcr/1.0" xmlns:mix="http://www.jcp.org/jcr/mix/1.0" 
      xmlns:sv="http://www.jcp.org/jcr/sv/1.0" xmlns:sling="http://sling.apache.org/jcr/sling/1.0"
      xmlns:rep="internal" xmlns:nt="http://www.jcp.org/jcr/nt/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
      <xsl:template match="your_custom_element">
        <node>
          ...
        </node>
      </xsl:template>
      ...
    </xsl:stylesheet>
    


### JSON Descriptor Files

Nodes, Properties and in fact complete subtrees may be described in JSON files using the following skeleton structure (see [http://www.json.org](http://www.json.org) or information on the syntax of JSON) :

    {
        // child node name
        "nodename" : {

            // optional primary node type, default "nt:unstructured"
            "jcr:primaryType": "sling:ScriptedComponent",

            // optional mixin node types as array
            "jcr:mixinTypes": [ ],
    
            // additional properties as name value pairs.
            // Multi-value properties are defined as JSON array.
            // Property type is derived from the value

            // String value (default)
            "sling:contentClass": "com.day.sling.jcr.test.Test",

            // Multi-value String
            "sampleMulti": [ "v1", "v2" ],

            // Long value, single and multi
            "sampleStruct": 1,
            "sampleStructMulti": [ 1, 2, 3 ],

            // Date follows pattern yyyy-mm-ddTHH:MM:SS.sss±HH:MM
            "sampleDate": "2014-11-27T13:26:00.000+01:00",

            // JCR Node Reference with name prefix (removed to derive node name)
            "jcr:reference:sampleRef": "386b0f48-49c3-4c58-8735-ceee6bfc1933",

            // JCR Path with name prefix (removed to derive node name)
            "jcr:path:samplePath": "/content/data",

            // JCR Name with name prefix (removed to derive node name)
            "jcr:name:sampleName": "data",

            // URI with name prefix (removed to derive node name)
            "jcr:uri:sampleUri": "http://sling.apache.org/",

            // Child nodes are simple JSON objects
            "sling:scripts": {
                "jcr:primaryType": "sling:ScriptList",
                "sling:Script": {
                        "jcr:primaryType": "sling:Script",
                        "sling:name": "/test/content/jsp/start.jsp",
                        "sling:type": "jsp",
                        "sling:glob": "*"
                }
            }
    }


### Extractors

By default, the `sling-jcr-contentloader` bundle tries to extract certain file types during content loading. These include `json`, `xml`, `zip`, and `jar` files. Therefore all available extractors are used for content processing. However if some files should be put into the repository unextracted, the `ignoreImportProviders` directive can be used with a comma separated list of extensions that should not be extracted, like `ignoreImportProviders:="jar,zip"`. Please note that the value needs to be put into quotation marks if more than one value is used like in the example.

### File name escaping

When the node name you want to import with the JCR ContentLoader contains characters that are not allowed in typical file systems (e.g. a ":" is not allowed on windows file systems), you can URL-encode the file name. It uses the [Java URLDecoder](https://docs.oracle.com/javase/8/docs/api/java/net/URLDecoder.html) internally.

Example: `jcr%3Acontent.txt` will be loaded into a node named `jcr:content.txt`.

### Workspace Targetting

By default, initial content will be loaded into the default workspace. To override this, add a `Sling-Initial-Content-Workspace` bundle manifest header to specify the workspace. Note that *all* content from a bundle will be loaded into the same workspace. 

### Example: Load i18n JSON files

The Sling Internationalization Support (i18n) supports providing JSON-filed based i18n files (see [i18n documentation][i18n-json-file-based]).
In this case the JSON file is not interpreted as content definition file, but is stored as binary file in the repository.
Additionally a mixin `mix:language` and a property `jcr:language` with the language code has to be set on the file node.

This is an example how such an i18n file can be loaded from an OSGi bundle with the Sling Content Loader.

Within your bundle header you have to define a separate path for the i18n files where you have to explicitly disable the JSON provider:

    <Sling-Initial-Content>
        SLING-INF/i18n;overwrite:=true;ignoreImportProviders:=json;path:=/apps/myapp/i18n
    </Sling-Initial-Content>

The folder `SLING-INF/i18n` from your bundles contains a pair of files for each language, e.g.:

* `en.json` - The JSON file containing the i18n keys
* `en.json.xml` - Additional content descriptor file setting the mixing and language property

Example for the content descriptor:

    <?xml version="1.0" encoding="UTF-8"?>
    <node>
        <name>en.json</name>
        <mixinNodeType>mix:language</mixinNodeType>
        <property>
            <name>jcr:language</name>
            <value>en</value>
            <type>String</type>
        </property>
    </node>
    

## Declared Node Type Registration

The `sling-jcr-base` bundle provides low-level repository operations which are at the heart of the functionality of Sling:
* *Node Type Definitions* \- The class `org.apache.sling.content.jcr.base.NodeTypeLoader` provides methods to register custom node types with a repository given a repository session and a node type definition file in CND format. This class is also used by this bundle to register node types on behalf of other bundles.

Bundles may list node type definition files in CND format in the `Sling-Nodetypes` bundle header. This header is a comma-separated list of resources in the respective bundle. Each resource is taken and fed to the `NodeTypeLoader` to define the node types.

After a bundle has entered the *resolved* state, the node types listed in the `Sling-Nodetypes` bundle header are registered with the repository.

Node types installed by this mechanism will never be removed again by the `sling-jcr-base` bundle. 

Starting with revision 911430, re-registration of existing node types is enabled by default. To disable this, add `;rereigster:=false` to the resource names for which re-registration should be disabled.

<div class="warning">
Support for re-registration of node types is relatively limited. In Jackrabbit, for example, only "trivial" changes are allowed.
</div>

### Automated tests

The initial content found in the [sling-test folder of the launchpad initial content](https://github.com/apache/sling-org-apache-sling-launchpad-content/tree/master/src/main/resources/content/sling-test) is verified by the [InitialContentTest](https://github.com/apache/sling-org-apache-sling-launchpad-integration-tests/blob/master/src/main/java/org/apache/sling/launchpad/webapp/integrationtest/InitialContentTest.java) when running the *launchpad testing* integration tests.

Those tests can be used as verified examples of initial content loading. Contributions are welcome to improve the coverage of those tests.


## ACLs and Principals

**Note:** Creating system users is not supported by contentloader, you should use repoinit instead. Repoinit also allows to set ACLs. See [SlingRepositoryInitializer](repository-initialization.html) for more information.

By adding a `security:acl` object to a content node definition in JSON you can define an ACL for this node. For each array entry in this example an ACE is added. Example:

    {
        "security:acl": [
            { "principal": "TestGroup1", "granted": ["jcr:read","jcr:write"] },
            { "principal": "TestUser1", "granted": ["jcr:read"], "denied": ["jcr:write"] }
        ]
    }

If ACLs already exist on the node you can add an `order` property to each array entry controlling the position where the new ACE is inserted into the list of existing ACEs. Possible values for this property:

* **first**: Place the target ACE as the first amongst its siblings
* **last**: Place the target ACE as the last amongst its siblings
* **before xyz**: Place the target ACE immediately before the sibling whose name is xyz
* **after xyz**: Place the target ACE immediately after the sibling whose name is xyz
* **numeric**: Place the target ACE at the specified index

You can also add new principals (users or groups) to the repository by adding a `security:principals` object. This is not related to any specific path/node, so you can add this JSON fragment anywhere. Example for creating one use and one group:

    {
        "security:principals": [
            { "name": "TestUser1", "password": "mypassword", "extraProp1": "extraProp1Value" },
            { "name": "TestGroup1", "isgroup": "true", "members": ["TestUser1"], "extraProp1": "extraProp1Value" }
        ]
    }

### ACE Restrictions (since 2.3.0)
When adding a `security:acl` object to a content node definition in JSON you can also define restrictions on the ACEs to further filter the impact. Example:

    {
        "security:acl": [
            { 
                "principal": "TestUser1", 
                "granted": [
                    "jcr:read",
                    "jcr:write"
                ],
                "restrictions": {
                    "rep:glob": "glob1"
                }
            },
            { 
                "principal": "TestGroup1", 
                "granted": [
                    "jcr:modifyAccessControl"
                ],
                "restrictions": {
                    "rep:itemNames": [
                        "name1",
                        "name2"
                    ]
                }
            }
        ]
    }


[i18n-json-file-based]: https://sling.apache.org/documentation/bundles/internationalization-support-i18n.html#json-file-based
