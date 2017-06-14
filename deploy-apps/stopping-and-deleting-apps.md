---
title: Stopping and deleting apps
owner: CLI
---

<strong><%= modified_date %></strong>

It’s important to know that when you perform a `cf push` command, there are three things that happen:

1. your code is uploaded, after which a buildpack converts it to a single container, called a 'droplet', that can be run on Cloud Foundry as an app
2. the droplet is used to start the requested number of instances of that app
3. a route is created, connecting your app to the internet

When deleting apps you need to remember aspects 1 and 3.

Services have a different lifecycle and need to be removed separately.

### Stopping and starting apps ###

If you temporarily want to stop your app, freeing up memory from your quota, you can use the command

<pre class="terminal">cf stop APP_NAME</pre>

This will stop the app running (although databases and other provisioned services will still be running and chargeable). Users visiting your app's URL will get the error:

<pre>
404 Not Found: Requested route ('APP_NAME.applications-domain.example.com') does not exist.
</pre>

You can start a stopped app with

<pre class="terminal">cf start APP_NAME</pre>

### Deleting apps ###

<p class='note'><strong>Note</strong>: This is irreversible. We strongly recommend running the `cf target` command before you start: check you *are* where you think you are, and working on what you think you are working on.</p>

If you want to remove your app completely it’s tempting to jump in with the `cf delete` command, but there are a few things to beware of:

* Services that are used by apps do not automatically get deleted
* Routes between the internet and your apps need to be explicitly removed.

If you have a simple app without any services the best way to delete it is

<pre class="terminal">cf delete -r APP_NAME</pre>

which will delete the app and its routes in one go. If your app does have services, please [delete them first](#deleting-services).

If you accidentally delete your app without the `r` option, you can delete the route manually. First confirm the details of the orphaned route by typing the `cf routes` command, to get a list of all active routes in the current space. This will list the space, the hostname, the overall domain, port, path, type and any bound apps or services. You will see your hostname listed but without an associated app. Use this information to populate the following command:

<pre class="terminal">cf delete-route DOMAIN_NAME --hostname HOSTNAME</pre>

###<a id='deleting-services'></a> Deleting services ###

Before deleting your app, you will need to delete any services you have provisioned for it.

You can check the details of these by using the `cf services` command to see all active services in the current space. You will be able to see which services are bound *only* to your app.

You can then use this information to run

<pre class="terminal">cf delete-service SERVICE_INSTANCE</pre>

When all services are removed you can then delete your app, as above.
