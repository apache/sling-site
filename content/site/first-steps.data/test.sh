#!/bin/sh
#
#    Licensed to the Apache Software Foundation (ASF) under one
#    or more contributor license agreements.  See the NOTICE file
#    distributed with this work for additional information
#    regarding copyright ownership.  The ASF licenses this file
#    to you under the Apache License, Version 2.0 (the
#    "License"); you may not use this file except in compliance
#    with the License.  You may obtain a copy of the License at
#    
#    http://www.apache.org/licenses/LICENSE-2.0
#    
#    Unless required by applicable law or agreed to in writing,
#    software distributed under the License is distributed on an
#    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied.  See the License for the
#    specific language governing permissions and limitations
#    under the License.
#

JAVA_HOME=${JAVA_HOME:=/usr/java/jdk1.5.0_11}
JAVA=${JAVA_HOME}/bin/java
JAVA_DEBUG="-Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,address=30503,server=y,suspend=n"
SLING_HOME=sling.test
SLING_LOG_FILE=
SLING_DEFS="-Dsling.install.20= -Dorg.osgi.service.http.port=8080"
SLING_JAR="target/org.apache.sling.launcher.app-2.0.0-incubator-SNAPSHOT.jar"

## Append command line arguments (not actually correct, but suffices it)
SLING_DEFS="${SLING_DEFS} $@"

## Enable this for JAAS LDAP Auth
# SLING_DEFS="${SLING_DEFS} -Djava.security.auth.login.config=${PWD}/ldap_login.conf"

## Enable this for JVMTI profiling
# SLING_DEFS="${SLING_DEFS} -agentlib:yjpagent"

export JAVA JAVA_DEBUG SLING_HOME SLING_LOG_FILE SLING_DEFS

${JAVA} ${JAVA_DEBUG} -Dsling.home=${SLING_HOME} -Dorg.apache.sling.osgi.log.file=${SLING_LOG_FILE} ${SLING_DEFS} -jar ${SLING_JAR}
