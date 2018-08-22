title=Leveraging @NotNull/@Nullable annotations to prevent NullPointerExceptions
type=page
status=published
tags=development
~~~~~~

[TOC]

# Introduction

The Sling API forces developers to sometimes check for `null` return values. Most prominently this is the case for [`Adaptable.adaptTo`](https://sling.apache.org/apidocs/sling8/org/apache/sling/api/adapter/Adaptable.html#adaptTo-java.lang.Class-) and [`ResourceResolver.getResource`](https://sling.apache.org/apidocs/sling8/org/apache/sling/api/resource/ResourceResolver.html#getResource-java.lang.String-). This is often forgotten, which may lead to `NullPointerException`s. Sling API 2.9.0 introduced the JSR-305 annotations ([SLING-4377](https://issues.apache.org/jira/browse/SLING-4377)) which allow tools to check automatically for missing null checks in the code. Since Sling API 2.18.4 JetBrains NotNull annotations are used instead.

# Annotations

The annotations used within Sling are based on the [Jetbrains Annotations][jetbrains-annotations-docs]. Although introduced by the company that offers the IntelliJ IDEA IDE,  those annotations are understood by most of the tools and used by other Apache Projects like Apache Oak.

Sling only uses the following two annotations:

1. `org.jetbrains.annotations.NotNull` (on return values and arguments which are never supposed to be `null`)
2. `org.jetbrains.annotations.Nullable` (only on return values which may be `null`)

Annotations which support setting the default null semantics of return values and or parameters on a package level are not used.

In case no annotations have been set on method arguments those accept `null` as a value. Return values should always be explicitly annotated, as from both cases checks can be derived.

# Use With Eclipse

Eclipse since Juno supports [null analysis based on any annotations](http://help.eclipse.org/juno/index.jsp?topic=%2Forg.eclipse.jdt.doc.user%2Freference%2Fpreferences%2Fjava%2Fcompiler%2Fref-preferences-errors-warnings.htm&anchor=null_analysis). Those need to be enabled in 
*Preferences->Java->Compiler->Errors/Warnings* via **Enable annoation-based null analysis**.
Also the annotations need to be configured. For Sling/JSR 305 those are

* `org.jetbrains.annotations.NotNull` as **'Nullable' annotation** (primary annotation)
* `org.jetbrains.annotations.Nullable` as **'NonNull' annotation** (primary annotation)
  
![Eclipse Settings for Null analysis](eclipse-settings-null-analysis.png)

Unfortunately Eclipse cannot infer information about fields which are for sure either null or not null (reasoning is available in [https://wiki.eclipse.org/JDT_Core/Null_Analysis/Options#Risks_of_flow_analysis_for_fields](https://wiki.eclipse.org/JDT_Core/Null_Analysis/Options#Risks_of_flow_analysis_for_fields) and [Eclipse Bug 247564](https://bugs.eclipse.org/bugs/show_bug.cgi?id=247564)). This also affecs constants (static final fields) or enums which are known to be non null, but still Eclipse will emit a warning like *The expression of type 'String' needs unchecked conversion to conform to '@Nonnull String'*. The only known workaround is to disable the **"Unchecked conversion from non-annotated type to @NonNull type"** or to annotate also the field with `@Nonnull`.

More information are available at [https://wiki.eclipse.org/JDT_Core/Null_Analysis](https://wiki.eclipse.org/JDT_Core/Null_Analysis).

Since Eclipse 4.5 (Mars) **external annotations** are supported as well (i.e. annotations maintained outside of the source code of the libraries, e.g. for the JRE, Apache Commons Lang). There are some external annotations being mainted at [lastnpe.org](http://www.lastnpe.org/) and [TraceCompass](https://github.com/tracecompass/tracecompass/tree/master/common/org.eclipse.tracecompass.common.core/annotations). There is no official repository yet though ([Eclipse Bug 449653](https://bugs.eclipse.org/bugs/show_bug.cgi?id=449653)).
[Lastnpe.org](http://www.lastnpe.org/) provides also an m2e extension to ease setting up the classpaths with external annotations from within your pom.xml.

# Use With Maven

## Leveraging Eclipse JDT Compiler (recommended)

You can use Eclipse JDT also in Maven (with null analysis enabled) for the regular compilation. That way it will give out the same warnings/errors as Eclipse and will also consider external annotations. 
JDT in its most recent version is provided by the `tycho-compiler-plugin` which can be hooked up with the `maven-compiler-plugin`.
The full list of options for JDT is described in [here](http://help.eclipse.org/neon/index.jsp?topic=%2Forg.eclipse.jdt.doc.user%2Ftasks%2Ftask-using_batch_compiler.htm).
This method was presented by Michael Vorburger in his presentation [The end of the world as we know it](https://www.slideshare.net/mikervorburger/the-end-of-the-world-as-we-know-it-aka-your-last-nullpointerexception-1b-bugs/14).

    ::xml
    <plugin>
      <artifactId>maven-compiler-plugin</artifactId>
      <version>3.5.1</version>
      <configuration>
        <source>1.8</source>
        <target>1.8</target>
        <showWarnings>true</showWarnings>
        <compilerId>jdt</compilerId>
        <compilerArguments>
          <!-- just take the full Maven classpath as external annotations -->
          <annotationpath>CLASSPATH</annotationpath>
        </compilerArguments>
        <!-- maintain the org.eclipse.jdt.core.prefs properties to options listed on
             http://help.eclipse.org/neon/index.jsp?topic=/org.eclipse.jdt.doc.user/tasks/task-using_batch_compiler.htm -->
        <compilerArgument>-err:nullAnnot,null,-missingNullDefault</compilerArgument>
     </configuration>
     <dependencies>
        <dependency>
           <groupId>org.eclipse.tycho</groupId>
           <artifactId>tycho-compiler-jdt</artifactId>
           <version>1.0.0</version>
        </dependency>
      </dependencies>
    </plugin>

## Leveraging FindBugs
You can also let Maven automatically run FindBugs to execute those checks via the **findbugs-maven-plugin**. For that just add the following plugin to your `pom.xml`

    ::xml
    <plugin>
      <groupId>org.codehaus.mojo</groupId>
      <artifactId>findbugs-maven-plugin</artifactId>
      <version>3.0.0</version>
      <configuration>
      <visitors>InconsistentAnnotations,NoteUnconditionalParamDerefs,FindNullDeref,FindNullDerefsInvolvingNonShortCircuitEvaluation</visitors>
      </configuration>
      <executions>
        <execution>
          <id>run-findbugs-fornullchecks</id>
          <goals>
            <goal>check</goal>
          </goals>
        </execution>
      </executions>
    </plugin>
    

The results are often very imprecise ([MFINDBUGS-208](http://jira.codehaus.org/browse/MFINDBUGS-208)), especially when it comes to line numbers, therefore it is best to start the Findbugs GUI in case of errors found by this plugin via `mvn findbugs:gui`.


# Use With FindBugs
FindBugs evaluates the JSR-305 annotations by default. You can restrict the rules to only the ones which check for those annotations, which are

* InconsistentAnnotations
* NoteUnconditionalParamDerefs
* FindNullDeref
* FindNullDerefsInvolvingNonShortCircuitEvaluation

A complete list of visitors class names in Findbugs can be found in the [sourcecode](https://code.google.com/p/findbugs/source/browse/#git%2Ffindbugs%2Fsrc%2Fjava%2Fedu%2Fumd%2Fcs%2Ffindbugs%2Fdetect%253Fstate%253Dclosed). The according [bug patterns](http://findbugs.sourceforge.net/bugDescriptions.html) have an identifier (in parenthesis) for which you can search in the according Java classes, in case you want to extend the checks.

Findbugs is also integrated in [SonarQube](http://docs.sonarqube.org/display/SONAR/Findbugs+Plugin) but for SonarQube you should now rather use the native Java plugin 
(look at [Use with SonarQube](#use-with-sonarqube)).

# Use with SonarQube

At least rule [squid:S2259](https://sonarqube.com/coding_rules#rule_key=squid%3AS2259) in SonarQube supports JSR-305 annotations as well for null checks.



[jetbrains-annotations-docs]: https://www.jetbrains.com/help/idea/nullable-and-notnull-annotations.html
