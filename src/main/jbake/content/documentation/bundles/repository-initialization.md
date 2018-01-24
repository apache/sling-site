title=Repository Initalization
type=page
status=published
tags=repoinit,jcr,repository
~~~~~~

The `SlingRepositoryInitializer` mechanism allows for running code before the `SlingRepository` service is registered.

This is useful for initialization and content migration purposes.

Please be aware of potential clustering and coordination issues when using this mechanism, if your environment lets several Sling instances access
the same content repository you'll need to implement a synchronization mechanism for such operations.

## SlingRepositoryInitializer
The `SlingRepositoryInitializer` is a very simple service interface, available from version 2.4.0 of the `org.apache.sling.jcr.api` and `org.apache.sling.jcr.base` bundles.

	public interface SlingRepositoryInitializer {
	    public void processRepository(SlingRepository repo) throws Exception;
	}
	
Services that implement this interface are called when setting up the JCR-based `SlingRepository` service, before registering it as an OSGi service.

They are called in increasing order of their `service.ranking` service property, which needs to be an `Integer` as usual.

If any of them throws an Exception, the `SlingRepository` service is not registered.
    
## The 'repoinit' Repository Initialization Language
The `org.apache.sling.repoinit.parser` implements a mini-language meant to create paths, service users and Access Control Lists in a content repository, as 
well as registering JCR namespaces and node types.

The language grammar is defined (using the JavaCC compiler-compiler, which has no runtime dependencies) in the `RepoInitGrammar.jjt` file in that module, and the automated tests provide a number of [test cases](https://github.com/apache/sling-org-apache-sling-repoinit-parser/tree/master/src/test/resources/testcases) which demonstrate various features.

The companion `org.apache.sling.jcr.repoinit` module implements those operations on an Oak JCR repository, using a `SlingRepositoryInitializer`
registered by default with a service ranking of 100. It also provides a `JcrRepoInitOpsProcessor` service to explicitly apply the output
of the repoinit parser to a JCR repository.

Here's a current example from the test cases mentioned above, that uses all language features as of version 1.0.2 of the parser module. 

The language is self-explaining but please refer to the actual test cases for details that are guaranteed to be up to date, assuming the tests pass.

    create service user user1, u-ser_2
    set ACL on /libs,/apps
        allow jcr:read for user1,u-ser_2

        deny jcr:write for u-ser_2
        deny jcr:lockManagement for user1
        remove jcr:understand,some:other for u3
    end

    create service user bob_the_service

    set ACL on /tmp
        allow some:otherPrivilege for bob_the_service
    end

    # Nodetypes inside the path apply to just that path element
    create path /content/example.com(sling:Folder)

    # Nodetypes and mixins applied to just a path element
    # Specifying mixins require
    # o.a.s.repoinit.parser 1.2.0 and
    # o.a.s.jcr.repoinit 1.2.0
    create path /content/example.com(sling:Folder mixin mix:referenceable,mix:shareable)

    # Mixins applied to just a path element
    create path /content/example.com(mixin mix:referenceable)
	
	# A nodetype in front is used as the default for all path elements
    create path (nt:unstructured) /var

    set ACL for alice, bob,fred
        # remove is currently not supported by the jcr.repoinit module
        remove * on / 
        allow jcr:read on /content,/var
        deny jcr:write on /content/example.com
        deny jcr:all on / nodetypes example:Page
    end
	
    set ACL for restrictions_examples
        deny jcr:modifyProperties on /apps, /content nodetypes sling:Folder, nt:unstructured restriction(rep:itemNames,prop1,prop2)
        allow jcr:addChildNodes on /apps restriction(rep:ntNames,sling:Folder,nt:unstructured)
        allow jcr:modifyProperties on /apps restriction(rep:ntNames,sling:Folder,nt:unstructured) restriction(rep:itemNames,prop1,prop2)
        allow jcr:addChildNodes on /apps,/content restriction(rep:glob,/cat/*,*/cat,*cat/*)

        # empty rep:glob means "apply to this node but not its children"
        # (requires o.a.s.jcr.repoinit 1.1.8)
        allow jcr:something on / restriction(rep:glob)
    end

    # Set repository level ACL
    # Setting repository level ACL require
    # o.a.s.repoinit.parser 1.2.0 and
    # o.a.s.jcr.repoinit 1.2.0
    set repository ACL for alice,bob
        allow jcr:namespaceManagement,jcr:nodeTypeDefinitionManagement
    end
	
	# register namespace requires 
	# o.a.s.repoinit.parser 1.0.4
	# and o.a.s.jcr.repoinit 1.0.2
	register namespace ( NSprefix ) uri:someURI/v1.42

	# register nodetypes in CND format
	# (same bundle requirements as register namespaces)
	#
	# The optional << markers are used when embedding
	# this in a Sling provisioning model, to avoid syntax errors
	#
	# The CND instructions are passed as is to the JCR
	# modules, so the full CND syntax is supported.
	#
	register nodetypes
	<<===
	<<  <slingevent='http://sling.apache.org/jcr/event/1.0'>
	<<
	<<  [slingevent:Event] > nt:unstructured, nt:hierarchyNode
	<<    - slingevent:topic (string)
	<<    - slingevent:properties (binary)
	===>>

    create user demoUser with password {SHA-256} dc460da4ad72c482231e28e688e01f2778a88ce31a08826899d54ef7183998b5

    # disable service user
    create service user deprecated_service_user
    disable service user deprecated_service_user : "Disabled user to make an example"

    create service user the-last-one

## Providing repoinit statements from the Sling provisioning model or other URLs

All bundles required for this feature need to be active before the `SlingRepository` service starts.

From version 1.0.2 of the `org.apache.sling.jcr.repoinit` bundle, the `o.a.s.jcr.repoinit.RepositoryInitializer` component uses an OSGi 
configuration as shown in this example to define where to read repoinit statements:

    org.apache.sling.jcr.repoinit.impl.RepositoryInitializer
      references=["model:context:/resources/provisioning/model.txt","model@repoinitTwo:context:/resources/provisioning/model.txt"]
    
This example defines two _references_ to URLs that supply repoinit statements. Their syntax is described below.

By default the `RepositoryInitializer` uses the first URL shown in the above example, which points to the provisioning model that's embedded by default in the Sling Launchpad runnable jar.

Note that previous versions of the `org.apache.sling.jcr.repoinit` bundle used different configuration parameters. From version 1.0.2 on, warnings are logged if those old parameters (_text.url,text.format,model.section.name_) are used.

### References to Sling Provisioning Model additional sections
The `slingstart-maven-plugin`, from V1.4.2 on, allows for embedding so-called "additional sections" in the Sling provisioning model by starting
their name with a colon.

At runtime this requires the `org.apache.sling.provisioning.model` bundle, version 1.4.2 or later.

The `o.a.s.jcr.repoinit` bundle can use this feature to execute `repoinit` statements provided by Sling provisioning models, as in this 
provisioning model example fragment:

    [:repoinit]
    create path /repoinit/provisioningModelTest

    create service user provisioningModelUser
	
To read repoinit statements from such an additional provisioning model section, the `RepositoryInitializer` configuration shown above uses references like

    model@repoinitTwo:context:/resources/provisioning/model.txt
	
Where _model_ means "use the provisioning model format", _repoinitTwo_ is the name of the additional section to read statements from in the provisioning 
model (without the leading colon) and _context:/resources/..._ is the URL to use to retrieve the provisioning model.

In this example the URL uses the _context_ scheme defined by the Sling Launchpad, but any scheme can be used provided a suitable URL handler is active.

The section name in that reference is optional and defaults to _repoinit_. If it's not specified the `@` should be omitted as well.
	
### References to URLs providing raw repoinit statements
Using a `RepositoryInitializer` reference like in this example, with the _raw_ prefix, means that its content is passed as is to the repoinit parser:

    raw:classpath://some-repoinit-file.txt
	
Which points to a `classpath:` URL to provide the raw repoinit statements in this example, but again any valid URL scheme can be used.

## Providing repoinit statements from OSGi factory configurations

From version 1.1.6 of the `org.apache.sling.jcr.repoinit` bundle, repoinit statements can also be provided by OSGi factory
configurations which use the `org.apache.sling.jcr.repoinit.RepositoryInitializer` factory PID.

Such configurations have two optional fields:

  * A multi-value `references` field with each value providing the URL (as a String) of raw repoinit statements.
  * A multi-value `scripts` field with each value providing repoinit statements as plain text in a String.

   
