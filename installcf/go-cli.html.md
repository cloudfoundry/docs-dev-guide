---
title: Getting Started with cf v6
---

## <a id='beta'></a>Beta Notice ##

cf v6 beta is a complete rewrite of the Cloud Foundry command-line interface. v6 is written in Go, and is more performant that the previous, Ruby-based version.

cf v6 is currently in beta testing. Limitations of the beta version are:

* Application manifests are not yet supported. Deployment options must be supplied on the command line, and will not be saved in a `manifest.yml` file.
* The display of staging and buildpack logs that results from using `gcf push` is still being optimized to work with Loggregator. Log message listings may be incomplete; the workaround is to run `gcf logs --recent` to display all staging log messages.
* For some commands, only the first 50 results are shown.

During the beta period, the executable will be named gcf instead of cf. cf v6 commands begin with "gcf". If you would prefer to completely switch to gcf now, you can use an alias to cf.

cf v6 is intended to replace cf v5. During the v6 beta period, cf v5 and v6 can co-exist on the same machine; you invoke v6 commands with the `gcf` command prefix. Upon general availability of cf v6, cf v5 will be deprecated, and the gcf executable will be renamed cf. At that point, cf v6 commands will be updated to replace the use of the `gcf` command prefix with `cf`.

cf v6 is available for download at https://github.com/cloudfoundry/cli/releases/tag/v6.0.0-beta2. See https://github.com/cloudfoundry/cli/blob/master/INSTALL.md for installation instructions.



## <a id='new'></a>New and Improved Features ##

## <a id='login'></a>login ##

The `login` command in cf v6 has expanded functionality. In addition to supplying your username and password, you can optionally specify (any or all of) the target API endpoint, organization, and space. cf will prompt for values you do not specify on the command line.

Usage:

<pre class="terminal">
gcf login [-a API_URL] [-u USERNAME] [-p PASSWORD] [-o ORG] [-s SPACE]
</pre>

If you have only one organization and one space, they will be automatically targeted when you log in; you need not specify them.

Upon successful login, cf v6 saves your API endpoint, organization, space values, and access token in a `config.json` file in your `~/.cf` directory. If you change your target API endpoint, organization, or space, the `config.json` file will be updated accordingly.

cf v6 will always use any flags passed in the cf login command first. In a script that logs you in and sets your target, use the non-interactive `gcf api`, `gcf auth`, and `gcf target` commands.

## <a id='push'></a>push ##

`push` command options are changed: most are introduced with a shorter, one-character length flag, and two new options are added, as noted in the argument list below.

Usage:

<pre class="terminal">
gcf push APP [-b URL] [-c COMMAND] [-d DOMAIN] [-i NUM_INSTANCES] [-m MEMORY] [-n HOST] [-p PATH] [-s STACK] [--no-hostname] [--no-route] [--no-start]`
</pre>

The only argument you must supply is `APP`. Optional arguments include:

* `-b` --- Custom buildpack URL, for example, https://github.com/heroku/heroku-buildpack-play.git.
* `-c` --- Start command for the application.
* `-d` --- Domain, for example, example.com.
* `-i` --- Number of instances of the application to run.
* `-m` --- Memory limit, for example, 256, 1G, 1024M, and so on.
* `-n` --- Hostname, for example, `my-subdomain`.
* `-p` --- Path to application directory or archive.
* `-s` --- Stack to use.
* `--no-hostname` --- Map the root domain to this application (NEW).
* `--no-route` --- Do not map a route to this application (NEW).
* `--no-start` --- Do not start the application after pushing.


## <a id='user-provided'></a> User-Provided Services ##

cf v6 has new commands for creating and updating user-provided services, described in the subsections below.

Note that when you create or update a user-provided service, you can use the `-l SYSLOG_DRAIN_URL` option to send data formatted according to RFC 5424 to a third-party log management software as described in RFC 6587.

Once created, user-provided services can be bound to an application with with `gcf bind-service`, unbound with `gcf unbind-service`, renamed with `gcf rename-service`, and deleted with `gcf delete-service`.

### <a id='user-cups'></a>gcf create-user-provided-service, gcf cups ###

Interactive Usage:

<pre class="terminal">
gcf create-user-provided-service SERVICE_INSTANCE -p "HOST, PORT, DATABASE, USERNAME, PASSWORD" -l SYSLOG-DRAIN-URL
</pre>

Non-interactive Usage:

<pre class="terminal">
gcf create-user-provided-service SERVICE_INSTANCE -p '{"username":"USERNAME","password":"PASSWORD"}' -l SYSLOG-DRAIN-URL
</pre>

### <a id='user-uups'></a>gcf update-user-provided-service`, gcf uups ###

You can use `gcf update-user-provided-service` to update one or more of the attributes for a user-provided service. Attributes that you do not supply will not be updated.

Interactive Usage:

<pre class="terminal">
gcf update-user-provided-service SERVICE_INSTANCE -p "HOST, PORT, DATABASE, USERNAME, PASSWORD" -l SYSLOG-DRAIN-URL
</pre>

Non-interactive Usage:

<pre class="terminal">
gcf update-user-provided-service SERVICE_INSTANCE -p '{"username":"USERNAME","password":"PASSWORD"}' -l SYSLOG-DRAIN-URL
</pre>


## <a id='user-provided'></a> Domains and Routes ##

The cf v6 commands for managing domains and routes are:

* `gcf create-domain` --- Create a domain in an organization for later use.
* `gcf share-domain` --- Share a domain with all organizations.
* `gcf map-domain` --- Map a domain to a space.
* `gcf unmap-domain` --- Unmap a domain from a space.
* `gcf delete-domain` --- Delete a domain.
* `gcf create-route` --- Create a URL route in a space for later use.
* `gcf map-route` --- Add a URL route to an appLICATION (mapping a route also creates it).
* `gcf unmap-route` --- Remove a URL route from an application.
* `gcf delete-route` --- Delete a route.


To use a domain in a route:

1. Use `gcf create-domain` to create a domain in the desired organization, unless the domain already exists in (or has been shared with) the organization.
1. Use `gcf map-domain` to map the domain to the desired space.
1. Use `gcf map-route` to map the domain to the desired application. You can map the domain to other applications in the same space, as long as each resulting route in the space is unique. Routes will be unique if you use the `-n HOSTNAME`option to specify a unique hostname for each route that uses the same domain.

## <a id='domains-routes'></a> Management of Roles for Organizations and Spaces ##


cf v6 provides new commands for managing users and roles.

* `gcf org-users` --- List users in the organization by role.
* `gcf set-org-role` --- Assign an organization role to a user. The available roles are "OrgManager", "BillingManager", and "OrgAuditor".
* `gcf unset-org-role` --- Remove an organization role from a user.
* `gcf space-users` --- List users in the space by role.
* `gcf set-space-role` --- Assign a space role to a user. The available roles are "SpaceManager", "SpaceDeveloper", and "SpaceAuditor".
* `gcf unset-space-role` --- Remove a space role from a user.


## <a id='aliases'></a> New Aliases ##

cf v6 introduces single-letter aliases for commonly used commands. For example, you can enter `gcf p` for `gcf push`, and `gcf t` for `gcf target`. You can see the alias for a command, if there is one, by running command line help, described below.

## <a id='help'></a> Command Line Help ##

Run `gcf help` to view a list all gcf commands and a brief description of each. To view detailed help for a command, add `-h` to the command line. For example:

<pre class="terminal">
gcf push -h
NAME:
   push - Push a new app or sync changes to an existing app

ALIAS:
   p

USAGE:
   gcf push APP [-b URL] [-c COMMAND] [-d DOMAIN] [-i NUM_INSTANCES]
               [-m MEMORY] [-n HOST] [-p PATH] [-s STACK]
               [--no-hostname] [--no-route] [--no-start]

OPTIONS:
   -b ''		Custom buildpack URL (for example: https://github.com/heroku/heroku-buildpack-play.git)
   -c ''		Startup command
   -d ''		Domain (for example: example.com)
   -i '1'		Number of instances
   -m '128'		Memory limit (for example: 256, 1G, 1024M)
   -n ''		Hostname (for example: my-subdomain)
   -p ''		Path of app directory or zip file
   -s ''		Stack to use
   --no-hostname	Map the root domain to this app
   --no-route		Do not map a route to this app
   --no-start		Do not start an app after pushing
</pre>

Note that:

* User input is capitalized, as in `gcf push APP`
* Optional user input is designated with a flag and brackets, as in `gcf create-route SPACE DOMAIN [-n HOSTNAME]`.

