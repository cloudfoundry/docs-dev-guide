---
title: Troubleshoot Application Deployment and Health
---

_This page assumes that you are using cf v6._

## <a id='cf-commands'></a>cf Troubleshooting Commands ##

Cloud Foundry's cf command line interface provides several commands you can use
to investigate application deployment and health.

* `cf apps`: Returns a list of the applications deployed to the current space
with deployment options, including the name, current state, number of instances,
memory and disk allocations, and URLs of each application.

* `cf app APP_NAME`: Returns the health and status of each instance of a
specific application in the current space, including instance ID number, current
state, how long it has been running, and how much CPU, memory, and disk it is
using.

* `cf env APP_NAME`: Returns environment variables set using `cf set-env`.

* `cf logs APP_NAME`: Returns a real-time stream of the application STDOUT and
STDERR. Use **Ctrl-C** (^C) to exit the real-time stream.

* `cf events APP_NAME`: Returns information about application crashes, including
error codes.
See
[https://github.com/cloudfoundry/errors](https://github.com/cloudfoundry/errors)
for a list of Cloud Foundry errors.

* `cf files APP_NAME`: Returns a list of files in an application directory.

Your application should direct its logs to STDOUT and STDERR.
The `logs` command also returns messages from any [log4j](http://logging.apache.org/log4j/)
facility that you configure to send logs to STDOUT.

**Note:** Some of these commands may return connection credentials.
Take care to remove credentials and other sensitive information from command
output before you post the output a public forum.

For more about `cf logs`, see [Viewing Logs in the Command Line Interface](./deploy-apps/streaming-logs.html#view).

## <a id='java-apps'></a>Java and Grails Best Practices ##

### <a id='jdbc'></a>Provide JDBC driver ###

The Java buildpack does not bundle a JDBC driver with your application.
If your application will access a SQL RDBMS, include the appropriate driver in
your application.

### <a id='memory'></a>Allocate Sufficient Memory ###

If you do not allocate sufficient memory to a Java application when you deploy
it, it may fail to start, or be killed by Cloud Foundry.
Allocate enough memory to allow for Java heap, PermGen, thread stacks, and JVM
overhead.
The Java buildpack allocates 10% of the memory limit to PermGen.
Memory-related JVM options are configured in `config/openjdk.yml`
(https://github.com/cloudfoundry/java-buildpack/blob/master/config/openjdk.yml).
When your application is running, you can use the `cf app APP_NAME` command to
see memory utilization.

### <a id='upload'></a>Troubleshoot Failed Upload ###

If your application fails to upload when you push it to Cloud Foundry, it may be
for one of the following reasons:

* WAR is too large: An upload may fail due to the size of the WAR file.
Cloud Foundry testing indicates WAR files as large as 250 MB upload
successfully.
If a WAR file larger than that fails to upload, it may be a result of the file
size.

* Connection issues: Application uploads can fail if you have a slow Internet
connection, or if you upload from a location that is very remote from the target
Cloud Foundry instance.
If an application upload takes a long time, your authorization token can expire
before the upload completes.
A workaround is to copy the WAR to a server that is closer to the Cloud Foundry
instance, and push it from there.

* Out-of-date cf client: Upload of a large WAR large is faster and hence less
likely to fail if you are using a recent version of cf.
If you are using an older version of the cf client to upload a large, and having
problems, try updating to the latest version of cf.

* Incorrect WAR targeting: By default, `cf push` uploads everything in the
current directory.
For a Java application, a plain `cf push` push will upload source code and other
unnecessary files, in addition to the WAR.
When you push a Java application, specify the path to the WAR:

  <pre class="terminal">
  cf push APP_NAME -p PathToWAR
  </pre>

 You can determine whether or not the path was specified for a previously pushed
application by looking at the application deployment manifest, `manifest.yml`.
If the `path` attribute specifies the current directory, the manifest will
include a line like this:

  ```
    path: .
  ```
 To re-push just the WAR, either:

 * Delete `manifest.yml` and push again, specifying the location of the WAR
using the `-p` flag, or

 * Edit the `path` argument in `manifest.yml` to point to the WAR, and re-push
the application.

### <a id='slow-start'></a>Slow Starting Java or Grails Apps ###

It is not uncommon for a Java or Grails application to take a while to start.
This, in conjunction with the current Java buildpack implementation, can pose a
problem.
The Java buildpack sets the Tomcat `bindOnInit` property to "false", which
causes Tomcat to not listen for HTTP requests until the application is deployed.
If your application takes a long to time to start, the DEA's health check may
fail by checking application health before the application can accept requests.
A workaround is to fork the Java buildpack and change `bindOnInit` to "false" in
`resources/tomcat/conf/server.xml`, although this has the downside that the
application may appear to be running (as far as Cloud Foundry is concerned)
before it is ready to serve requests.

## <a id='node-apps'></a>Node Best Practices ##

* Specify a Node.js applications's web start command in a Procfile or the
application deployment manifest.

## <a id='ruby-apps'></a>Ruby Best Practices ##

* Precompile assets: Recommended to reduce staging time.

* Use `rails_serv_static_assets` on Rails 4: By default Rails 4 will return a
404 if an asset is not handled via an external proxy such as Nginx.
The `rails_serve_static_assets` gem enables your Rails server to deliver static
assets directly, instead of returning a 404.
You can use this capability to populate an edge cache CDN or serve files
directly from your web application.
The `rails_serv_static_assets` gem enables this behavior by setting the
`config.serve_static_assets` option to "true", so you do not need to configure
it manually.