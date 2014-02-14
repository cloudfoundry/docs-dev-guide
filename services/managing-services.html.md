---
title: Managing Services
---

_This page assumes you are using cf v6._

## <a id='viewing-services'></a> View Available Services ##

After targeting and logging into Cloud Foundry, you can view what services are available to your targeted organization. Available services may differ between organizations and between Cloud Foundry marketplaces.

<i>Note: This is an example. These services may not be available on your Cloud Foundry marketplace you target.</i>

<pre class="terminal">
$ cf services --marketplace
Getting services from marketplace in org my-org / space test as me@example.com...
OK

service          plans                                                                 description
blazemeter       basic1kmr, free-tier, hv40kmr, pp10kmr, pro5kmr                       The JMeter Load Testing Cloud
cleardb          amp, boost, shock, spark                                              Highly available MySQL for your Apps.
cloudamqp        bunny, lemur, panda, rabbit, tiger                                    Managed HA RabbitMQ servers in the cloud
cloudforge       free, pro, standard                                                   Development Tools In The Cloud
elephantsql      elephant, hippo, panda, turtle                                        PostgreSQL as a Service
loadimpact       li100, li1000, li500, lifree                                          Cloud-based, on-demand website load testing
memcachedcloud   100mb, 1gb, 2-5gb, 250mb, 25mb, 500mb, 5gb                            Enterprise-Class Memcached for Developers
memcachier       dev                                                                   The easiest, most advanced memcache.
mongolab         sandbox                                                               Fully-managed MongoDB-as-a-Service
newrelic         standard                                                              Manage and monitor your apps
rediscloud       100mb, 10gb, 1gb, 2-5gb, 250mb, 25mb, 500mb, 50gb, 5gb                Enterprise-Class Redis for Developers
searchify        plus, pro, small                                                      Custom search you control
searchly         advanced, business, enterprise, micro, professional, small, starter   Search Made Simple.
sendgrid         bronze, free, gold, platinum, silver                                  Email Delivery. Simplified.
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

* [User Provided Service Instances](user-provided.html)

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
