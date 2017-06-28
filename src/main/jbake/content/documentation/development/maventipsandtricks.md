title=MavenTipsAndTricks		
type=page
status=published
~~~~~~

Here's our collection of tips and tricks for building Sling with [Maven](http://maven.apache.org).

# Maven local repository

The first time you run a Maven build, or when Maven needs additional build components, it downloads plugins and dependencies under its *local repository* folder on your computer. By default, this folder is named *.m2/repository* in your home directory.

Maven uses this repository as a cache for artifacts that it might need for future builds, which means that the first Sling build usually takes much longer than usual, as Maven needs to download many tools and dependencies into its local repository while the build progresses.

The build might fail if one of those downloads fails, in that case it might be worth retrying the build, to check if that was just a temporary connection problem, or if there's a more serious error.

In some cases, the local Maven repository might get corrupted - if your build fails on a computer and works on another one, clearing the local repository before restarting the build might be worth trying.

# Maven settings

## Ignore your local settings
To make sure you're getting the same results as we are when building Sling, it is recommend to ignore any local settings.

On unixish platforms, using


    mvn -s /dev/null ...


does the trick.

<div class="note">
Does anyone have a similar command-line option that works under Windows?
</div>

# MAVEN_OPTS
The MAVEN_OPTS environment variable defines options for the JVM that executes Maven.

Set it according to your platform, i.e. `export MAVEN*OPTS=...` on unixish systems or `set MAVEN*OPTS=...` on Windows.

## Increase JVM memory if needed
If getting an OutOfMemoryException when running mvn, try setting


    MAVEN_OPTS="-Xmx256M -XX:MaxPermSize=256m"


to allocate 256MB of RAM to Maven.

## Debugging code launched by Maven
To run the Sling launchpad webapp in debug mode from Maven, for example, use something like


    MAVEN_OPTS="-agentlib:jdwp=transport=dt_socket,address=30303,server=y,suspend=n"


And then connect to port 30303 with a remote JVM debugger (most IDEs do this).

## Avoid spaces in Maven repository and workspace paths
Some Maven plugins do not like spaces in paths. It is better to avoid putting your Maven repository, or your code, under paths like *Documents and Settings*, for example.
