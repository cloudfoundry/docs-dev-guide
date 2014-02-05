---
title: Add a Service
---

This guide walks you through binding and using services.
It assumes you have pushed an application to your Cloud Foundry instance.

## <a id='intro'></a>Intro to Services ##

Cloud Foundry Services are add-ons that can be provisioned alongside
your application. There are two types of Cloud Foundry services:

 - Service brokers advertise catalogs of [managed services](./managed.html) such as databases, key-value stores, messaging, or other types of services.
 - [User-provided services](./user-provided.html) allow you to represent external assets like databases, messaging services, and key-value stores in Cloud Foundry.

In order to use services with your application you will need to:

1. [Create a service instance](#create)
1. [Bind a service instance to your application](#binding)
1. [Update your application to use the service](#using)

### Services vs. Service Instances
Services provision services instances.
For this example, ExampleDB is a service that provisions MySQL
databases. Depending on the plan you select, you might get a database
in a multi-tenant server, or a dedicated server. But not all services
provide databases; a service may simply provision an account on their
system for you. Whatever is provisioned for you we refer to as a
service instance.

## <a id='create'></a>Creating Managed Service Instances ##

_This page assumes that you are using cf v6._

You can create a managed service instance with the command `cf create-service`:

```
$ cf create-service <SERVICE> <PLAN> <SERVICE-INSTANCE>
```

**Note**: For more information about creating a user-provided service instance, refer to the [User-Provided Service Instances](./user-provided.html) topic.

`cf create-service` takes the following required arguments:

* SERVICE: The service you choose.
* PLAN: Service plans are a way for providers to offer varying levels
of resources or features for the same service.
* SERVICE-INSTANCE: A name you provide for your service instance. This
is an alias for the instance which is meaningful to you. Enter any series of alpha-numeric
characters ([a-z], [A-Z], [0-9]) plus hyphens (-) or underscores (\_). You can rename the instance later at any time.

Following this step, your managed service instance is provisioned.

<pre class="terminal">
Creating service my-exampledb in org console / space development as user@example.com... OK
</pre>

## <a id='binding'></a>Binding a Service Instance to your Application ##

Not all services provide bindable service instances.
Binding requires an additional level of integration with a provider,
and it doesn't make sense in all cases for the provider to return any
credentials for an application's use.

For services that offer bindable service instances, the binding
operation puts credentials for the service instance in the environment
variable VCAP\_SERVICES, where your application can consume them.
For more information, see [VCAP_SERVICES Environment
Variable](../deploy-apps/environment-variable.html).

You can bind either a managed or a user-provided service instance to an application with the command `cf bind-service`:

```
$ cf bind-service <APP> <SERVICE_INSTANCE>
```

`cf bind-service` takes the following required arguments:

* APP: The name of the app to which you want to bind a service.
* SERVICE_INSTANCE: The name you provided when you created your service instance.

If the service supports binding, your cf service instance is now
bound to your app. Use `cf push` to update the VCAP_SERVICES
environment variable with your changes.

<pre class="terminal">
Binding service my-exampledb to app rails-sample in org console / space development as user@example.com... OK

	TIP: Use 'cf push' to ensure your env variable changes take effect
</pre>

## <a id='using'></a>Using Bound Service Instances with your Application ##

Once you have a service instance created and bound to your app, you
will need to configure your application to dynamically fetch the
credentials for your service.
These credentials are stored in the [VCAP\_SERVICES environment
variable](../deploy-apps/environment-variable.html#VCAP_SERVICES) and
there are generally two methods for consuming credentials from there.

* **Auto-configuration**: Some buildpacks create a service connection for you
by creating additional environment variables, updating config files, or passing
system parameters to the jvm.
* **Manual**: [Parse the JSON
yourself](../deploy-apps/environment-variable.html#app); helper libraries are
available for some frameworks.

| Runtime               | Framework                   | Binding Strategy         |
| :-------------        |:-------------               |:-------------            |
| Java / JVM        | <li>[Spring](./spring-service-bindings.html) <li>[Grails](./grails-service-bindings.html) <li>[Lift](./lift-service-bindings.html) | Auto-configuration<br/>Manual |
| Ruby            | <li>[Rack, Rails, or Sinatra](./ruby-service-bindings.html) |  [Limited auto-configuration support for Rails only](./ruby-service-bindings.html#auto-config)<br/>Manual |
| Javascript          | <li>[Node.js](./node-service-bindings.html) | Manual |