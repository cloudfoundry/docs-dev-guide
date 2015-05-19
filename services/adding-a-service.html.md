---
title: Adding a Service
---

_This page assumes you are using cf CLI v6._

This guide walks you through adding, binding, and using services.
It assumes you have pushed an application to your Cloud Foundry instance.

## <a id='intro'></a>Intro to Services ##

Cloud Foundry Services are add-ons that can be provisioned alongside your application. Learn all about Services at [Using Services](index.html).

There are two types of Cloud Foundry services:

- Service brokers advertise catalogs of [managed services](./managed.html) such as databases, key-value stores, messaging, or other types of services.
- [User-provided services](./user-provided.html) allow you to represent external assets like databases, messaging services, and key-value stores in Cloud Foundry.

In order to use services with your application you will need to:

1. [Create](#create) a service instance.
1. [Bind](#bind) a service instance to your application.
1. [Update](#use) your application to use the service.

### <a id='instances'></a> Services vs. Service Instances ###

Services provision services instances. For example, ExampleDB might be a service that provisions MySQL databases.
Depending on the plan you select, you might get a database in a multi-tenant
server, or a dedicated server.

Not all services provide databases; a service may simply provision an account on
their system for you.
Whatever is provisioned for you by a service is a service instance.

## <a id='create'></a>Creating Managed Service Instances ##

You can create a managed service instance with the command: `cf create-service SERVICE PLAN SERVICE_INSTANCE`

`cf create-service` takes the following required arguments:

* SERVICE: The service you choose.
* PLAN: Service plans are a way for providers to offer varying levels
of resources or features for the same service.
* SERVICE\_INSTANCE: A name you provide for your service instance.
This is an alias for the instance which is meaningful to you.
Use any series of alpha-numeric characters, hyphens (-), and underscores (\_).
You can rename the instance at any time.

Following this step, your managed service instance is provisioned:

<pre class="terminal">
$ cf create-service rabbitmq small-plan my_rabbitmq

Creating service my_rabbitmq in org my-org / space development as user@example.com... OK
</pre>

<p class="note"><strong>Note</strong>: For more information about creating a user-provided service instance,
refer to <a href="./user-provided.html">User-Provided Service Instances</a>.</p>

### <a id='arbitrary-params-create'></a> Arbitrary Parameters  ###
Some services may support additional configuration parameters, which can be passed along with the provision request. The parameters are passed in a valid JSON object containing service-specific configuration parameters, provided either in-line or in a file. For a list of supported configuration parameters, see documentation for the particular service offering.

<pre class="terminal">
$ cf create-service my-db-service small-plan my-db -c '{"storage_gb":4}'

Creating service my-db in org console / space development as user@example.com... OK
</pre>

<pre class="terminal">
$ cf create-service my-db-service small-plan my-db -c /tmp/config.json

Creating service my-db in org console / space development as user@example.com... OK
</pre>

## <a id='bind'></a>Binding a Service Instance to your Application ##

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

You can bind either a managed or a user-provided service instance to an application with the command `cf bind-service APPLICATION SERVICE_INSTANCE`

`cf bind-service` takes the following required arguments:

* APPLICATION: The name of the application to which you want to bind a service.
* SERVICE\_INSTANCE: The name you provided when you created your service
instance.

If the service supports binding, this command binds the service instance to your
application.

<pre class="terminal">
$ cf bind-service rails-sample my_rabbitmq

Binding service my_rabbitmq to app rails-sample in org my-org / space development as user@example.com... OK

	TIP: Use 'cf push' to ensure your env variable changes take effect
</pre>

Use `cf push` to update the VCAP_SERVICES environment variable with your
changes.

### <a id='arbitrary-params-binding'></a> Arbitrary Parameters  ###
Some services may support additional configuration parameters, which can be passed along with the binding request. The parameters are passed in a valid JSON object containing service-specific configuration parameters, provided either in-line or in a file. For a list of supported configuration parameters, see documentation for the particular service offering.

<pre class="terminal">
$ cf bind-service rails-sample my-db -c '{"role":"read-only"}'

Binding service my-db to app rails-sample in org console / space development as user@example.com... OK
</pre>

<pre class="terminal">
$ cf bind-service rails-sample my-db -c /tmp/config.json

Binding service my-db to app rails-sample in org console / space development as user@example.com... OK
</pre>

## <a id='use'></a>Using Bound Services ##

Once you have a service instance created and bound to your application, you will
need to configure the application to dynamically fetch the credentials for your
service.
These credentials are stored in the
[VCAP_SERVICES](../deploy-apps/environment-variable.html#VCAP-SERVICES)
environment variable.
There are generally two methods for consuming these credentials.

* **Auto-configuration**: Some buildpacks create a service connection for you
by creating additional environment variables, updating config files, or passing
system parameters to the JVM.
* **Manual**: [Parse the JSON yourself](../deploy-apps/environment-variable.html#VCAP-APPLICATION). Helper libraries are
available for some frameworks.

See the [buildpacks documentation](../../buildpacks/index.html) to learn more
about working with specific frameworks.
