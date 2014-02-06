---
title: Managing Services
---
_This page assumes you are using cf v6._

## <a id='viewing-services'></a> View Available Services ##

After targeting and logging into Cloud Foundry using
[cf](../installcf/cf.html), you can view available services in the
current targeted org and space using the `cf services` command:

<pre class='terminal'>
	$ cf services

	Getting services in org console / space development as user@example.org... OK

	name             service       plan     bound apps
	my-exampledb     exampledb     spark    sample1
</pre>

## <a id='create'></a>Create a Managed Service Instance ##

You can create a managed service instance with the command `cf create-service`:

```
$ cf create-service <SERVICE> <PLAN> <SERVICE-INSTANCE>
```

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

## <a id='user-provided'></a>Create a User-Provided Service Instance ##

User-provided service instances are service instances which have been provisioned outside of Cloud Foundry. For example, a DBA may provide a developer with credentials to an Oracle database managed outside of, and unknown to, Cloud Foundry. Rather than hard-coding credentials for these instances into your applications, you can create a mock service instance in Cloud Foundry to represent an external resource, and provide whatever credentials your application requires.

For more information about creating a user-provided service instance, refer to the [User-Provided Service Instances](./user-provided.html) topic.

## <a id='bind'></a>Bind a Service Instance ##

Binding a service to your application adds credentials for the service instance to the [VCAP\_SERVICES](../deploy-apps/environment-variable.html) environment variable. In most cases, these credentials are unique to the binding; another app bound to the same service instance would receive different credentials. You may need to restart your application for it to recognize the change.

How your app leverages the contents of environment variables may depend on the framework you employ. Refer to the [Deploying Apps](../deploy-apps/) section of the help for more information.

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

## <a id='unbind'></a>Unbind a Service Instance ##

Unbinding a service removes the credentials created for your application from the [VCAP\_SERVICES](../deploy-apps/environment-variable.html) environment variable. You may need to restart your application for it to recognize the change.

You can unbind either a managed or a user-provided service instance with the command `cf bind-service`:

```
$ cf unbind-service <APP> <SERVICE_INSTANCE>
```

`cf unbind-service` takes the following required arguments:

* APP: The name of the app to which you want to bind a service.
* SERVICE_INSTANCE: The name you provided when you created your service instance.

## <a id='delete'></a>Delete a Service Instance ##

Deleting a service unprovisions the service instance and deletes *all data* along with the service instance.

```
$ cf delete-service <SERVICE_INSTANCE>
```
You can optionally include the `-f` flag to force deletion without confirmation.
