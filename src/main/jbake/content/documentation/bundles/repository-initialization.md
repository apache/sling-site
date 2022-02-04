title=Repository Initialization (repoinit)
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

As  I write this, the source code consists of [three modules](https://github.com/apache?utf8=%E2%9C%93&q=sling+repoinit): the parser, the JCR 
repoinit adapter module and the integration tests.

The language grammar is defined (using the JavaCC compiler-compiler, which has no runtime dependencies) in the `RepoInitGrammar.jjt` file in that module, and the automated tests provide a number of [test cases](https://github.com/apache/sling-org-apache-sling-repoinit-parser/tree/master/src/test/resources/testcases) which demonstrate various features.

The companion `org.apache.sling.jcr.repoinit` module implements those operations on an Oak JCR repository, using a `SlingRepositoryInitializer`
registered by default with a service ranking of 100. It also provides a `JcrRepoInitOpsProcessor` service to explicitly apply the output
of the repoinit parser to a JCR repository.

The language is mostly self-explaining, the test suite listed below in Appendix A exposes
all language constructs and options.

A [jbang script in the Sling whiteboard repository](https://github.com/apache/sling-whiteboard/blob/master/jbang/RepoinitValidator.java) can be used to test the syntax of repoinit statements by
running a specific version of the repoinit parser on them.

### Notes on Repository Initializer Config Files

If the Repository Initializer is defined inside a **.config** file then according to the .config file
definition found [here](/documentation/bundles/configuration-installer-factory.html#configuration-files-config)
these rules apply:

* Quotes that start / end a String literal need to be escaped with a backslash like this: **\\\"**
* Quotes inside a String literal need to be escapped with a double backslash like this: **\\\\\"**
* Equals Sign inside a String need to be escaped with a backslash like this: **\\=**

## Providing repoinit statements from the Sling provisioning model or other URLs

All bundles required for this feature need to be active before the `SlingRepository` service starts.

From version 1.0.2 of the `org.apache.sling.jcr.repoinit` bundle, the `o.a.s.jcr.repoinit.RepositoryInitializer` component uses an OSGi 
configuration as shown in this example to define where to read repoinit statements:

<pre class="language-no-highlight">
  org.apache.sling.jcr.repoinit.impl.RepositoryInitializer
    references=["model:context:/resources/provisioning/model.txt","model@repoinitTwo:context:/resources/provisioning/model.txt"]
</pre>
    
This example defines two _references_ to URLs that supply repoinit statements. Their syntax is described below.

By default the `RepositoryInitializer` uses the first URL shown in the above example, which points to the provisioning model that's embedded by default in the Sling Launchpad runnable jar.

Note that previous versions of the `org.apache.sling.jcr.repoinit` bundle used different configuration parameters. From version 1.0.2 on, warnings are logged if those old parameters (_text.url,text.format,model.section.name_) are used.

### References to Sling Provisioning Model additional sections
The `slingstart-maven-plugin`, from V1.4.2 on, allows for embedding so-called "additional sections" in the Sling provisioning model by starting
their name with a colon.

At runtime this requires the `org.apache.sling.provisioning.model` bundle, version 1.4.2 or later.

The `o.a.s.jcr.repoinit` bundle can use this feature to execute `repoinit` statements provided by Sling provisioning models, as in this 
provisioning model example fragment:

<pre class="language-no-highlight">
  [:repoinit]
  create path /repoinit/provisioningModelTest

  create service user provisioningModelUser
</pre>
	
To read repoinit statements from such an additional provisioning model section, the `RepositoryInitializer` configuration shown above uses references like

<pre class="language-no-highlight">
  model@repoinitTwo:context:/resources/provisioning/model.txt
</pre>
	
Where _model_ means "use the provisioning model format", _repoinitTwo_ is the name of the additional section to read statements from in the provisioning 
model (without the leading colon) and _context:/resources/..._ is the URL to use to retrieve the provisioning model.

In this example the URL uses the _context_ scheme defined by the Sling Launchpad, but any scheme can be used provided a suitable URL handler is active.

The section name in that reference is optional and defaults to _repoinit_. If it's not specified the `@` should be omitted as well.
	
### References to URLs providing raw repoinit statements
Using a `RepositoryInitializer` reference like in this example, with the _raw_ prefix, means that its content is passed as is to the repoinit parser:

<pre class="language-no-highlight">
  raw:classpath://some-repoinit-file.txt
</pre>
	
Which points to a `classpath:` URL to provide the raw repoinit statements in this example, but again any valid URL scheme can be used.

## Providing repoinit statements from OSGi factory configurations

From version 1.1.6 of the `org.apache.sling.jcr.repoinit` bundle, repoinit statements can also be provided by OSGi factory
configurations which use the `org.apache.sling.jcr.repoinit.RepositoryInitializer` factory PID.

Such configurations have two optional fields:

  * A multi-value `references` field with each value providing the URL (as a String) of raw repoinit statements.
  * A multi-value `scripts` field with each value providing repoinit statements as plain text in a String.

# Appendix

## Appendix A: repoinit syntax: parser test scenarios
A concatenation of all test scenarios from the
[repoinit parser module](https://github.com/apache/sling-org-apache-sling-repoinit-parser/tree/master/src/test/resources/testcases)
follows.

Assuming that test suite is complete, this exposes all the language constructs
and options, with descriptive comments where needed. If something's unclear, please
ask or provide patches for these tests to make them easier to understand.

The following output is generated by the [concatenate-test-scenarios.sh](https://github.com/apache/sling-org-apache-sling-repoinit-parser/tree/master/concatenate-test-scenarios.sh) script found in the
repoinit parser repository.

### Repoinit parser test scenarios
    
    # test-1.txt
    
    create service user bob,alice, tom21
    create service user lonesome
    create service user pathA with path some/relative/path
    create service user pathA with path /some/absolute/path
    
    # test-2.txt
    
    create service user Mark-21
    delete service user Leonardo,Winston_32
    
    # test-3.txt
    
    #
    # single-word
    # We're testing the comments now
    # This is A COMMENT with other things like 12, 34
    # And now for a tag, <ok> ?
    # And some punctuation: .,;-_[]+"*ç%&/()=?^`"
       # Also with leading whitespace.
    
    # blank lines work, of course   
    create service user comments_test_passed
    
    # test-4.txt
    
    # trailing comments test
    create service user comments_test_passed
    # something
    
    # test-5.txt
    
    # trailing comments test without following blank lines
    create service user comments_test_passed
    # something
    
    # test-10.txt
    
    # Set ACL example from SLING-5355
    # Without the "with glob" option, we're not planning to support
    # that at this time. 
    set ACL on /libs,/apps, /, /content/example.com/some-other_path
        remove * for user1,user2
        allow jcr:read for user1,user2
        allow privilege_without_namespace for user4
    
        deny jcr:write,something:else,another:one for user2
        deny jcr:lockManagement for user1
        deny jcr:modifyProperties for user2 restriction(rep:itemNames,prop1,prop2)
    end
    
    set ACL on /no-indentation
    allow jcr:read for userA,userB
    end
    
    # test-11.txt
    
    # Test multiple remove lines
    # Although the repoinit language includes a remove statement,
    # it is not generally supported by the current version of the
    # o.a.s.jcr.repoinit module. Only the "remove *" variant is
    # supported starting with o.a.s.jcr.repoinit V1.1.34
    set ACL on /libs,/apps
        remove * for user1,user2
        allow jcr:read for user1,user2
    
        remove * for another
        allow x:y for another
    
        remove jcr:ACL for userTestingSpecificRemove
    end
    
    # test-12.txt
    
    # Test path-centric Set Acl with options (SLING-6423)
    set ACL on /libs,/apps (ACLOptions=merge)
        remove * for user1,user2
        allow jcr:read for user1,user2
    
        remove * for another
        allow x:y for another
    end
    
    # Multiple options
    set ACL on /libs,/apps (ACLOptions=mergePreserve,someOtherOption,someOther123,namespaced:option)
        remove * for user1,user2
        allow jcr:read for user1,user2
    
        remove * for another
        allow x:y for another
    end
    
    # test-13.txt
    
    # Test for repository-level ACL (SLING-7061), requires
    # o.a.s.repoinit.parser 1.2.0, o.a.s.jcr.repoinit 1.1.6
    set repository ACL for user1,user2
        remove *
        allow jcr:read,jcr:lockManagement
        deny jcr:write
    end
    
    # test-14.txt
    
    # Test allowed path characters, see SLING-6774
    set ACL on /one:name,/two+name,/three@name
        remove * for user1
        allow jcr:read for user1
    end
    
    # test-15.txt
    
    # Mixing paths and repo-level ACL
    set ACL on /content,:repository
        allow jcr:all for user1
    end
    
    # test-20.txt
    
    # Various "create path" tests
    
    # Nodetypes:
    # A nodetype in brackets right after "create path", like
    # sling:Folder below, sets the default type for all path
    # segments of this statement.
    # A nodetype in brackets at the end of a path segment, like
    # nt:unstructured below, applies just to that path segment.
    # If no specific nodetype is set, the repository uses its
    # default based on node type definitions.
    
    create path (sling:Folder) /var/discovery(nt:unstructured)/somefolder
    
    # more tests and examples
    create path /one/two/three
    create path /three/four(nt:folk)/five(nt:jazz)/six
    create path (nt:x) /seven/eight/nine
    create path /one(mixin nt:art)/step(mixin nt:dance)/two/steps
    create path (nt:foxtrot) /one/step(mixin nt:dance)/two/steps
    create path /one/step(mixin nt:dance,nt:art)/two/steps
    create path /one/step(nt:foxtrot mixin nt:dance)/two/steps
    create path /one/step(nt:foxtrot mixin nt:dance,nt:art)/two/steps
    create path /one:and/step/two:and/steps
    create path /one@home/step/two@home/steps
    create path /one+tap/step/two+tap/steps
    
    # test-30.txt
    
    # Test the principal-centered ACL syntax
    
    set ACL for user1,u2
        remove * on /libs,/apps
        allow jcr:read on /content
    
        deny jcr:write on /apps
        
        # Optional nodetypes clause
        deny jcr:lockManagement on /apps, /content nodetypes sling:Folder, nt:unstructured
        # nodetypes clause with restriction clause
        deny jcr:modifyProperties on /apps, /content nodetypes sling:Folder, nt:unstructured restriction(rep:itemNames,prop1,prop2)
        remove jcr:understand,some:other on /apps
    
        # multi value restriction
        allow jcr:addChildNodes on /apps restriction(rep:ntNames,sling:Folder,nt:unstructured)
    
        # multiple restrictions
        allow jcr:modifyProperties on /apps restriction(rep:ntNames,sling:Folder,nt:unstructured) restriction(rep:itemNames,prop1,prop2)
    
        # restrictions with glob patterns
        allow jcr:addChildNodes on /apps,/content restriction(rep:glob,/cat,/cat/,cat)
        allow jcr:addChildNodes on /apps,/content restriction(rep:glob,cat/,*,*cat)
        allow jcr:addChildNodes on /apps,/content restriction(rep:glob,/cat/*,*/cat,*cat/*)
    
        allow jcr:something on / restriction(rep:glob)
    end
    
    # test-31.txt
    
    # Principal-centered ACL syntax with options (SLING-6423)
    set ACL for user1,u2 (ACLOptions=mergePreserve)
        remove * on /libs,/apps
        allow jcr:read on /content
    end
    
    # With multiple options
    set ACL for user1,u2 (ACLOptions=mergePreserve,someOtherOption,someOther123,namespaced:option)
        remove * on /libs,/apps
        allow jcr:read on /content
    end
    
    # test-32.txt
    
    # repo-level permissions in "set ACL for"
    set ACL for user1
        allow jcr:all on :repository,/content
    end
    
    # test-33.txt
    
    # Set principal-based access control (see SLING-8602), requires
    # o.a.s.repoinit.parser 1.2.8 and
    # o.a.s.jcr.repoinit 1.1.14
    # precondition for o.a.s.jcr.repoinit: 
    # repository needs to support 'o.a.j.api.security.authorization.PrincipalAccessControlList'
    # Also, this only works for users selected by the Jackrabbit/Oak FilterProvider, see
    # https://jackrabbit.apache.org/oak/docs/security/authorization/principalbased.html#configuration
    
    set principal ACL for principal1,principal2
        remove * on /libs,/apps
        allow jcr:read on /content
    
        deny jcr:write on /apps
    
        # Optional nodetypes clause
        deny jcr:lockManagement on /apps, /content nodetypes sling:Folder, nt:unstructured
        # nodetypes clause with restriction clause
        deny jcr:modifyProperties on /apps, /content nodetypes sling:Folder, nt:unstructured restriction(rep:itemNames,prop1,prop2)
        remove jcr:understand,some:other on /apps
    
        # multi value restriction
        allow jcr:addChildNodes on /apps restriction(rep:ntNames,sling:Folder,nt:unstructured)
    
        # multiple restrictions
        allow jcr:modifyProperties on /apps restriction(rep:ntNames,sling:Folder,nt:unstructured) restriction(rep:itemNames,prop1,prop2)
    
        # restrictions with glob patterns
        allow jcr:addChildNodes on /apps,/content restriction(rep:glob,/cat,/cat/,cat)
        allow jcr:addChildNodes on /apps,/content restriction(rep:glob,cat/,*,*cat)
        allow jcr:addChildNodes on /apps,/content restriction(rep:glob,/cat/*,*/cat,*cat/*)
    
        allow jcr:something on / restriction(rep:glob)
    end
    
    # Principal-based ACL syntax with options (SLING-6423)
    set principal ACL for principal1,principal2 (ACLOptions=mergePreserve)
        remove * on /libs,/apps
        allow jcr:read on /content
    end
    
    # With multiple options
    set principal ACL for principal1,principal2 (ACLOptions=mergePreserve,someOtherOption,someOther123,namespaced:option)
        remove * on /libs,/apps
        allow jcr:read on /content
    end
    
    # repository level
    set principal ACL for principal1,principal2
        allow jcr:namespaceManagement on :repository 
    end
    
    set principal ACL for principal1
        allow jcr:all on :repository,/content
    end
    
    # test-34.txt
    
    # Functions at the beginning of path names (SLING-8757)
    
    set ACL on home(alice)
      allow jcr:one for alice, bob, carol
    end
    
    set ACL on home(jack),/tmp/a,functionNamesAreFree(bobby)
      allow jcr:two for alice
    end
    
    set ACL for fred
      allow jcr:three on /one,home(Alice123),/tmp
    end
    
    set ACL on /a/b,home(jack),/tmp/a,square(bobby)
      allow jcr:four for alice
    end
    
    set ACL for austin
      allow jcr:five on /one,home(Alice123),/tmp
    end
    
    set ACL on home(  spacesAreOk )
      allow jcr:six for spaceman
    end
    
    set ACL on home(alice)/sub/folder, /anotherPath, home(fred)/root
      allow jcr:seven for mercury
    end
    
    # test-40.txt
    
    # Register namespaces, requires
    # o.a.s.repoinit.parser 1.0.4
    # and o.a.s.jcr.repoinit 1.0.2
    register namespace (foo) uri:some-uri/V/1.0
    register namespace ( prefix_with-other.things ) andSimpleURI
    
    # test-42.txt
    
    # Register privileges
    register privilege withoutabstract_withoutaggregates
    register privilege ns:withoutabstract_withoutaggregatesNS
    register abstract privilege withabstract_withoutaggregates
    register abstract privilege ns:withabstract_withoutaggregatesNS
    
    register privilege withoutabstract_withaggregate with bla
    register privilege withoutabstract_withaggregates with bla,blub
    register privilege withoutabstract_withaggregates with bla,ns:namespacedA
    register privilege ns:withoutabstract_withaggregates with bla,ns:namespacedB
    
    register abstract privilege withabstract_withaggregate with foo
    register abstract privilege withabstract_withaggregates with foo,bar
    register abstract privilege withabstract_withaggregates with foo,ns:namespacedC
    register abstract privilege ns:withabstract_withaggregates with foo,ns:namespacedD
    
    register privilege priv with declared_aggregate_priv1,declared_aggregate_priv2
    register privilege priv with declared_aggregate_priv1,namespaced:_priv4
    
    # test-50.txt
    
    # Embedded CNDs for nodetype definitions
    
    register nodetypes
    <<===
        <slingevent='http://sling.apache.org/jcr/event/1.0'>
        <nt='http://www.jcp.org/jcr/nt/1.0'>
        <mix='http://www.jcp.org/jcr/mix/1.0'>
        
        [slingevent:Event] > nt:unstructured, nt:hierarchyNode
          - slingevent:topic (string)
          - slingevent:application (string)
          - slingevent:created (date)
          - slingevent:properties (binary)
          
        [slingevent:Job] > slingevent:Event, mix:lockable
          - slingevent:processor (string)
          - slingevent:id (string)
          - slingevent:finished (date)
         
        [slingevent:TimedEvent] > slingevent:Event, mix:lockable
          - slingevent:processor (string)
          - slingevent:id (string)
          - slingevent:expression (string)
          - slingevent:date (date)
          - slingevent:period (long)
    ===>>
    
    register nodetypes
    <<===
    Just one line, not indented
    ===>>
    
    register nodetypes
    <<===
    << Using line prefixes
    << to avoid conflicts with Sling provisioning model parser
    ===>>
    
    # test-60.txt
    
    # Create/delete users
    
    delete user userB
    create user userB
    
    create user userC with password some_password
    
    # Although the following syntax is valid for encrpyted passwords,
    # the o.a.s.jcr.repoinit module only supports plain text
    # ones, see SLING-6219
    create user userD with password {SHA-256}dc460da4ad72c
    create user userE with password {someEncoding} afdgwdsdf
    
    create user one_with-more-chars.ok:/123456 with password {encoding_with.ok-:/12345} pw-with.ok-:/13456
    
    create user userF with path /thePathF
    create user userG with path /thePathG with password {theEncoding} userGpwd
    create user userH with path thePathH
    create user userJ with path thePathJ with password {theEncoding} userJpwd
    
    # test-61.txt
    
    # Disable service users
    disable service user svcA : "This message explains why it's disabled.  Whitespace   is  preserved."
    disable service user svcB : "Testing escaped double \"quote\" in this string."
    disable service user svcC : "Testing escaped backslash \\ in this string."
    disable service user svcD : "Testing quoted escaped backslash \"\\\" in this string."
    disable service user svcE : "Testing unescaped single backslash \ in this string."
    
    # test-62.txt
    
    # Create groups
    create group groupa
    create group groupb with path /thePathF
    
    # test-63.txt
    
    # Delete groups
    delete group groupa
    
    # test-64.txt
    
    # Add members to groups
    add user1,user2 to group grpA
    
    # test-65.txt
    
    # Remove members from group
    remove user3,user5 from group grpB
    
    # test-66.txt
    
    # Add and remove group members
    add user1,user2 to group grpA
    add user3 to group grpB
    add user4,user5 to group grpB
    remove user1 from group grpA
    remove user3,user5 from group grpB
    
    # test-67.txt
    
    # Set properties
    set properties on /pathA, /path/B
      set sling:ResourceType{String} to /x/y/z
      set cq:allowedTemplates to /d/e/f/*, m/n/*
      default someInteger{Long} to 42
      set aDouble{Double} to 3.14
      set someFlag{Boolean} to true
      default someDate{Date} to "2020-03-19T11:39:33.437+05:30"
      set customSingleValueStringProp to test
      set customSingleValueQuotedStringProp to "hello, you!"
      set customMultiValueStringProp to test1, test2
      default threeValues to test1, test2, test3
      set quotedA to "Here's a \"double quoted string\" with suffix"
      set quotedMix to "quoted", non-quoted, "the last \" one"
    end
    
    set properties on /single/path
      set someString to "some string"
    end
    
    set properties on /test/curly/brackets
      set curlyBracketsAndDoubleQuotes{String} to "{\"one, two\":\"three, four\"}"
      set curlyBracketsAndSingleQuotes{String} to "{'five, six':'seven,eight'}"
    end
    
    set properties on /endkeyword
      # using "end" instead of "endS" below causes parsing to fail
      set endS to one
      set two to endS
    end
    
    set properties on /forcedMultiValue
      set singleMultiValue{String[]} to "single"
      set emptyMultiValue{String[]} to
      set singleLongMultiValue{Long[]} to 1243
      set emptyLongMultiValue{Long[]} to
    end
    
    set properties on /blankLinesInList
      set one to two
    
      set two to four
    
      set three to five
    end
    
    # SLING-10252: set properties on the user or group profile
    set properties on authorizable(bob)
      set stringProp to "hello, you!"
    end
    set properties on authorizable(bob)/nested
      set stringProp to "hello, you nested!"
    end
    
    set properties on authorizable(bob), authorizable(alice)
      set stringProp to "hello, you again!"
    end
    set properties on authorizable(bob)/nested, authorizable(alice)/nested
      set stringProp to "hello, you nested again!"
    end
    
    # test-68.txt
    
    # SLING-9857: "with forced path" option
    create user A with path /path/user/A
    create user AF with forced path /path/user/AF
    
    create service user B with path /path/service/B
    create service user BF with forced path /path/service/BF
    
    create group G with path /path/group/G
    create group GF with forced path /path/group/GF
    
    # test-69.txt
    
    # Disable users, with various messages
    disable user A : "This message explains why it's disabled.  Whitespace   is  preserved."
    disable user uB : "Testing escaped double \"quote\" in this string."
    disable user userC : "Testing escaped backslash \\ in this string."
    disable user D : "Testing quoted escaped backslash \"\\\" in this string."
    disable user E : "Testing unescaped single backslash \ in this string."
    
    # test-70.txt
    
    # Remove AC policies entirely (not just individual entries)
    delete ACL for ana
    delete ACL for alice, aida
    delete ACL on :repository, home(anni), functionNamesAreFree(aendu)
    delete ACL on /, /var, /etc
    delete ACL on /content
    delete principal ACL for ada, amy
    delete principal ACL for adi
    
    # test-71.txt
    
    # Support quoted Group IDs
    create group "Test Group"
    create group "Test Group With Spaces" with path /thePathF
    delete group "Test Group"
    set ACL on /content
        allow jcr:read for "Test Group",user1
    end
    set ACL on /content
        allow jcr:read for "Test Group- Cool People","Test Group",user1
    end
    set ACL for user1,"Test Group",u2
        allow jcr:read on /content
    end
    set principal ACL for user1,"Test Group" (ACLOptions=mergePreserve)
        remove * on /libs,/apps
        allow jcr:read on /content
    end
    set ACL on /test (ACLOptions=merge)
        remove * for user1,"Test Group",user2
    end
    set properties on authorizable(bob), authorizable("Test Group")
      set stringProp to "hello, you again!"
    end
    set properties on authorizable(bob)/nested, authorizable("Test Group")/nested
      set stringProp to "hello, you nested again!"
    end
    add user1,"Test Group 2000",user2 to group "Parent Group"
    remove user1,"Test Group 2000",user2 from group "Parent Group"
    
    # Test other escaped characters 
    create group "Tab	Group"
    create group "Untrimmed Group "
    create group " Really Untrimmed Group "
    create group "Group\With\Backslash"
    create group "Group
    Newline"
    

