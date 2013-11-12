---
title: About Starting Applications 
---

##<a id='start-command'></a>The Application Start Command ##

There are three ways that Cloud Foundry can obtain the command to use to start an application; they are listed below in order of precedence.

1. The value supplied with the `--command` qualifier (or in the application’s `manifest.yml` file). For example, `cf push --command '.java/bin/java myapp'`.
1. The value of the `web` key in the procfile, for the application, if it exists. A procfile is a text file named `Procfile`, in the root directory of your application, that lists the process types in an application, and associated start commands. For example, `web: YourStartCommand`
1. The start command (if specified) for the “web” process type, in `default_process_types` section of the output from the buildpack's `bin/release` script.

##<a id='run-utility'></a>Run a Standalone Utility at Deployment ##
You can run an application-related utility by invoking it at the time you push the application.
One use case for this capability is database creation and migration.If you are going to run a database application to Cloud Foundry, you need to create and populate the database. Similarly, when the database schema changes you will need to update or migrate the database accordingly.

###<a id='custom-start'></a>Specify a Custom Start Command ###


The mechanism for invoking a script or utility on Cloud Foundry is to customize the command that Cloud Foundry issues to start the application. There are two ways to use a custom start command:

* Specify the command at the command line using the `--command` qualifier when running `cf push`.

* Specify the command in the application’s deployment manifest, `manifest.yml`.

###<a id='revert-start'></a>Revert to Standard Start Command ###

Unless you want to run the custom start command every time you push the application, you must revert to the default or previously defined start command. To do so, after the utility has run and the application is started:

* If you ran the custom command at the command line, re-push the application using the `--reset` qualifier, which tells Cloud Foundry to use the deployment attributes in `manifest.yml`. (Otherwise, the next time you push the application, Cloud Foundry will use the same qualifiers you supplied during the prior push.)

* If you specified the command in the manifest, remove the custom command from the manifest and re-push the application.

###<a id='single-app'></a>Run a Start Command on One Instance ###

There is another factor to consider when using a custom start command:  if you start more than a single instance of the application when you push it, the custom command will be used to start each of the instances ---inappropriate in the case of database creation or migration. For examples of using a custom start command to migrate a database, for a single application instance only, see [Migrate a Database on Cloud Foundry](../services/migrate-db.html).






