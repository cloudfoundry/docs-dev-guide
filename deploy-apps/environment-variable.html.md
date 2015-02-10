---
title: Cloud Foundry Environment Variables
---

_This page assumes you are using cf CLI v6._

Environment variables are the means by which the Cloud Foundry runtime
communicates with a deployed application about its environment.
This page describes the environment variables that Droplet Execution Agents
(DEAs) and buildpacks set for applications.

For information about setting your own application-specific environment
variables, refer to the [Set Environment Variable in a Manifest](./manifest.html#env-block) section in
the Application Manifests topic.

## <a id='view-env'></a>View Environment Variables ##

Use the `cf env` command to view the Cloud Foundry environment variables for your application. `cf env` displays the following environment variables:

* The `VCAP_SERVICES` variables existing in the container environment
* The user-provided variables set using the `cf set-env` command

<pre class="terminal">
  $ cf env my-app
  Getting env variables for app my-app in org My-Org / space development as admin...
  OK

  System-Provided:
  {
    "VCAP_SERVICES": {
      "p-mysql-n/a": [
        {
          "credentials": {
      	    "uri":"postgres://lrra:e6B-X@p-mysqlprovider.example.com:5432/lraa
          },
          "label": "p-mysql-n/a",
          "name": "p-mysql",
          "syslog_drain_url": "",
          "tags": ["postgres","postgresql","relational"]
        }
      ]
    }
  }

  User-Provided:
  my-env-var: 100
  my-drain: http://drain.example.com
</pre>

## <a id='dea-set'></a>Variables Available to Your Application ##

The subsections that follow describe the environment variables that Cloud Foundry makes available for your application container.

You can access environment variables programmatically, including variables
defined by the buildpack.
Refer to the buildpack documentation for [Java](../../buildpacks/java/java-tips.html#env-var),
[Node.js](../../buildpacks/node/node-tips.html#env-var), and
[Ruby](../../buildpacks/ruby/ruby-tips.html#env-var).

### <a id='HOME'></a>HOME ###
Root folder for the deployed application.

`HOME=/home/vcap/app`

### <a id='memory'></a>MEMORY_LIMIT ###
The maximum amount of memory that each instance of the application can consume. 
You specify this value in an application manifest or with the cf CLI when pushing an application. The value is limited by space and org quotas.

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

<table border="1" class="nice">
  <tr>
    <th>Attribute</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>application_users</code>, <code>users</code></td>
    <td></td>
  </tr>
  <tr>
    <td><code>instance_id</code></td>
    <td>GUID that identifies the application.</td>
  </tr>
  <tr>
    <td><code>instance_index</code></td>
    <td>Index number of the instance. You can access this value directly with the <a href="#CF-INSTANCE-INDEX">CF_INSTANCE_INDEX</a> variable.</td>
  </tr>
  <tr>
    <td><code>application_version</code>, <code>version</code></td>
    <td>GUID that identifies a version of the application that was pushed. Each time an application is pushed, this value is updated.</td>
  </tr>
  <tr>
    <td><code>application_name</code>, <code>name</code></td>
    <td>The name assigned to the application when it was pushed.</td>
  </tr>
  <tr>
    <td><code>application_uris</code></td>
    <td>The URI(s) assigned to the application.</td>
  </tr>
  <tr>
    <td><code>started_at</code>, <code>start</code></td>
    <td>The last time the application was started.</td>
  </tr>
  <tr>
    <td><code>started_at_timestamp</code></td>
    <td>Timestamp for the last time the application was started.</td>
  </tr>
  <tr>
    <td><code>host</code></td>
    <td>IP address of the application isntance.</td>
  </tr>
  <tr>
    <td><code>port</code></td>
    <td>Port of the application instance. You can access this value directly with the <a href="#PORT">PORT</a> variable.</td>
  </tr>
  <tr>
    <td><code>limits</code></td>
    <td>The memory, disk, and number of files permitted to the instance. Memory and disk limits are supplied when the application is deployed, either on the command line or in the application manifest. The number of files allowed is operator-defined.</td>
  </tr>
  <tr>
    <td><code>state_timestamp</code></td>
    <td>The timestamp for the time at which the application achieved its current state.</td>
  </tr>
</table>

For example:

~~~

VCAP_APPLICATION={"instance_id":"451f045fd16427bb99c895a2649b7b2a",
"instance_index":0,"host":"0.0.0.0","port":61857,"started_at":"2013-08-12
00:05:29 +0000","started_at_timestamp":1376265929,"start":"2013-08-12 00:05:29
+0000","state_timestamp":1376265929,"limits":{"mem":512,"disk":1024,"fds":16384}
,"application_version":"c1063c1c-40b9-434e-a797-db240b587d32","application_name"
:"styx-james","application_uris":["styx-james.a1-app.cf-app.com"],"version":"c10
63c1c-40b9-434e-a797-db240b587d32","name":"styx-james","uris":["styx-james.a1-ap
p.cf-app.com"],"users":null}

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

<table border="1" class="nice">
  <tr>
    <th>Attribute</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>name</code></td>
    <td>The name assigned to the service instance by the user when it was created.</td>
  </tr>
  <tr>
    <td><code>label</code></td>
    <td><strong>v1 broker API</strong> The service name and service version (if there is no version attribute, the string "n/a" is used), separated by a dash character, for example "cleardb-n/a".<br/><strong>v2 broker API</strong> The service name.</td>
  </tr>
  <tr>
    <td><code>tags</code></td>
    <td>An array of strings an app can use to identify a service.</td>
  </tr>
  <tr>
    <td><code>plan</code></td>
    <td>The service plan selected when the service was created.</td>
  </tr>
  <tr>
    <td><code>credentials</code></td>
    <td>A JSON object containing the service-specific set of credentials needed to access the service instance. For example, for the cleardb service, this will include name, hostname, port, username, password, uri, and jdbcUrl.</td>
  </tr>
</table>

To see the value of VCAP\_SERVICES for an application pushed to Cloud Foundry,
see [View Environment Variable Values](#view-env).

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
## <a id='instance-vars'></a>Application Instance-Specific Variables ##

Each instance of an application can access a set of variables with the <code>CF_INSTANCE</code> prefix. These variables provide information for a given application instance, including identification of the host DEA by its IP address.

### <a id='CF-INSTANCE-ADDR'></a>CF\_INSTANCE\_ADDR ###
The [CF\_INSTANCE\_IP](#CF-INSTANCE-IP) and [CF\_INSTANCE\_PORT](#CF-INSTANCE-PORT) of the app instance in the format `particular-DEA-IP:particular-app-instance-port`.

`CF_INSTANCE_ADDR=1.2.3.4:5678`

### <a id='CF-INSTANCE-INDEX'></a>CF\_INSTANCE\_INDEX ###
The index number of the app instance.

`CF_INSTANCE_INDEX=0`

### <a id='CF-INSTANCE-IP'></a>CF\_INSTANCE\_IP ###
The external IP address of the DEA running the container with the app instance.

`CF_INSTANCE_IP=1.2.3.4`

### <a id='CF-INSTANCE-PORT'></a>CF\_INSTANCE\_PORT ###
The [PORT](#PORT) of the app instance.

`CF_INSTANCE_PORT=5678`

### <a id='CF-INSTANCE-PORTS'></a>CF\_INSTANCE\_PORTS ###
The external and internal ports allocated to the app instance.

`CF_INSTANCE_PORTS=[{external:5678,internal:5678}]`
