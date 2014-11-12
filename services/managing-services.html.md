---
title: Managing Service Instances with the CLI
---

_This page assumes you are using cf v6._

## <a id='viewing-services'></a> View Available Services ##

After targeting and logging into Cloud Foundry, you can view what services are available to your targeted organization. Available services may differ between organizations and between Cloud Foundry marketplaces.

<i>Note: This is an example. These services may not be available on your Cloud Foundry marketplace you target.</i>

<pre class="terminal">
$ cf marketplace
Getting services from marketplace in org scoen / space test as scoen@gopivotal.com...
OK

service                     plans                  description
blazemeter                  free-tier              The JMeter Load Testing Cloud
cleardb                     spark                  Highly available MySQL for your Apps.
cloudamqp                   lemur                  Managed HA RabbitMQ servers in the cloud
elephantsql                 turtle                 PostgreSQL as a Service
memcachedcloud              25mb                   Enterprise-Class Memcached for Developers
mongolab                    sandbox                Fully-managed MongoDB-as-a-Service
newrelic                    standard               Manage and monitor your apps
rediscloud                  25mb                   Enterprise-Class Redis for Developers
searchly                    starter                Search Made Simple.
sendgrid                    free                   SMTP service by SendGrid
</pre>

## <a id='create'></a>Create a Service Instance ##

Use this command to create a service instance.

<pre class="terminal">
$ cf create-service cleardb spark cleardb-test
Creating service cleardb-test in org my-org / space test as me@example.com...
OK
</pre>

## <a id='user-provided'></a>Create a User-Provided Service Instance ##

User-provided service instances are service instances which have been provisioned outside of Cloud Foundry. For example, a DBA may provide a developer with credentials to an Oracle database managed outside of, and unknown to Cloud Foundry. Rather than hard coding credentials for these instances into your applications, you can create a mock service instance in Cloud Foundry to represent an external resource using the familiar `create-service` command, and provide whatever credentials your application requires.

Refer to the [User Provided Service Instances](user-provided.html) topic for more information.

## <a id='update_service'></a>Update a Service Instance Plan ##

Updating the service instance plan modifies the plan used by an existing service instance. For example, updating a database service instance with a 1 GB plan to a new 100 MB plan.

You must restart your application to ensure that it recognizes changes to environment variables.

You can update an existing service instance as follows:

<pre class="terminal">
$ cf update-service my-service-instance -p new-plan
Updating service instance my-service-instance as me@example.com...
OK

$ cf restart my-app
</pre>

## <a id='bind'></a>Bind a Service Instance ##

Binding a service to your application adds credentials for the service instance to the [VCAP_SERVICES](../deploy-apps/environment-variable.html) environment variable. In most cases these credentials are unique to the binding; another app bound to the same service instance would receive different credentials.How your app leverages the contents of environment variables may depend on the framework you employ. Refer to the [Deploying Apps](../deploy-apps/index.html) section for more information.

* You must restart or in some cases re-push your application for the application to recognize changes to environment variables.
* Not all services support application binding. Many services provide value to the software development process and are not directly used by an application running on Cloud Foundry.

You can bind an existing service to an existing application as follows:

<pre class="terminal">
$ cf bind-service my-app cleardb-test
Binding service cleardb-test to my-app in org my-org / space test as me@example.com...
OK
TIP: Use 'cf push' to ensure your env variable changes take effect

$ cf restart my-app
</pre>

## <a id='unbind'></a>Unbind a Service Instance ##

Unbinding a service removes the credentials created for your application from the [VCAP_SERVICES](../deploy-apps/environment-variable.html) environment variable. You must restart or in some cases re-push your application for the application to recognize changes to environment variables.

<pre class="terminal">
$ cf unbind-service my-app cleardb-test
Unbinding app my-app from service cleardb-test in org my-org / space test as me@example.com...
OK
</pre>

## <a id='delete'></a>Delete a Service Instance ##

Deleting a service unprovisions the service instance and deletes *all data* along with the service instance.

<pre class="terminal">
$ cf delete-service cleardb-test

Are you sure you want to delete the service cleardb-test ? y
Deleting service cleardb-test in org my-org / space test as me@example.com...
OK
</pre>
