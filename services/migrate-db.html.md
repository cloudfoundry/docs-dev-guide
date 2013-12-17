---
title: Migrate a Database on Cloud Foundry
---

_This page assumes that you are using cf v5._

Use migrations to change your database schema in a structured and organized manner. This page provides general guidelines for migrating databases, with detailed recommendations for migrating a database for a Rails application.

## <a id='general_guidelines'></a>General Database Migration Guidelines ##

The technique used to migrate a specific database on Cloud Foundry depends on the application framework. Although Cloud Foundry does not provide a direct mechanism for running shell-commands or Rake tasks on a deployed application, you can use one of the following approaches:

- Migrate your database by running the appropriate SQL statements or a script in an interactive SQL shell, for example, `psql` for Postgres. You can use `grep` to search your application’s env.log for `DATABASE_URL` (your database’s connection details), connect to and migrate the schema, then use `cf push` to update the application.

- Migrate your database by specifying a custom start command in your application’s Cloud Foundry `manifest.yml` file that invokes shell-commands or Rake tasks on a deployed application. Note that if you simply add the custom command to the `manifest.yml` file, the migration will be run on every instance of your application. To limit performing the migration to the first instance of your app, you can:
    - Use that code in a single instance then scale, OR
    - Limit the number of instances that run the code by using the `VCAP_APPLICATION` environment variable.

The following technique using the Rails `rake db:migrate task` is a specific instance of this more general case.

## <a id='migrate_rails'></a>Migrating a Database for a Rails Application ##
In Rails, you typically run the Rake task `rake db:migrate` to migrate a database. You can perform the same task on a deployed instance by adding a start command that includes the Rake task to the application's `manifest.yml` file as follows:

~~~
---
applications:
- name: my-application
  command: "bundle exec rake db:migrate && bundle exec rails -p $PORT"
  ... the rest of your settings ...
~~~

Note, however, that this will run the `db:migrate` command on every instance of your application, not just once. You can limit performing the migration to the first instance of your application by migrating in a single instance then scaling, or by creating and using a custom Rake task.

### <a id='single_and_scale'></a>Migrate in a Single Instance then Scale ###
Start a single instance when running the migration, then re-push the application with the desired number of instances. To do this:

1.  Edit your application's `manifest.yml` file, setting the instances attribute to “1” and adding the custom start command: `command: "bundle exec rake db:migrate && bundle exec rails -p $PORT"`

 ~~~
 ---
 applications:
 - name: my-application
   instances: 1
   command: "bundle exec rake db:migrate && bundle exec rails -p $PORT"
   ... the rest of your settings ...
 ~~~

2. Run `cf push` to deploy your application.

3. Re-edit your `manifest.yml`, setting the instances attribute to the desired number of instances and removing the custom start command.

4. Run `cf push --reset` to deploy your application using the newly modified `manifest.yml`.

### <a id='create_custom_task'></a>Create and Use a Custom Rake Task ###
Cloud Foundry provides metadata for each instance of a deployed application in the form of an environment variable, `VCAP_APPLICATION`. This environment variable contains a unique number for each instance, the `instance_index` key. The first instance of an application has an `instance_index` value of “0”.

1. Using the above information, create a Rake task that parses the `instance_index` value from the `VCAP_APPLICATION` environment variable then limits execution to `instance_index` == 0 – that is, to the first instance. If the `instance_index` is non-zero or unset, the tasks exits Rake and skips any subsequent tasks.

 ~~~
 namespace :cf do
   desc "Only run on the first application instance"
   task :on_first_instance do
     instance_index = JSON.parse(ENV["VCAP_APPLICATION"])["instance_index"] rescue nil
     exit(0) unless instance_index == 0
   end
 end
 ~~~

2. Edit your application's `manifest.yml` file, adding a custom start command the reference this new task:

 ~~~
 ---
 applications:
 - name: my-rails-app
   instances: 5
   command: bundle exec rake cf:on_first_instance db:migrate && bundle exec rails -p $PORT"
  ... the rest of your settings ...
 ~~~

3. Run `cf push` to deploy your application.