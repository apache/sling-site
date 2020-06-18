title=How to Create a Composite NodeStore with the Feature Model
type=page
status=published
tags=featuremodel,sling,kickstarter
~~~~~~

### About this How-To

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00;">

#### What we'll explore: 

* Create a Sling instance with a Composite NodeStore using the Feature Model
* Learn why it's a good idea to segment your application from your content

#### What you should know: 

* Skill Level: Intermediate
* Environment: Windows/Unix
* Time: 20 minutes

</div>

* Back To: [How to Create a Custom Feature Model Project](/documentation/feature-model/howtos/sling-with-custom-project.html)
* Back to the: [Feature Model How-To Guide](/documentation/feature-model/feature-model-howto.html)

### Prerequisites

In order to follow this how-to you'll need the following on your computer:

* Java 8
* Maven 3
* Bash shell


### What's the Composite NodeStore

A Composite NodeStore is a repository composed of two or more nodestores. The nodestores work together
to provide a single logical repository. Like a UNIX file system, each nodestore acts similar to
file system mount points. For example, you can mount the `/content` node as read-write and the
`/apps` and `/libs` nodes as read-only.


### Why use a Composite NodeStore

The Composite NodeStore can be used to improve the stability of your site. In general, you can think
of a Sling site as consisting of two parts: your content (which changes often) and your application
(which changes periodically). Unless there's a scheduled application release, there's very little
reason to allow a running Sling instance to be changed from a code/application perspective. 

It provides a great way to ensure that application changes are not allowed without an 
official release, but still allow day-to-day editorial content changes. Some of the benefits of using
the Composite NodeStore and separating your content and application concerns are:

* Improve site stability 
* Minimize downtime with blue-green deployments
* Use CI/CD pipelines to release immutable versions of your application
* Easily update/rollback your application without impacting your valuable content
* Ensure your site is always up-to-date and current


<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00;">

For those of you familiar with container orchestration platforms like Kubernetes (k8s), can you
think of a reason why the Composite NodeStore may be useful for Sling applications in the container world?

</div>

 
### Explanation on what will happen

Let's take a quick look at what will happen behind the scenes as we work through this tutorial. 

1. First, we'll start Sling using a regular nodestore. We'll call this our _seed_ step as it'll allow
   us to bootstrap our instance with our application code. When we're done with the _seeding_ process,
   we'll have our application fully populated in the `/apps` and `/libs` JCR nodes. These nodes will
   later become read-only.
2. Once Sling has started for the first time and completed the seeding process, we'll stop the instance.
3. Then, we'll designate the seeded repository as our read-only segment store.
4. Lastly, we'll start Sling in _composite mode_. When Sling comes up it will create another nodestore,
   called _global_ that will function as our read-write portion of the repository. At this point, your
   application can't be changed while the Sling instance is running.


### Step 1: Obtain the Kickstarter module

<div style="background: #fff3cd; padding: 14px; border-left: 10px solid #ffeeba;">

**Note:** These instructions will be updated to use the binary release once an official Sling Feature Model JSON file is released.

</div>

Build the Kickstarter and install it into your local Maven repository.

    $ git clone https://github.com/apache/sling-org-apache-sling-kickstart.git
    $ cd sling-org-apache-sling-kickstart
    $ mvn clean install

### Step 2: Initialize (seed) the repository

Start Sling for the first time using the seed creation script.

    $ ./bin/create_seed_fm.sh

This script uses the Kickstarter to start Sling with two Feature Models:

1. `feature-sling12-two-headed.json` - Our main Feature Model. Sling Feature Model without a NodeStore
2. `feature-two-headed-seed.json` - Additional Feature Model. Feature Model with a single NodeStore

When you see the line below, Sling has been fully initialized and should be safely stopped by entering `<CTRC>+C`.

    ESAPI: SUCCESSFULLY LOADED validation.properties via the CLASSPATH from '/ (root)'...

<div style="background: #fff3cd; padding: 14px; border-left: 10px solid #ffeeba;">

**TODO:** Add more detail on what happens during the seeding process. 

</div>


### Step 3: Start Sling using the Composite NodeStore

Now, let's start Sling a second time using the Composite NodeStore.

    $ ./bin/run_composite_fm.sh


<div style="background: #fff3cd; padding: 14px; border-left: 10px solid #ffeeba;">

**TODO:** Add more detail on what happens during the composite startup process. 

</div>


### Step 4: Verify read-only and read-write nodes

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00;">

The next set of steps uses the _SlingPostSevlet_ and cURL to test the read-write and read-only portions of 
the repository. If you prefer not to use cURL, simply [log into Sling](http://localhost:8080), navigate to 
[Composum](http://localhost:8080/bin/browser.html) and manipulate the nodes by hand.

</div>


**1.** Let's start by making a post request and add a JCR property to the `/content` node. 

    $ curl -s -v -u admin:admin -FtestProperty='I can write to the content node' \
          'http://localhost:8080/content/slingshot' > /dev/null
    ...
    < HTTP/1.1 200 OK
    ...

Since this is a read-write repository path, you should receive an _HTTP 200 OK_ response and be able to write to a property called 
`testProperty` with the value `I can write to the content node` on the `/content/slingshot` node.

**2.** Now, let's try the same test, but let's attempt to write to a read-only node.

    $ curl -s -v -u admin:admin -FtestProperty='I cannot write to the apps node' \
          'http://localhost:8080/apps/slingshot' > /dev/null
    ...
    < HTTP/1.1 500 Server Error
    ...

You should now receive an _HTTP 500 error_ response. So, even as the admin user you can't write to the `/apps` section of the repository. 


## Mission Accomplished

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00; margin-bottom: 1em;">

#### What we learned: 

* The benefits of running a repository comprised of read-only and read-write nodes
* How to run Sling using the Composite Nodestore
* Even as the admin user, we can't make changes to read-only nodes

</div>

If you stick with us, we'll show you how to convert an existing Provisioning Model to a Feature Model..

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00; margin-bottom: 1em;">

* Next Up: [How to Convert a Provisioning Model to a Feature Model](/documentation/feature-model/howtos/create-sling-fm.html)
* Back To: [How to Create a Custom Feature Model Project](/documentation/feature-model/howtos/sling-with-custom-project.html) 

</div>
