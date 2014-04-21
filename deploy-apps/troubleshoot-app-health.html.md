---
title: Troubleshoot Application Deployment and Health
---

_This page assumes that you are using cf v6._

The basic tools for troubleshooting are:

* `cf apps`, `cf events`, `cf logs --recent` and the other [troubleshooting commands](#cf-commands)
* The [heuristics](#scenarios) to apply in common failure scenarios
* The [Cloud Foundry Developers](https://groups.google.com/a/cloudfoundry.org/forum/#!forum/vcap-dev)
mailing list, where you can search on error messages

## <a id='scenarios'></a>Failure Scenarios and Troubleshooting Heuristics ##

This section explains basic troubleshooting for failure scenarios in each stage
of app deployment.

### <a id='upload'></a>App fails to upload ###

Verify that your app does not exceed the maximum size allowed by Cloud
Controller.

Verify that your network connection is not slow and causing the upload to
time out.
If you are seeing `500` errors, a slow network connection may be at fault.

If your app contains a large number of files and is failing to upload,
it sometimes helps to push the app repeatedly.
Each push uploads a few more files.
Eventually, all files have uploaded and the push succeeds.

### <a id='detect'></a>Cloud Foundry fails to detect a buildpack ###

Verify that your app is in a language or framework supported by one of
the three [system buildpacks](../../buildpacks/), or, that you are using the
`-b` option to give `cf push` the location of an appropriate buildpack.

### <a id='compile'></a>App fails to compile ###

Verify that the amount of memory your app is configured to use is within
the limit specified by the buildpack.

Verify that your app uses the `PORT` environment variable and does not specify
a port in any other way.

Verify that your app generally adheres to the principles of the
[Twelve-Factor App](http://12factor.net) and [Prepare to Deploy an Application]
(./prepare-to-deploy.html).
Your app might build in a way that works fine locally but fails in the cloud.
These texts explain the kinds of adjustments that solve this kind of problem.

Alternatively, sometimes a Cloud Controller problem causes a compile failure.

### <a id='start'></a>App fails to start or scale ###

Verify that you are pushing the app to a Cloud Foundry app space that has
sufficient memory available for all instances of your app.

Verify that components within Cloud Foundry can communicate with each other.
Look for log entries indicating problems such as _example here_.
Cloud networking issues can cause problems like this.

### <a id='trace'></a>Before you re-run a Command ###

If a command fails or produces unexpected results, re-run it with `CF_TRACE`
enabled to view requests and responses between `cf` and the Cloud Controller
REST API.

For example:

* Re-run `cf push` with `CF_TRACE` enabled:

  `cf push <app_name> CF_TRACE=true`

* Re-run `cf push` while appending API request diagnostics to a log file:

  `cf push <app_name> CF_TRACE=<path_to_trace.log>`

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

* `cf logs <app_name>`: Returns a real-time stream of the application STDOUT and
STDERR. Use **Ctrl-C** (^C) to exit the real-time stream.

* `cf events <app_name>`: Returns information about application crashes, including
error codes.
See
[https://github.com/cloudfoundry/errors](https://github.com/cloudfoundry/errors)
for a list of Cloud Foundry errors.
Shows that an app instance exited; for more detail, look in the application logs.

* `cf files <app_name>`: Lists the files in an application directory.
Given a path to a file, outputs the contents of that file. Given a path to a
subdirectory, lists the files within.

* `cf logs <app_name>`: Tails logs, or dumps recent ones with the `--recent` option.
See [Viewing Logs in the Command Line Interface](./streaming-logs.html#view).

**Note**: Your application should direct its logs to STDOUT and STDERR.
The `cf logs` command also returns messages from any [log4j](http://logging.apache.org/log4j/)
facility that you configure to send logs to STDOUT.

### <a id='health'></a>Check Health and Status ###

To check the health and status of your application, use `cf app <appname>`.

For example:

<pre class="terminal">
$ cf app my-app
Showing health and status for app my-app in org joeclouduser-org / space development as joeclouduser@<%=vars.app_domain%>...
OK

requested state: started
instances: 1/1
usage: 256M x 1 instances
urls: my-app999.<%=vars.app_domain%>

     state     since                    cpu    memory          disk
#0   running   2014-01-27 11:59:30 AM   0.0%   18.5M of 256M   52.5M of 1G
</pre>

### <a id='env'></a>Examine Environment Variables ###

`cf push` deploys the application to a container on the server.
The environment variables that reside in the container are the environment
variables of your application.

You can set environment variables in a manifest created before you deploy.
See [Deploying with Application Manifests](./manifest.html).

You can also set an environment variable with a `cf set-env` command followed
by a `cf push` command:

* Once you run `cf set-env`, you can see the variable by running `cf env`.
* However, you must run `cf push` again for the variable to take effect in the
container environment.

To see the environment variables that you have set using the `cf set-env` command:

  `cf env <appname>`
To see the variables in the container environment:

  `cf files <appname> logs/env.log`

### <a id='logs'></a>Logs ###

To see recent log entries:

  `cf logs <appname> --recent`
To see log entries in real time:

  `cf logs <appname>`
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