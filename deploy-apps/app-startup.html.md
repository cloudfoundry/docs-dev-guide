---
title: About Starting Applications
---

_This page assumes that you are using cf v6_.

`cf push` starts your application with a command from one of three sources:

1. The `-c` command-line option, for example:

 ``$ cf push my-app -c "node my-app.js"``
1. The `command` attribute in the application manifest, for example:

 `command: node my-app.js`

1. The buildpack, which provides a start command appropriate for a particular type of application.

The source `cf` uses depends on factors explained below.

##<a id='first-time'></a>How cf push Determines its Default Start Command ##

The first time you deploy an application, `cf push` uses the buildpack start command by default.
After that, `cf push` defaults to whatever start command was used for the previous push.

To override these defaults, provide the `-c` option, or the command attribute in the manifest.
When you provide start commands _both_ at the command line and in the manifest, `cf push` ignores the command in the manifest.

##<a id='revert'></a>Forcing cf push to use the Buildpack Start Command ##

To force `cf` to use the buildpack start command, specify a start command of `null`.

You can specify a null start command in one of two ways.

1. Using the `-c` command-line option:

 ``$ cf push my-app -c "null"``
1. Using the `command` attribute in the application manifest:

 `command: null`

This can be helpful after you have deployed while providing a start command at the command line or the manifest.
At this point, a command that you provided, rather than the buildpack start command, has become the default start command.
In this situation, if you decide to deploy using the buildpack start command, the `null` command makes that easy.

##<a id='databases'></a>Start commands for Deploying while Migrating a Database ##

Start commands are used in special ways when you migrate a database as part of an application deployment. See [Migrating a Database on Cloud Foundry](../services/migrate-db.html).