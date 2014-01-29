---
title: Configure Service Connections for Node.js
---
_This page assumes that you are using cf v5._

## <a id='intro'></a>Introduction ##

This guide is for developers who wish to bind a data source t0o a Node.js
application deployed and running on Cloud Foundry.

### <a id='creating'></a> Creating a Service ##

To create a service issue the following command with cf and answer the
interactive prompts:

~~~bash
$ cf create-service
~~~

### <a id='binding'></a> Binding a Service ##

To bind the service to the application, use the following cf command:

~~~bash
$ cf bind-service --app [application name] --service [service name]
~~~

## <a id='Connecting'></a> Connecting to a Service ##

You will need to include the appropriate package for the type of services your
application uses. For example:

* Rabbit MQ via the [ampq](https://github.com/postwait/node-amqp) module
* Mongo via the [mongodb](http://mongodb.github.com/node-mongodb-native/) and
[mongoose](http://mongoosejs.com/) modules
* MySQL via the [mysql](https://github.com/felixge/node-mysql) module
* Postgres via the [pg](https://github.com/brianc/node-postgres) module
* Redis via the [redis](https://github.com/mranney/node_redis) module

## <a id='Connecting'></a> Add the Dependency to package.json ##

Edit `package.json` and add the intended module to dependencies section.
Normally, only one would be necessary, but for the sake of the example we will
add all of them:

~~~json
{
  "name": "hello-node",
  "version": "0.0.1",
  "dependencies": {
    "express": "*",
    "mongodb": "*",
    "mongoose": "*",
    "mysql": "*",
    "pg": "*",
    "redis": "*",
    "ampq": "*"
  },
  "engines": {
    "node": "0.8.x"
  }
}
~~~

You will also need to run `npm shrinkwrap` to regenerate your
`npm-shrinkwrap.json` file after you edit `package.json`.

## <a id='creds'></a>Parse VCAP\_SERVICES for Credentials  ##

You will need to parse the VCAP\_SERVICES environment variable in your code to
get the required connection details such as host address, port, user name, and
password.

For example, if you are using PostgreSQL, your VCAP\_SERVICES environment
variable might look something like this:

~~~json
{
	"mypostgres": [{
		"name": "myinstance",
		"credentials": {
			"uri": "postgres://myusername:mypassword@host.example.com:5432/serviceinstance"
		}
	}]
}
~~~

This example JSON is simplified; yours may contain additional properties.

First, parse the VCAP_SERVICES environment variable. For example:

~~~
var vcap_services = JSON.parse(process.env.VCAP_SERVICES)
~~~

Then you will need to pull out the credential information required to connect
to your service.
Each of the service packages require slightly different information.
If you are working with Postgres, for example, you will need a uri to connect.
You can assign the value of the uri to a variable as follows:

~~~
var uri = vcap_services.mypostgres[0].credentials.uri
~~~

Now you can use your credentials as you normally would in your program to
connect to your database.