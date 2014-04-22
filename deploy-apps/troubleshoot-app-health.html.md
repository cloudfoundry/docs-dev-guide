---
title: Troubleshoot Application Deployment and Health
---

_This page assumes that you are using cf v6._

The basic tools for troubleshooting are:

* [Troubleshooting commands](#cf-commands) like `cf apps`, `cf events`, and `cf logs --recent`
* [Heuristics](#scenarios) to apply in common failure scenarios
* Diagnostic information, including [environment variables](#env), [logs](#logs), and [Cloud Controller REST API requests and responses](#trace)

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

## <a id='scenarios'></a>Failure Scenarios and Troubleshooting Heuristics ##

This section explains basic troubleshooting for failure scenarios in each stage
of app deployment.

### <a id='upload'></a>App fails to upload ###

* Verify that your app does not exceed the maximum size allowed by Cloud
Controller.

* Verify that your network connection is not slow and causing the upload to
time out.
If you are seeing `500` errors, a slow network connection may be at fault.

* If your app contains a large number of files and is failing to upload,
it sometimes helps to push the app repeatedly.
Each push uploads a few more files.
Eventually, all files have uploaded and the push succeeds.

### <a id='detect'></a>Cloud Foundry fails to detect a buildpack ###

* Verify that your app is in a language or framework supported by one of
the three [system buildpacks](../../buildpacks/), or, that you are using the
`-b` option to give `cf push` the location of an appropriate buildpack.

### <a id='compile'></a>App fails to compile ###

* Verify that the amount of memory your app is configured to use is within
the limit specified by the buildpack.

* Verify that your app uses the `PORT` environment variable and does not specify
a port in any other way.

* Verify that your app generally adheres to the principles of the
[Twelve-Factor App](http://12factor.net) and [Prepare to Deploy an Application]
(./prepare-to-deploy.html).
Your app might build in a way that works fine locally but fails in the cloud.
These texts explain the kinds of adjustments that solve this kind of problem.

* Alternatively, sometimes a Cloud Controller problem causes a compile failure.

### <a id='start'></a>App fails to start or scale ###

* Verify that you are pushing the app to a Cloud Foundry app space that has
sufficient memory available for all instances of your app.

* Verify that components within Cloud Foundry can communicate with each other.
Cloud networking issues can cause problems like this.

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

    `cf push <app_name> CF_TRACE=true`

* Re-run `cf push` while appending API request diagnostics to a log file:

    `cf push <app_name> CF_TRACE=<path_to_trace.log>`

**Note**: `CF_TRACE` is a **local** environment variable that modifies
the behavior of `cf` itself.
Do not confuse `CF_TRACE` with the [variables in the container environment]
(#env) where your apps run.











