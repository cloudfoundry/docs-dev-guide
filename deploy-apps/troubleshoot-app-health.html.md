---
title: Troubleshoot Application Deployment and Health
---

_This page assumes that you are using cf v5._

## <a id='cf-commands'></a>cf Troubleshooting Commands ##

Cloud Foundry's cf command line interface provides several commands you can use to investigate application deployment and health.


* `cf apps` --- Lists applications that are deployed to the current space, deployment options, including the number of instances, memory and disk allocations, and the current state of each application. For command usage, see the [apps](../installcf/cf.html#apps) section on the [cf Command Line Interface](../installcf/cf.html) page.

* `cf app` --- Returns the health and status of each instance of an application, including current status, how long it has been running, and how much CPU, memory, and disk it consumes. For command usage, see [app](../installcf/cf.html#app).

* `cf logs` --- You can use this command to view environment variables, the staging log, and recent output to STDOUT and STDERR for an application. The `VCAP_SERVICES` variable lists services have been bound to the application and the credentials for connecting to each service.

  You may need to configure your application to issue messages to STDOUT and STDERR. If your application uses a log4j facility that is configured to send log messages to STDOUT, such messages will also be returned by the `logs` command. (If your application environment logs errors of interest to a file, rather than STDOUT or STDERR, use the `cf file` command to view the messages.)

  **Note:**  Because `cf logs` returns connection credentials, be sure not to post command output to a public forum without removing this sensitive information first.

  For command usage, see [logs](../installcf/cf.html#logs).

* `cf events` --- This command returns information about application crashes, including error codes. See [https://github.com/cloudfoundry/errors](https://github.com/cloudfoundry/errors) for a list of Cloud Foundry errors. For command usage, see [events](../installcf/cf.html#events).

* `cf files` and `cf file`--- You can use these command to view a list of files in an application directory, or the contents of a particular file, respectively. For command usage, see [files](../installcf/cf.html#files) and [file](../installcf/cf.html#file).

* `cf guid` --- You can use this command to return the guid of an application. For usage information, see [guid](../installcf/cf.html#guid).

* `cf stats` --- Lists resource statistics for each instance of an application, including CPU, memory, and disk usage. For usage information, see [stats](../installcf/cf.html#stats).

## <a id='java-apps'></a>Java and Grails Best Practices ##

### <a id='jdbc'></a>Provide JDBC driver ###

The Java buildpack does not bundle a JDBC driver with your application. If your application will access a SQL RDBMS, include the appropriate driver in your application.

### <a id='memory'></a>Allocate Sufficient Memory ###

If you do not allocate sufficient memory to a Java application when you deploy it, it may fail to start, or be killed by Cloud Foundry. Allocate enough memory to allow for Java heap, PermGen, thread stacks, and JVM overhead. The Java buildpack allocates 10% of the memory limit to PermGen. Memory-related JVM options are configured in `config/openjdk.yml` (https://github.com/cloudfoundry/java-buildpack/blob/master/config/openjdk.yml). When your application is running, you can use the `cf stats` command to see memory utilization.

### <a id='upload'></a>Troubleshoot Failed Upload ###

If your application fails to upload when you push it to Cloud Foundry, it may be for one of the following reasons:

* WAR is too large --- Upload may fail due to the size of the WAR file. Cloud Foundry testing indicates WAR files as large as 250 MB upload successfully. If a WAR file larger than that fails to upload, it may be a result of the file size.

* Connection issues --- Application upload can fail if you have a slow internet connection, or if you upload from a location that is very remote from the target Cloud Foundry instance. If application upload takes a long time, your authorization token can expire before the upload completes. A workaruond is to copy the WAR to a server that is closer to the Cloud Foundry instance, and push it from there.

* Out-of-date cf client --- Upload of a large WAR large is faster and hence less likely to fail if you are using a recent version of cf. If you are using an older version of the cf client to upload a large, and having problems, try updating to the latest version of cf:

  <pre class="terminal">
  $ gem update cf
  </pre>

* Incorrect WAR targeting --- By default, `cf push` uploads everything in the current directory. For a Java application, a plain `cf push` push will upload source code and other unnecessary files, in addition to the WAR. When you push a Java application, specify the path to the WAR:

  <pre class="terminal">
  cf push --path PathToWAR
  </pre>

 You can determine whether or not the path was specified for a previously pushed application by looking at the application deployment manifest, `manifest.yml`. If the `path` attribute specifies the current directory, the manifest will include a line like this:

 `path: .`

 To re-push just the WAR, either:

 * Delete `manifest.yml` and push again, specifying the location of the WAR using the `--path` argument, or

 * Edit the `--path` argument in `manifest.yml` to point to the WAR, and re-push the application.

### <a id='slow-start'></a>Slow Starting Java or Grails Apps ###

 It is not uncommon for a Java or Grails application to take a while to start.  This, in conjunction with the current Java buildpack implementation, can pose a problem. The Java buildpack sets the Tomcat `bindOnInit` property to "false", which causes Tomcat to not listen for HTTP requests until the application is deployed.  If your application takes a long to time to start, the DEA's health check may fail by checking application health before it will accept requests. A workaround is to fork the Java buildpack and change `bindOnInit` to "false" in `resources/tomcat/conf/server.xml`, although this has the downside that the application may appear to be running (as far as Cloud Foundry is concerned) before it is ready to serve requests.

## <a id='node-apps'></a>Node Best Practices ##

* Specify a Node.js applications's web start command in a Procfile or the application deployment manifest.

## <a id='ruby-apps'></a>Ruby Best Practices ##

* Precompile assets --- Recommended to reduce staging time.

* Use `rails_serv_static_assets` on Rails 4 --- By default Rails 4 will return a 404 if an asset is not handled via an external proxy such as Nginx. The `rails_serve_static_assets` gem enables your Rails server to deliver static assets directly, instead of returning a 404. You can use this capability to populate an edge cache CDN or serve files directly from your web application.  The `rails_serv_static_assets` gem enables this behavior by setting the `config.serve_static_assets` option to "true", so you do not need to configure it manually.
