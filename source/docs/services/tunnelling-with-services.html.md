---
title: Tunneling to Services
---

**Tunneling to services is not yet supported in Cloud Foundry v2.**  

You can access a provisioned service using a native connector for the service. For example, you can connect to a mySQL database using a command like this:

`mysql -D [DATABASE_NAME]  -h [HOST_NAME] -P [PORT] -u [USER] -p`

You can determine the connection details for the services bound to an application from the `VCAP_SERVICES` environment variable in the application’s `env.log` file.

For information about `VCAP_SERVICES` and how to view an application’s `env.log` file, see [VCAP_SERVICES Environment Variable](../deploying-apps/environment-variable.html).

<!---
## <a id='what-is-tunnelling'></a>What Is Tunneling? ##

A provisioned service on Cloud Foundry is not directly accessible to the outside world by default. An application that is bound to the service has access, but only because it sits on the same network, behind the Cloud Foundry firewall.

To gain access to a service from outside the Cloud Foundry ecosystem, you use a technique called tunneling. You deploy a special application, called Caldecott, to a Cloud Foundry account. The application then binds and connects to the desired service and proxies a connection over HTTP to the service. Once deployed, Caldecott remains available for the creation of tunnels.

Once established, the tunnel can be used by a client, most likely cf. The client makes a port on the loopback adapter (127.0.0.1) available to use with a native client of the bound service.

## <a id='creating-a-tunnel'></a>Create a tunnel ##

The following example illustrates how to create a tunnel to a MySQL database and then use mysqldump to create a backup of the database (even though it will be empty).

Create a service instance with cf;

<pre class="terminal">
$ cf create-service
1: blob 0.51
2: mongodb 2.0
3: mysql 5.1
4: postgresql 9.0
5: rabbitmq 2.4
6: redis 2.2
7: redis 2.4
8: redis 2.6
What kind?> 3

Name?> mysql-a7cc7

Creating service mysql-a7cc7... OK
</pre>

Tunnel to the service with cf, select mysqldump for the client and give a file path (mydb.sql) to dump to;

<pre class="terminal">
$ cf tunnel mysql-a7cc7
1: none
2: mysql
3: mysqldump
Which client would you like to start?> 3

Opening tunnel on port 10000... OK
Waiting for local tunnel to become available... OK
Output file> mydb.sql
</pre>

The dump is successfully writen to mydb.sql. At this point the tunnel has closed. However, if option 1 - none is selected, the tunnel is held open indefinitely supplying the connection details:

<pre class="terminal">
$ cf tunnel mysql-a7cc7
1: none
2: mysql
3: mysqldump
Which client would you like to start?> 1

Opening tunnel on port 10000... OK

Service connection info:
  username : uFlLtV9lfB1xV
  password : pqS7RpFXG9Jhu
  name     : db1626ceeb99d42739244cb5c635519e6


Open another shell to run command-line clients or
use a UI tool to connect using the displayed information.
Press Ctrl-C to exit...
</pre>

This allows a native client to connect to the service. Note that in this instance, for MySQL, the connection is available on port 10000, not 3306.

-->
