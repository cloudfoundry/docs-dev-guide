---
title: Add a Service
---

Cloud Foundry allows you to deploy applications without worrying about configuration headaches, making it faster and easier to build, test, deploy and scale your app.

This guide walks you through binding and using services. It assumes you have pushed an application to your Cloud Foundry instance. If you have not done that, see [../deploy-apps/Getting Started](getting-started.html).

## <a id='intro'></a>Intro to Services ##

Cloud Foundry Services are add-ons that can be provisioned alongside your application. Learn all about Services at [Using Services](services-intro.html).

In order to use services with your application you will need to:

1. [Create a service instance](#create)
1. [Bind a service instance to your application](#binding)
1. [Update your application to use the service](#using)

### Services vs. Service Instances
Services provision services instances. As an example, ClearDB is a service which provisions MySQL databases. Depending on the plan you select, you might get a database in a multi-tenant server, or a dedicated server. But not all services provide databases; a service may simply provision an account on their system for you. Whatever is provisioned for you we refer to as a service instance.

## <a id='create'></a>Creating Service Instances ##

You can create a service instance with the command, `cf create-service`.

<pre class="terminal">
$ cf create-service
1: cleardb n/a, via cleardb
2: cloudamqp n/a, via cloudamqp
3: elephantsql n/a, via elephantsql
4: mongolab n/a, via mongolab
5: rediscloud n/a, via garantiadata
6: treasuredata n/a, via treasuredata
What kind?> 1
</pre>

After you choose a service, `cf` will ask you to provide a name for your service instance. This is an alias for the instance which is meaningful to you. `cf` will provide a default for you, or you can enter any series of alpha-numeric characters ([a-z], [A-Z], [0-9]) plus hyphens (-) or underscores (_). You can rename the instance later at any time.

<pre class="terminal">
Name?> cleardb-e2006
</pre>

Next you will be asked to select a plan. Service plans are a way for providers to offer varying levels of resources or features for the same service.

<pre class="terminal">
1: amp: For apps with moderate data requirements
2: boost: Best for light production or staging your applications
3: shock: Designed for apps where you need real MySQL reliability, power and throughput.
4: spark: Great for getting started and developing your apps.
Which plan?>
</pre>

Following this step, your service instance will be provisioned.

<pre class="terminal">
Creating service cleardb-e2006... OK
</pre>

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

## <a id='configuring'></a>Configuring Connections for Different Frameworks ##

The procedure for configuring an application to connect to a service varies by framework. Note that auto-configuration is not supported for all frameworks. The table below has links to instructions for configuring service connections in different environments.

| Runtime               | Framework                   |Auto-Configuration Support|
| :-------------        |:-------------               |:-------------            |
| Java / JVM        | <li>[Spring](spring-service-bindings.html) <li>[Grails](grails-service-bindings.html) <li>[Lift](lift-service-bindings.html) | Supported. |
| Ruby            | <li>[Rack, Rails, or Sinatra](ruby-service-bindings.html) |  Supported only for Rails, with some limitations. For more information, <br> see [Options for Configuring Ruby Apps for Services](ruby-service-bindings.html#options). |
| Javascript          | <li>[Node.js](node-service-bindings.html) |Not available. |
