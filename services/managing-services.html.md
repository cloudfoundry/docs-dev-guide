---
title: Managing Services
---
_This page assumes that you are using cf v5._

## <a id='viewing-services'></a> View Available Services ##

After targeting and logging into Cloud Foundry using [cf](../installcf/cf.html), you can view what services are available to applications running on your Cloud Foundry instance by running this command.

<pre class="terminal">
$ cf services
</pre>

The command above returns service metadata, including the service type (for example mySQL or Rabbit MQ), service version, provider, a description, and so on. 

## <a id='create'></a>Create a Service Instance ##

Use this command to create a service instance.

<pre class="terminal">
$ cf create-service
1: mongodb n/a, via mongolab
2: mongodb 2.2
3: mysql 5.5
4: postgresql 9.2
5: rabbitmq 3.0
6: redis 2.6
7: redis n/a, via redistogo
8: smtp n/a, via sendgrid
What kind?> 3

Name?> mysql-a0a77

1: 100: Shared service instance, 10MB storage, 2 connections
2: 200: Dedicated server, shared VM, 256MB memory, 2.5GB storage, 30 connections
Which plan?> 2

Creating service mysql-a0a77... OK
</pre>

## <a id='user-provided'></a>Create a User-Provided Service Instance ##

User-provided service instances are service instances which have been provisioned outside of Cloud Foundry. For example, a DBA may provide a developer with credentials to an Oracle database managed outside of, and unknown to Cloud Foundry. Rather than hard coding credentials for these instances into your applications, you can create a mock service instance in Cloud Foundry to represent an external resource using the familiar `create-service` command, and provide whatever credentials your application requires.

* [User Provided Service Instances](user-provided.html)

## <a id='bind'></a>Bind a Service Instance ##

Binding a service to your application adds credentials for the service instance to the [VCAP_SERVICES](../deploy-apps/environment-variable.html) environment variable. In most cases these credentials are unique to the binding; another app bound to the same service instance would receive different credentials. You may need to restart your application for it to recognize the change.

How your app leverages the contents of environment variables may depend on the framework you employ. Refer to the [Deploying Apps](../deploy-apps/) section for more information.

You can bind an existing service to an existing application as follows:

<pre class="terminal">
$ cf bind-service
1: my-app
Which application?> 1

1: mysql-a0a77
Which service?> 1

Binding mysql-a0a77 to my-app... OK
</pre>

## <a id='unbind'></a>Unbind a Service Instance ##

Unbinding a service removes the credentials created for your application from the [VCAP_SERVICES](../deploy-apps/environment-variable.html) environment variable. You may need to restart your application for it to recognize the change.

<pre class="terminal">
$ cf unbind-service
1: my-app
Which application?> 1

1: mysql-a0a77
Which service?> 1

Unbinding mysql-a0a77 from my-app... OK
</pre>

## <a id='delete'></a>Delete a Service Instance ##

Deleting a service unprovisions the service instance and deletes *all data* along with the service instance.

<pre class="terminal">
$ cf delete-service
1: mysql-a0a77
Which service?> 1

Really delete mysql-a0a77?> y

Deleting mysql-a0a77... OK
</pre>
