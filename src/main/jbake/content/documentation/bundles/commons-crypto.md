title=Commons Crypto
type=page
status=published
tags=commons,crypto
~~~~~~

[TOC]

**[Commons Crypto](https://github.com/apache/sling-org-apache-sling-commons-crypto) provides a simple API to encrypt and decrypt messages and an extensible implementation based on [Jasypt](https://www.jasypt.org).**

The Jasypt implementation and Web Console plugin are optional.


## API


### Crypto Service

Encrypt a secret message (e.g. service password) and decrypt the ciphertext. The used crypto method is up to the implementation.

	::java
    public interface CryptoService {

        String encrypt(String message);

        String decrypt(String ciphertext);

    }

Use a reference target to get a particular crypto service, e.g. by *names* (names should be meaningful e.g. mail or database).

	::java
    @Reference(
        target = "(names=sample)"
    )
    private volatile CryptoService cryptoService;


### Password Provider

Password providers are useful when dealing with password-based encryption (PBE, see also [RFC 2898](https://tools.ietf.org/html/rfc2898)).

	::java
    public interface PasswordProvider {

        char[] getPassword();

    }


#### File Password Provider

The file-based password provider reads the password for encryption/decryption from a given file.

<img src="commons-crypto/FilePasswordProvider~sample.png" alt="FilePasswordProvider Sample Configuration" style="width: 50%; border: 1px solid silver">


## Jasypt implementation

The Commons Crypto module provides a crypto service implementation based on the [Jasypt](https://www.jasypt.org) `StandardPBEStringEncryptor`.

The `JasyptStandardPbeStringCryptoService` requires at least a password provider and an initialization vector (IV) generator (`IvGenerator`) to set up the internal `StandardPBEStringEncryptor`.

<img src="commons-crypto/JasyptStandardPBEStringCryptoService~sample.png" alt="JasyptStandardPbeStringCryptoService Sample Configuration" style="width: 50%; border: 1px solid silver">

<img src="commons-crypto/JasyptRandomIvGeneratorRegistrar~sample.png" alt="JasyptRandomIvGeneratorRegistrar Sample Configuration" style="width: 50%; border: 1px solid silver">


## Web Console Plugin

The plugin (`/system/console/sling-commons-crypto-encrypt`) allows message encryption with a selected crypto service.

<img src="commons-crypto/sling-commons-crypto-encrypt-webconsole-plugin.png" alt="Sling Commons Crypto Encrypt Web Console Plugin" style="width: 50%; border: 1px solid silver">


## Sample configurations

A module with (minimal) sample configurations can be found in [Sling's samples Git repo](https://github.com/apache/sling-samples/tree/master/sling-commons-crypto-configuration).

`org.apache.sling.commons.crypto.internal.FilePasswordProvider~sample.json`

    {
      "jcr:primaryType": "sling:OsgiConfig",
      "names": ["sample"], // names is optional
      "path": "/var/sling/password"
    }

`org.apache.sling.commons.crypto.jasypt.internal.JasyptRandomIvGeneratorRegistrar~sample.json`

    {
      "jcr:primaryType": "sling:OsgiConfig",
      "algorithm": "SHA1PRNG"
    }


`org.apache.sling.commons.crypto.jasypt.internal.JasyptStandardPbeStringCryptoService~sample.json`

    {
      "jcr:primaryType": "sling:OsgiConfig",
      "names": ["sample"], // names is optional
      "algorithm": "PBEWITHHMACSHA512ANDAES_256"
    }
