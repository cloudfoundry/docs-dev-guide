---
title: About Domains, Subdomains and Routes
---


This page has information about how to specify the route (or URL) that Cloud Foundry uses to direct requests to an application. A route is made up of a _subdomain_ and a _domain_ that you can specify when you push an application.

In the following route, the subdomain is `myapp` and the domain is `example.com`:

`myapp.example.com`
## <a id='domains'></a>Key Facts About Domains ##

In Cloud Foundry, domains are associated with spaces.

A Cloud Foundry instance defines a default domain that is available to all spaces. For example, in the Pivotal-hosted instance of Cloud Foundry, the `cfapps.io` domain is automatically mapped to all spaces in all organizations.

Cloud Foundry also supports _custom domains_ --- you can map a registered domain of your own to a space in Cloud Foundry, as described below. If you want to use SSL with a custom domain, see [Configure an SSL-Enabled Custom Domain](./cloudflare.html).

## <a id='map-domain'></a>Map a Custom Domain to a Space ##

If you want use a registered domain of your own, you must define it in Cloud Foundry and map it the application’s space with the `cf map-domain` command.

The command below maps the custom domain `example.com`  to the “development” space.

`cf map-domain --space development example.com`

If you do not want the application to be available via a URL, do not assign a domain to the application.

## <a id='view-domains'></a>View Domains for a Space ##

You can see domains that are mapped to a space using the `cf domains` command. In this example, two domains are mapped to the “development” space:  the default `cfapps.io` domain and the and custom `example.com` domain:

<pre class="terminal">
cf push my-new-app
cf domains --space development
Getting domains in development... OK

name           owner
cfapps.io      none
example.com    jdoe
</pre>



## <a id='unmap-domain'></a>Unmap a Domain ##
You can unmap a domain with the `cf unmap-domain` command.  In this example, the `example.com` domain is unmapped from the “development” space:

<pre class="terminal">
cf unmap-domain --space development example.com
Unmapping example.com from development... OK
</pre>

## <a id='subdomain'></a>Key Facts About Subdomains ##

In some cases, defining the subdomain portion of a route is optional, but generally speaking this segment of a route is required to ensure that the route is unique. Note in particular that you _must_ define a subdomain:

- If you assign the default domain defined for your Cloud Foundry instance (for example, `cfapps.io`).
- If you assign a custom domain to the application, and that domain is, or will be, assigned to other applications. Note that in the case of a custom domain, a subdomain for it must be registered with your naming service along with the top-level domain.

You might choose not to assign a subdomain to an application that will not accept browser requests, or if you are using a custom domain for a single application only.

## <a id='assign-at-push'></a>Assign Domain and Subdomain at push Time ##

When you run `cf push` interactively, it prompts you to supply a subdomain and domain for the application. In the example dialog below, note that the:

- The options for subdomain are “myapp,” the value supplied earlier in the dialog for application name, and “none”. You can also enter a string at the prompt.
- The options for domain are (1) `cfapps.io`, the default domain for the Cloud Foundry instance, (2) `example.com`, a custom domain previously mapped to the space, and (3) “none”.

The route created for the application as a result of the selections made below is:

`myapp.example.com`

<pre class="terminal">
cf push
Name> myapp

Instances> 1

1: 64M
2: 128M
3: 256M
4: 512M
Memory Limit> 256M

Creating myapp... OK

1: myapp
2: none
Subdomain> 1

1: cfapps.io
2: example.com
3: none
Domain> 2

Creating route myapp.example.com... OK
Binding myapp.example.com to myapp... OK

</pre>


## <a id='assign-in-manifest'></a>Assign Subdomain in Manifest ##

If you create or edit the manifest for an application, you can use the `host` (for subdomain) and ``domain` attributes to define the components of the application’s route. For more information, see [Application Manifests](../deploy-apps/manifest.html).

## <a id='list-routes'></a>List Routes ##

You can list routes for the current space with `cf routes` command.  Note that the subdomain is shown as “host”, separate from the domain segment. For example:
<pre class="terminal">
cf routes
Getting routes... OK

host                     domain
myapp                    example.com
1test                    cfapps.io
sinatra-hello-world      cfapps.io
sinatra-to-do            cfapps.io
</pre>

## <a id='define-route'></a>Define or Change a Route from Command Line
You can assign or change the route for an application with the `cf map` command. For example, this command maps the route  `myapp.example.com` to the application named “myapp”:
<pre class="terminal">

cf map --app myapp --host myapp --domain example.com
</pre>

Note that you use the `--host` qualifier to specify the subdomain.

If the application is running when you map a route, restart the application. The new route will not be active until the application is restarted.

