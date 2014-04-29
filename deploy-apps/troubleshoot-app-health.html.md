---
title: Troubleshoot Application Deployment and Health
---

_This page assumes that you are using cf v6._

## <a id='scenarios'></a>Failure Scenarios ##

This section explains how to troubleshoot common `cf push` failure scenarios.

### <a id='upload'></a>App fails to upload ###

**Make sure your org has enough memory for all instances of your app.**
Use `cf orgs` to see the names of your orgs and `cf org <org_name>` to see
the memory alloted to the org where you are deploying.

**Make sure your app is not too large.**

* The app bits to push cannot exceed 1GB.

* The droplet that results from compiling those bits cannot exceed 1.5GB;
droplets are typically 1/3 larger than the pushed bits.

* The app bits, compiled droplet, and buildpack cache together cannot use
more than 4GB of space during staging.

**If your app contains a large number of files, try pushing the app repeatedly.**
Each push uploads a few more files.
Eventually, all files have uploaded and the push succeeds.
This is less likely to work if your app has many _small_ files.

### <a id='detect'></a>Cloud Foundry fails to detect a buildpack ###

**Make sure your app is in a language or framework supported by one of the three
[system buildpacks](../../buildpacks/).**
If that is not the case, use `cf push` with the `-b` option to deploy with an
appropriate custom buildpack.

### <a id='compile'></a>App fails to compile ###

**Make sure your application code uses the `VCAP_APP_PORT` environment variable.**
When it needs the value of the port where the app listens, your application
code must alway obtain the `VCAP_APP_PORT` environment variable.

    For example, this Ruby snippet assigns the port value to the `listen_here`
    variable:

    `listen_here = ENV['VCAP_APP_PORT']`

**Make sure your app generally adheres to the principles of the
[Twelve-Factor App](http://12factor.net) and [Prepare to Deploy an Application]
(./prepare-to-deploy.html).**
These texts explain how to prevent situations where your app builds locally but
fails to build in the cloud.

### <a id='time'></a>Deployment times out ###

A cf push can timeout during an upload or a staging.
Symptoms can include a 504 Gateway Timeout error or a message stating "Error uploading application."
If this happens, try these techniques.

**Check your network speed.**
Depending on the size of your application, your cf push could be timing out because the upload is taking too long.
Recommended internet connection speed is at least 768 KB/s (6 Mb/s) for uploads.

**Make sure you are only pushing needed files.**
By default cf will push all the contents of the current working directory.
Make sure you are pushing just your application's directory.
If your application is too large, or if it has many small files, Cloud Foundry may time out during the upload.
You can also reduce the size of the upload by removing unneeded files or [specifying files to be ignored](prepare-to-deploy.html#exclude) in the `.cfignore` file.

**Set the CF\_STAGING\_TIMEOUT and CF\_STARTUP\_TIMEOUT environment variables.**
By default your app has 15 minutes to stage and 5 minutes to start.
You can increase these times by setting `CF_STAGING_TIMEOUT` and `CF_STARTUP_TIMEOUT`.
Type `cf help` at the command line for more information.


### <a id='out-of-memory'></a>App crashes with 'out of memory' errors ###

**Make sure your app is not consuming more memory than it should.**
When you ran `cf push` and `cf scale`, that configured a limit on the amount
of memory your app should use.
Check your app's actual memory usage.
If it exceeds the limit, modify the app to use less memory.

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











