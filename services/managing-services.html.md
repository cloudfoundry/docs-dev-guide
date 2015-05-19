---
title: Managing Service Instances with the CLI
---

_This page assumes you are using cf CLI v6._

## <a id='viewing-services'></a> View Available Services ##

After targeting and logging into Cloud Foundry, you can view what services are available to your targeted organization. Available services may differ between organizations and between Cloud Foundry marketplaces.

<pre class="terminal">
$ cf marketplace
Getting services from marketplace in org my-org / space test as me@example.com...
OK

service               plans                  description
p-mysql               100mb, 1gb             A DBaaS
p-riakcs              developer              An S3-compatible object store
</pre>

## <a id='create'></a>Create a Service Instance ##

Creating a service instance provisions a reserved resource from the service. See [Services Overview](index.html) for more information.

<pre class="terminal">
$ cf create-service p-mysql 100mb mydb
Creating service mydb in org my-org / space test as me@example.com...
OK
</pre>

### <a id='user-provided'></a>Create a User-Provided Service Instance ##

User-provided service instances are resources which have been pre-provisioned outside of Cloud Foundry. For example, a DBA may provide a developer with credentials to an Oracle database managed outside of, and unknown to Cloud Foundry. Rather than hard coding credentials for these instances into your applications, you can create a mock service instance in Cloud Foundry to represent an external resource and configure it with the credentials provided by your DBA. Once this mock instance is created in the platform, the same CLI commands (documented on this page) can be used to manage user-provided instances as for instances provisioned by the platform.

Refer to the [User Provided Service Instances](user-provided.html) topic for more information.

## <a id='rename_service'></a>Rename a Service Instance ##

You can change the name given to a service instance. Keep in mind that upon restarting any bound applications, the name of the instance will change in the [VCAP_SERVICES](../deploy-apps/environment-variable.html) environment variable. If your application depends on the instance name for discovering credentials, changing the name could break your applications use of the service instance.

<pre class="terminal">
$ cf rename-service mydb mydb1
Renaming service mydb to mydb1 in org my-org / space test as me@example.com...
OK
</pre>

## <a id='update_service'></a>Update a Service Instance ##

With v192 of [cf-release](https://github.com/cloudfoundry/cf-release) and v6.7 of the [CLI](https://github.com/cloudfoundry/cli), Cloud Foundry introduced support for users to update attributes of a service instance (besides the name) after provisioning. Currently the only attribute of an instance that can be modified is the service plan.

### Upgrade/Downgrade Service Plan

By updating the service plan for an instance, users can effectively upgrade and downgrade their service instance to other service plans. Though the platform and CLI now supports this feature, services must expressly implement support for it so not all services will. Further, a service may support updating between some plans but not others (e.g. a service may support updating a plan where only a logical change is required, but not where data migration is necessary). In either case, users can expect to see a meaningful error when plan update is not supported.

You can update the plan for an existing service instance as follows:

<pre class="terminal">
$ cf update-service mydb -p new-plan
Updating service instance mydb as me@example.com...
OK
</pre>

### <a id='arbitrary-params-update'></a> Arbitrary Parameters  ###
Some services may support additional configuration parameters, which can be passed along with the update request. The parameters are passed in a valid JSON object containing service-specific configuration parameters, provided either in-line or in a file. For a list of supported configuration parameters, see documentation for the particular service offering.

<pre class="terminal">
$ cf update-service mydb -c '{"storage_gb":4}'

Updating service instance mydb as me@example.com...
</pre>

<pre class="terminal">
$ cf update-service mydb -c /tmp/config.json

Updating service instance mydb as me@example.com...
</pre>

## <a id='bind'></a>Bind a Service Instance ##

Binding a service to your application adds credentials for the service instance to the [VCAP_SERVICES](../deploy-apps/environment-variable.html) environment variable. In most cases these credentials are unique to the binding; another app bound to the same service instance would receive different credentials.How your app leverages the contents of environment variables may depend on the framework you employ. Refer to the [Deploying Apps](../deploy-apps/index.html) section for more information.

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
