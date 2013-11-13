---
title: Getting Started with Application Deployment
---

## <a id='intro'></a>Overview of Deployment Process ##

You deploy an application to Cloud Foundry by running a `push` command from a Cloud Foundry command line interface (CLI). Between the time you run `push` and the time that the application is available, Cloud Foundry does a bunch of work. It uploads and stores application files, examines and stores application metadata, creates a droplet (the Cloud Foundry unit of execution) for the application, selects an appropriate droplet execution agent (DEA) to run the droplet, and starts the application.

An application that uses services, such as a database, messaging, or email server, will not be fully functional until you *provision* the service and, if required, *bind* it to the application. Provisioning typically means creating a cloud-resident instance of the service. Binding is required for some types of services; if the application needs to connect to and authenticate with the service, the service instance must be bound to the application. You can provision and bind a service as part of the push process, or as a subsequent, separate step, using the `create-service` and `bind-service` CLI commands. Depending on the type of service, you may need to configure your application with the bound service’s connection information. For data services, you will typically need to seed or migrate the datastore.


## <a id='prepare'></a>Step 1 --- Prepare to Deploy  ##

Preparing to deploy an application involves:

* Making sure that your application architecture is *cloud-ready*. There are several Cloud Foundry behaviors, related to file storage, HTTP sessions, and port usage that might indicate simple modifications to your application.

* Ensuring that all required application resources will be uploaded and extraneous files and artifacts are excluded. For example, you might need to include a database driver, and especially for a large application, you will want to explicitly exclude extraneous files that exist within your application directory structure.

* Understanding language and framework-specific options and requirements. You will want to verify that your Cloud Foundry instance supports the type of application you are going to deploy, or know the URL of an externally available buildpack that can stage the application. Any buildpack has a mechanism for detecting an application's type --- for instance, whether it is a Java or a Node.js application --- so it is a good idea to understand how the buildback that a will stage your application performs that discovery.

For more information on these and other topics that will help you prepare to deploy your application, see

* [Prepare to Deploy](prepare-to-deploy.html)
* [Tips for Ruby Developers](ruby-tips.html)
* [Tips for Node.js Developers](node-tips.html)
* [Tips for Java Developers](java-tips.html)

## <a id='prepare'></a>Step 2 --- Install or Update Your CLI ##

There are two versions of the cf CLI: v5 and v6  The two CLIs provide similar functionality, but vary in terms of specific commands and usage patterns.  For installation and usage information, see:

* Ruby cf CLI --- [Install cf v5](install-ruby-cli.html)
* Go cf CLI --- [Install cf v6](install-go-cli.html)

## <a id='logon-target'></a>Step 3 --- Know Your Credentials and Target ##

Before you can use a CLI to push an application you need to know:

* Your username and password for your Cloud Foundry instance.
* What is your target? A Cloud Foundry target identifies a particular workspace within a Cloud Foundry instance where you can run applications. A target is identified by:
	* The API endpoint, or URL, where your Cloud Foundry instance listens for user and API connections, and
	* The Cloud Foundry organizations  and spaces you can target.  A Cloud Foundry workspace is organized into organizations, and within them, spaces. A Cloud Foundry user is granted access to one or more organizations and spaces within those organizations.

## <a id='domain'></a>Step 4 --- (Optional) Configure Domains ##

When you deploy an application, specify the route (or URL) that Cloud Foundry uses to direct requests to an application. A route is made up of a subdomain and a domain that you can specify when you push an application. You can use the default domain defined for your Cloud Foundry instance, or specify a different registered domain that has been mapped to the Cloud Foundry organization space to which you are deploying the applications. For more information, see:

* [About Domains, Subdomains and Routes](./domains-routes.html) --- See this topic for information about working with domains.
* [Configure SSL-Enabled Custom Domain](./cloudflare.html) --- See this topic for instructions on how to configure an SSL-enabled domain.

## <a id='options'></a>Step 5 --- Determine Deployment Options ##

Before you deploy, you need to decide on the answers to some questions:

* **Name**: You can use any series of alpha-numeric characters without spaces as the name of your application.
* **Instances**: The number of instances you want running. To avoid the risk of an application being unavailable during Cloud Foundry upgrade processes, you should run more than one instance of an application. When a DEA is upgraded, the applications running on it are _evacuated_: shut down gracefully on the DEA to be upgraded, and restarted on another DEA. On Pivotal CF Hosted, BOSH is configured to upgrade DEAs one at a time, so for an application whose startup time is less than two minutes, running a second instance should be sufficient. Cloud Foundry recommends running more than two instances of an application that takes longer than two minutes to start.
* **Memory Limit**: The maximum amount of memory that each instance of your application is allowed to consume. If an instance goes over the maximum limit, it will be restarted. If it has to be restarted too often, it will be terminated. So make sure you are generous in your memory limit.
* **Start Command**: This is the command that Cloud Foundry will use to start each instance of your application. The start command is specific to your framework.
      * If you do not specify a start command when you push the application, Cloud Foundry will use the value of the `web` key in the `procfile` for the application, if it exists; failing that, Cloud Foundry will start the application using the  value of the buildpack's web attribute of `default_process_types`.
* **URL and Domain**: `cf` will prompt you for both a URL and a domain. The URL is the subdomain for your application and it will be hosted at the primary domain you choose. The combination of the URL and domain must be globally unique.
* **Services**: `cf` will ask you if you want to create and bind one or more services such as MySQL or Redis to your application. You can respond "yes" to  create and bind services during the push process, or if you prefer, do it after you have deployed the application.
You can define a variety of deployment options on the command line when you run `cf push`, or in a manifest file. For more information:

* See the [push](../manage/cf.html#push) section on "cf Command Line Interface" for information about the `push` command and supplying qualifiers on the command line.
* See the [cf Push and the Manifest](manifest.html#push-and-manifest) section on "Application Manifests" for information about using an application manifest to supply deployment options.

## <a id='push'></a>Step 6 --- Push the Application ##

Here is an example transcript from deploying a Ruby on Rails application.
Note that in this example, we already provisioned an ElephantSQL instance and named it "elephantpg":

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

  1: cfapps.io
  2: none
  Domain> cfapps.io

  Creating route whiteboard.cfapps.io... OK
  Binding whiteboard.cfapps.io to whiteboard... OK

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
  Staging in progress...
  Staging in progress...
  Staging in progress...
  Staging in progress...
  Staging in progress...
  Staging in progress...
  Staging in progress...
    0/1 instances: 1 starting
    0/1 instances: 1 starting
    0/1 instances: 1 starting
    0/1 instances: 1 starting
    0/1 instances: 1 starting
    0/1 instances: 1 starting
    0/1 instances: 1 starting
    0/1 instances: 1 starting
    0/1 instances: 1 starting
    0/1 instances: 1 starting
    0/1 instances: 1 starting
    0/1 instances: 1 starting
    0/1 instances: 1 starting
    0/1 instances: 1 starting
    1/1 instances: 1 running
  OK
</pre>

## <a id='service-connection'></a>Step 7 --- (Optional) Configure Service Connections ##

If you bound a service to the application you deployed, it may be necessary to configure your application with the service URL and credentials. For more information, see:

* [Configure Service Connections for Ruby Apps](../services/ruby-service-bindings.html)
* [Configure Service Connections for Node.js Apps](../services/node-service-bindings.html)
* [Configure Service Connections for Spring Apps](../services/spring-service-bindings.html)
* [Configure Service Connections for Grails Apps](../services/grails-service-bindings.html)
* [Configure Service Connections for lift Apps](../services/lift-service-bindings.html)

## <a id='troubleshoot-push'></a>Step 8 --- Troubleshoot Deployment Problems ##

If your application does not start on Cloud Foundry, it's a good idea to double-check that your application can run locally.

You can troubleshoot your application in the cloud using `cf`.

To check the health of your application, use

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

If your application has crashed and you cannot retrieve the logs with `cf logs`, you can retrieve its dying words with:

<pre class="terminal">
  cf crashlogs appname
</pre>


