---
title: Configure Service Connections for Ruby
---

_This page assumes that you are using cf v6._

After you create a service instance and bind it to an application, you must
configure the application to connect to the service.

## <a id='cf-app-utils'></a>Query VCAP_SERVICES with cf-app-utils ##

`cf-apps-utils` is a gem that allows your application to search for credentials
from VCAP_SERVICES by name, tag, or label.

* [cf-app-utils-ruby](https://github.com/cloudfoundry/cf-app-utils-ruby)

## <a id='auto-config'></a>Auto-configuration for Rails ##

Ruby on Rails applications often expect to find the connection string for a
relational database stored in the environment variable `DATABASE_URL`.
If the Ruby buildpack detects a Rails app, it looks in the `VCAP_SERVICES`
environment variable for a service instance having the key `uri` in the
`credentials` JSON object, whose value has a scheme matching `mysql` or
`postgres`.
If the buildpack finds a match, it updates `DATABASE_URL` with the value of
`uri`.
If multiple bound instances contain a `uri` key with matching scheme, the
buildpack will use the first one found.

## <a id='config-file'></a>Define Connection in Configuration File ##

For a Ruby database application, you configure the database connection
information in the application's `database.yml` file.
When you bind a service to an application, the service connection details are
written to the applications's `VCAP_SERVICES` environment variable.
`VCAP_SERVICES` lists, in JSON format, the services bound to your application
and the credentials required to connect to each.

In Ruby, you can read the contents of `VCAP_SERVICES` with `ENV`. For example:

~~~ruby
my_services = JSON.parse(ENV['VCAP_SERVICES'])
~~~

Use the hash key for the service to obtain the connection credentials
from `VCAP_SERVICES`.

- For services that use the [v2 Service Broker API](../../services/api.html), the hash key is the name of the service.

- For services that use the [v1 Service Broker API](../../services/api-v1.html), the hash key is formed by combining
the service provider and version, in the format PROVIDER-VERSION.

  Example: For service provider "p-mysql" with version "n/a", the hash key is
`p-mysql-n/a`.

You can obtain the credentials for the example service with these Ruby statements:

~~~ruby
  db = JSON.parse(ENV['VCAP_SERVICES'])["p-mysql-n/a"]
  credentials = db.first["credentials"]
  host = credentials["host"]
  username = credentials["username"]
  password = credentials["password"]
  database = credentials["database"]
  port = credentials["port"]
~~~

To configure a Rails application, you would change your `database.yml` to use
erb syntax to set the connection values using the credentials obtained from
`VCAP_SERVICES`.
If you are using the p-mysql service, your `database.yml` file might look like:

~~~
<%
  mydb = JSON.parse(ENV['VCAP_SERVICES'])["p-mysql-n/a"]
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

If you are instantiating your adapter client directly, rather than using the
active record pattern or another object-relation mapping (ORM) technique, your
code would like something like this:

~~~ruby

mysqldb = JSON.parse(ENV['VCAP_SERVICES'])["p-mysql-n/a"]
credentials = {
  :host => credentials["host"],
  :username => credentials["username"],
  :password => credentials["password"],
  :database => credentials["name"],
  :port => credentials["port"]
}

client = Mysql2::Client.new credentials

~~~

Your code may vary from the example above, depending on the hash key for the
service and the syntax for instantiating your database adapter client.

## <a id='migrate'></a>Seed or Migrate Database ##

Before you can use your database the first time, you must create and populate
or migrate it.
For more information, see [Migrate a Database on Cloud Foundry](./migrate-db.html).

## <a id='troubleshooting'></a>Troubleshooting ##

If you have trouble connecting to your service, run the `cf logs` command to view log messages for your application. The results of the `cf files my_app logs/env.log` command includes the value of the `VCAP_SERVICES` environment variable.

Example:

<pre class="terminal">
  $ cf files my_app logs/env.log
  Getting files for app my_app in or my_org / space my_space as a.user@example.com...
OK

TMPDIR=/home/vcap/tmp
VCAP_APP_PORT=64585
USER=vcap
VCAP_APPLICATION={"instance_id":"7dd14302a0804727a036b3b3f55300dc","instance_index":0,"host":"0.0.0.0","port":64585,"started_at":"2014-01-31 21:53:34 +0000","started_at_timestamp":1391205214,"start":"2014-01-31 21:53:34 +0000","state_timestamp":1391205214,"limits":{"mem":512,"disk":1024,"fds":16384},"application_version":"c1901bd3-ad2a-40f5-a8fd-204a901d038e","application_name":"my_app","application_uris":["my_app.example.com"],"version":"c1901bd3-ad2a-40f5-a8fd-204a901d038e","name":"my_app","uris":["my_app.example.com"],"users":null}
PATH=/bin:/usr/bin
PWD=/home/vcap
VCAP_SERVICES={"p-mysql-n/a":[{"name":"p-mysql","label":"p-mysql-n/a","tags":["postgres","postgresql","relational"],"plan":"small_plan","credentials":{"uri":"postgres://lrraxnih:eBawTKceuvKDGZycBvYUv5Bd6B-X1m4a9t@sample.p-mysqlprovider.com:5432/lraaxnih"}}]}
SHLVL=1
HOME=/home/vcap/app
PORT=64585
VCAP_APP_HOST=0.0.0.0
DATABASE_URL=postgres://lrraxnih:eBawTKceuvKDGZycBvYUv5Bd6B-X1m4a9t@sample.p-mysqlprovider.com:5432/lraaxnih
MEMORY_LIMIT=512m
_=/usr/bin/env
</pre>

If you encounter the error "A fatal error has occurred. Please see the Bundler
troubleshooting documentation," update your version of bundler and run `bundle
install` again.


<pre class="terminal">
  $ gem update bundler
  $ gem update --system
  $ bundle install
</pre>
