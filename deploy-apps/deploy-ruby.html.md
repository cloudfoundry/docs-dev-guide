---
title: Deploy Rack, Rails, or Sinatra Applications
---

This page has information specific to deploying  Rack, Rails, or Sinatra applications.  It supplements the information in the [Getting Started](getting-started.html).

## <a id='bundler'></a> Application Bundling ##

You need to run <a href="http://gembundler.com/">Bundler</a> to create a `Gemfile` and a `Gemfile.lock`. These files must be in your application before you push to Cloud Foundry.

## <a id='config'></a> Rack Config File ##

For Rack and Sinatra you need a `config.ru` file like this:

~~~ruby
require './hello_world'
run HelloWorld.new
~~~

## <a id='precompile'></a> Asset Precompilation ##

Cloud Foundry supports the Rails asset pipeline. If you do not precompile assets before deploying your application, Cloud Foundry will precompile them when staging the application. Precompiling before deploying reduces the time it takes to stage an application.

Use this command to precompile assets before deployment:

<pre class="terminal">
rake assets:precompile
</pre>


Note that the Rake precompile task reinitializes the Rails application. This could pose a problem if initialization requires service connections or environment checks that are unavailable during staging. To prevent reinitialiation during precompilation, add this line to `application.rb`:

~~~ruby
config.assets.initialize_on_precompile = false
~~~

If the `assets:precompile` task fails, Cloud Foundry uses live compilation mode, the alternative to asset precompilation. In this mode, assets are compiled when they are loaded for the first time. You can force live compilation by adding this line to `application.rb`.

~~~ruby
Rails.application.config.assets.compile = true
~~~

## <a id='workers'></a> Worker Tasks ##

Worker tasks are supported by Cloud Foundry. Follow this [Rails workers quick start](rails-running-worker-tasks.html) to understand how it works.

## <a id='console'></a> Rails Console ##

Cloud Foundry v2 does not yet support Rails Console.

## <a id='services'></a> Binding to Services ##

Refer to the [instructions for Ruby service bindings](../bind-services/ruby-service-bindings.html).

## <a id='rake'></a> Running Rake Tasks ##

Cloud Foundry does not provide a mechanism for running a Rake task on a deployed application.
If you need to run a Rake task that must be performed in the Cloud Foundry environment (rather than locally before deploying or redeploying), you can configure the command that Cloud Foundry uses to start the application to invoke the Rake task.

An application's start command is configured in the application's manifest file, `manifest.yml`, with the `command` attribute.

If you have previously deployed the application, the application manifest should already exist. There are two ways to create a manifest. You can manually create the file and save it in the application's root directory before you deploy the application for the first time. If you do not manually create the manifest file, cf will prompt you to supply deployment settings when you first push the application, and will create and save the manifest file for you, with the settings  you specified interactively. For more information about application manifests, and supported attributes, see [Application Manifests](manifest.html).

For an example of invoking a Rake database migration task at application startup, see [Migrate a Database for a Rails App](../bind-services/migrate-db.html#migrate-ruby-db).




