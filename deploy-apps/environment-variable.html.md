---
title: Cloud Foundry Environment Variables
---

_This page assumes that you are using cf v6._

Environment variables are the means by which the Cloud Foundry runtime
communicates with a deployed application about its environment.
This page describes the environment variables that Droplet Execution Agents
(DEAs) and buildpacks set for applications.

For information about setting your own application-specific environment
variables, see [Set Environment Variable in a Manifest](manifest.html#var) on
the [Application Manifests](manifest.html) page.

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

### <a id='app'></a>Access Environment Variables Programmatically ###

The sections below show how to access an environment variable from a program. These examples obtain the `VCAP_SERVICES` environment variable

### Java

```
System.getenv("VCAP_SERVICES");
```

### Ruby

```
ENV['VCAP_SERVICES']
```

### Node.js

```
process.env.VCAP_SERVICES
```

## <a id='dea-set'></a>Variables Defined by the DEA ##

The subsections that follow describe the environment variables set by a DEA for
an application at staging time.

### <a id='HOME'></a>HOME ###
Root folder for the deployed application.

`HOME=/home/vcap/app`

### <a id='HOME'></a>MEMORY_LIMIT ###
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

### <a id='VCAP\_APP\_HOST'></a>VCAP\_APP\_HOST

The IP address of the DEA host.

`VCAP_APP_HOST=0.0.0.0`

### <a id='VCAP_APPLICATION'></a>VCAP_APPLICATION ###

This variable contains useful information about a deployed application.
Results are returned in JSON format.
The table below lists the attributes that are returned.


|Attribute|Description |
| --------- | --------- |
|application_users, users | |
|instance_id|GUID that identifies the application. |
|instance_index |Index number, relative to the DEA, of the instance. |
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

### <a id='VCAP_APP_PORT'></a>VCAP\_APP\_PORT ###

Equivalent to the [PORT](#PORT) variable, defined above.

### <a id='VCAP_SERVICES'></a>VCAP\_SERVICES ###

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
|label (v1 API)|The service name and service version (if there is no version attribute, the string "n/a" is used), separated by a dash character, for example "cleardb-n/a"|
|label (v2 API)|The service name |
|plan|The service plan selected when the service was created |
|credentials|A JSON object containing the service-specific set of credentials needed to access the service instance. For example, for the cleardb service, this will include name, hostname, port, username, password, uri, and jdbcUrl|


The example below contains the JSON for the VCAP_SERVICES environment variable
for bound instances of several services available in the Cloud Foundry Services
Marketplace.

~~~
VCAP_SERVICES=
{
  "elephantsql-dev": [
    {
      "name": "elephantsql-dev-c6c60",
      "label": "elephantsql-dev",
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

## <a id='ruby-buildpack'></a>Variables Defined by Ruby Buildpack ##

The subsections that follow describe the environment variables set by the Ruby
buildpack for an application at staging time.

### <a id='BUNDLE_BIN_PATH'></a>BUNDLE\_BIN\_PATH ###

Location where Bundler installs binaries.

`BUNDLE_BIN_PATH:/home/vcap/app/vendor/bundle/ruby/1.9.1/gems/bundler-1.3.2/bin/bundle`

### <a id='BUNDLE_GEMFILE'></a>BUNDLE_GEMFILE ###

Path to application’s gemfile.

`BUNDLE_GEMFILE:/home/vcap/app/Gemfile`

### <a id='BUNDLE_WITHOUT'></a>BUNDLE_WITHOUT ###

The `BUNDLE_WITHOUT` environment variable causes Cloud Foundry to skip
installation of gems in excluded groups.
`BUNDLE_WITHOUT` is particularly useful for Rails applications, where there are
typically “assets” and “development” gem groups containing gems that are not
needed when the app runs in production

For information about using this variable, see http://blog.cloudfoundry.com/2012/10/02/polishing-cloud-foundrys-ruby-gem-support.

`BUNDLE_WITHOUT=assets`

### <a id='DATABASE_URL'></a>DATABASE_URL ###

The Ruby buildpack looks at the database\_uri for bound services to see if they
match known database types.
If there are known relational database services bound to the application, the
buildpack sets up the DATABASE_URL environment variable with the first one in
the list.

If your application depends on DATABASE\_URL being set to the connection string
for your service, and Cloud Foundry does not set it, you can set this variable
manually.

`$ cf set-env my_app_name DATABASE_URL mysql://b5d435f40dd2b2:ebfc00ac@us-cdbr-east-03.cleardb.com:3306/ad_c6f4446532610ab`

### <a id='GEM_HOME'></a>GEM_HOME ###

Location where gems are installed.

`GEM_HOME:/home/vcap/app/vendor/bundle/ruby/1.9.1`

### <a id='GEM_PATH'></a>GEM_PATH ###

Location where gems can be found.

`GEM_PATH=/home/vcap/app/vendor/bundle/ruby/1.9.1:`

### <a id='RACK_ENV'></a>RACK_ENV ###
This variable specifies the Rack deployment environment: development,
deployment, or none.
This governs what middleware is loaded to run the application.

`RACK_ENV=production`

### <a id='RAILS_ENV'></a>RAILS_ENV ###
This variable specifies the Rails deployment environment: development, test, or
production.
This controls which of the environment-specific configuration files will govern
how the application will be executed.

`RAILS_ENV=production`

### <a id='RUBYOPT'></a>RUBYOPT ###
This Ruby environment variable defines command-line options passed to Ruby
interpreter.

`RUBYOPT: -I/home/vcap/app/vendor/bundle/ruby/1.9.1/gems/bundler-1.3.2/lib -rbundler/setup`

## <a id='node-buildpack'></a>Variables Defined by Node Buildpack ##

### <a id='BUILD_DIR'></a>BUILD_DIR ###
Directory into which Node.js is copied each time a Node.js application is run.

### <a id='CACHE_DIR'></a>CACHE_DIR ###

Directory that Node.js uses for caching.

### <a id='PATH'></a>PATH ###

The system path used by Node.js.

`PATH=/home/vcap/app/bin:/home/vcap/app/node_modules/.bin:/bin:/usr/bin`