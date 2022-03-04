title=Apache Sling Eventing and Job Handling		
type=page
status=published
tags=core,events
~~~~~~


## Overview

The Apache Sling Event Support bundle adds additional features to the OSGi Event Admin and for distributed event processing.

The bundle provides the following features

* [Jobs](#jobs-guarantee-of-processing)
* [Distributed Events](#distributed-events)
* [Scheduled Events](#sending-scheduled-events)

To get some hands on code, you can refer to the following tutorials:

* [How to Manage Events in Sling](/documentation/tutorials-how-tos/how-to-manage-events-in-sling.html)
* [Scheduler Service (commons scheduler)](/documentation/bundles/scheduler-service-commons-scheduler.html)

## Jobs (Guarantee of Processing)

In general, the eventing mechanism (OSGi EventAdmin) has no knowledge about the contents of an event. Therefore, it can't decide if an event is important and should be processed by someone. As the event mechanism is a "fire event and forget about it" algorithm, there is no way for an event admin to tell if someone has really processed the event. Processing of an event could fail, the server or bundle could be stopped etc.

On the other hand, there are use cases where the guarantee of processing is a must and usually this comes with the requirement of processing exactly once. Typical examples are sending notification emails (or sms), post processing of content (like thumbnail generation of images or documents), workflow steps etc.

The Sling Event Support adds the notion of a job. A job is a special event that has to be processed exactly once. 
To be precise, the processing guarantee is at least once. However, the time window for a single job where exactly
once can't be guaranteed is very small. It happens if the instance which processes a job crashes after the job 
processing is finished but before this state is persisted. Therefore a job consumer should be prepared to process
a job more than once. Of course, if there is no job consumer for a job, the job is never processed. However this
is considered a deployment error.

The Sling Jobs Processing adds some overhead, so in some cases it might be better to use just the [Commons Scheduler Service](/documentation/bundles/scheduler-service-commons-scheduler.html) or the [Commons Thread Pool](/documentation/bundles/apache-sling-commons-thread-pool.html) for asynchronous execution of code.

While older versions of the job handling were based on sending and receiving events through the OSGi event admin, newer versions provide enhanced support through special Java interface. This approach is preferred over the still supported but deprecated event admin way.

A job consists of two parts, the job topic describing the nature of the job and the payload which is a key value map of serializable objects. A client can initiate a job by calling the *JobManager.addJob* method:

        import org.apache.sling.jobs.JobManager;
        import org.osgi.service.component.annotations.Component;
        import org.osgi.service.component.annotations.Reference;
        import java.util.Map;
        import java.util.HashMap;
        
        @Component
        public class MyComponent {
        
            @Reference
            private JobManager jobManager;
            
            public void startJob() {
                final Map<String, Object> props = new HashMap<String, Object>();
                props.put("item1", "/something");
                props.put("count", 5);
                
                jobManager.addJob("my/special/jobtopic", props);
            }        
        }

The job topic follows the conventions for the topic of an OSGi event. All objects in the payload must be serializable and publically available (exported by a bundle). This is required as the job is persisted and unmarshalled before processing.

As soon as the method returns from the job manager, the job is persisted and the job manager ensures that this job will be processed exactly once.

### JobBuilder

Instead of creating the jobs by calling `JobManager.addJob("my/special/jobtopic", props);` the `JobBuilder` can be used, which is retrieved via `JobManager.createJob("my/special/jobtopic")`. The last method being called on the `JobBuilder` must be `add(...)`, which finally adds the job to the queue.


### Scheduled Jobs

Scheduled Jobs are put in the queue at a specific time (optionally periodically). For that the `ScheduleBuilder` must be used which is retrieved via `JobBuilder.schedule()`.

An example code for scheduling a job looks like this:

    import org.apache.sling.jobs.JobManager;
    import org.apache.sling.event.jobs.JobBuilder.ScheduleBuilder;
    import org.osgi.service.component.annotations.Component;
    import org.osgi.service.component.annotations.Reference;

    @Component(immediate=true)
    public class MyComponent {

        private static final String TOPIC = "midnight/job/topic";

        @Reference
        private JobManager jobManager;

        public void startScheduledJob() {
            if (JobManager.getJobScheduledJobs(TOPIC,1,null) == null) {
                // only add the jobs if it is not yet scheduled
                ScheduleBuilder scheduleBuilder = jobManager.createJob(TOPIC).schedule();
                scheduleBuilder.daily(0,0); // execute daily at midnight
                if (scheduleBuilder.add() == null) {
                    // something went wrong here, use scheduleBuilder.add(List<String>) instead to get further information about the error
	            }
            }
        }
    }


Internally the scheduled Jobs use the [Commons Scheduler Service](/documentation/bundles/scheduler-service-commons-scheduler.html). But in addition they are persisted (by default below `/var/eventing/scheduled-jobs`) and survive therefore even server restarts. When the scheduled time is reached, the job is automatically added as regular Sling Job through the `JobManager`.


### Job Consumers

A job consumer is a service consuming and processing a job. It registers itself as an OSGi service together with a property defining which topics this consumer can process:

        import org.osgi.service.component.annotations.Component;
        import org.apache.sling.event.jobs.Job;
        import org.apache.sling.event.jobs.consumer.JobConsumer;

        @Component(service=JobConsumer.class, property= {
        	JobConsumer.PROPERTY_TOPICS + "=my/special/jobtopic"
        })
        public class MyJobConsumer implements JobConsumer {

            public JobResult process(final Job job) {
                // process the job and return the result
                return JobResult.OK;
            }
        }
The consumer can either return *JobResult.OK* indicating that the job has been processed, *JobResult.FAILED* indicating the processing failed, but can be retried or *JobResult.CANCEL* the processing has failed permanently.
   
### Job Executors
If the job consumer needs more features like providing progress information or adding more information of the processing,*JobExecutor* should be implemented.      
A job executor is a service processing a job. It registers itself as an OSGi service together with a property defining which topics this consumer can process:

        import org.osgi.service.component.annotations.Component;
        import org.apache.sling.event.jobs.Job;
        import org.apache.sling.event.jobs.consumer.JobExecutor;
        import org.apache.sling.event.jobs.consumer.JobExecutionContext;

        @Component(service=JobExecutor.class, property={
        	JobExecutor.PROPERTY_TOPICS + "=my/special/jobtopic"
        })
        public class MyJobExecutor implements JobExecutor {

            public JobExecutionResult process(final Job job, JobExecutionContext context)
                //process the job and return the result
                
                //initialize job progress with n number of steps
                context.getJobContext().initProgress(n, -1);
                context.getJobContext().log("Job initialized");
                
                //increment progress by 2 steps
                context.getJobContext().incrementProgressCount(2);
                context.getJobContext().log("2 steps completed.");
                
                //stop processing if job was cancelled
                if(context.isStopped()) {
                    context.getJobContext().log("Job Stopped after 4 steps.");
                    return context.result().message(resultMessage).cancelled();
                }
                
                //add job log
                context.getJobContext().log("Job finished.");
                
                return context.result().message(resultMessage).succeeded();
            }
        }
        
*JobExecutionContext* can be used by executor to update job execution progress, add job logs, build a JobExecutionResult and to check if job is still active by jobExecutionContext.isStopped().
The executor can return job result "succeeded" by calling JobExecutionContext.result(successMsg).succeeded(), job result "failed" by calling JobExecutionContext.result(errorMessage).failed() and  job result "cancelled" by calling JobExecutionContext.result(message).cancelled().
The *Job* interface allows to query the topic, the result message, progress, logs, the payload and additional information about the current job. 
     
### Job Handling

New jobs are first persisted in the resource tree (for failover etc.), then the job is distributed to an instance responsible for processing the job and on that instance the job is put into a processing queue. There are different types of queues defining how the jobs are processed (one after the other, in parallel etc.).

For managing queues, the Sling Job Handler uses the OSGi ConfigAdmin - it is possible to configure one or more queue configurations through the ConfigAdmin. One way of creating and configuring such configurations is the Apache Felix WebConsole. If there is no specific queue configuration maintained for the given job topic, the Sling Job Handler falls back to using the `Apache Sling Job Default Queue` (which can be configured through OSGi as well).

#### Queue Configurations

A queue configuration can have the following properties:

| Property Name | Description |
|---|---|
| `queue.name` | The name of the queue. If matching is used for topics, the value {0} can be used for replacing the matched part. |
| `queue.type` | The type of the queue: ORDERED, UNORDERED, TOPIC_ROUND_ROBIN |
| `queue.topics` | A list of topics processed by this queue. Either the concrete topic is specified or the topic string ends with /* or /. If a star is at the end all topics and sub topics match, with a dot only direct sub topics match. |
| `queue.maxparallel` | How many jobs can be processed in parallel? -1 for number of processors.|
| `queue.retries` | How often the job should be retried in case of failure (i.e. Job did not finish with succeeded or cancelled result). -1 for endless retries. In case of exceptions there is no retry. |
| `queue.retrydelay` | The waiting time in milliseconds between job retries. |
| `queue.priority` | The thread priority: NORM, MIN, or MAX |
| `service.ranking` | A ranking for this configuration.|

The configurations are processed in order of their service ranking. The first matching queue configuration is used for the job.

#### Ordered Queues

An ordered queue processes one job after the other.

#### Unordered Queues (or Parallel queues)

Unordered queues process jobs in parallel.

#### Topic-Round-Robin Queues

The jobs are processed in parallel. Scheduling of the jobs is based on the topic of the jobs. These are started by doing round-robin on the available topics.


### Job Distributing

For job distribution (= distributing the processing in a cluster), the job handling uses the topology feature from Sling - each instance in the topology announces the set of topics (consumers) it currently has - and this defines the job capabilities, a mapping from an instance to the topics it can process.

When a job is scheduled, the job manager uses these capabilities to find out the set of instances which is able to process the request. If the queue type is *ordered* then all jobs are processed by the leader of this set. For parallel queues, the jobs are distributed equally amongst those instance.

Failover is handled by the leader: if an instance dies, the leader will detect this through the topology framework and then redistribute jobs from the dead instance to the available instances. Of course this takes a leader change into account as well. In addition if the job capabilities change and this require a reschedule of jobs, that's done by the leader as well.

### Job Creation Patterns

The job manager ensures that a job is processed exactly once. However, the client code has to take care that a job is created exactly once. We'll discuss this based on some general usage patterns:

#### Jobs based on user action

If a user action results in the creation of a job, the thread processing the user action can directly create the job. This ensures that even in a clustered scenario the job is created only once.

#### Jobs in a clustered environment

Jobs are shared within all cluster members; if an observation event or any other OSGi event results in the creation of a job, special care needs to be taken to avoid that the job is created on all cluster instances. The easiest way to avoid this, is to use the topology API and make sure the job is only created on the leader instance.

Also attention should be spent when registering scheduled jobs; the API does not prevent you to register multiple instances of the same job for the same time. But typically this is not desired, but instead that event should be executed only once in the cluster at the specified time. To achieve this behavior always check if a job for the desired topic is already registered; and only in case it is not schedule that job. See the example at [Scheduled Jobs](#scheduled-jobs-1). 

You should not unschedule such a job in `@Deactivate` method of an OSGI Component. In a clustered environment with nodes starting and stopping in an often unexpected order and time this could lead to situations where the job is not scheduled and therefor not executed.



  
## Distributed Events

In addition to the job handling, the Sling Event support adds handling for distributed events. A distributed event is an OSGi event which is sent across JVM boundaries to a different VM. A potential use case is to broadcast information in a clustered environment.

### Basic Principles

The foundation of the distributed event mechanism is to distribute each event to every node in a clustered environment. The event distribution mechanism has no knowledge about the intent of the event and therefore is not able to make delivery decisions by itself. It is up to the sender to decide what should happen. The sender must explicitly declare an event to be distributed as for example framework related events (bundle stopped, installed etc.) should not be distributed.

The event mechanism will provide additional functionality making it easier for event receivers to decide if they should process an event. The event receiver can determine if the event is a local event or comming from a remote application node. Therefore a general rule of thumb is to process events only if they're local and just regard remote events as a FYI.

For distributed events two properties are defined (check the *EventUtil* class):

* *event.distribute* - this flag is set by the sender of an event to give a hint if the event should be distributed across instances. For example JCR observation based events are already distributed on all instances, so there is no further need to distribute them. If the flag is present, the event will be distributed. The value has currently no meaning, however the EventUtil method should be used to add this property. If the flag is absent the event is distributed locally only.
* *event.application* - An identifier for the current application node in the cluster. This information will be used to detect if an event has been created on different nodes. If the event has been created on the same node, the *event.application* is missing, if it is a remote event, the *event.application* contains the ID of the node, the event has been initially created. Use the *EventUtil.isLocal(Event)* method to detect if the event is a local or a distributed event.

While the *event.distribute* must be set by the sender of an event (if the event should be distributed), the *event.application* property is maintained by the event mechanism. Therefore a client sending an event should *never* set this information by itself. This will confuse the local event handlers and result in unexpected behaviour. On remote events the *event.application* is set by the event distribution mechanism.

### Event Distribution Across Application Nodes (Cluster)

The (local) event admin is the service distributing events locally. The Sling Distributing Event Handler is a registered event handler that is listening for events to be distributed. It distributes the events to remote application notes, Sling's resource tree is used for distribution. The distributing event handler writes the events into the resource tree, the distributing event handlers on other application nodes get notified through observation and then distribute the read events locally.

As mentioned above, the client sending an event has to mark an event to be distributed in a cluster by setting the *event.distribute* in the event properties (through *EventUtil*). This distribution mechanism has the advantage that the application nodes do not need to know each other and the distribution mechanism is independent from the used event admin implementation.

## Sending Scheduled Events

Scheduled events are OSGi events that have been created by the environemnt. They are generated on each application node of the cluster through an own scheduler instance. Sending these events works the same as sending events based on JCR events (see above).
