---
title: Bind a Service
---

_This page assumes that you are using cf v6._

## <a id='binding'></a>Binding a Service Instance to your Application ##

Some services provide bindable service instances.
For services that offer bindable service instances, binding a service to your
application adds credentials for the service instance to the
[VCAP_SERVICES](../deploy-apps/environment-variable.html#VCAP-SERVICES)
environment variable.

In most cases these credentials are unique to the binding; another application
bound to the same service instance would receive different credentials.

How your application leverages the contents of environment variables may depend
on the framework you employ.
Refer to the [Deploy Applications](../deploy-apps/index.html) topics for more information.

You can bind a service to an application with the command `cf bind-service APPLICATION SERVICE_INSTANCE`.
Example:

<pre class="terminal">
$ cf bind-service my_app example_service
</pre>

Note: You can see which services are available in your current space with the
`cf services` command.

## <a id='using'></a>Using Bound Services ##

Once you have a service instance created and bound to your app, you will need to
configure your application to use the correct credentials for your service.

There are three ways of consuming service instance credentials within your
application.

| Binding Strategy     | Description                                                                                                                            |
| :------------------- | :--------------------                                                                                                                  |
| Auto-configuration | Cloud Foundry creates a service connection for you.                                                                |
| cfruntime            | Creates an object with the location and settings of your services. Set your service connections based on the values in that object.    |
| Manual               | Parse the JSON credentials object yourself from VCAP\_SERVICES |