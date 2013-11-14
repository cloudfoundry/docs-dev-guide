---
title: Bind a Service
---

_This page assumes that you are using cf v5._

## <a id='binding'></a>Binding a Service Instance to your Application ##

Not all services provide bindable service instances. Binding requires an additional level of integration with a provider, and it doesn't make sense in all cases for the provider to return any credentials for an application's use.

For services that offer bindable service instances, the binding operation puts credentials for the service instance in the environment variable VCAP_SERVICES, where your application can consume them. For more information, see [VCAP_SERVICES Environment Variable](../deploy-apps/environment-variable.html).

You can bind a service to an application with the command `cf bind-service`. You will first be asked for the application to bind the service to.

<pre class="terminal">
$ cf bind-service
1: myapp
Which application?> 1
</pre>

Next you will be asked for the service instance you want to bind.

<pre class="terminal">
1: cleardb-e2006
Which service?> 1
</pre>

If the service supports binding, your service instance will then be bound to your app.

<pre class="terminal">
Binding cleardb-e2006 to myapp... OK
</pre>

## <a id='using'></a>Using Service Instances with your Application ##

Once you have a service instance created and bound to your app, you will need to configure your application to use the correct credentials for your service.

There are three ways of consuming service instance credentials within your application.

| Binding Strategy     | Description                                                                                                                            |
| :------------------- | :--------------------                                                                                                                  |
| Auto-configuration | Cloud Foundry creates a service connection for you.                                                                |
| cfruntime            | Creates an object with the location and settings of your services. Set your service connections based on the values in that object.    |
| Manual               | Parse the JSON credentials object yourself from the [VCAP_SERVICES Environment Variable](../deploy-apps/environment-variable.html). |

