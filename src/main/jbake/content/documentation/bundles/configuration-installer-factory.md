title=Configuration Installer Factory		
type=page
status=published
tags=installer
~~~~~~

The configuration installer factory provides support for configurations to the [OSGI installer](/documentation/bundles/osgi-installer.html). The provisioning of artifacts is handled by installer providers like the [file installer](/documentation/bundles/file-installer-provider.html) or the [JCR installer](/documentation/bundles/jcr-installer-provider.html).


## Configurations
 	 
Configuration file names are related to the PID and factory PID. The structure of the file name is as follows:
 	 

    filename ::= <pid> ( ( '-' | '~' ) <subname> ) ? ( '.cfg' | '.config' | '.cfg.json')

 	 
If the form is `<pid>('.cfg'|'.config'|'.cfg.json')`, the file contains the properties for a Managed Service. The `<pid>` is then the PID of the Managed Service. See the Configuration Admin service for details.
 	 
When a Managed Service Factory is used, the situation is different. The `<pid>` part then describes the PID of the Managed Service Factory. You can pick any `<subname>`, the installer will then create an instance for the factory for each unique name. For example:
 	 

    com.acme.xyz.cfg // configuration for Managed Service
    // com.acme.xyz
    com.acme.abc-default.cfg // Managed Service Factory,
    // creates an instance for com.acme.abc
    
Since Installer Configuration Factory 1.2.0 ([SLING-7786](https://jira.apache.org/jira/browse/SLING-7786)) you should use the tilde `~` as separator between `<pid>` and `<subname>` instead of the `-`.


If a configuration is modified, the file installer will write the configuration back to a file to ensure persistence across restarts (if `sling.fileinstall.writeback` is enabled). A similar writeback mechanism is supported by the [JCR installer](jcr-installer-provider.html).

The code for parsing the configuration files is in [InternalResource#readDictionary](https://github.com/apache/sling-org-apache-sling-installer-core/blob/7b2e4407baa45b79d954dd20c53bb2077c3a5e49/src/main/java/org/apache/sling/installer/core/impl/InternalResource.java#L230).

### Property Files (.cfg)

Configuration files ending in `.cfg` are plain property files (`java.util.Property`). The format is simple:
 	 

    file ::= ( header | comment ) *
    header ::= <header> ( ':' | '=' ) <value> ( '\<nl> <value> ) *
    comment ::= '#' <any>

Notice that this model only supports string properties. For example:
 	 
    # default port
    ftp.port = 21

In addition the XML format defined by [java.util.Property](https://docs.oracle.com/javase/7/docs/api/java/util/Properties.html#loadFromXML%28java.io.InputStream%29) is supported if the file starts with the character `<`.

#### Limitations

* Only String types are supported
* Only ISO 8859-1 character encoding supported
* No multi-values
* No writeback support

### Configuration Files (.config)

Configuration files ending in `.config` use the format of the [Apache Felix ConfigAdmin implementation](http://svn.apache.org/viewvc/felix/releases/org.apache.felix.configadmin-1.8.12/src/main/java/org/apache/felix/cm/file/ConfigurationHandler.java?view=markup) (in version 1.8.12). This format allows to specify the type and cardinality of a configuration property and is not limited to string values. It must be stored in UTF-8 encoding.

The first line of such a file might start with a comment line (a line starting with a `#`). Comments within the file are not allowed.

The format is:

    file ::= (comment) (header) *
    comment ::= '#' <any>
    header ::= prop '=' value
    prop ::= symbolic-name // 1.4.2 of OSGi Core Specification
    symbolic-name ::= token { '.' token } 
    token ::= { [ 0..9 ] | [ a..z ] | [ A..Z ] | '_' | '-' }
    value ::= [ type ] ( '[' values ']' | '(' values ')' | simple ) 
    values ::= ( simple { ',' simple } | '\' <nl> simple { ', \' <nl> simple } <nl> )
    simple ::= '"' stringsimple '"'
    type ::= <1-char type code>
    stringsimple ::= <quoted string representation of the value where both '"' and '=' need to be escaped>

The quoted string format is equal to the definition from HTTP 1.1 ([RFC2616](http://www.w3.org/Protocols/rfc2616/rfc2616-sec2.html)), except that both '"' and '=' need to be escaped.

The 1 character type code is one of:

* `T` : `String`
* `I` : `Integer`
* `L` : `Long`
* `F` : `Float`
* `D` : `Double`
* `X` : `Byte`
* `S` : `Short`
* `C` : `Character`
* `B` : `Boolean`

or for primitives

* `i` : `int`
* `l` : `long`
* `f` : `float`
* `d` : `double`
* `x` : `byte`
* `s` : `short`
* `c` : `char`
* `b` : `boolean`

For Float and Double types the methods [Float.intBitsToFloat](https://docs.oracle.com/javase/7/docs/api/java/lang/Float.html#intBitsToFloat%28int%29) and [Double.longBitsToDouble](https://docs.oracle.com/javase/7/docs/api/java/lang/Double.html#longBitsToDouble%28long%29) are being used to convert the numeric string into the correct type. These methods rely on the IEEE-754 floating-point formats described in [Single-precision floating-point format](https://en.wikipedia.org/wiki/Single-precision_floating-point_format) and [Double-precision floating-point format](https://en.wikipedia.org/wiki/Double-precision_floating-point_format). A more user-friendly format is not yet supported for these types ([SLING-7757](https://issues.apache.org/jira/browse/SLING-7757)).

Multiple values enclosed by `[` and `]` lead to an array while those enclosed by `(` and `)` lead to a `Collection` in the underlying `java.util.Dictionary` of the `org.osgi.service.cm.Configuration` and vice-versa.

Although both objects and primites are supported, in case you use single-value entries or collections the deserialization will autobox primitives.

A number of such .config files exist in the Sling codebase and can be used as examples.

#### Limitations

* No support for collections containing different types
* No support for nested multivalues (arrays or Collections)
* No user-friendly (readable) values for floating points ([SLING-7757](https://issues.apache.org/jira/browse/SLING-7757))

### Configuration Files (.cfg.json)

This is only supported since Installer Configuration Factory 1.2.0 ([SLING-7787](https://issues.apache.org/jira/browse/SLING-7787)).

The exact JSON format is described in the [OSGi R7 Service Configurator Spec](https://osgi.org/specification/osgi.cmpn/7.0.0/service.configurator.html).

The only differences to the spec are outlined below

* `:configurator:resource-version` may be used, but only version 1 is supported
* other keys starting with `:configurator:` should not be used (in general they are validated but not further evaluated)
  * The PID is given via the file name (the part preceeding the `.cfg.json`) instead of `:configurator:symbolic-name`
  * There is no version support i.e. `:configurator:version` should not be used either

#### Limitations

* No writeback support yet ([SLING-8419](https://issues.apache.org/jira/browse/SLING-8419))

### sling:OsgiConfig resources

Only the [JCR Installer](/documentation/bundles/jcr-installer-provider.html#configuration-and-scanning) supports also configurations given as resources with properties of type `sling:OsgiConfig`. Internally those are converted directly into the Dictionary format being supported by the [OSGi Configuration Admin](https://osgi.org/javadoc/r4v42/org/osgi/service/cm/Configuration.html#update%28java.util.Dictionary%29) in [ConfigNodeConverter](https://github.com/apache/sling-org-apache-sling-installer-provider-jcr/blob/fcb77de40973672548e79f3a42c19f5decd95651/src/main/java/org/apache/sling/installer/provider/jcr/impl/ConfigNodeConverter.java#L44).

#### Limitations

* Not all types supported ([SLING-2477](https://issues.apache.org/jira/browse/SLING-2477))
* No writeback support
* Only array multivalue support ([SLING-4183](https://issues.apache.org/jira/browse/SLING-4183))

# Project Info

* Configuration installer factory ([org.apache.sling.installer.factory.configuration](https://github.com/apache/sling-org-apache-sling-installer-factory-configuration))

