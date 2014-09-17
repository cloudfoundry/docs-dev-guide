---
title: Cloud Foundry Environment Variables
---

_This page assumes that you are using cf v6._

Environment variables are the means by which the Cloud Foundry runtime
communicates with a deployed application about its environment.
This page describes the environment variables that Droplet Execution Agents
(DEAs) and buildpacks set for applications.

For information about setting your own application-specific environment
variables, refer to the [Set Environment Variable in a Manifest](./manifest.html#env-block) section in
the Application Manifests topic.

## <a id='view'></a>View Environment Variable Values ##
The sections below describe methods of viewing the values of Cloud Foundry
environment variables.

### <a id='cli'></a>View Environment Variables using CLI ###

The cf command line interface provides two commands that can return environment
variables.

To see the environment variables that you have set using the `cf set-env`
command:

<pre class="terminal">
$ cf env my_app_name
</pre>

To see the environment variables in the container environment:

<pre class="terminal">
$ cf files my_app_name logs/env.log
</pre>

## <a id='dea-set'></a>Variables Defined by the DEA ##

The subsections that follow describe the environment variables set by a DEA for
an application at staging time.

You can access environment variables programmatically, including variables
defined by the buildpack (if any).
Refer to the buildpack documentation for [Java](../../buildpacks/java/java-tips.html#env-var),
[Node.js](../../buildpacks/node/node-tips.html#env-var), and
[Ruby](../../buildpacks/ruby/ruby-tips.html#env-var).

### <a id='HOME'></a>HOME ###
Root folder for the deployed application.

`HOME=/home/vcap/app`

### <a id='memory'></a>MEMORY_LIMIT ###
The maximum amount of memory that each instance of the application can consume.
This value is set as a result of the value you specify in an application
manifest, or at the command line when pushing an application.

If an instance goes over the maximum limit, it will be restarted. If it has to be restarted too often, it will be terminated.

`MEMORY_LIMIT=512m`

### <a id='PORT'></a>PORT ###
The port on the DEA for communication with the application.
The DEA allocates a port to the application during staging.
For this reason, code that obtains or uses the application port should reference
it using `PORT`.

`PORT=61857`

### <a id='PWD'></a>PWD ###
Identifies the present working directory, where the buildpack that processed the
application ran.

`PWD=/home/vcap`

### <a id='TMPDIR'></a>TMPDIR###
Directory location where temporary and staging files are stored.

`TMPDIR=/home/vcap/tmp`

### <a id='USER'></a>USER###
The user account under which the DEA runs.

`USER=vcap`

### <a id='VCAP-APP-HOST'></a>VCAP\_APP\_HOST

The IP address of the DEA host.

`VCAP_APP_HOST=0.0.0.0`

### <a id='VCAP-APPLICATION'></a>VCAP_APPLICATION ###

This variable contains useful information about a deployed application.
Results are returned in JSON format.
The table below lists the attributes that are returned.


|Attribute|Description |
| --------- | --------- |
|application_users, users | |
|instance_id|GUID that identifies the application. |
|instance_index |Index number of the instance. |
|application_version, version |GUID that identifies a version of the application that was pushed. Each time an application is pushed, this value is updated. |
|application_name, name |The name assigned to the application when it was pushed. |
|application_uris |The URI(s) assigned to the application.   |
|started_at, start |The last time the application was started. |
|started\_at\_timestamp |Timestamp for the last time the application was started. |
|host |IP address of the application instance. |
|port |Port of the application instance. |
|limits  |The memory, disk, and number of files permitted to the instance. Memory and disk limits are supplied when the application is deployed, either on the command line or in the application manifest. The number of files allowed is operator-defined. |
|state_timestamp |The timestamp for the time at which the application achieved its current state.|

~~~

VCAP_APPLICATION={"instance_id":"451f045fd16427bb99c895a2649b7b2a","instance_index":0,"host":"0.0.0.0","port":61857,"started_at":"2013-08-12 00:05:29 +0000","started_at_timestamp":1376265929,"start":"2013-08-12 00:05:29 +0000","state_timestamp":1376265929,"limits":{"mem":512,"disk":1024,"fds":16384},"application_version":"c1063c1c-40b9-434e-a797-db240b587d32","application_name":"styx-james","application_uris":["styx-james.a1-app.cf-app.com"],"version":"c1063c1c-40b9-434e-a797-db240b587d32","name":"styx-james","uris":["styx-james.a1-app.cf-app.com"],"users":null}`

~~~

### <a id='VCAP-APP-PORT'></a>VCAP\_APP\_PORT ###

Equivalent to the [PORT](#PORT) variable, defined above.

### <a id='VCAP-SERVICES'></a>VCAP\_SERVICES ###

For [bindable services](../services/) Cloud Foundry will add connection details
to the `VCAP_SERVICES` environment variable when you restart your application,
after binding a service instance to your application.

The results are returned as a JSON document that contains an object for each
service for which one or more instances are bound to the application.
The service object contains a child object for each service instance of that
service that is bound to the application.
The attributes that describe a bound service are defined in the table below.

The key for each service in the JSON document is the same as the value of the
"label" attribute.

|Attribute|Description |
| --------- | --------- |
|name|The name assigned to the service instance by the user when it was created |
|label| **v1 broker API** The service name and service version (if there is no version attribute, the string "n/a" is used), separated by a dash character, for example "cleardb-n/a"<br/>**v2 broker API** The service name|
|tags| An array of strings an app can use to identify a service |
|plan|The service plan selected when the service was created |
|credentials|A JSON object containing the service-specific set of credentials needed to access the service instance. For example, for the cleardb service, this will include name, hostname, port, username, password, uri, and jdbcUrl|

To see the value of VCAP\_SERVICES for an application pushed to Cloud Foundry,
see [View Environment Variable Values](#view).

The example below shows the value of VCAP_SERVICES in the [v1 format](../../services/api-v1.html) for bound instances of several services
available in the [Pivotal Web Services](http://run.pivotal.io) Marketplace.

~~~
VCAP_SERVICES=
{
  "elephantsql-n/a": [
    {
      "name": "elephantsql-c6c60",
      "label": "elephantsql-n/a",
      "tags": [
        "postgres",
        "postgresql",
        "relational"
      ],
      "plan": "turtle",
      "credentials": {
        "uri": "postgres://seilbmbd:PHxTPJSbkcDakfK4cYwXHiIX9Q8p5Bxn@babar.elephantsql.com:5432/seilbmbd"
      }
    }
  ],
  "sendgrid-n/a": [
    {
      "name": "mysendgrid",
      "label": "sendgrid-n/a",
      "tags": [
        "smtp"
      ],
      "plan": "free",
      "credentials": {
        "hostname": "smtp.sendgrid.net",
        "username": "QvsXMbJ3rK",
        "password": "HCHMOYluTv"
      }
    }
  ]
}
~~~

The [v2 format](../../services/api.html) of the same services would look like this:

~~~
VCAP_SERVICES=
{
  "elephantsql": [
    {
      "name": "elephantsql-c6c60",
      "label": "elephantsql",
      "tags": [
        "postgres",
        "postgresql",
        "relational"
      ],
      "plan": "turtle",
      "credentials": {
        "uri": "postgres://seilbmbd:PHxTPJSbkcDakfK4cYwXHiIX9Q8p5Bxn@babar.elephantsql.com:5432/seilbmbd"
      }
    }
  ],
  "sendgrid": [
    {
      "name": "mysendgrid",
      "label": "sendgrid",
      "tags": [
        "smtp"
      ],
      "plan": "free",
      "credentials": {
        "hostname": "smtp.sendgrid.net",
        "username": "QvsXMbJ3rK",
        "password": "HCHMOYluTv"
      }
    }
  ]
}
~~~
