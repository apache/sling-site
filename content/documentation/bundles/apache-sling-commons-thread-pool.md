Title: Apache Sling Commons Thread Pool

The Apache Sling Commons Thread Pool bundle provides a thread pool services. All thread pools are managed by the `org.apache.sling.commons.threads.ThreadPoolManager`. This service can be used to get a thread pool.

Thread pools are managed by name - there is a default thread pool and custom thread pools can be generated on demand using a unique name.

The thread pools are actually wrappers around the thread pool support (executer) from the Java library. The advantage of using this thread pool service is, that the pools can be configured and managed through OSGi configurations. In addition the bundle contains a plugin for the Apache Felix Web Console.

When using the `ThreadPoolMananger` it is important to release a thread pool using the manager after it has been used.