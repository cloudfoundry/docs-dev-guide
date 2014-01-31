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

  `cf cups SERVICE_INSTANCE -l syslog://example.com`

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

  `cf uups SERVICE_INSTANCE -l syslog://example.com`

### <a id='cups-example'></a> Binding User-Provided Services to Applications  ###

There are two ways to bind user-provided services to applications:

* When you push an application, you can use a manifest.
* After you push an application, you can use the `cf bind-service` command.

In either case, you must be pushing your app to a space where the desired user-provided instances already exist.

For example, if you want to bind a service instance called `test-mysql-01` to your app, the services block of a manifest should look like this:

~~~
services:
 - test-mysql-01
~~~

See [Deploying with Application Manifests](../deploy-apps/manifest.html#services-block).

For an example of the `cf bind-service` command, see the next section.

### <a id='cups-example'></a> Example: Creating a Service and Binding it to an Application ###

<pre class="terminal">
	$ cf cups test-pubsub-01 -p "host, port, binary, username, password"

	host> pubsub01.example.com

	port> 1234

	binary> foo.rb

	username> pubsubuser

	password> p@$$w0rd
	Creating user provided service test-pubsub-01 in org araher-org / space development as araher@pivotallabs.com...
	OK
</pre>

Now when you list the available services, you see the new service you created.

<pre class="terminal">
	$ cf services
	Getting services in org araher-org / space development as araher@pivotallabs.com...
	OK

	name               service         plan    bound apps
	test-pubsub-01     user-provided
</pre>

Bind the service to your app.

<pre class="terminal">
cf bind-service blue test-pubsub-01
Binding service test-pubsub-01 to app blue in org araher-org / space development as araher@pivotallabs.com...
OK
TIP: Use 'cf push' to ensure your env variable changes take effect
</pre>

Now `VCAP_SERVICES`, the environment variable which controls binding, has been set locally but not yet pushed to the environment of the container where your app is running.

Push your app again to update the container environment and cause the binding to take effect.

~~~
$ cf push blue
Updating app blue in org araher-org / space development as araher@pivotallabs.com...
OK
...
~~~

Now [VCAP_SERVICES](../deploy-apps/environment-variable.html) has been updated with your credentials. You can verify this by searching the environment log for your application.

~~~
cf files blue logs/env.log | grep VCAP_SERVICES
VCAP_SERVICES={"user-provided":[{"name":"test-pubsub-01","label":"user-provided","tags":[],"credentials":{"binary":"foo.rb","host":"pubsub01.example.com","password":"p@29w0rd","port":"1234","username":"pubsubuser"},"syslog_drain_url":""}]}
~~~


