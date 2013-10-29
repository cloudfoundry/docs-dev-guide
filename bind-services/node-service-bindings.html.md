---
title: Binding a service
---

**Note:** The auto-configuration functionality described on this page is not yet supported in Cloud Foundry v2.

## <a id='intro'></a>Introduction ##

This guide is for developers who wish to bind a data source to a Node.js application deployed and running on Cloud Foundry.

## <a id='prerequisites'></a>Prerequisites ##

* A Cloud Foundry account, you can sign up [here](https://my.cloudfoundry.com/signup)
* The [CF](../../managing-apps/index.html) command line tool
* [Node.js](http://www.nodejs.org) installed using the matching version of Node.js on your Cloud Foundry instance
* [NPM](http://npmjs.org/) - Node Package Manager, to manage dependencies on your application
* A sample application such as the one created in [this](./index.html) tutorial

### <a id='creating'></a> Creating a service ##

To create a service issue the following command with cf and answer the interactive prompts;

~~~bash
$ cf create-service
~~~

## <a id='autoconfig'></a>Auto Configuration ##

When any of the service types mentioned below are bound to a Node.js application, configuration for that data source will be configured automatically by Cloud Foundry.

* Rabbit MQ via the '[ampq](https://github.com/postwait/node-amqp)' module
* Mongo via the '[mongodb](http://mongodb.github.com/node-mongodb-native/)' and '[mongoose](http://mongoosejs.com/)' modules
* MySQL via the '[mysql](https://github.com/felixge/node-mysql)' module
* Postgres via the '[pg](https://github.com/brianc/node-postgres) module
* Redis via the '[redis](https://github.com/mranney/node_redis)' module

At the moment the application is set to listen to port 3000. To be able to deploy the application unmodified a dependency on the cf-autoconfig node module has to be added to the project. Make the following two modifications, add cf-autoconfig to package.json

~~~json

{
  "name": "hello-node",
  "version": "0.0.1",
  "dependencies": {
    "express": "*",
    "cf-autoconfig": "*"
  },
  "engines": {
    "node": "0.8.x"
  }
}
~~~

and then require the library at the start of the application;

~~~javascript
require("cf-autoconfig");
var express = require("express");
var app = express();

app.get('/', function(req, res) {
    res.send('Hello from Cloud Foundry');
});

app.listen(3000);
~~~

Deploy the application as normal and the port will automatically be assigned, along with any bound data connections. If you do not wish to use auto configuration then just change the app to look for the bound port using environment variables;

~~~javascript
var express = require("express");
var app = express();

app.get('/', function(req, res) {
    res.send('Hello from Cloud Foundry');
});

app.listen(process.env.VCAP_APP_PORT || 3000);
~~~

## <a id='Connecting'></a> Connecting to a Service ##

Let's add a function to the application called record_visit, this, for some examples, will record the visitors IP address and the date and for the others will simply demonstrate connectivity.

### <a id='module-support'></a> Adding support for the correct module ###

Edit package.json and add the intended module to dependencies section, normally only one would be necessary but for brevity's sake we will add all of them.

~~~json
{
  "name": "hello-node",
  "version": "0.0.1",
  "dependencies": {
    "express": "*",
    "cf-autoconfig": "*",
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

Next, edit app.js as appropriate for the intended module, passing in blank connection details where normally we would pass in details such as host address, port, user name and password.

### <a id='mongodb'></a> Mongodb ##

~~~javascript
require("cf-autoconfig");
var express = require("express");
var app = express();

var record_visit = function(req, res){
  require('mongodb').connect('', function(err, conn){
    conn.collection('ips', function(err, coll){
      object_to_insert = { 'ip': req.connection.remoteAddress, 'ts': new Date() };
      coll.insert( object_to_insert, {safe:true}, function(err){
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.write(JSON.stringify(object_to_insert));
        res.end('\n');
      });
    });
  });
}

app.get('/', function(req, res) {
  record_visit(req, res);
});

app.listen(3000);
~~~~

### <a id='redis'></a> Redis ##

~~~javascript
require("cf-autoconfig");
var express = require("express");
var app = express();

var record_visit = function(req, res){
  var redis = require("redis"),
  client = redis.createClient();

  client.on("error", function (err) {
    console.log("Error " + err);
  });

  client.set("last_ip", req.connection.remoteAddress, redis.print);
}

app.get('/', function(req, res) {
  record_visit(req, res);
  res.send('Hello from Cloud Foundry');
});

app.listen(3000);
~~~~


### <a id='mysql'></a> MySQL ##

~~~javascript
require("cf-autoconfig");
var express = require("express");
var app = express();

var record_visit = function(req, res){

  var mysql      = require('mysql');
  var connection = mysql.createConnection();

  connection.connect();

  connection.query('SELECT NOW() as time_now;', function(err, rows, fields) {
    if (err) throw err;

    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.write(rows[0].time_now);
    res.end('\n');

    console.log('The solution is: ', );
  });

  connection.end();
}

app.get('/', function(req, res) {
  record_visit(req, res);
});

app.listen(3000);
~~~~

### <a id='rabbitmq'></a> Rabbit MQ ##

~~~javascript
require("cf-autoconfig");
var express = require("express");
var app = express();

var record_visit = function(req, res){
  var amqp = require('amqp');

  var connection = amqp.createConnection();

  // Wait for connection to become established.
  connection.on('ready', function () {
    // Use the default 'amq.topic' exchange
    connection.queue('my-queue', function(q){
        // Catch all messages
        q.bind('#');

        // Receive messages
        q.subscribe(function (message) {
          // Print messages to stdout
          console.log(message);
        });
    });
  });
}

app.get('/', function(req, res) {
  record_visit(req, res);
});

app.listen(3000);
~~~~

### <a id='binding'></a> Binding a service ##

To bind the service to the application, use the following cf command;

~~~bash
$ cf bind-service --app [application name] --service [service name]
~~~

