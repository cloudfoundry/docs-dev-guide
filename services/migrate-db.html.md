---
title: Migrating a Database on Cloud Foundry
---

_This page assumes that you are using cf v5._

Application development and maintenance often requires changing a database schema, known as migrating the database. This topic describes three ways to migrate a database on Cloud Foundry.
## <a id='single_migration'></a>Migrate Once ##

This method executes SQL commands directly on the database, bypassing Cloud Foundry. This is the fastest option for a single migration. However, this method is less efficient for multiple migrations because it requires manually accessing the database every time.

1. Obtain your database credentials by searching for the `VCAP_SERVICES` environment variable in the application environment log:  

 `cf files my-app logs/env.log | grep VCAP_SERVICES`

2. Connect to the database using your database credentials.

3. Migrate the database using SQL commands.

4. Update the application using `cf push`.

## <a id='occasional_migration'></a>Migrate Occasionally ##
This method leverages a reusable schema migration command or script. Each migration requires first running the migration command when deploying a single instance of the application, then re-deploying the application with the original start command and number of instances.

1. Create a schema migration command or SQL script to migrate the database.

2. Deploy your application with the `command` option referencing the script. Use the `instances 1` option to limit the deployment to a single instance: `cf push --command ‘your_schema_migration_command’ --instances 1`

 Example: `cf push --command ‘rake db:migrate’ --instances 1`

3. Revert to the original deployment settings by using one of the following:
    - The original start command and number of instance.
    - The start command specified in the manifest file using `cf push --reset`. If the manifest does not specify a start command, the reset option uses the default.

## <a id='frequent_migration'></a>Migrate Frequently ##
This method partially automates migrations by using an idempotent script limited to the first instance of a deployed application. This option takes the most effort to implement, but becomes more efficient with frequent migrations.

1. Create a script that:
    - Examines the `instance_index` of the `VCAP_APPLICATION` environment variable. The `instance_index` has a value of “0” in the first deployed instance of an application. 
        For example, this code uses Ruby to extract the `instance_index` from `VCAP_APPLICATION`:

        `instance_index = JSON.parse(ENV["VCAP_APPLICATION"])["instance_index"]`
    - If and only if the instance_index is “0”, runs an idempotent script or uses an existing idempotent command to migrate the database.

2. Add the schema migration script chained with a start command to the `manifest.yml` file using the `command` attribute.

 Example partial manifest:

  ~~~
    - name: my-rails-app
    command: bundle exec rake db:migrate && rails s
  ~~~

3. Update the application using `cf push --reset`.

### <a id='frequent_migration'></a> Migrate Frequently Example using Rails ###

1. Create a Rake task to limit an idempotent command to the first instance of a deployed application:

  ~~~
    namespace :cf do
      desc "Only run on the first application instance"
      task :on_first_instance do
        instance_index = JSON.parse(ENV["VCAP_APPLICATION"])["instance_index"] rescue nil
        exit(0) unless instance_index == 0
      end
    end
  ~~~

2. Add the task to the `manifest.yml` file, referencing the idempotent command `rake db:migrate` with the the `command` attribute. 

  ~~~
   ---
    applications:
    - name: my-rails-app
      command: bundle exec rake cf:on_primary_instance db:migrate && rails s  
  ~~~

3. Update the application using `cf push --reset`.