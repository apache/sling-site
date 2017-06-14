title=Scheduler Service (commons scheduler)		
type=page
status=published
~~~~~~

The scheduler is a service for scheduling other services/jobs (it uses the open source Quartz library). The scheduler can be used in two ways, by registering the job through the scheduler API and by leveraging the whiteboard pattern that is supported by the scheduler. In most cases the whiteboard pattern is preferred

<div class="note">
The notion of Job used in this context is a different one than the one used for <a href="/documentation/bundles/apache-sling-eventing-and-job-handling.html">Sling Jobs</a>. The main difference is that a scheduler's job is not persisted.
</div>

## Examples of jobs that are scheduled by leveraging the whiteboard pattern

The following examples show you how to define and schedule a job by leveraging the whiteboard pattern.

### Scheduling with a cron expression

The following job is executed every minute by setting *scheduler.expression* to the cron expression *"0 * * * * ?"*:


package sling.docu.examples;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Service;
import org.apache.felix.scr.annotations.Property;

@Component
@Service(value = Runnable.class)
@Property( name = "scheduler.expression", value = "0 * * * * ?")
public class ScheduledCronJob implements Runnable {

/** Default log. */
protected final Logger log = LoggerFactory.getLogger(this.getClass());

public void run() {
log.info("Executing a cron job (job#1) through the whiteboard pattern");
}
//
}


### Scheduling at periodic times

The following job is executed every ten seconds by setting *scheduler.period* to *10*:


package sling.docu.examples;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Service;
import org.apache.felix.scr.annotations.Property;

@Component
@Service(value = Runnable.class)
@Property( name = "scheduler.period", longValue = 10)
public class ScheduledPeriodicJob implements Runnable {

/** Default log. */
protected final Logger log = LoggerFactory.getLogger(this.getClass());

public void run() {
log.info("Executing a perodic job (job#2) through the whiteboard pattern");
}
//
}


### Preventing concurrent execution

By default, jobs can be concurrently executed. To prevent this, set the *scheduler.concurrent* property to *false*:


@Property(name="scheduler.concurrent", boolValue=false)

### Scheduling the job just once in a cluster

If the same code/same services is executed on multiple nodes within a cluster, the same job might be scheduled on each instance. If this is not desired, the job can either be bound to the leader of the topology or a single instance (which one this is, is not further defined):

@Property(name="scheduler.runOn", value="LEADER");

or

@Property(name="scheduler.runOn", value="SINGLE");

Since in contrast to [Sling Jobs](/documentation/bundles/apache-sling-eventing-and-job-handling.html) the scheduler queue is only held in memory, there will be no distribution of jobs. So if job '1' was scheduled on instance 'a' with the option to run on the leader only, but the leader is instance 'b', which hasn't the job in the queue, the job will never be executed by any instance!

## The Scheduler API

The scheduler has methods to execute jobs periodically, based on a cron expression or at a given time. For more details please refer to the [javadocs](http://sling.apache.org/apidocs/sling6/org/apache/sling/commons/scheduler/Scheduler.html).

## Examples of scheduled jobs registered through the scheduler API

The following examples show you how to define and schedule a job that is registered through the scheduler api.

### Defining the job

The following code sample defines a *job* object that writes a message in the logs:


final Runnable job = new Runnable() {
public void run() {
log.info("Executing the job");
}
};


### Scheduling with a cron expression

To execute the job as defined above at 10:15am every Monday, Tuesday, Wednesday, Thursday and Friday, you can use the *addJob()* method with the following parameters:


String schedulingExpression = "0 15 10 ? * MON-FRI";
this.scheduler.addJob("myJob", job, null, schedulingExpression, true);


Refer to http://www.docjar.com/docs/api/org/quartz/CronTrigger.html
to define more scheduling expressions.

### Scheduling at periodic times

To execute the job as defined above every 3 minutes (180 seconds), you can use the *addPeriodicJob()* method with the following parameters:


long period = 3*60; //the period is expressed in seconds
this.scheduler.addPeriodicJob("myJob", job, null, period, true);


### Scheduling at a given time

To execute the job as defined above at a specific date (on January 10th 2020), you can use the *fireJobAt()* method with the following parameters:


SimpleDateFormat formatter = new SimpleDateFormat("yyyy/MM/dd");
String date = "2020/01/10";
java.util.Date fireDate = formatter.parse(date);
this.scheduler.fireJobAt("myJob", job, null, fireDate);



### A service scheduling the job based on 3 different kinds of scheduling

The code implementing a service that simultaneously executes the job based on 3 different kinds of scheduling can look as follows:


package sling.docu.examples;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.sling.commons.scheduler.Scheduler;
import org.osgi.service.component.ComponentContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Reference;

/**
*  This service executes scheduled jobs
*
*/
@Component
public class HelloWorldScheduledService {

/** Default log. */
protected final Logger log = LoggerFactory.getLogger(this.getClass());

/** The scheduler for rescheduling jobs. */
@Reference
private Scheduler scheduler;


protected void activate(ComponentContext componentContext) throws Exception {
//case 1: with addJob() method: executes the job every minute
String schedulingExpression = "0 * * * * ?";
String jobName1 = "case1";
Map<String, Serializable> config1 = new HashMap<String, Serializable>();
boolean canRunConcurrently = true;
final Runnable job1 = new Runnable() {
public void run() {
log.info("Executing job1");
}
};
try {
this.scheduler.addJob(jobName1, job1, config1, schedulingExpression, canRunConcurrently);
} catch (Exception e) {
job1.run();
}

//case 2: with addPeriodicJob(): executes the job every 3 minutes
String jobName2 = "case2";
long period = 180;
Map<String, Serializable> config2 = new HashMap<String, Serializable>();
final Runnable job2 = new Runnable() {
public void run() {
log.info("Executing job2");
}
};
try {
this.scheduler.addPeriodicJob(jobName2, job2, config2, period, canRunConcurrently);
} catch (Exception e) {
job2.run();
}

//case 3: with fireJobAt(): executes the job at a specific date (date of deployment + delay of 30 seconds)
String jobName3 = "case3";
final long delay = 30*1000;
final Date fireDate = new Date();
fireDate.setTime(System.currentTimeMillis() + delay);
Map<String, Serializable> config3 = new HashMap<String, Serializable>();
final Runnable job3 = new Runnable() {
public void run() {
log.info("Executing job3 at date: {} with a delay of: {} seconds", fireDate, delay/1000);
}
};
try {
this.scheduler.fireJobAt(jobName3, job3, config3, fireDate);
} catch (Exception e) {
job3.run();
}
}

protected void deactivate(ComponentContext componentContext) {
log.info("Deactivated, goodbye!");
}

}




