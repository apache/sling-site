title=How to Convert a Provisioning Model to a Feature Model
type=page
status=published
tags=featuremodel,sling,kickstarter
~~~~~~

### About this How-To

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00;">

#### What we'll explore: 

* We'll convert the Sling Starter project to a Feature Model using a Maven plugin
* We'll visit our old friend, the Kickstarter, and start Sling using the generated Feature Model

#### What you should know: 

* Skill Level: Intermediate 
* Environment: Windows/Unix
* Time: 20 minutes

</div>

* Back To: [How to Create a Composite NodeStore](/documentation/feature-model/howtos/create-sling-composite.html)
* Back to the: [Feature Model How-To Guide](/documentation/feature-model/feature-model-howto.html)


### Prerequisites

In order to follow this how-to you'll need the following on your computer:

* Java 8
* Maven 3
* Bash shell


### Create a Feature Model

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00;">

**Note:** At the time of this writing, the Feature Model is not officially used by Sling.
Until Sling is fully converted to the Feature Model, we'll have to use the
 _Provisioning to Feature Model Converter Plugin_. The plugin will create a Feature Model 
from each Provisioning Model file. The plugin will then assemble all the Feature Models
into a single Feature Model file using the Feature Aggregate.

</div>


### Step 1: Get Sling Starter and the Kickstarter projects

Start by creating a directory called `myfeaturemodel`. We'll use this directory as our
project workspace.

    $ mkdir myfeaturemodel

We'll add two projects to this workspace:

* The Sling Starter source code
* The Sling Kickstarter source code

        $ cd myfeaturemodel
        $ git clone https://github.com/apache/sling-org-apache-sling-starter.git
        $ git clone https://github.com/apache/sling-org-apache-sling-kickstart.git

Your workspace should now look like this:

    $ ls -l
    drwxr-xr-x  15 user group 480 Jun  8 16:16 sling-org-apache-sling-kickstart
    drwxr-xr-x  13 user group 416 Jun  8 16:10 sling-org-apache-sling-starter


### Step 2: Run the Provisioning Model Conversion

The Kickstarter provides a Maven POM file called `sling-fm-pom.xml`  that converts the Sling Starter Provisioning Models
to Feature Models. It then aggregates them into a single Feature Model.

    $ cd sling-org-apache-sling-kickstart
    $ mvn -f sling-fm-pom.xml install -Dsling.starter.folder=../sling-org-apache-sling-starter 

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00;">

Once the build is complete, you'll find a Feature Model file at
`sling-org-apache-sling-kickstart/target/slingfeature-tmp/feature-sling12.json`.

</div>


Before continuing, run one more Maven build in this directory as we will need a copy of the Kickstarter JAR in the next
section.

    $ mvn clean install


### Step 3: Run Sling using the Feature Model

Now that we have a Feature Model file for Sling and a Kickstarter JAR, we are ready to create a new directory
to execute Sling using the Kickstarter and the Feature Model we just created.

Begin, by changing into the parent workspace (`myfeaturemodel`) and create a new directory to run the Kickstarter.
Then, copy the Feature Model file and Kickstarter JAR.

    $ cd ..
    $ mkdir kickstart-run && cd kickstart-run
    $ cp ../sling-org-apache-sling-kickstart/target/slingfeature-tmp/feature-sling12.json .
    $ cp ../sling-org-apache-sling-kickstart/target/org.apache.sling.kickstart-0.0.3-SNAPSHOT.jar .

Lastly, let's start Sling using the Feature Model.

    $ java -jar org.apache.sling.kickstart-0.0.3-SNAPSHOT.jar -s feature-sling12.json


## Mission Accomplished

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00; margin-bottom: 1em;">

#### What we learned: 

* Learned that the _Provisioning to Feature Model Converter Plugin_ can be used to convert Provisioning Models to Feature Models
* Converted the Provisioning Models in the Sling Starter project to a single Feature Model
* Started Sling using the newly created Feature Model file with the Kickstarter

</div>

<div style="background: #cde0ea; padding: 14px; border-left: 10px solid #f9bb00; margin-bottom: 1em;">

* Back To: [How to Create a Composite NodeStore](/documentation/feature-model/howtos/create-sling-composite.html)

</div>
