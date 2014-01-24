---
title: Getting Started with Application Deployment
---
_This page assumes that you are using cf v6_

## <a id='intro'></a>Overview of Deployment Process ##

You deploy an application to Cloud Foundry by running a `push` command from a
Cloud Foundry command line interface (CLI). Refer to the [Install cf v6](../installcf/install-go-cli.html) topic for more information.
Between the time you run `push` and the time that the application is available,
Cloud Foundry:

* Uploads and stores application files
* Examines and stores application metadata
* Creates a "droplet" (the Cloud Foundry unit of execution) for the application
* Selects an appropriate droplet execution agent (DEA) to run the droplet
* Starts the application

An application that uses services, such as a database, messaging, or email
server, is not fully functional until you *provision* the service and, if
required, *bind* the service to the application.
You can provision and bind services when you push your application for the first
time.

## <a id='prepare'></a>Step 1: Prepare to Deploy ##

Before you deploy your application to Cloud Foundry, make sure that:

* Your application is *cloud-ready*.
There are several Cloud Foundry behaviors related to file storage, HTTP
sessions, and port usage that might require modifications to your application.

* All required application resources are uploaded. Extraneous files and
artifacts are excluded.
For example, you might need to include a database driver. In that case, particularly for a
large application, you should explicitly exclude extraneous files that
exist within your application directory structure.

* Your Cloud Foundry instance supports the type of application you are going to
deploy, or you have the URL of an externally available buildpack that can stage
the application.

For help preparing to
deploy your application, see:

* [Prepare to Deploy](prepare-to-deploy.html)
* [Tips for Ruby Developers](ruby-tips.html)
* [Tips for Node.js Developers](node-tips.html)
* [Tips for Java Developers](java-tips.html)

## <a id='logon-target'></a>Step 2: Know Your Credentials and Target ##

Before you can push your application to Cloud Foundry you need to know:

* The URL to target for your Cloud Foundry instance.
Typically this is a URL that begins with "api."
Consult your cloud operator if you are unsure of your target URL.
* Your username and password for your Cloud Foundry instance.
* The organization and space where you want to deploy your application.
A Cloud Foundry workspace is organized into organizations, and within them,
spaces.
As a Cloud Foundry user, you have access to one or more organizations and
spaces.

## <a id='domain'></a>Step 3: (Optional) Configure Domains ##

When you deploy an application, you can specify the route (or URL) that Cloud
Foundry uses to direct requests to an application.
A route is made up of a subdomain and a domain that you can specify when you
push an application.
You can use the default domain defined for your Cloud Foundry instance, or
specify a different registered domain that has been mapped to the Cloud Foundry
organization space to which you are deploying the applications.

For more information, see [About Domains, Subdomains and Routes](./domains-routes.html)

## <a id='options'></a>Step 4: Determine Deployment Options ##

Before you deploy, you need to decide on the following:

* **Name**: You can use any series of alpha-numeric characters, without spaces,
as the name of your application.
* **Instances**: Generally speaking, the more instances you run, the less downtime
your application is likely to have.
If your application is still in development, running a single instance makes it
easier to troubleshoot.
For any production application, you should run a minimum of two instances.
* **Memory Limit**: The maximum amount of memory that each instance of your
application is allowed to consume.
If an instance exceeds this limit, the instance is restarted.
If the instance has to be restarted too often, it is terminated.
To prevent this we recommend being generous with your memory limit.
* **Start Command**: This is the command that Cloud Foundry uses to start
each instance of your application.
This start command varies by application framework.
* **URL and Domain**: `cf` prompts you for both a URL and a domain.
The URL is the subdomain for your application. It is hosted at the
primary domain you choose.
The combination of the URL and domain must be globally unique.
* **Services**: `cf` asks whether you want to create and bind one or more
services (such as MySQL) to your application.
You can respond "yes" to create and bind services during the push process, or,
if you prefer, create and bind services after deployment.

### <a id='defining-options'></a>Defining Deployment Options ###

You can define deployment options on the command line or in a
manifest file.
The first time you run `cf push` for an application, unless you provide
deployment options on the command line, cf looks for `manifest.yml` in the
current working directory.

When you redeploy an application, cf does _not_ refer to `manifest.yml` for
deployment settings.
Instead, cf deploys the application with the currently active deployment
settings.
For more information, see [Application Manifests](./manifest.html).

When you deploy an application while it is running, `cf` stops all instances of
that application and then deploys.
Users who try to run the application get a "404 not found" message while cf push
is running.
Stopping all instances is necessary to prevent two versions of your code running
at the same time.
A worst-case example would be deploying an update that involved a database
schema migration, because instances running the old code would not work and
users could lose data.

`cf` uploads all application files except version control files with file
extensions `.svn`, `.git`, and `.darcs`.
To exclude other files from upload, specify them in a `.cfignore` file in the
directory where you run the push command.
This technique is similar to using a `.gitignore` file.
For more information, see [Prepare to Deploy an Application](./prepare-to-deploy.html#exclude).

For more information about the manifest file, see the [Deploying with Application Manifests](./manifest.html).

## <a id='push'></a>Step 5: Push the Application ##

The following is an example transcript from deploying a Ruby on Rails
application.
Note that in this example, we already provisioned an ElephantSQL instance and
named it "elephantpg":

<pre class="terminal">
  $ cf push
  Name> whiteboard

  Instances> 1

  1: 64M
  2: 128M
  3: 256M
  4: 512M
  5: 1G
  6: 2G
  Memory Limit> 256M

  Creating whiteboard... OK

  1: whiteboard
  2: none
  Subdomain> whiteboard

  1: example.com
  2: none
  Domain> example.com

  Creating route whiteboard.example.com... OK
  Binding whiteboard.example.com to whiteboard... OK

  Create services for application?> n

  Bind other services to application?> y

  1: elephantpg
  Which service?> 1

  Binding elephantpg to whiteboard... OK
  Save configuration?> n

  Uploading whiteboard... OK
  Starting whiteboard... OK
  -----> Downloaded app package (224K)
  Installing ruby.
  -----> Using Ruby version: ruby-1.9.2
  -----> Installing dependencies using Bundler version 1.3.2
         Running: bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin --deployment
         ...
         Your bundle is complete! It was installed into ./vendor/bundle
         Cleaning up the bundler cache.
  -----> Writing config/database.yml to read from DATABASE_URL
  -----> Preparing app for Rails asset pipeline
         Running: rake assets:precompile
         Asset precompilation completed (41.70s)
  -----> Rails plugin injection
         Injecting rails_log_stdout
         Injecting rails3_serve_static_assets
  -----> Uploading staged droplet (41M)
  -----> Uploaded droplet
  Checking whiteboard...
  Staging in progress...
  Staging in progress...
    0/1 instances: 1 starting
    0/1 instances: 1 starting
    1/1 instances: 1 running
  OK
</pre>

## <a id='service-connection'></a>Step 6: (Optional) Configure Service Connections ##

If you bound a service to the application you deployed, it may be necessary to
configure your application with the service URL and credentials.
For more information, see the specific documentation for your application
framework:

* [Ruby](../services/ruby-service-bindings.html)
* [Node.js](../services/node-service-bindings.html)
* [Spring](../services/spring-service-bindings.html)
* [Grails](../services/grails-service-bindings.html)
* [Lift](../services/lift-service-bindings.html)

## <a id='troubleshoot-push'></a>Step 7: Troubleshoot Deployment Problems ##

If your application does not start on Cloud Foundry, first check that your
application can run locally.

You can troubleshoot your application in the cloud using `cf`.

To check the health of your application, use:

<pre class="terminal">
cf health appname
</pre>

To check how much memory your application is using:

<pre class="terminal">
  cf stats appname
</pre>

To see the environment variables and recent log entries:

<pre class="terminal">
  cf logs appname
</pre>

To tail your logs:

<pre class="terminal">
  cf tail appname
</pre>

If your application has crashed and you cannot retrieve the logs with `cf logs`,
you can retrieve the last log entries with:

<pre class="terminal">
  cf crashlogs appname
</pre>