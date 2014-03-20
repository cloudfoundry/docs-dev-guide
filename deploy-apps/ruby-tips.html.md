---
title: Tips for Ruby Developers
---
_This page assumes that you are using cf v6._

This page has information specific to deploying Rack, Rails, or Sinatra
applications.

## <a id='bundler'></a> Application Bundling ##

You need to run <a href="http://gembundler.com/">Bundler</a> to create a
`Gemfile` and a `Gemfile.lock`.
These files must be in your application before you push to Cloud Foundry.

## <a id='config'></a> Rack Config File ##

For Rack and Sinatra you need a `config.ru` file like this:

~~~ruby
require './hello_world'
run HelloWorld.new
~~~

## <a id='precompile'></a> Asset Precompilation ##

Cloud Foundry supports the Rails asset pipeline.
If you do not precompile assets before deploying your application, Cloud
Foundry will precompile them when staging the application.
Precompiling before deploying reduces the time it takes to stage an
application.

Use this command to precompile assets before deployment:

<pre class="terminal">
rake assets:precompile
</pre>

Note that the Rake precompile task reinitializes the Rails application.
This could pose a problem if initialization requires service connections or
environment checks that are unavailable during staging.
To prevent reinitialization during precompilation, add this line to
`application.rb`:

~~~ruby
config.assets.initialize_on_precompile = false
~~~

If the `assets:precompile` task fails, Cloud Foundry uses live compilation
mode, the alternative to asset precompilation.
In this mode, assets are compiled when they are loaded for the first time.
You can force live compilation by adding this line to `application.rb`.

~~~ruby
Rails.application.config.assets.compile = true
~~~

## <a id='rake'></a> Running Rake Tasks ##

Cloud Foundry does not provide a mechanism for running a Rake task on a
deployed application.
If you need to run a Rake task that must be performed in the Cloud Foundry
environment (rather than locally before deploying or redeploying), you can
configure the command that Cloud Foundry uses to start the application to
invoke the Rake task.

An application's start command is configured in the application's manifest
file, `manifest.yml`, with the `command` attribute.

If you have previously deployed the application, the application manifest
should already exist.
There are two ways to create a manifest.
You can manually create the file and save it in the application's root
directory before you deploy the application for the first time.
If you do not manually create the manifest file, cf will prompt you to supply
deployment settings when you first push the application, and will create and
save the manifest file for you, with the settings you specified interactively.
For more information about application manifests, and supported attributes, see
[Deploying with Application Manifests](manifest.html).

For an example of invoking a Rake database migration task at application
startup, see [Migrating a Database on Cloud Foundry](../services/migrate-db.html#migrate-ruby-db).

## <a id='workers'></a> Running Rails 3 Worker Tasks ##

Often when developing a Rails 3 application, you may want delay certain tasks
so as not to consume resource that could be used for servicing requests from
your user.
This section shows you how to create and deploy an example Rails application
that will make use of a worker library to defer a task, this task will then be
executed by a separate application.
The guide also shows how you can scale the resource available to the worker
application.

### <a id='worker-libs'></a> Choosing a Worker Task Library ###

The first task is to decide which worker task library to use.
Here is a summary of the three main libraries available for Ruby / Rails:

| Library | Description
| :------------------ | :-------
| [Delayed::Job](https://github.com/collectiveidea/delayed_job) | A direct extraction from [Shopify](http://www.shopify.com/) where the job table is responsible for a multitude of core tasks.
| [Resque](https://github.com/defunkt/resque) | A Redis-backed library for creating background jobs, placing those jobs on multiple queues, and processing them later.
| [Sidekiq](https://github.com/mperham/sidekiq) | Uses threads to handle many messages at the same time in the same process. It does not require Rails but will integrate tightly with Rails 3 to make background message processing dead simple. This library is also Redis-backed and is actually somewhat compatible with Resque messaging.

For other alternatives, see
[https://www.ruby-toolbox.com/categories/Background_Jobs](https://www.ruby-toolbox.com/categories/Background_Jobs)

### <a id='example-app'></a> Creating an Example Application ###

For the purposes of the example application, we will use Sidekiq.

First, create a Rails application with an arbitrary model called "Things":

<pre class="terminal">
$ rails create rails-sidekiq
$ cd rails-sidekiq
$ rails g model Thing title:string description:string
</pre>

Add `sidekiq` and `uuidtools` to the Gemfile:

~~~ruby
source 'https://rubygems.org'

gem 'rails', '3.2.9'
gem 'mysql2'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'sidekiq'
gem 'uuidtools'
~~~

Install the bundle.

<pre class="terminal">
$ bundle install
</pre>

Create a worker (in app/workers) for Sidekiq to carry out its tasks:

<pre class="terminal">
$ touch app/workers/thing_worker.rb
</pre>

~~~ruby
class ThingWorker

  include Sidekiq::Worker

  def perform(count)

    count.times do

      thing_uuid = UUIDTools::UUID.random_create.to_s
      Thing.create :title => "New Thing (#{thing_uuid})", :description =>
"Description for thing #{thing_uuid}"
    end

  end

end
~~~

This worker will create n number of things, where n is the value passed to the
worker.

Create a controller for "Things":

<pre class="terminal">
$ rails g controller Thing
</pre>

~~~ruby
class ThingController < ApplicationController

  def new
    ThingWorker.perform_async(2)
    redirect_to '/thing'
  end

  def index
    @things = Thing.all
  end

end
~~~

Add a view to inspect our collection of "Things":

<pre class="terminal">
$ mkdir app/views/things
$ touch app/views/things/index.html.erb
</pre>

~~~html
<%= @things.inspect %>
~~~


#### <a id='deploy'></a>Deploying Once, Deploying Twice ####

This application needs to be deployed twice for it to work, once as a Rails web
application and once as a standalone Ruby application.
The easiest way to do this is to keep separate cf manifests for each
application type:

Web Manifest: Save this as `web-manifest.yml`:

~~~yaml
---
applications:
- name: sidekiq
  memory: 256M
  instances: 1
  host: sidekiq
  domain: ${target-base}
  path: .
  services:
  - sidekiq-mysql:
  - sidekiq-redis:
~~~

Worker Manifest: Save this as `worker-manifest.yml`:

~~~yaml
---
applications:
- name: sidekiq-worker
  memory: 256M
  instances: 1
  path: .
  command: bundle exec sidekiq
  services:
  - sidekiq-redis:
  - sidekiq-mysql:
~~~

Since the url "sidekiq.cloudfoundry.com" is probably already taken, change it
in `web-manifest.yml` first, then push the application with both manifest
files:

<pre class="terminal">
$ cf push -f web-manifest.yml
$ cf push -f worker-manifest.yml
</pre>

If `cf` asks for a URL for the worker application, select "none".

### <a id='test'></a>Test the Application ###

Test the application by visiting the new action on the "Thing" controller at
the assigned url.
In this example, the URL would be `http://sidekiq.cloudfoundry.com/thing/new`.

This will create a new Sidekiq job which will be queued in Redis, then picked
up by the worker application.
The browser is then redirected to `/thing` which will show the collection of
"Things".

### <a id='scale'></a>Scale Workers ###

Use the `cf scale` command to change the number of Sidekiq workers.

Example:

<pre class="terminal">
$ cf scale sidekiq-worker -i 2
</pre>

## <a id='buildpack'></a>About the Ruby Buildpack ##

For information about using and extending the Ruby buildpack in Cloud Foundry,
see https://github.com/cloudfoundry/heroku-buildpack-ruby.

The table below below lists:

* **Resource** --- The software installed by the Cloud Foundry Ruby buildpack,
when appropriate.
* **Available Versions** --- The versions of each software resource that are
available from the buildpack.
* **Installed by Default** --- The version of each software resource that is
installed by default.
* **To Install a Different Version** --- How to change the buildpack to install
a different version of a software resource.

| Resource | Available Versions | Installed by Default | To Install a Different Version
| --------- | --------- | --------- |---------
| Ruby | 1.8.7  patchlevel 374, Rubygems 1.8.24 <br><br>1.9.2  patchlevel 320, Rubygems 1.3.7.1 <br><br>1.9.3  patchlevel 448, Rubygems 1.8.24 <br><br>2.0.0 patchlevel 247, Rubygems 2.0.3 | The latest security patch release of 1.9.3 | Specify desired version in application gem file.
| Bundler | 1.2.1 <br><br>1.3.0.pre.5<br><br>1.3.2 | 1.3.2 | Not supported.

**This table was last updated on August 14, 2013.**