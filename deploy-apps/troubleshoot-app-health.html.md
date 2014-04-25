---
title: Troubleshoot Application Deployment and Health
---

_This page assumes that you are using cf v6._

## <a id='scenarios'></a>Failure Scenarios ##

This section explains how to troubleshoot common `cf push` failure scenarios.

### <a id='upload'></a>App fails to upload ###

Verify that:

*  You are pushing the app to an org that has enough memory for all instances
of your app.

    Use `cf orgs` to see the names of your orgs and `cf org <org_name>` to see
the memory alloted to the org where you are deploying.

* Your app is not too large.

    * The app bits to push cannot exceed 1GB.

    * The droplet that results from compiling those bits cannot exceed 1.5GB;
droplets are typically 1/3 larger than the pushed bits.

    * The app bits, compiled droplet, and buildpack cache together cannot use
more than 4GB of space during staging.

If your app contains a large number of files and is failing to upload,
it sometimes helps to push the app repeatedly.
Each push uploads a few more files.
Eventually, all files have uploaded and the push succeeds.
This is less likely to work if your app has many _small_ files.

### <a id='detect'></a>Cloud Foundry fails to detect a buildpack ###

Verify that one of the following is true:

* Your app is in a language or framework supported by one of the three
[system buildpacks](../../buildpacks/).

* You are using `cf push` with the `-b` option to deploy with an appropriate
custom or admin buildpack.

### <a id='compile'></a>App fails to compile ###

Verify that:

* When it needs the value of the port where the app listens, your application
code always obtains the `VCAP_APP_PORT` environment variable.

    For example, this Ruby snippet assigns the port value to the `listen_here`
    variable:

    `listen_here = ENV['VCAP_APP_PORT']`

* Your app generally adheres to the principles of the
[Twelve-Factor App](http://12factor.net) and [Prepare to Deploy an Application]
(./prepare-to-deploy.html).
These texts explain how to prevent situations where your app builds locally but
cannot build in the cloud.

### <a id='time'></a>Deployment times out ###

* A slow network connection can cause uploads to time out, including with `500` errors.

	Resource-matching and uploading 1 Gig of data must take less than 30 minutes.
	Recommended internet connection speed is at least 768 KB/s (6 Mb/s) for uploads.

	You can estimate the maximum workable application size for slower connections
	as follows:

	 _upload speed in Megabits/Second_ times _1800 seconds_ equals _application size in Megabits_

	(You can then divide the result by 8 to obtain the application size in Megabytes.)

    For example:

    _2 Mbps_ times _1800_ equals _3600 Megabits_ divided by _8_ equals a _450 Megabyte estimated maximum app size_


*  Resource matching can exceed the request timeout, causing the deployment to fail with `504` errors.

    This problem is sometimes caused by an app containing too many small files.

* Contact Support if you think any of the following apply:

    * Deployment fails with "Error uploading application," possibly because the app bits upload packaging job exceeds five minutes.

    * Upload fails because uploading app bits takes longer than 20 minutes.

    * Deployment fails because staging (after the bits are uploaded and packaged) exceeds the default timeout of 15 minutes.


### <a id='out-of-memory'></a>App crashes with 'out of memory' errors ###

* Verify that your app is not consuming more memory than you have configured
as its limit using `cf push` and `cf scale`.

## <a id='info'></a>Gathering Diagnostic Information ##

Gather the diagnostic information that shows the symptoms of the problem you
are troubleshooting, and also "baseline" information for context.

### <a id='env'></a>Examining Environment Variables ###

`cf push` deploys your application to a container on the server.
The environment variables in the container govern your application.

You can set environment variables in a manifest created before you deploy.
See [Deploying with Application Manifests](./manifest.html).

You can also set an environment variable with a `cf set-env` command followed
by a `cf push` command.
You must run `cf push` for the variable to take effect in the container
environment.

* View the environment variables that you have set using the `cf set-env` command:

    `cf env <appname>`

* View the variables in the container environment:

    `cf files <appname> logs/env.log`

### <a id='logs'></a>Exploring logs ###

To explore all logs available in the container, first view the log filenames, then view the log that interests you:

<pre class="terminal">
$ cf files my-app logs/
	Getting files for app my-app in org joeclouduser-org / space development as joeclouduser@<%=vars.app_domain%>...
	OK

	env.log                                   932B
	staging_task.log                          844B
	stderr.log                                182B
	stdout.log                                  0B

$ cf files my-app logs/stderr.log
	Getting files for app my-app in org joeclouduser-org / space development as joeclouduser@<%=vars.app_domain%>...
	OK

	[2014-01-27 20:21:58] INFO  WEBrick 1.3.1
	[2014-01-27 20:21:58] INFO  ruby 1.9.3 (2013-11-22) [x86_64-linux]
	[2014-01-27 20:21:58] INFO  WEBrick::HTTPServer#start: pid=31 port=64391
</pre>

### <a id='trace'></a>Tracing Cloud Controller REST API Calls ###

If a command fails or produces unexpected results, you can re-run it with
`CF_TRACE` enabled to view requests and responses between `cf` and the
Cloud Controller REST API.

For example:

* Re-run `cf push` with `CF_TRACE` enabled:

    `CF_TRACE=true cf push <app_name>`

* Re-run `cf push` while appending API request diagnostics to a log file:

    `CF_TRACE=<path_to_trace.log> cf push <app_name>`

These examples enable `CF_TRACE` for a single command only.
To enable it for an entire shell session, set the variable first:

  `export CF_TRACE=true`

  `export CF_TRACE=<path_to_trace.log>`

**Note**: `CF_TRACE` is a **local** environment variable that modifies
the behavior of `cf` itself.
Do not confuse `CF_TRACE` with the [variables in the container environment]
(#env) where your apps run.

## <a id='cf-commands'></a>cf Troubleshooting Commands ##

Cloud Foundry's cf command line interface provides commands for investigating
app deployment and health.

Some of these commands may return connection credentials.
Remove credentials and other sensitive information from command
output before you post the output a public forum.

* `cf apps`: Returns a list of the applications deployed to the current space
with deployment options, including the name, current state, number of instances,
memory and disk allocations, and URLs of each application.

* `cf app <app_name>`: Returns the health and status of each instance of a
specific application in the current space, including instance ID number, current
state, how long it has been running, and how much CPU, memory, and disk it is
using.

* `cf env <app_name>`: Returns environment variables set using `cf set-env`.

* `cf events <app_name>`: Returns information about application crashes, including
error codes.
See
[https://github.com/cloudfoundry/errors](https://github.com/cloudfoundry/errors)
for a list of Cloud Foundry errors.
Shows that an app instance exited; for more detail, look in the application logs.

* `cf logs <app_name> --recent`: Dumps recent logs.
See [Viewing Logs in the Command Line Interface](./streaming-logs.html#view).

* `cf logs <app_name>`: Returns a real-time stream of the application STDOUT and
STDERR. Use **Ctrl-C** (^C) to exit the real-time stream.

* `cf files <app_name>`: Lists the files in an application directory.
Given a path to a file, outputs the contents of that file. Given a path to a
subdirectory, lists the files within. Use this to [explore](#logs) individual
logs.

**Note**: Your application should direct its logs to STDOUT and STDERR.
The `cf logs` command also returns messages from any [log4j](http://logging.apache.org/log4j/)
facility that you configure to send logs to STDOUT.











