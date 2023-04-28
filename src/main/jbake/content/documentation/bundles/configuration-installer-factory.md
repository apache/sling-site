title=Configuration Installer Factory		
type=page
status=published
tags=installer
~~~~~~

The configuration installer factory provides support for configurations to the [OSGI installer](/documentation/bundles/osgi-installer.html). The provisioning of artifacts is handled by installer providers like the [file installer](/documentation/bundles/file-installer-provider.html) or the [JCR installer](/documentation/bundles/jcr-installer-provider.html).

# Applying of Configurations

Configuration resource names are related to the PID and factory PID. The structure of the underlying file name/JCR node name is as follows:


    filename ::= <pid> ( ( '-' | '~' ) <subname> ) ? ( '.cfg' | '.config' | '.cfg.json')

Singleton configurations are defined using a filename that consists of the PID followed by the extension, defining the format of the file (see below). For factory configurations the filename has three parts, the factory PID, a subname and the extension. The subname is separated by a tilde (prefered) or dash from the factory PID. You can pick any `<subname>`, the installer will then create an instance for the factory for each unique name. For example:


    com.acme.xyz.cfg // singleton configuration
    // com.acme.xyz
    com.acme.abc-default.cfg // factory configuration
    // creates an instance for com.acme.abc named default

Since Installer Configuration Factory 1.2.0 ([SLING-7786](https://jira.apache.org/jira/browse/SLING-7786)) you should use the tilde `~` as separator between `<pid>` and `<subname>` instead of the `-` (dash).

The code for parsing the configuration resources is in [InternalResource#readDictionary](https://github.com/apache/sling-org-apache-sling-installer-core/blob/7b2e4407baa45b79d954dd20c53bb2077c3a5e49/src/main/java/org/apache/sling/installer/core/impl/InternalResource.java#L230).

The configuration is then applied via [OSGi Configuration Admin Service](https://docs.osgi.org/specification/osgi.cmpn/7.0.0/service.cm.html#d0e11641)

# Write Back

If a configuration is modified, the file installer will write the configuration back to a file to ensure persistence across restarts and to allow to share the configuration update with other instances (if `sling.fileinstall.writeback` is enabled). A similar writeback mechanism is supported by the [JCR installer](jcr-installer-provider.html). Consider using the [Web Console Plugin Configuration Printer][1] instead.


# Merging of Configurations

By default, if multiple configurations for the same PID or factory PID plus subname are found, these configurations are not merged but only the one with the highest priority is effective.

Starting with Installer Configuration Factory 1.4.0 ([SLING-10538](https://issues.apache.org/jira/browse/SLING-10538)), a new framework property has been introduced to enable merging of configurations: `sling.installer.config.mergeSchemes`. If this is set, for example to `launchpad` then all configurations from launchpad (i.e. with a installer resource scheme `launchpad`) act as default configurations. When now a configuration from a different location - for example the repository (scheme: `jcrinstall`) is installed - that configuration is first merged with the default configuration. Similar, for write back and the [OSGi Installer Configuration Printer Web Console][1] only the properties with different configuration values than the default configuration are written back/exposed.

Enabling this feature is a change in behaviour and must be used with care. However, it bridges the current difference between launchpad based Sling applications and feature model based applications. While the feature model usually merges configurations, launchpad based applications do not. Enabling the above property closes that gap.

# Configuration Serialization Formats

There are multiple file formats supported how a configuration can be passed to the OSGi installer. Most formats are binary formats which must be specified as `nt:file` resources in a JCR repository.

### Configuration Files (.cfg.json)

This is the preferred way to specify configurations as it is an official format specified by OSGi in the [OSGi R7 Service Configurator Spec](https://osgi.org/specification/osgi.cmpn/7.0.0/service.configurator.html) and is also used by the [Feature Model](https://github.com/apache/sling-org-apache-sling-feature/blob/master/readme.md). The detailed JSON format is described in that specification. It allows for typed values, allowing all possible types including Collections and comments.

There are some differences to the [resource format specification](https://osgi.org/specification/osgi.cmpn/7.0.0/service.configurator.html#service.configurator-resources) as outlined below:

* Each file contains exactly one configuration, therefore it only contains the properties of the configuration.
* Keys starting with `:configurator:` should not be used (in general they are validated but not further evaluated)
* The PID is given via the file name (the part preceeding the `.cfg.json`) instead of `:configurator:symbolic-name`
* There is no version support i.e. `:configurator:version` should not be used either

This is an example file

    {
       "key": "val",
       "some_number": 123,
       // This is an integer value:
       "size:Integer" : 500
    }

#### Limitations

* This is only supported since Installer Configuration Factory 1.2.0
* No support of multiline String values ([SLING-10217](https://issues.apache.org/jira/browse/SLING-10217)), therefore, for repoinit rather use `.config`.

### Configuration Files (.config)

Configuration files ending in `.config` use the format of the [Apache Felix ConfigAdmin implementation](http://svn.apache.org/viewvc/felix/releases/org.apache.felix.configadmin-1.8.12/src/main/java/org/apache/felix/cm/file/ConfigurationHandler.java?view=markup) (in version 1.8.12). This format allows to specify the type and cardinality of a configuration property and is not limited to string values. It must be stored in UTF-8 encoding. This format is preferred over properties files and nodes stored in the repository.

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



### sling:OsgiConfig resources

Only the [JCR Installer](/documentation/bundles/jcr-installer-provider.html#configuration-and-scanning) supports also configurations given as resources with properties of type `sling:OsgiConfig`. Internally those are converted directly into the Dictionary format being supported by the [OSGi Configuration Admin](https://osgi.org/javadoc/r4v42/org/osgi/service/cm/Configuration.html#update%28java.util.Dictionary%29) in [ConfigNodeConverter](https://github.com/apache/sling-org-apache-sling-installer-provider-jcr/blob/fcb77de40973672548e79f3a42c19f5decd95651/src/main/java/org/apache/sling/installer/provider/jcr/impl/ConfigNodeConverter.java#L44).

While this way of specifying configurations in a JCR repository seems like a natural fit, it should be avoided as it neither supports all required types nor is it portable.

#### Limitations

* Not all types supported ([SLING-2477](https://issues.apache.org/jira/browse/SLING-2477))
* No writeback support
* Only array multivalue support ([SLING-4183](https://issues.apache.org/jira/browse/SLING-4183))


# Web Console Plugin: Configuration Printer

There is a Felix Web Console Plugin which exposes the current OSGi configuration for a configuration PID ([SLING-8897](https://issues.apache.org/jira/browse/SLING-8897)) at `/system/console/osgi-installer-config-printer` in all supported serialization formats. This is an alternative to using the [write back functionality](./jcr-installer-provider.html#write-back-support) for generating a configuration file from a live system.

# Project Info

* Configuration installer factory ([org.apache.sling.installer.factory.configuration](https://github.com/apache/sling-org-apache-sling-installer-factory-configuration))


[1]: #web-console-plugin-configuration-printer
