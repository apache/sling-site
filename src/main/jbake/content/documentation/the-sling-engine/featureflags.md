title=Feature Flags		
type=page
status=published
tags=core,featureflags
~~~~~~

Feature Flags are used to select whether a particular feature is enabled or not. This allows to
continuosly deploy new features of an application without making them globally available yet.

Features may be enabled based on various contextual data:

  * Time of Day
  * Segmentation Data (gender, age, etc.), if available
  * Request Parameter
  * Request Header
  * Cookie Value
  * Static Configuration

Feature flags can be provided by registering `org.apache.sling.featureflags.Feature` services.
Alternatively feature flags can be provided by factory configuration with factory PID
`org.apache.sling.featureflags.Feature` as follows:

| Property | Description |
|---|---|
| `name` | Short name of this feature. This name is used to refer to this feature when checking for it to be enabled or not. This property is required and defaults to a name derived from the feature's class name and object identity. It is strongly recommended to define a useful and unique for the feature|
| `description` | Description for the feature. The intent is to descibe the behaviour of the application if this feature would be enabled. It is recommended to define this property. The default value is the value of the name property. |
| `enabled` | Boolean flag indicating whether the feature is enabled or not by this configuration|

