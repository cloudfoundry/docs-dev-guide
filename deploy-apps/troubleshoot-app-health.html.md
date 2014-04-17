---
title: Troubleshoot Application Deployment and Health
---

_This page assumes that you are using cf v6._

## <a id='cf-commands'></a>cf Troubleshooting Commands ##

Cloud Foundry's cf command line interface provides several commands you can use
to investigate application deployment and health.

Some of these commands may return connection credentials.
Take care to remove credentials and other sensitive information from command
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

* `cf files <app_name>`: Lists the files in an application directory.
Given a path to a file, outputs the contents of that file. Given a path to a
subdirectory, lists the files within.

* `cf logs <app_name>`: Tails logs, or dumps recent ones with the `--recent` option.
See [Viewing Logs in the Command Line Interface](./streaming-logs.html#view).

**Note**: Your application should direct its logs to STDOUT and STDERR.
The `cf logs` command also returns messages from any [log4j](http://logging.apache.org/log4j/)
facility that you configure to send logs to STDOUT.

