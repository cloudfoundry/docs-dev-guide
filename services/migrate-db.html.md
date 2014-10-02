---
title: Migrating a Database in Cloud Foundry
---

_This page assumes that you are using cf v6._

Application development and maintenance often requires changing a database schema, known as migrating the database. This topic describes three ways to migrate a database on Cloud Foundry.

## <a id='single-migration'></a>Migrate Once ##

This method executes SQL commands directly on the database, bypassing Cloud Foundry.
This is the fastest option for a single migration.
However, this method is less efficient for multiple migrations because it requires manually accessing the database every time.

<p class="note"><strong>Note</strong>: Use this method if you expect your database migration to take longer than the timeout that cf push applies to your application.
The timeout defaults to 60 seconds, but you can extend it up to 180 seconds with the <code>-t</code> command line option.</p>

1. Run `cf env` and obtain your database credentials by searching in the `VCAP_SERVICES` environment variable:

    <pre class="terminal">
    $ cf env db-app
    Getting env variables for app my-db-app in org My-Org / space development as admin...
    OK

    System-Provided:
    {
      "VCAP_SERVICES": {
        "example-db-n/a": [
          {
            "name": "test-777",
            "label": "example-db-n",
            "tags": ["mysql","relational"],
            "plan": "basic",
            "credentials" : {
              "jdbcUrl": "jdbcmysql://aa11:2b@cdbr-05.example.net:3306/ad_01",
              "uri": "mysql://aa11:2b@cdbr-05.example.net:	34/ad_01?reconnect=true",
              "name": "ad_01",
              "hostname": "cdbr-05.example.net",
              "port": "1234",
              "username": "aa11",
              "password": "2b"
            }
          }
        ]
      }
    </pre>

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

    <p class="note"><strong>Note</strong>: After this step the database has been migrated but the application itself has not started, because the normal start command is not used.</p>

3. Deploy your application again with the normal start command and desired number of instances. For example:

    `cf push APP -c 'null' -i 4`

    <p class="note"><strong>Note</strong>: This example assumes that the normal start command for your application is the one provided by the buildpack, which the <code>-c 'null'</code> option forces cf to use.</p>

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

For an example of the migrate frequently method used with Rails, see [Running Rake Tasks](../../buildpacks/ruby/ruby-tips.html#rake).