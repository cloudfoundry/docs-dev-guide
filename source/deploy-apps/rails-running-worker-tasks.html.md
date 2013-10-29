---
title: Rails 3, Running Worker Tasks
---

## <a id='intro'></a>Introduction ##

Often when developing a Rails 3 application, you may want delay certain tasks so as not to consume resource that could be used for servicing requests from your user.

This quick guide will show you how to create and deploy an example Rails application that will make use of a worker library to defer a task, this task will then be executed by a separate application. The guide will also show you how you can scale the resource available to the worker application.

## <a id='worker-libs'></a> Choosing a worker task library ##

The first task, is to decide which worker task library to use. Here is a summary of the three main libraries available for Ruby / Rails;

### [Delayed::Job](https://github.com/collectiveidea/delayed_job) ###

"A direct extraction from [Shopify](http://www.shopify.com/) where the job table is responsible for a multitude of core tasks."

### [Resque](https://github.com/defunkt/resque) ###

"A Redis-backed library for creating background jobs, placing those jobs on multiple queues, and processing them later."

### [Sidekiq](https://github.com/mperham/sidekiq) ###

"Uses threads to handle many messages at the same time in the same process. It does not require Rails but will integrate tightly with Rails 3 to make background message processing dead simple." This library is also Redis-backed and is actually somewhat compatible with Resque messaging.

There are a lot more too, see https://www.ruby-toolbox.com/categories/Background_Jobs for more!

## <a id='example-app'></a> Creating an example application ##

For the purposes of the example application, we will use Sidekiq, setup is pretty straight forward and it's a very performant solution.

First, create a Rails application with an arbitrary model called things;

<pre class="terminal">
$ rails create rails-sidekiq
$ cd rails-sidekiq
$ rails g model Thing title:string description:string
</pre>

Add sidekiq and uuidtools to the Gemfile, it's going to end up looking like this;

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

Install the bundle;

<pre class="terminal">
$ bundle install
</pre>

Create a worker (in app/workers) for sidekiq to carry out it's tasks;

<pre class="terminal">
$ touch app/workers/thing_worker.rb
</pre>

~~~ruby
class ThingWorker

  include Sidekiq::Worker

  def perform(count)

    count.times do

      thing_uuid = UUIDTools::UUID.random_create.to_s
      Thing.create :title => "New Thing (#{thing_uuid})", :description => "This is the description for thing #{thing_uuid}"
    end

  end

end
~~~

This worker will create n number of things, where n is the value passed to the worker.

Create a controller for 'things';

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

Add a view to inspect our collection of things;

<pre class="terminal">
$ mkdir app/views/things
$ touch app/views/things/index.html.erb
</pre>

~~~html
<%= @things.inspect %>
~~~

## <a id='deploy'></a>Deploying once, deploying twice... ##

This application needs to be deployed twice for it to work, once as a Rails web application and once as a standalone Ruby application. The easiest way to do this is to keep separate CF manifests for each application type;

Web Manifest (save this as web-manifest.yml);

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
    sidekiq-mysql:
      vendor: mysql
      version: "5.1"
      tier: free
    sidekiq-redis:
      vendor: redis
      version: "2.6"
      tier: free
~~~

Worker Manifest (save this as worker-manifest.yml);

~~~yaml
---
applications:
- name: sidekiq-worker
  memory: 256M
  instances: 1
  path: .
  command: bundle exec sidekiq
  services:
    sidekiq-redis:
      vendor: redis
      version: "2.6"
      tier: free
    sidekiq-mysql:
      vendor: mysql
      version: "5.1"
      tier: free
~~~

The url 'sidekiq.cloudfoundry.com' will probably be taken, change it in web-manifest.yml first.
Push the application with both manifest files;

<pre class="terminal">
$ cf push -m web-manifest.yml
$ cf push -m worker-manifest.yml
</pre>

CF will likely ask for a URL for the worker application, select option 2 - "none".

## <a id='test'></a>Testing the application ##

Test the application by visiting the new action on the thing controller at the assigned url, in this example, the URL would have been http://sidekiq.cloudfoundry.com/thing/new

This will create a new sidekiq job which will be queued in Redis and then picked up by the worker application, the browser is then redirected to /thing which will show the collection of 'things'. The likelihood is that the task will be completed by Sidekiq before the browser has even redirected!

## <a id='test'></a>Scale your workers ##

The nice thing about this approach is it makes scaling your Sidekiq workers trivial, pending available resource.

Change the number of workers to two;

<pre class="terminal">
$ cf scale sidekiq-worker --instances 2
</pre>

