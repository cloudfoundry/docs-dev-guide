---
title: Configure Service Connections for Ruby
---

_This page assumes that you are using cf v5._

After you create a service instance and bind it to an application you must configure the application to connect to the service.


## <a id='config-file'></a>Define Connection in Configuration File ##

For a Ruby database application, you configure the database connection information in the application's `database.yml` file. When you bind a service to an application, the service connection details are written to the applications's `VCAP_SERVICES` environment variable. `VCAP_SERVICES` lists, in JSON format, the services bound to your application and the credentials required to connect to each.

In Ruby, you can read the contents of `VCAP_SERVICES` with `ENV`. For example:

~~~ruby

my_services = JSON.parse(ENV['VCAP_SERVICES'])
~~~

You use the hash key for the service to obtain the the connection credentials from `VCAP_SERVICES`. You can determine the hash key for a service from the output of the `cf services` command, which lists available services. For example:

<pre class="terminal">
  cf services
  Getting services in production... OK

  name           service           provider      version   plan     bound apps
  myservice      elephantsql       elephantsql   n/a       turtle   myapp

</pre>

The hash key is formed from the service provider and version --- *provider-version*. For the service listed above, the provider is "elephantsql" and the version is "n/a", resulting in a hash key of "elephantsql-n/a".

You can obtain the credentials for the example service with these Ruby statements:

~~~ruby
  db = JSON.parse(ENV['VCAP_SERVICES'])["elephantsql-n/a"]
  credentials = db.first["credentials"]
  host = credentials["host"]
  username = credentials["username"]
  password = credentials["password"]
  database = credentials["database"]
  port = credentials["port"]
~~~

To configure a Rails application, you would change your `database.yml` to use
erb syntax to set the connection values using the credentials obtained from `VCAP_SERVICES`. If you are using the ElephantSQL Postgres service, your `database.yml` file might look like:

~~~

<%
  mydb = JSON.parse(ENV['VCAP_SERVICES'])["elephantsql-n/a"]
  credentials = mydb.first["credentials"]
%>

production:
  adapter: pg
  encoding: utf8
  reconnect: false
  pool: 5
  host: <%= credentials["host"] %>
  username: <%= credentials["username"] %>
  password: <%= credentials["password"] %>
  database: <%= credentials["database"] %>
  port: <%= credentials["port"] %>

~~~

If you are instantiating your adapter client directly, rather than using the active record pattern or another object-relation mapping (ORM) technique, your code would like something like this:

~~~ruby

mysqldb = JSON.parse(ENV['VCAP_SERVICES'])["cleardb-n/a"]
credentials = {
  :host => credentials["host"],
  :username => credentials["username"],
  :password => credentials["password"],
  :database => credentials["name"],
  :port => credentials["port"]
}

client = Mysql2::Client.new credentials

~~~

Your code may vary from the example above, depending on the hash key for the service and the syntax for instantiating your database adapter client.


## <a id='migrate'></a>Seed or Migrate Database ##

Before you can use your database the first time, you must create and populate or migrate it. For more information, see [Migrate a Database on Cloud Foundry](./migrate-db.html).

## <a id='troubleshooting'></a>Troubleshooting ##

If you have trouble connecting to your service, run the `cf logs` command to view log messages and see the values of the environment variables available to your application. `cf logs` command results include the value of the `VCAP_SERVICES` environment variable, for example:

<pre class="terminal">
  $ cf logs myapp
  Reading logs/console.log... OK
  Starting console on port 64868...

  Reading logs/env.log... OK
  VCAP_SERVICES={
    "elephantsql-n/a":[{
      "name":"elephant-postgres",
      "label":"elephantsql-n/a",
      "plan":"turtle",
      "credentials":{"uri":"postgres://username:password@server.example.com:5432/uniqid"}}]
  }
  ...more environment variables and values will show here...

  Reading logs/staging_task.log... OK
  ...output from the staging process displayed here...

  Reading logs/console.log
  ...output from running the application displayed here...
  --
</pre>

If you encounter the error "a fatal error has occurred. Please see the Bundler troubleshooting documentation", update your version of bundler and run `bundle install` again.

<pre class="terminal">
  $ gem update bundler
  $ gem update --system
  $ bundle install
</pre>


