title=Running Apache Sling on Apache Karaf
type=page
status=published
tags=karaf
~~~~~~

**NOTE:** Tested and built with Apache Karaf 4.3.0

## Sling Karaf Features

A features repository for easy deployment of [Apache Sling](https://sling.apache.org) on [Apache Karaf](https://karaf.apache.org) (see [Provisioning](https://karaf.apache.org/manual/latest/#_provisioning) for details).

([GitBox](https://gitbox.apache.org/repos/asf?p=sling-org-apache-sling-karaf-features.git) | [GitHub](https://github.com/apache/sling-org-apache-sling-karaf-features))


## Sling Karaf Configs

OSGi configurations for provisioning with Apache Karaf used in [Sling's Karaf Features](#sling-karaf-features).

([GitBox](https://gitbox.apache.org/repos/asf?p=sling-org-apache-sling-karaf-configs.git) | [GitHub](https://github.com/apache/sling-org-apache-sling-karaf-configs))


## Sling Karaf Distribution

A [distribution](https://karaf.apache.org/manual/latest/#_custom_distributions) of [Apache Sling](https://sling.apache.org) based on [Apache Karaf](https://karaf.apache.org) ([Sling's Karaf Features](#sling-karaf-features) and artifacts in a single archive).

([GitBox](https://gitbox.apache.org/repos/asf?p=sling-org-apache-sling-karaf-distribution.git) | [GitHub](https://github.com/apache/sling-org-apache-sling-karaf-distribution))


## Getting Started

1) [Start Apache Karaf](https://karaf.apache.org/manual/latest/#_quick_start) or _Sling's Karaf Distribution_.

2) Add the Apache Sling features repository (not necessary when using _Sling's Karaf Distribution_):

    karaf@root()> feature:repo-add mvn:org.apache.sling/org.apache.sling.karaf-features/0.1.1-SNAPSHOT/xml/features

3) Sling requires OSGi R7 [Http Service](https://docs.osgi.org/specification/osgi.cmpn/7.0.0/service.http.html) and [Http Whiteboard Service](https://docs.osgi.org/specification/osgi.cmpn/7.0.0/service.http.whiteboard.html), e.g. [Apache Felix HTTP Service](https://github.com/apache/felix-dev/tree/master/http):

    karaf@root()> feature:install felix-http

4) Install custom or [default configurations for Sling](#sling-karaf-configs):

    karaf@root()> feature:install sling-configs

5) Install a Sling Quickstart feature, e.g. `sling-quickstart-oak-tar` or `sling-quickstart-oak-mongo` (requires a running and configured MongoDB):

    karaf@root()> feature:install sling-quickstart-oak-tar

6) Install Starter Content (feature includes [Composum](https://github.com/ist-dresden/composum)):

    karaf@root()> feature:install sling-starter-content

7) Browse to [http://localhost:8181/](http://localhost:8181/).
