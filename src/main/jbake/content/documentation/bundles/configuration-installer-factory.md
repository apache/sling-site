title=Configuration Installer Factory		
type=page
status=published
tags=installer
~~~~~~

The configuration installer factory provides support for configurations to the [OSGI installer](/documentation/bundles/osgi-installer.html). The provisioning of artifacts is handled by installer providers like the file installer or the JCR installer.


## Configurations
 	 
Configuration file names are related to the PID and factory PID. The structure of the file name is as follows:
 	 

    filename ::= <pid> ( '-' <subname> )? ('.cfg'|'.config')

 	 
If the form is `<pid>('.cfg'|'.config')`, the file contains the properties for a Managed Service. The `<pid>` is then the PID of the Managed Service. See the Configuration Admin service for details.
 	 
When a Managed Service Factory is used, the situation is different. The `<pid>` part then describes the PID of the Managed Service Factory. You can pick any `<subname>`, the installer will then create an instance for the factory for each unique name. For example:
 	 

    com.acme.xyz.cfg // configuration for Managed Service
    // com.acme.xyz
    com.acme.abc-default.cfg // Managed Service Factory,
    // creates an instance for com.acme.abc


If a configuration is modified, the file installer will write the configuration back to a file to ensure peristence across restarts (if `sling.fileinstall.writeback` is enabled).

### Property Files (.cfg)

Configuration files ending in '.cfg' are plain property files (`java.util.Property`). The format is simple:
 	 

    file ::= ( header | comment ) *
    header ::= <header> ( ':' | '=' ) <value> ( '\<nl> <value> ) *
    comment ::= '#' <any>

Notice that this model only supports string properties. For example:
 	 
    # default port
    ftp.port = 21

### Configuration Files (.config)

Configuration files ending in '.config' use the format of the Apache Felix ConfigAdmin implementation. It allows to specify the type and cardinality of a configuration property and is not limited to string values.

The first line of such a file might start with a comment line (a line starting with a #). Comments within the file are not allowed.

The format is:

    file ::= (comment) (header) *
    comment ::= '#' <any>
    header ::= prop '=' value
    prop ::= symbolic-name // 1.4.2 of OSGi Core Specification
    symbolic-name ::= token { '.' token } 
    token ::= { [ 0..9 ] | [ a..z ] | [ A..Z ] | '_' | '-' }
    value ::= [ type ] ( '[' values ']' | '(' values ')' | simple ) 
    values ::= simple { ',' simple } 
    simple ::= '"' stringsimple '"'
    type ::= <1-char type code>
    stringsimple ::= <quoted string representation of the value where both '"' and '=' need to be escaped>

The quoted string format is equal to the definition from HTTP 1.1 ([RFC2616](http://www.w3.org/Protocols/rfc2616/rfc2616-sec2.html)), except that both '"' and '=' need to be escaped.

The 1 character type code is one of:

* 'T' : simple string
* 'I' : Integer
* 'L' : Long
* 'F' : Float
* 'D' : Double
* 'X' : Byte
* 'S' : Short
* 'C' : Character
* 'B' : Boolean

A number of such .config files exist in the Sling codebase and can be used as examples.

# Project Info

* Configuration installer factory ([org.apache.sling.installer.factory.configuration](https://github.com/apache/sling-org-apache-sling-installer-factory-configuration))

