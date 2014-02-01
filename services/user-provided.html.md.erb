---
title: User Provided Service Instances
---

_This page assumes that you are using cf v6._

User-provided service instances are service instances which have been provisioned outside of Cloud Foundry. For example, a DBA may provide a developer with credentials to an Oracle database managed outside of and unknown to Cloud Foundry. Rather than hard-coding credentials for these instances into your applications, you can create a mock service instance in Cloud Foundry to represent an external resource, and provide whatever credentials your application requires. Once created, user-provided service instances behave just like other service instances.

The `cf services` command lists all the services (both user-provided and others) in your target space.

## <a id='user-cups'></a>cf Commands for Working with User-Provided Services ##

cf commands for creating and updating user-provided services can be used in three ways: interactively, non-interactively, and in conjunction with third-party log management software as described in [RFC 6587](http://tools.ietf.org/html/rfc6587). When used with third-party logging, cf sends data formatted according to [RFC 5424](http://tools.ietf.org/html/rfc5424).

Once created, user-provided services can be bound to an application with `cf bind-service`, unbound with `cf unbind-service`, renamed with `cf rename-service`, and deleted with `cf delete-service`.

Finally, you can list service auth tokens with `cf service-auth-tokens`, create them with `cf create-service-auth-token`, and update them with `cf update-service-auth-token`.

### <a id='user-cups'></a>The cf create-user-provided-service Command ###

The alias for `create-user-provided-service` is `cups`.

To create a service in interactive mode, use the `-p` option with a comma-separated list of parameter names.
cf then prompts you for each parameter in turn.

  `cf cups SERVICE_INSTANCE -p "host, port, dbname, username, password"`

To create a service non-interactively, use the `-p` option with a JSON hash of parameter keys and values.

  `cf cups SERVICE_INSTANCE -p '{"username":"admin","password":"pa55woRD"}'`

To create a service that drains information to third-party log management software, use the `-l SYSLOG_DRAIN_URL` option.

  `cf cups SERVICE_INSTANCE -l syslog://<%=vars.app_domain%>`

### <a id='user-uups'></a> The cf update-user-provided-service Command ###

The alias for `update-user-provided-service` is `uups`.
You can use `cf update-user-provided-service` to update one or more of the attributes for a user-provided service.
Attributes that you do not supply are not updated.

To update a service in interactive mode, use the `-p` option with a comma-separated list of parameter names.
cf then prompts you for each parameter in turn.

  `cf uups SERVICE_INSTANCE -p "HOST, PORT, DATABASE, USERNAME, PASSWORD"`

To update a service non-interactively, use the `-p` option with a JSON hash of parameter keys and values.

  `cf uups SERVICE_INSTANCE -p '{"username":"USERNAME","password":"PASSWORD"}'`

To update a service that drains information to third-party log management software, use the `-l SYSLOG_DRAIN_URL` option.

  `cf uups SERVICE_INSTANCE -l syslog://<%=vars.app_domain%>`

## <a id='cups-example'></a> Binding User-Provided Services to Applications  ##

There are two ways to bind user-provided services to applications:

* With a manifest, _when_ you push the application.
* With the `cf bind-service` command, _after_ you push the application.

In either case, you must push your app to a space where the desired user-provided instances already exist.

For example, if you want to bind a service instance called `test-mysql-01` to an app, the services block in the manifest should look like this:

~~~
services:
 - test-mysql-01
~~~

This excerpt from the cf push command and response shows that cf reads the manifest and binds the service instance to the app, which is called `test-msg-app`.

<pre class="terminal">
$ cf push
Using manifest file /Users/janclouduser/test-apps/test-msg-app/manifest.yml

...

Binding service test-mysql-01 to test-msg-app in org janclouduser-org / space development as janclouduser@<%=vars.app_domain%>
OK
</pre>

For more information about manifests, see [Deploying with Application Manifests](../deploy-apps/manifest.html#services-block).

For an example of the `cf bind-service` command, see the next section.

## <a id='cups-example'></a> Example: Creating a Service and Binding it to an Application ##

Suppose we want to create and bind an instance of a publish-subscribe messaging service to an app called test-msg-app.
Our Cloud Foundry username is `janclouduser`, and we know the URL and port for the service.

1. We begin with the `cf create-user-provided-service command` in interactive mode, using its alias, `cups`.

	<pre class="terminal">
	$ cf cups test-pubsub-01 -p "host, port, binary, username, password"

	host> pubsub01.<%=vars.app_domain%>

	port> 1234

	url> pubsub-example.com

	username> pubsubuser

	password> p@$$w0rd
	Creating user provided service test-pubsub-01 in org janclouduser-org / space development as janclouduser@<%=vars.app_domain%>...
	OK
	</pre>

1. When we list available services, we see that the new service is not yet bound to any apps.

	<pre class="terminal">
	$ cf services
	Getting services in org janclouduser-org / space development as janclouduser@<%=vars.app_domain%>...
	OK

	name               service         plan    bound apps
	test-pubsub-01     user-provided
	</pre>

1. Now we bind the service to our app.

	<pre class="terminal">
	$ cf bind-service test-msg-app test-pubsub-01
	Binding service test-pubsub-01 to app test-msg-app in org janclouduser-org / space development as janclouduser@<%=vars.app_domain%>...
	OK
	TIP: Use 'cf push' to ensure your env variable changes take effect
	</pre>

	At this point `VCAP_SERVICES`, the environment variable which controls binding, has been set locally but not yet pushed to the environment of the container where our app is running.

1. We push our app a second time to update the container environment and cause the binding to take effect.

	<pre class="terminal">
	$ cf push test-msg-app
	Updating app test-msg-app in org janclouduser-org / space development as janclouduser@<%=vars.app_domain%>...
	OK
	...
	</pre>

1. To verify that the service instance is now recorded in [VCAP_SERVICES](../deploy-apps/environment-variable.html), we search the environment log.

	<pre class="terminal">
	$ cf files test-msg-app logs/env.log | grep VCAP_SERVICES
	VCAP_SERVICES={"user-provided":[{"name":"test-pubsub-01","label":"user-provided","tags":[],"credentials":{"binary":"pubsub.rb","host":"pubsub01.<%=vars.app_domain%>","password":"p@29w0rd","port":"1234","username":"pubsubuser"},"syslog_drain_url":""}]}
	</pre>


