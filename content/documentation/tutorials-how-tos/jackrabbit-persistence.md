title=Jackrabbit Persistence		
type=page
status=published
~~~~~~

Out-of-the-box the embedded Jackrabbit repository used by Sling (the Embedded Jackrabbit Repository bundle) uses Derby to persist the JCR nodes and properties. For some applications or environments it may be required or required to replace Derby with another backing store such as PostgreSQL or Oracle.

This page is based on the journey of Tony Giaccone to get Sling running with a PostgreSQL based Jackrabbit instance.


## Management Summary

To replace Derby as the persistence manager for Jackrabbit the following steps are required:

1. Provide a JDBC driver for your database as an OSGi bundle
1. Reconfigure Jackrabbit to use your database
1. (Re-) Start the Embedded Jackrabbit bundle

When you are not using the Derby persistence manager, you may safely remove the Derby bundle from your Sling instance.


## JDBC Driver

The hardest thing to do is probably getting the JDBC driver for your database. One option is to look at the bundles provided by Spring Source in their repository at <http://www.springsource.com/repository/>.

Another option is to create the bundle on your own using Peter Kriens' [bnd Tool](http://bnd.bndtools.org/):

1. Get the JDBC driver for your database from the driver provider
1. Wrap the JDBC driver library into an OSGi bundle:

:::sh
# Example for PostgreSQL JDBC 3 driver 8.4-701
$ java -jar bnd.jar wrap postgresql-8.4-701.jdbc3.jar
$ mv postgresql-8.4-701.jdbc3.bar postgresql-8.4-701.jdbc3-bnd.jar

1. Deploy the driver to your local Maven 2 Repository (Required if adding the JDBC driver to a Maven build, e.g. using the Sling Launchpad Plugin)

:::sh
$ mvn install:install-file
-DgroupId=postgresql -DartifactId=postgresql -Dversion=8.4.701.jdbc3
-Dpackaging=jar -Dfile=postgresql-8.4-701.jdbc3-bnd.jar


Tony reports no success with the Spring Source bundle, whily the bnd approach worked for the PostgreSQL JDBC driver.


## Replace Derby in a running Sling Instance

To replace Derby in a running Sling instance follow these steps (e.g. through the Web Console at `/system/console`):

1. Uninstall the Apache Derby bundle
1. Install the JDBC bundle prepared in the first step
1. Stop the Jackrabbit Embedded Repository bundle
This needs to be reconfigured and restarted anyway. So lets just stop it to prevent failures in the next step.
1. Refresh the packages (click the *Refresh Packages* button)

Alternatively, you may wish to stop Sling after uninstalling Derby and installing the JDBC bundle. Technically, this is not required, though.


## Reconfiguring Jackrabbit

To actually use a persistence manager other than the default (Derby) persistence manager, you have to configure Jackrabbit to use it. Create a `repository.xml` file in the `sling/jackrabbit` folder before starting Sling for the first time. If the repository was already started, you can also modify the existing file.

To prepare a repository.xml file before first startup, use the [`repository.xml`](http://svn.apache.org/repos/asf/sling/trunk/bundles/jcr/jackrabbit-server/src/main/resources/repository.xml) as a template and modify it by replacing the `<PersistenceManager>` elements to refer to the selected persistence manager.

If the file already exists, you can modifiy this existing file and there is no need to get the original from the SVN repository.

For example to use PostgreSQL instead of Derby modify the `<PersistenceManager>` elements as follows:

:::xml
<Repository>
...
<Workspace name="${wsp.name}">
...
<PersistenceManager class="org.apache.jackrabbit.core.persistence.bundle.PostgreSQLPersistenceManager">
<param name="driver" value="org.postgresql.Driver"/>
<param name="url" value="jdbc:postgresql://localhost:5432/YOUR_DB_NAME_HERE"/>
<param name="schema" value="postgresql"/>
<param name="user" value="YOUR_USER_HERE"/>
<param name="password" value="YOUR_PASSWORD_HERE"/>
<param name="schemaObjectPrefix" value="jcr_${wsp.name}_"/>
<param name="externalBLOBs" value="false"/>
</PersistenceManager>
...
</Workspace>

<Versioning rootPath="${rep.home}/version">
...
<PersistenceManager class="org.apache.jackrabbit.core.persistence.bundle.PostgreSQLPersistenceManager">
<param name="driver" value="org.postgresql.Driver"/>
<param name="url" value="jdbc:postgresql://localhost:5432/YOUR_DB_NAME_HERE"/>
<param name="schema" value="postgresql"/>
<param name="user" value="YOUR_USER_HERE"/>
<param name="password" value="YOUR_PASSWORD_HERE"/>
<param name="schemaObjectPrefix" value="version_"/>
<param name="externalBLOBs" value="false"/>
</PersistenceManager>
</Versioning>
...
</Repository>


Modify the `url`, `user`, and `password` parameters to match your database setup.

If you reconfigure Jackrabbit to use the new persistence manager, the existing repository data in the `sling/jackrabbit` directory, except the `repository.xml` file, of course, should now be removed.

Finally either start Sling or start the Jackrabbit Embedded Repository bundle.


## Credits

This description is based on Tony Giaccone's description [Swapping Postgres for Derby](http://markmail.org/message/wlbfrukmjjsl33hh) sent to the Sling Users mailing list.
