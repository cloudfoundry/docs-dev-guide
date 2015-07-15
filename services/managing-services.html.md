---
title: Managing Service Instances with the CLI
---

_This page assumes you are using cf CLI v6._

This topic walks you through adding, binding, and using services.
Before using this topic, Pivotal recommends that you push an application to your Cloud Foundry instance.

## <a id='intro'></a>Intro to Services ##

Cloud Foundry Services are add-ons that you can provision alongside your application. For more information about Services, refer to the [Using Services](index.html) topic.

There are two types of Cloud Foundry Services:

- Service brokers advertise catalogs of [managed services](./managed.html) such as databases, key-value stores, or messaging services.
- [User-provided services](./user-provided.html) allow you to represent external assets like databases, messaging services, and key-value stores in Cloud Foundry.

In order to use services with your application you need to:

1. [Create](#create) a service instance.
1. [Bind](#bind) a service instance to your application.

### <a id='instances'></a> Services vs. Service Instances ###

Services provision services instances. For example, ExampleDB might be a service that provisions MySQL databases.
Depending on the plan you select, you might get a database in a multi-tenant
server, or a dedicated server.

Not all services provide databases. A service might simply provision an account on
its system for you.
Whatever a service provisions for you is a service instance.

## <a id='viewing-services'></a> View Available Services ##

After targeting and logging into Cloud Foundry, you can view what services are available to your targeted organization. Available services might differ between organizations and between Cloud Foundry marketplaces.

<pre class="terminal">
$ cf marketplace
Getting services from marketplace in org my-org / space test as me@example.com...
OK

service               plans                  description
p-mysql               100mb, 1gb             A DBaaS
p-riakcs              developer              An S3-compatible object store
</pre>

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

Run the following command to provision your managed service instance:

<pre class="terminal">
$ cf create-service rabbitmq small-plan my_rabbitmq

Creating service my_rabbitmq in org console / space development as user@example.com... OK
</pre>

<p class="note"><strong>Note</strong>: For more information about creating a user-provided service instance,
refer to the <a href="./user-provided.html">User-Provided Service Instances</a> topic.</p>

### <a id='arbitrary-params-create'></a> Arbitrary Parameters  ###

_Arbitrary parameters require cf CLI v6.12.1+_

Some services may support additional configuration parameters, which can be passed along with the provision request. The parameters are passed in a valid JSON object containing service-specific configuration parameters, provided either in-line or in a file. For a list of supported configuration parameters, see documentation for the particular service offering.

<pre class="terminal">
$ cf create-service my-db-service small-plan my-db -c '{"storage_gb":4}'

Creating service my-db in org console / space development as user@example.com... OK
</pre>

<pre class="terminal">
$ cf create-service my-db-service small-plan my-db -c /tmp/config.json

Creating service my-db in org console / space development as user@example.com... OK
</pre>

### <a id='instance-tags-create'></a> Instance Tags  ###
_Instance tags require cf CLI v6.12.1+_

Services include a list of tags to help categorize the service. To help distinguish between different service instances, one may pass a comma-separated list of tags using the `-t` flag. When the service instance is bound to an app, these tags will be made available in [VCAP_SERVICES](../deploy-apps/environment-variable.html), in addition to the tags provided by the service.

<pre class="terminal">
$ cf create-service my-db-service small-plan my-db -t "prod, workers"

Creating service my-db in org console / space development as user@example.com... OK
</pre>

## <a id='user-provided'></a>Create a User-Provided Service Instance ##

User-provided service instances are resources which have been pre-provisioned outside of Cloud Foundry. For example, a DBA may provide a developer with credentials to an Oracle database managed outside of, and unknown to Cloud Foundry. Rather than hard coding credentials for these instances into your applications, you can create a mock service instance in Cloud Foundry to represent an external resource and configure it with the credentials provided by your DBA. Once this mock instance is created in the platform, the same CLI commands (documented on this page) can be used to manage user-provided instances as for instances provisioned by the platform.

Refer to the [User Provided Service Instances](user-provided.html) topic for more information.

## <a id='rename_service'></a>Rename a Service Instance ##

You can change the name given to a service instance. Keep in mind that upon restarting any bound applications, the name of the instance changes in the [VCAP_SERVICES](../deploy-apps/environment-variable.html) environment variable. If your application depends on the instance name for discovering credentials, changing the name could break your applications use of the service instance.

<pre class="terminal">
$ cf rename-service mydb mydb1
Renaming service mydb to mydb1 in org my-org / space test as me@example.com...
OK
</pre>

## <a id='update_service'></a>Update a Service Instance ##

With v192 of [cf-release](https://github.com/cloudfoundry/cf-release) and v6.7 of the [CLI](https://github.com/cloudfoundry/cli), Cloud Foundry introduced support for users to update attributes of a service instance (besides the name) after provisioning. Currently the only attribute of an instance that can be modified is the service plan.

### Upgrade/Downgrade Service Plan

By updating the service plan for an instance, users can effectively upgrade and downgrade their service instance to other service plans. Though the platform and CLI now support this feature, services must expressly implement support for it so not all services will. Further, a service might support updating between some plans but not others (e.g. a service might support updating a plan where only a logical change is required, but not where data migration is necessary). In either case, users can expect to see a meaningful error when plan update is not supported.

You can update the plan for an existing service instance as follows:

<pre class="terminal">
$ cf update-service mydb -p new-plan
Updating service instance mydb as me@example.com...
OK
</pre>

### <a id='arbitrary-params-update'></a> Arbitrary Parameters  ###

_Arbitrary parameters require cf CLI v6.12.1+_

Some services might support additional configuration parameters, which can be passed along with the update request. The parameters are passed in a valid JSON object containing service-specific configuration parameters, provided either in-line or in a file. For a list of supported configuration parameters, see documentation for the particular service offering.

<pre class="terminal">
$ cf update-service mydb -c '{"storage_gb":4}'

Updating service instance mydb as me@example.com...
</pre>

<pre class="terminal">
$ cf update-service mydb -c /tmp/config.json

Updating service instance mydb as me@example.com...
</pre>

### <a id='instance-tags-create'></a> Instance Tags  ###
_Instance tags require cf CLI v6.12.1+_

Services include a list of tags to help categorize the service. To help distinguish between different service instances, one may pass a comma-separated list of tags using the `-t` flag. When the service instance is bound to an app, these tags will be made available in [VCAP_SERVICES](../deploy-apps/environment-variable.html), in addition to the tags provided by the service.

<pre class="terminal">
$ cf update-service my-db -t "staging, web"

Updating service my-db in org console / space development as user@example.com... OK
</pre>

## <a id='bind'></a>Bind a Service Instance ##

Some services provide bindable service instances. Binding a service to your application adds credentials for the service instance to the [VCAP_SERVICES](../deploy-apps/environment-variable.html) environment variable. In most cases these credentials are unique to the binding; another app bound to the same service instance would receive different credentials. How your app leverages the contents of environment variables might depend on the framework you employ. Refer to the [Deploying Apps](../deploy-apps/index.html) section for more information.

* You must restart or in some cases re-push your application for the application to recognize changes to environment variables.
* Not all services support application binding. Many services provide value to the software development process and are not directly used by an application running on Cloud Foundry.

You can bind an existing service to an existing application as follows:

<pre class="terminal">
$ cf bind-service my-app mydb
Binding service mydb to my-app in org my-org / space test as me@example.com...
OK
TIP: Use 'cf push' to ensure your env variable changes take effect

$ cf restart my-app
</pre>

### <a id='arbitrary-params-binding'></a> Arbitrary Parameters  ###

_Arbitrary parameters require cf CLI v6.12.1+_

Some services might support additional configuration parameters, which can be passed along with the binding request. The parameters are passed in a valid JSON object containing service-specific configuration parameters, provided either in-line or in a file. For a list of supported configuration parameters, see documentation for the particular service offering.

<pre class="terminal">
$ cf bind-service rails-sample my-db -c '{"role":"read-only"}'

Binding service my-db to app rails-sample in org console / space development as user@example.com... OK
</pre>

<pre class="terminal">
$ cf bind-service rails-sample my-db -c /tmp/config.json

Binding service my-db to app rails-sample in org console / space development as user@example.com... OK
</pre>

## <a id='use'></a>Using Bound Services ##

Once you have a service instance created and bound to your application, you
need to configure the application to dynamically fetch the credentials for your
service.
These credentials are stored in the
[VCAP_SERVICES](../deploy-apps/environment-variable.html#VCAP-SERVICES)
environment variable.
There are generally two methods for these consuming credentials.

* **Auto-configuration**: Some buildpacks create a service connection for you
by creating additional environment variables, updating config files, or passing
system parameters to the JVM.
* **Manual**: [Parse the JSON yourself](../deploy-apps/environment-variable.html#VCAP-APPLICATION). Helper libraries are
available for some frameworks.

See the [buildpacks documentation](../../buildpacks/index.html) to learn more
about working with specific frameworks.

## <a id='update-credentials'></a>Update Service Credentials

If you need to update your service credentials, perform the following steps:

  1. [Unbind the service instance](#unbind) using the credentials you are updating with the following command:

    <pre class='terminal'>
    $ cf unbind-service &lt;YOUR-APP&gt; &lt;YOUR-SERVICE-INSTANCE&gt;
    </pre>

  1. [Bind the service instance](#bind). This adds your credentials to the [VCAP_SERVICES](../deploy-apps/environment-variable.html) environment variable.

    <pre class='terminal'>
    $ cf bind-service &lt;YOUR-APP&gt; &lt;YOUR-SERVICE-INSTANCE&gt;
    </pre>

  1. Restart or re-push the application bound to the service instance so that the application recognizes your environment variable updates.

## <a id='unbind'></a>Unbind a Service Instance ##

Unbinding a service removes the credentials created for your application from the [VCAP_SERVICES](../deploy-apps/environment-variable.html) environment variable. You must restart or in some cases re-push your application for the application to recognize changes to environment variables.

<pre class="terminal">
$ cf unbind-service my-app mydb
Unbinding app my-app from service mydb in org my-org / space test as me@example.com...
OK
</pre>

## <a id='delete'></a>Delete a Service Instance ##

Deleting a service unprovisions the service instance and deletes *all data* along with the service instance.

<pre class="terminal">
$ cf delete-service mydb

Are you sure you want to delete the service mydb ? y
Deleting service mydb in org my-org / space test as me@example.com...
OK
</pre>
