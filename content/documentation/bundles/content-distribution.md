Title: Content Distribution (org.apache.sling.distribution)
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

### How to trigger distribution over HTTP?

### How to configure binary-less distribution?

### How to configure priority paths?

### How to configure error queues?

