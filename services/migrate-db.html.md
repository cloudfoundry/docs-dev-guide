---
title: Migrating a Database on Cloud Foundry
---

_This page assumes that you are using cf v6._

Application development and maintenance often requires changing a database schema, known as migrating the database. This topic describes three ways to migrate a database on Cloud Foundry.
## <a id='single_migration'></a>Migrate Once ##

This method executes SQL commands directly on the database, bypassing Cloud Foundry. This is the fastest option for a single migration. However, this method is less efficient for multiple migrations because it requires manually accessing the database every time.

1. Obtain your database credentials by searching for the `VCAP_SERVICES` environment variable in the application environment log:

 `cf files my-app logs/env.log | grep VCAP_SERVICES`

2. Connect to the database using your database credentials.

3. Migrate the database using SQL commands.

4. Update the application using `cf push`.

## <a id='occasional_migration'></a>Migrate Occasionally ##

This method requires:

* Creating a schema migration command or script.
* Running the migration command when deploying a single instance of the application.
* Re-deploying the application with the original start command and number of instances.

this method efficient for occasional use because you can re-use the schema migration command or script.

1. Create a schema migration command or SQL script to migrate the database. For example:

  `rake db:migrate`

2. Deploy a single instance of your application with the database migration command as the start command. For example:

  `cf push APP -c ‘rake db:migrate’ -i 1`

**Note**: Because the normal start command is not used, after this step the application has not actually started.

3. Deploy your application again with the normal start command and desired number of instances. For example:

	`cf push APP -c 'null' -i 4`

**Note**: This example assumes that the normal start command for your application is the one provided by the buildpack, which the `-c 'null'` option forces cf to use.

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

3. Update the application using `cf push`.

**Note**: This application assumes that you are using a manifest and providing the application name there.

### <a id='frequent_migration'></a> Example: Using the Migrate Frequently Method with Rails ###

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

3. Update the application using `cf push`.