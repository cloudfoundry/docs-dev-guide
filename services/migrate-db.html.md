---
title: Migrating a Database on Cloud Foundry
---

_This page assumes that you are using cf v6._

Application development and maintenance often requires changing a database schema, known as migrating the database. This topic describes three ways to migrate a database on Cloud Foundry.

## <a id='single-migration'></a>Migrate Once ##

This method executes SQL commands directly on the database, bypassing Cloud Foundry.
This is the fastest option for a single migration.
However, this method is less efficient for multiple migrations because it requires manually accessing the database every time.

**Note**: Use this method if you expect your database migration to take longer than the timeout that cf push applies to your application.
The timeout defaults to 60 seconds, but you can extend it up to 180 seconds with the `-t` command line option.

1. Obtain your database credentials by searching for the `VCAP_SERVICES` environment variable in the application environment log:

    `cf files my-app logs/env.log | grep VCAP_SERVICES`

2. Connect to the database using your database credentials.

3. Migrate the database using SQL commands.

4. Update the application using `cf push`.

## <a id='occasional-migration'></a>Migrate Occasionally ##

This method requires you to:

* Create a schema migration command or script.
* Run the migration command when deploying a single instance of the application.
* Re-deploy the application with the original start command and number of instances.

This method is efficient for occasional use because you can re-use the schema migration command or script.

1. Create a schema migration command or SQL script to migrate the database. For example:

    `rake db:migrate`

2. Deploy a single instance of your application with the database migration command as the start command. For example:

    `cf push APP -c ‘rake db:migrate’ -i 1`

    **Note**: After this step the database has been migrated but the application itself has not started, because the normal start command is not used.

3. Deploy your application again with the normal start command and desired number of instances. For example:

    `cf push APP -c 'null' -i 4`

    **Note**: This example assumes that the normal start command for your application is the one provided by the buildpack, which the `-c 'null'` option forces cf to use.

## <a id='frequent-migration'></a>Migrate Frequently ##
This method uses an idempotent script to partially automate migrations. The script runs on the first application instance only.

This option takes the most effort to implement, but becomes more efficient with frequent migrations.

1. Create a script that:
    - Examines the `instance_index` of the `VCAP_APPLICATION` environment variable. The first deployed instance of an application always has an `instance_index` of “0”.
        For example, this code uses Ruby to extract the `instance_index` from `VCAP_APPLICATION`:

        `instance_index = JSON.parse(ENV["VCAP_APPLICATION"])["instance_index"]`
    - Determines whether or not the `instance_index` is “0”.
    - If and only if the `instance_index` is “0”, runs a script or uses an existing command to migrate the database. The script or command must be idempotent.

2. Create a manifest that provides:
   - The application name
   - The `command` attribute with a value of the schema migration script chained with a start command.

    Example partial manifest:

    ~~~
     ---
      applications:
      - name: my-rails-app
      command: bundle exec rake db:migrate && rails s
    ~~~

3. Update the application using `cf push`.

### <a id='migrate-ruby-db'></a> Example: Using the Migrate Frequently Method with Rails ###

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

2. Add the task to the `manifest.yml` file, referencing the idempotent command `rake db:migrate` with the `command` attribute.

    ~~~
   ---
    applications:
    - name: my-rails-app
      command: bundle exec rake cf:on_primary_instance db:migrate && rails s
    ~~~

3. Update the application using `cf push`.