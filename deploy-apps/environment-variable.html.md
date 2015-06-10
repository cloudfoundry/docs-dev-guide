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
  Getting env variables for app my-app in org my-org / space my-space as admin...
  OK
  
  System-Provided:
  
  
  {
   "VCAP_APPLICATION": {
    "application_name": "my-app",
    "application_uris": [
     "my-app.10.244.0.34.xip.io"
    ],
    "application_version": "fb8fbcc6-8d58-479e-bcc7-3b4ce5a7f0ca",
    "limits": {
    "disk": 1024,
    "fds": 16384,
    "mem": 256
    },
    "name": "my-app",
    "space_id": "06450c72-4669-4dc6-8096-45f9777db68a",
    "space_name": "my-space",
    "uris": [
     "my-app.10.244.0.34.xip.io"
    ],
    "users": null,
    "version": "fb8fbcc6-8d58-479e-bcc7-3b4ce5a7f0ca"
    }
  }
  
  User-Provided:
  MY_DRAIN: http://drain.example.com
  MY_ENV_VARIABLE: 100
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

The example below shows the value of VCAP_SERVICES in the 
<%=vars.api_v1_format%> for bound instances of several services available in the 
[Pivotal Web Services](http://run.pivotal.io) Marketplace.

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

The <%=vars.api_v2_format%> of the same services would look like this:

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

## <a id='evgroups'></a>Environment Variable Groups ##

Environment variable groups are system-wide variables that enable operators to apply a group of environment variables to all running applications and all staging applications separately.

An environment variable group consists of a single hash of name-value pairs that are later inserted into an application container at runtime or at staging. These values can contain information such as HTTP proxy information. The values for variables set in an environment variable group are case-sensitive.

When creating environment variable groups, consider the following:

* Only the Cloud Foundry operator can set the hash value for each group.
* All authenticated users can get the environment variables assigned to their application.
* All variable changes take effect after the operator restarts or restages the applications.
* Any user-defined variable takes precedence over environment variables provided by these groups.

The table below lists the commands for environment variable groups.

<table border="1" class="nice">
  <tr>
    <th>CLI Command</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><code>running-environment-variable-group</code>, <code>revg</code></td>
    <td>Retrieves the contents of the running environment variable group.</td>
  </tr>
  <tr>
    <td><code>staging-environment-variable-group</code>, <code>sevg</code></td>
    <td>Retrieves the contents of the staging environment variable group.</td>
  </tr>
  <tr>
    <td><code>set-staging-environment-variable-group</code>, <code>ssevg</code></td>
    <td>Passes parameters as JSON to create a staging environment variable group.</td>
  </tr>
  <tr>
    <td><code>set-running-environment-variable-group</code>, <code>srevg</code></td>
    <td>Passes parameters as JSON to create a running environment variable group.</td>
  </tr>
 </table>
 
 The following examples demonstrate how to get the environment variables:
 
  <pre class="terminal">
  $ cf revg
  Retrieving the contents of the running environment variable group as sampledeveloper@pivotal.io...
  OK
  Variable Name   Assigned Value
  HTTP Proxy      87.226.68.130
 
  $ cf sevg
  Retrieving the contents of the staging environment variable group as sampledeveloper@pivotal.io...
  OK
  Variable Name   Assigned Value
  HTTP Proxy      27.145.145.105
  EXAMPLE-GROUP   2001

  $ cf apps
  Getting apps in org SAMPLE-ORG-NAME / space dev as sampledeveloper@pivotal.io...
  OK

  name                                               requested state   instances   memory   disk   urls
  APP-NAME                                         started           1/1         256M     1G     APP-NAME.cf-app.com, test-foo.com
 
  $ cf env APP-NAME
  Getting env variables for app APP-NAME in org SAMPLE-ORG-NAME / space dev as sampledeveloper@pivotal.io...
  OK

  System-Provided:


  {
   "VCAP\_APPLICATION": {
    "application\_name": "APP-NAME",
    "application\_uris": [
     "APP-NAME.sample-app.com",
     "test-foo.com"
    ],
    "application\_version": "7d0d64be-7f6f-406a-9d21-504643147d63",
    "limits": {
     "disk": 1024,
     "fds": 16384,
     "mem": 256
    },
    "name": "APP-NAME",
    "space\_id": "37189599-2407-9946-865e-8ebd0e2df89a",
    "space_name": "dev",
    "uris": [
     "APP-NAME.sample-app.com",
     "test-foo.com"
    ],
    "users": null,
    "version": "7d0d64be-7f6f-406a-9d21-504643147d63"
   }
  }

  Running Environment Variable Groups:
  HTTP Proxy: 87.226.68.130

  Staging Environment Variable Groups:
  EXAMPLE-GROUP: 2001
  HTTP Proxy: 27.145.145.105
  </pre>
  
  The following examples demonstrate how to set the environment variables:
  
  <pre class="terminal">
  $ cf ssevg '{"test":"87.226.68.130","test2":"27.145.145.105"}'
  Setting the contents of the staging environment variable group as admin...
  OK
  $ cf sevg
  Retrieving the contents of the staging environment variable group as admin...
  OK
  Variable Name   Assigned Value
  test            87.226.68.130
  test2           27.145.145.105
  
  $ cf srevg '{"test3":"2001","test4":"2010"}'
  Setting the contents of the running environment variable group as admin...
  OK
  $ cf revg
  Retrieving the contents of the running environment variable group as admin...
  OK
  Variable Name   Assigned Value
  test3           2001
  test4           2010
 
</pre>