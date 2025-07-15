title=Content Distribution (org.apache.sling.distribution)		
type=page
status=published
tags=contentdistribution
~~~~~~
[TOC]


## Introduction

The Sling Content Distribution (SCD) module allows one to distribute Sling resources between different Sling instances. The API works at path level and the distribution agents basically enable distribution of specific paths between instances. There are several main usecases in which SCD can help. Typically the distribution is done from one or more source instances to one or more target instances.

## Distribution usecases

Some of the usecases have sample configuration in [Distribution Sample Module](https://github.com/apache/sling/tree/trunk/contrib/extensions/distribution/sample/src/main/resources/SLING-CONTENT/libs/sling/distribution) and are tested in [Distribution ITs Module](https://github.com/apache/sling/tree/trunk/contrib/extensions/distribution/it).

### Forward distribution
A forward distribution setup allows one to transfer content from a source instance to a farm of target instances. That is done by pushing the content from source to target.

#### Setup overview

* one source instance
    * one distribution agent connected to importer endpoints for all target instances.   
* N target instances
    * one distribution importer on each target instance used to import packages into the local instance.

#### Sample configuration

* on source instance: one forward agent

        org.apache.sling.distribution.agent.impl.ForwardDistributionAgentFactory-publish.json            
            name="publish"
            packageImporter.endpoints=["http://localhost:4503/libs/sling/distribution/services/importers/default"]

* on target instance: one local importer

        org.apache.sling.distribution.packaging.impl.importer.LocalDistributionPackageImporterFactory-default
            name="default"

#### Trigger forward distribution

Forward distribution can be triggered by sending a `POST` HTTP request to the agent resource on the source instance with the parameter `action=ADD` and parameters `path=<resourcePath>`.

The example below distributes the path `/content/sample1`

    $ curl -v -u admin:admin http://localhost:8080/libs/sling/distribution/services/agents/publish -d 'action=ADD' -d 'path=/content/sample1'

#### Events

The following OSGi [events](https://github.com/apache/sling-org-apache-sling-distribution-api/blob/master/src/main/java/org/apache/sling/distribution/event) will be raised during the forward distribution process.

| Event                                                     | Instance |
| --------------------------------------------------------- | -------- |
| `org/apache/sling/distribution/agent/package/created`     | source   |
| `org/apache/sling/distribution/agent/package/queued`      | source   |
| `org/apache/sling/distribution/agent/package/distributed` | source   |
| `org/apache/sling/distribution/agent/package/dropped`     | source   |
| `org/apache/sling/distribution/importer/package/imported`    | target   |

### Reverse distribution

A reverse distribution setup allows one to transfer content from a farm of source instances to a target instance. That is done by pulling the content from source instances into the target instance.

#### Setup overview
* one target instance
    * one distribution agent connected to exporter endpoints for all target instances.   
* N source instances
    * one distribution (queue) agent on each source instance; changes from the source instances are placed in the queues of these agents.
    * one distribution exporter on each source instance that exports packages from the queue agent.

#### Sample configuration

* on target instance: one reverse agent

        org.apache.sling.distribution.agent.impl.ReverseDistributionAgentFactory-reverse.json            
            name="reverse"
            packageExporter.endpoints=["http://localhost:4503/libs/sling/distribution/services/exporters/reverse"]

* on source instance: one queue agent and one exporter for that agent

        org.apache.sling.distribution.agent.impl.QueueDistributionAgentFactory-reverse.json            
            name="reverse"

        org.apache.sling.distribution.packaging.impl.exporter.AgentDistributionPackageExporterFactory-reverse
            name="reverse"
            agent.target="(name=reverse)"


#### Trigger reverse distribution

Reverse distribution can be triggered by sending a `POST` HTTP request to the agent resource on the target instance with the parameter `action=PULL`.

The example below adds the the path `/content/sample1` and then reverse distribute it.

    $ curl -v -u admin:admin http://localhost:8081/libs/sling/distribution/services/agents/publish -d 'action=PULL' -d 'path=/content/sample1'

### Sync distribution

A sync distribution setup allows one to synchronize content in a farm of instances. That is done by using a coordinator instance (typically an author instance) that pulls content from all instances in a farm and pushes it back to all.

#### Setup overview:
* one coordinator instance
    * one distribution agent connected to exporter/importer endpoints for all farm instances.   
* N farm instances
    * one distribution (queue) agent on each farm instance; changes from these instances are placed in the queues of the queue agents.
    * one distribution exporter on each farm instance that exports packages from the queue agent.
    * one distribution importer on each farm instance used to import packages into the local instance.

#### Sample configuration

* on coordinator instance: one sync agent

        org.apache.sling.distribution.agent.impl.SyncDistributionAgentFactory-sync.json            
            name="sync"
            packageExporter.endpoints=["http://localhost:4503/libs/sling/distribution/services/exporters/reverse", "http://localhost:4504/libs/sling/distribution/services/exporters/reverse"]
            packageImporter.endpoints=["http://localhost:4503/libs/sling/distribution/services/importers/default", "http://localhost:4504/libs/sling/distribution/services/importers/default"]


* on each farm instance: one local exporter and one local importer

        org.apache.sling.distribution.agent.impl.QueueDistributionAgentFactory-reverse.json            
            name="reverse"

        org.apache.sling.distribution.packaging.impl.exporter.AgentDistributionPackageExporterFactory-reverse
            name="reverse"
            agent.target="(name=reverse)"

        org.apache.sling.distribution.packaging.impl.importer.LocalDistributionPackageImporterFactory-default
            name="reverse"
            agent.target="(name=reverse)"




### Multidatacenter sync distribution

A multidatacenter sync distribution setup allows one to synchronize content in a farm of publish instances across datacenters. This a variation of sync distribution but using a coordinator in each datacenter.

#### Setup overview

* one coordinator instance in each datacenter
    * one distribution agent for intra-datacenter synchronization. Like a regular sync agent it connects to all farm instances in its datacenter and syncronizes them. In addition to a regular sync agent it keeps the packages also in dedicated queues for the other DCs, so that the coordinators from the other DCs can pull the updates.
    * one distribution exporter for each queue dedicated for the remote DCs. The inter-dc coordinators from the other DCs will connect to these exporter endpoints.
    * one distribution agent for inter-datacenter synchronization; it conntects to the dedicated queues exposed by intra-dc coordinators from the other datacenters.
* N farm instances in each datacenter
    * one distribution (queue) agent on each farm instance; changes from these instances are placed in the queues of the queue agents.
    * one distribution exporter on each farm instance that exports packages from the queue agent.
    * one distribution importer on each farm instance used to import packages into the local instance.

#### Sample configuration


* on coordinator instance: one intradcsync agent with two exporters for the other dcs, and one interdcsync agent that connects to remote exporters.

        org.apache.sling.distribution.agent.impl.SyncDistributionAgentFactory-intradcsync          
            name="intradcsync"
            packageExporter.endpoints=["http://localhost:4503/libs/sling/distribution/services/exporters/reverse", "http://localhost:4504/libs/sling/distribution/services/exporters/reverse"]
            packageImporter.endpoints=["http://localhost:4503/libs/sling/distribution/services/importers/default", "http://localhost:4504/libs/sling/distribution/services/importers/default"]
            passiveQueues=["dc2queue", "dc3queue"]

        org.apache.sling.distribution.packaging.impl.exporter.AgentDistributionPackageExporterFactory-dc2queue
            name="dc2queue"
            agent.target="(name=intradcsync)"
            queue="dc2queue"

        org.apache.sling.distribution.packaging.impl.exporter.AgentDistributionPackageExporterFactory-dc3queue
            name="dc3queue"
            agent.target="(name=intradcsync)"
            queue="dc3queue"

        org.apache.sling.distribution.agent.impl.SyncDistributionAgentFactory-interdcsync           
            name="interdcsync"
            packageExporter.endpoints=["http://localhost:5502/libs/sling/distribution/services/exporters/dc1queue", "http://localhost:6502/libs/sling/distribution/services/exporters/dc1queue"]
            packageImporter.endpoints=["http://localhost:4503/libs/sling/distribution/services/importers/default", "http://localhost:4504/libs/sling/distribution/services/importers/default"]


* on each farm instance: one local exporter and one local importer

        org.apache.sling.distribution.agent.impl.QueueDistributionAgentFactory-reverse.json            
            name="reverse"

        org.apache.sling.distribution.packaging.impl.exporter.AgentDistributionPackageExporterFactory-reverse
            name="reverse"
            agent.target="(name=reverse)"

        org.apache.sling.distribution.packaging.impl.importer.LocalDistributionPackageImporterFactory-default
            name="default"




## Additional options

### How to configure binary-less distribution?

Binary-less distribution is supported for deployments over a shared data store and involving agents that leverage the
Vault based Distribution package exporter (Factory PID:
org.apache.sling.distribution.serialization.impl.vlt.VaultDistributionPackageBuilderFactory) package builder.

With binary-less mode enabled, the content packages distributed contain references to binaries rather than
the actual binaries.

SCD does not explicitly deal with binary references. Instead, it configures Apache Jackrabbit FileVault
export options in order to assemble/import binary references.

Upon import, if a referenced binary is not visible on the destination instance, SCD will retry distributing the content package
after a delay has elapsed.

Binary-less is configured by setting the `useReferences` to `true` on the VaultDistributionPackageBuilderFactory.

### How to configure priority queue?

SCD agents allow to prioritize the distribution of content depending on its path.
This feature improves the delays in use cases where a subset of the content to be distributed must meet tighter delay
than the remaining one (e.g. news flash).

Each agent can be configured with one or more priority queues.

In order to setup the priority queues, configure the `priorityQueues` agent property by providing the queuePrefix and path regular expression.

### How to configure retry strategy?

The agent behaviour upon failed distribution request can be configured via the Retry Strategy `retry.strategy` and
`retry.attempts` properties.

With the `none` strategy, an agent will retry distributing an item forever, blocking the queue until the distribution succeeds.
The 'none' strategy guarantees the distribution order but may block the queue until someone resolves the situation.

With the `errorQueue` strategy, an agent will automatically create an additional error queue. The agent will
retry up to `retry.attempts` attempts then move the failed item to the error queue. The error queue is passive and allow
to keep track of the failed distribution item for post analysis.
The `errorQueue` strategy does not guarantee the distribution order, but it guarantee that the queue is stuck for a bounded number of retries.
