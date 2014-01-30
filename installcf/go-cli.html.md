---
title: Getting Started with cf v6
---

_This page assumes that you have used cf v5 in the past, and are now using cf v6._

cf v6 is simpler, faster and more powerful than v5.

* For v6, cf has been completely re-written in Go, and is more performant than previous versions, which were written in Ruby.
* For v6, there are native installers for all major operating systems.
* Commands behave consistently and logically: required arguments never have flags; optional arguments always have flags.
* Command names are shorter and more readable, and most have single-letter aliases.
* While cf v5 used interactive prompts widely, cf v6 uses interactive prompts only for login and for creating user-provided services.
* While many cf v5 commands read manifests, only the push command in cf v6 reads manifests.


## <a id='install'></a>Installation ##

Installation of cf now consists of a simple point-and-click, and no longer requires you to install Ruby on your system first (or ever).
You can install on any major operating system using new binaries or new native installers.
We recommend that you watch our [tools page](https://console.run.pivotal.io/download_cli) to learn when updates are released, and download a new binary or a new installer when you want to update.
See [Install cf Version 6](./install-go-cli.html) for instructions.

## <a id='login'></a>Improvements to login ##

The `login` command in cf v6 has expanded functionality. In addition to your username and password, you can provide a target API endpoint, organization, and space. cf prompts for any values that you do not specify on the command line. If you have only one organization and one space, you can omit them because `cf login` targets them automatically.

Alternatively, you can write a script to log in and set your target, using the non-interactive `cf api`, `cf auth`, and `cf target` commands.
Usage:

<pre class="terminal">
cf login [-a API_URL] [-u USERNAME] [-p PASSWORD] [-o ORG] [-s SPACE]
</pre>

Upon successful login, cf v6 saves a `config.json` file containing your API endpoint, organization, space values, and access token. If you change these settings, the `config.json` file is updated accordingly.

By default, `config.json` is located in your `~/.cf` directory. The new `CF_HOME` environment variable allows you to locate the `config.json` file wherever you like.

## <a id='push'></a>Improvements to push and curl ##

In cf v6, `push` is simpler to use and faster.

* `APP`, the name of the application to push, is the only required argument, and the only argument that has no flag. Even `APP` can be omitted when you provide the application name in a manifest.
* Many command line options are now one character long. For example, `-n` is now the flag for hostname or subdomain, replacing ``--host``.
* There is no longer an interactive mode.
* You no longer create manifests interactively.
* You no longer create services with push at the command line, interactively, or in a manifest. See [User-Provided Services](#user-provided) to learn about new commands for creating services.
* The `-m` (memory limit) option now requires a unit of measurement: `M`,`MB`,`G`,`or GB`, in upper case or lower case.

cf v6 has expanded capabilities in the form of four new options.

* `-t` (timeout) allows you to give your application more time to start, up to 180 seconds.
* `--no-manifest` forces cf to ignore any existing manifest.
* `--no-hostname` makes it possible to specify a route with a domain but no hostname.
* `--no-route` is suitable for applications which process data while running in the background. These applications, sometimes called "workers" are bound only to services and should not have routes.

Usage:

<pre class="terminal">
cf push APP [-b URL] [-c COMMAND] [-d DOMAIN] [-i NUM_INSTANCES] [-m MEMORY] [-n HOST] [-p PATH] [-s STACK] [--no-hostname] [--no-route] [--no-start]`
</pre>

Optional arguments include:

* `-b` --- Custom buildpack URL, for example, https://github.com/heroku/heroku-buildpack-play.git.
* `-c` --- Start command for the application.
* `-d` --- Domain, for example, example.com.
* `-f` --- replaces `--manifest`
* `-i` --- Number of instances of the application to run.
* `-m` --- Memory limit, for example, 256, 1G, 1024M, and so on.
* `-n` --- Hostname, for example, `my-subdomain`.
* `-p` --- Path to application directory or archive.
* `-s` --- Stack to use.
* `-t` --- Timeout [elaborate...]
* `--no-hostname` --- Map the root domain to this application (NEW).
* `--no-manifest` --- Ignore manifests if they exist.
* `--no-route` --- Do not map a route to this application (NEW).
* `--no-start` --- Do not start the application after pushing.

curl is also improved in cf v6:

* `curl` automatically uses the identity with which you are logged in.
* `curl` usage has been simplified to closely resemble the familiar UNIX pattern.

## <a id='user-provided'></a> User-Provided Services ##

cf v6 has new commands for creating and updating user-provided services. You have the choice of three ways to use these commands: interactively, non-interactively, and in conjunction with third-party log management software as described in [RFC 6587](http://tools.ietf.org/html/rfc6587). When used with third-party logging, cf sends data formatted according to [RFC 5424](http://tools.ietf.org/html/rfc5424).

Once created, user-provided services can be bound to an application with with `cf bind-service`, unbound with `cf unbind-service`, renamed with `cf rename-service`, and deleted with `cf delete-service`.

### <a id='user-cups'></a>The cf create-user-provided-service Command ###

The alias for `create-user-provided-service` is `cups`.
Use the `-p` option with a comma-separated list of parameter names to enable interactive mode.
cf then prompts you for each parameter in turn.

  `cf cups <service-instance> -p "host, port, dbname, username, password"`

Use the `-p` option with a JSON hash of parameter keys and values to create a service non-interactively.

  `cf cups <service-instance> -p '{"username":"admin","password":"pa55woRD"}'`

Use the `-l SYSLOG_DRAIN_URL` option to .

  `cf cups <service-instance> -l syslog://example.com`

### <a id='user-uups'></a> The cf update-user-provided-service Command ###

The alias for `update-user-provided-service` is `uups`.
You can use `cf update-user-provided-service` to update one or more of the attributes for a user-provided service.
Attributes that you do not supply are not updated.

Use the `-p` option with a comma-separated list of parameter names to enable interactive mode. cf then prompts you for each parameter in turn.

  `cf uups <service-instance> -p "HOST, PORT, DATABASE, USERNAME, PASSWORD"`

Use the `-p` option with a JSON hash of parameter keys and values to update a service non-interactively.

  `cf uups <service-instance> -p '{"username":"USERNAME","password":"PASSWORD"}'`

Use the `-l SYSLOG_DRAIN_URL` option to update a service that drains information to third-party log management software.

  `cf uups <service-instance> -l syslog://example.com`

## <a id='domains-etc'></a> Domains, Routes, Organizations and Spaces ##

The relationships between domains, routes, organizations, and spaces have been simplified in cf v6.

* All domains are now mapped to an org.
* Routes are (still) scoped to spaces and apps.

cf v6 has improved separation between management of private domains and management of shared domains.
In terms of domains, cf v6 is designed to work with new and older versions of `cf_release`.

cf v6 provides these commands for managing domains and routes.

* `cf create-domain` --- Create a domain in an organization for later use.
* `cf share-domain` --- Share a domain with all organizations.
* `cf delete-domain` --- Delete a domain.
* `cf create-route` --- Create a URL route in a space for later use.
* `cf map-route` --- Add a URL route to an appLICATION (mapping a route also creates it).
* `cf unmap-route` --- Remove a URL route from an application.
* `cf delete-route` --- Delete a route.

To use a domain in a route:

1. Use `cf create-domain` to create a domain in the desired organization, unless the domain already exists in (or has been shared with) the organization.
1. Use `cf map-domain` to map the domain to the desired space.
1. Use `cf map-route` to map the domain to the desired application. You can map the domain to other applications in the same space, as long as each resulting route in the space is unique. Use the `-n HOSTNAME`option to specify a unique hostname for each route that uses the same domain.

**Note**: The `map-domain` and `unmap-domain` commands no longer exist.

cf v6 provides these commands for managing users and roles. <Ask Scott which are new>

* `cf org-users` --- List users in the organization by role.
* `cf set-org-role` --- Assign an organization role to a user. The available roles are "OrgManager", "BillingManager", and "OrgAuditor".
* `cf unset-org-role` --- Remove an organization role from a user.
* `cf space-users` --- List users in the space by role.
* `cf set-space-role` --- Assign a space role to a user. The available roles are "SpaceManager", "SpaceDeveloper", and "SpaceAuditor".
* `cf unset-space-role` --- Remove a space role from a user.

## <a id='easy'></a> Consistent Behavior to Help You Work Efficiently  ##

We have focused on building clear principles into cf v6 to help operators and developers work efficiently and comfortably.

cf v6 commands behave consistently and logically:

* Required arguments never have flags.
* Optional arguments always have flags.
* If there is more than one required argument, the order of required arguments matters.
* Optional arguments can be provided in any order.

For example, consider `cf create-service`, which has three required arguments that must be provided in order: `SERVICE`, `PLAN`, and `SERVICE_INSTANCE`.
On the other hand, `cf push` has one required argument and several optional arguments. You can provide the optional arguments in any order.

### <a id='aliases'></a> New Aliases ###

cf v6 introduces single-letter aliases for commonly used commands. For example, you can enter `cf p` for `cf push`, and `cf t` for `cf target`. You can see the alias for a command, if there is one, by running command line help.

### <a id='help'></a> Command Line Help ###

Along with the streamlined command set and command nomenclature, cf v6 has more consistent command line help.
The help follows these style conventions, which may differ from other forms of documentation:

* Optional user input is designated with a flag and brackets, as in `cf create-route SPACE DOMAIN [-n HOSTNAME]`.
* User input is capitalized, as in `cf push APP`.

Run `cf help` to view a list all cf commands and a brief description of each. To view detailed help for a command, add `-h` to the command line. For example:

<pre class="terminal">
	$ cf push -h
	NAME:
	   push - Push a new app or sync changes to an existing app

	ALIAS:
	   p

	USAGE:
	   cf push APP [-b URL] [-c COMMAND] [-d DOMAIN] [-i NUM_INSTANCES]
	               [-m MEMORY] [-n HOST] [-p PATH] [-s STACK]
	               [--no-hostname] [--no-route] [--no-start]

	OPTIONS:
	   -b 			Custom buildpack URL (e.g. https://github.com/heroku/heroku-buildpack-play.git)
	   -c 			Startup command, set to null to reset to default start command
	   -d 			Domain (e.g. example.com)
	   -i 			Number of instances
	   -m 			Memory limit (e.g. 256M, 1024M, 1G)
	   -n 			Hostname (e.g. my-subdomain)
	   -p 			Path of app directory or zip file
	   -s 			Stack to use
	   -t 			Start timeout in seconds
	   -f 			Path to manifest
	   --no-manifest	Ignore manifest file
	   --no-hostname	Map the root domain to this app
	   --no-route		Do not map a route to this app
	   --no-start		Do not start an app after pushing

</pre>



