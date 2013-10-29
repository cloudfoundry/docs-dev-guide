---
title: Migrate a Database on Cloud Foundry
---

The technique you use to migrate a database on Cloud Foundry depends on the application framework. This page has specific recommendations for migrating a database for a Rails application, and general guidelines for migrating databases in other environments.




## <a id='migrate-ruby-db'></a>Migrate a Database for a Rails App ##

You can use a Rake task --- `rake db:migrate` --- to migrate a Rails application's database. You can run the Rake task on Cloud Foundry by customizing the command that Cloud Foundry uses to start the application, so that it runs the migration before starting the application.

The instructions below include directions for editing an application's manifest to migrate the database prior to starting the application. For more information about `manifest.yml`, see [cf Push and the Manifest](/docs/using/deploying-apps/manifest.html#push-and-manifest) on the [Application Manifests](/docs/using/deploying-apps/manifest.html) page.

Assuming that you will run multiple instances of the application, you want to run the migration just once, not for each application instance. The sections below describe two approaches for ensuring that the database migration is performed only for one of multiple application instances.  

### <a id='start-scale'></a>Start an Instance and then Scale ###

 Start a single instance when running the migration, and then re-push the application to start the desired number of instances.  

  1. In `manifest.yml`, set the instances attribute to "1", and using the `command` attribute, specify the Rake task --- `rake db:migrate` --- command before the command that starts the application.   

     ~~~
     ---
     applications:
     - name: my-rails-app
       instances: 1
       command: rake db:migrate && rails s
       ... the rest of your settings  ...
    ~~~

  2. Push the application.

  3. Edit `manifest.yml` to set the `instances` attribute to the desired quantity and to remove the migrate task from the `command` attribute, and then re-push the application. 

### <a id='task'></a>Use Rake Task to Limit Migration ###

If you wish, you can create a Rake task that limits the migration to the first instance started. The metadata for an application instance running on Cloud Foundry includes `instance_index`; the first instance that starts up has `instance_index` of "0".

1. Write a Rake task that limits an action to the first application instance. The example below uses the `VCAP_APPLICATION` environment variable to limit execution of the migration to the first instance, which has `instance_index` of "0".

  ~~~
  namespace :cf do
     desc "Only run on the primary Cloud Foundry instance"
     task :on_primary_instance do
        instance_index = JSON.parse(ENV["VCAP_APPLICATION"])["instance_index"] rescue nil
       exit(0) unless instance_index == 0
     end
  end
~~~

2. In `manifest.yml`, define `command` using the new task to limit the `db:migrate` action to the first application instance. For example:

     ~~~
     ---
     applications:
     - name: my-rails-app
       instances: 5
       command: bundle exec rake cf:on_primary_instance db:migrate && rails s
       ... the rest of your settings  ...
     ~~~

 Verify that the application instances started up, because, as with the prior method, if the migration fails, the application instances will not be started.


## <a id='migrate-node-db'></a>Database Migration Guidelines ##

The process you use to migrate a database on Cloud Foundry will vary by framework. In general, it is likely you will take one of the following approaches:

- Migrate your schema by running the appropriate SQL statements or a script in an interactive SQL shell, for example, `psql` for Postgres. 

- Migrate your schema using a command that relies on having access to your application's code base. Rails' `rake db:migrate` task is a specific instance of this more general case. If you have written code to migrate your database, and you want to execute that code from within your application, either migrate-then-scale or limit the number of instances that run the migration using the `VCAP_APPLICATION` environment variable, as described in [Use Rake Task to Limit Migration](#task). 
 
