---
title: Application Manifests
---

_This page assumes that you are using cf v5._

An application manifest defines a set of application deployment settings, such as the name of an application, the number of instances to deploy, the maximum memory available to an instance, the services it uses, and so on. The default name for a manifest is `manifest.yml`.

## <a id='purpose'></a>Purpose of Manifest File ##


The purpose of a manifest is to automate application deployment --- it allows you to provide deployment settings in a file rather than at the command line.  Any deployment option that you can supply at the command line when you run `cf push` can be specified in a manifest. Some deployment options (those for which `cf push` does not prompt) can *only* be specified in the manifest.


## <a id='sample'></a>A Simple Sample Manifest ##

The sample manifest shown below specifies deployment setting for a Node.js application named “nodetestdh01”.  When the application is pushed using this manifest, two instances will be created.  The application URL will be `crn.csapps.io`.

~~~
applications:
- name: nodetestdh01
  memory: 64M
  instances: 2
  host: crn
  domain: csapps.io
  path: .
~~~

Manifests are written in YAML. For information about YAML, see www.yaml.org.

## <a id='push-and-manifest'></a>cf Push and the Manifest ##

When you push an application, cf looks for a file named `manifest.yml`. The push command looks for the manifest in the current working directory, and if it is not found there, in directories above the application root in the directory structure. If the manifest file name is not `manifest.yml` you should specify its name with the `--manifest` (`-m)` option, for example:

<pre class="terminal">
cf push -m prod-manifest.yml
</pre>

**Note:**  cf does not look for a manifest under these circumstances:

* If you use the `--interactive` option with `cf push`, cf does not look for a manifest, instead, it prompts you for deployment options.
* If you use the `--no-manifest` option with `cf push`, if a manifest exists, it is ignored.

The first time you push an application, assuming a manifest is found, cf uses the deployment settings the file contains.

If cf does *not* find a manifest, it prompts you interactively for required deployment options. Once you have supplied the required inputs, cf asks if you want to save the deployment settings to a manifest, as described in the following section.

When you *re-deploy* an application, `cf push` does *not* apply the settings in an existing manifest. Instead, the most recently configured deployment options are applied. For example, if, after initially pushing an application with a manifest that specified “instances: 1”, you use `cf scale` to increase the number of instances to 2, the next time you push the application, 2 instances will be created. You must use the `--reset` option to cause the settings in the manifest to be applied.


## <a id='create'></a>How to Create a Manifest ##

There are two ways to create a manifest:

* Automatically --  When you push an application for the first time (without a manifest) you can supply deployment options as command arguments, or in response to interactive prompts.  cf asks if you want to save the deployment settings to a manifest. If you respond “yes”, the deployment options you selected are saved in the root directory of the application director `manifest.yml`.

* Manually -- You can create a text file with desired deployment options. Save the manifest in the root of your project directory structure, or in a directory above the root in the directory structure.


## <a id='manual'></a>What Must be Manually Defined in a Manifest ##

There are some deployment options that can only be defined in the manifest. For example:

* Ruby symbols -- If you want to use Ruby symbols in a manifest you must manually define them in the the manifest.  See [Use Symbols in a Manifest](#symbols).

* Environment variables -- If you want to define an environment variable, you must edit the manifest file. See [Set Environment Variable in a Manifest](#vars).

* Multi-application manifests -- If you want to deploy multiple applications with a single push command, you must manually edit the manifest file to define the deployment options for each of the applications. In a multi-application manifest, you can define the dependency relationships among the applications.  See [Define a Multi-App Manifest with Dependencies](#multi-app).

* Inheritance -- If you want the settings in one manifest to be included in another, you must specify that in its manifest, as described in [Multiple Manifests and Inheritance](#inheritance).

* Application stack --- If you want to specify a particular stack, you must add the `stack` attribute to the manifest.

## <a id='specify-service'></a>Specify Services in a Manifest ##

To specify service instances to be created and bound to an application at deployment, add lines like these to the manifest:

<tt>
services:<br>
&nbsp;&nbsp;&nbsp;<i>service-instance-name:</i><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;type: <i>service-type</i><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;provider: <i>service-provider</i><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;plan: <i>service-plan</i><br>
</tt>

The following sample manifest specifies two services.

~~~
applications:
- name: mysample
  memory: 256M
  instances: 1
  host: tapp
  domain: ctapps.io
  path: .
  services:
    rediscloud-8cccc:
      type: rediscloud
      provider: garantiadata
      plan: 20mb
    mongolab-6d208:
      type: mongolab
      provider: mongolab
      plan: sandbox
~~~

## <a id='var'></a>Set Environment Variable in a Manifest ##

To define an environment variable that your application uses, add lines like these to the manifest:

<tt>
env:<br>
&nbsp;&nbsp;&nbsp;<i>var_name: var_value</i><br>
</tt>

For example:

<tt>
env:<br>
&nbsp;&nbsp;&nbsp;greeting: hello<br>
</tt>

See the example "base-manifest" in [Not-So-Simple Sample Manifests](#not-simple).


## <a id='symbols'></a>Use Symbols in a Manifest ##

`manifest.yml` supports the following symbols. (A symbol is a Ruby object, the name of an object that is reolved later.)

* `target-base` -- The base URL of your target. For example, if your target is “api.mycloud.com”, the value of target-base is “mycloud.com”. `target-base` is useful if you want to create a manifest for an application that can be pushed to multiple Cloud Foundry instances.

* `random-word` -- A random string of characters, useful for ensuring uniqueness of a URL.

Otherwise, symbol resolution simulates lexical scoping --- you can define arbitrary properties, which can be overridden by child manifests (described above in [Multiple Manifests and Inheritance](#multi-app)) or in a nested hash.

## <a id='inheritance'></a>Multiple Manifests and Inheritance ##

A manifest document can inherit properties from a parent manifest by including this line:

~~~
inherit: path/to/parent.yml
~~~

This pulls the content of the parent manifest into the child manifest, deep-merging the properties defined in the child manifest with those defined in the parent. Symbols (discussed above in [Use Symbols in a Manifest](#symbols)) are resolved after the merge has taken place, so properties defined in the child manifest can be used in properties set in the parent manifest. This allows you to provide basic information, such as service binding information, in a “base” manifest, which can be extended by a child manifest. For example:

* You can create various child manifests for different deployment modes (for example, debug, local, and public) that extend the settings in a base parent manifest.

* You can package a basic configuration with an application, and a user can extend the configuration with a child manifest with additional properties, or with property settings that override those in the parent.

## <a id='multi-app'></a>Define a Multi-App Manifest with Dependencies ##

Manifests enable deployment of multiple applications through a single push command. For example, consider two independent but related applications, a publisher and a subscriber. The subscriber should start before the publisher, so it is available to receive messages as soon as the publisher starts.  If you define these two applications within the same project, you can create a multi-application manifest document, in which you can then specify the dependency.  For example, you can structure the project like this:

~~~
./big-app
./big-app/publisher
./big-app/subscriber
~~~

The manifest below defines two applications, “publisher” and “subscriber”, that use a single Redis service.  Because  the “publisher” application depends on the “subscriber” application, when you do `cf push` from the "big-app" directory, “subscriber” will be started before “publisher”.

~~~
applications:
- name: publisher
  memory: 64M
  path: ./publisher
  domain: example.com
  host: publisher
  instances: 1
  services:
    work-queue:
      type: rediscloud
      provider: garantiadata
      plan: 20mb
  depends-on: ./subscriber
- name: subscriber
  memory: 64M
  path: ./subscriber
  domain: example.com
  host: subscriber
  instances: 1
  services:
    work-queue:
      type: rediscloud
      provider: garantiadata
      plan: 20mb
~~~



## <a id='not-simple'></a>Not-So-Simple Sample Manifests ##
This section contains two manifests that illustrate a variety of manifest features.

**Notes:**

* The first line of a manifest contains three dashes (`---`).

* Settings that apply to all applications in a manifest are declared before the first application block. Examples of such cross-application settings include the environment variables and the services defined in "base-manifest.yml".

* Both manifests are multi-application manifests.

* The first attribute for an application, `name`, is preceded by a dash (“-”).

* "production-manifest.yml" inherits the setting in "base-manifest.yml"; all of the settings in "base-manifest.yml" will be applied to the applications defined in "production-manifest.yml". For example, the environment variables defined in "base-manifest.yml" are available to the applications defined in "production-manifest.yml".

* Comment lines begin with “#”.


### production-manifest.yml ###

~~~
---
inherit: base-manifest.yml

properties:
  rails-env: production
  app-host: app1-host

applications:
  - name: app1-web
    host: ${app-host}
    domain: ${target-base}
    instances: 8
    command: bundle exec rake server:start_command
  - name: app1-worker1
    instances: 4
    command: bundle exec rake VERBOSE=true QUEUE=*
  - name: app1-worker2
    command: bundle exec rake VERBOSE=true
~~~

### base-manifest.yml ###

~~~
---
properties:
  app-host: ${name}

path: .
env:
  RAILS_ENV: ${rails-env}
  RACK_ENV: ${rails-env}
  BUNDLE_WITHOUT: test:development
services:
  frontend-db:
    type: cleardb
    provider: cleardb
    plan: shock
mem: 512M
disk: 1G
instances: 1
host: none
domain: none

# app-specific configuration
applications:
- name: frontend
  host: ${app-host}
  domain: ${target-base}
  instances: 2
  command: bundle exec rake server:start_command
- name: app2-worker1
  instances: 2
  command: bundle exec rake VERBOSE=true QUEUE=*
- name: app2-worker2
  command: bundle exec rake VERBOSE=true

~~~

## <a id='attributes'></a>Supported Manifest Attributes ##


|Attribute|Description |Required?|Example |
| --------- | --------- | --------- |--------- |
|inherit |Use to specify another manifest that the current manifest extends.| n| inherit: base-manifest.yml|
|properties |Use to specify one or more property: value pairs.  |n |properties: <br>&nbsp;&nbsp;app-host: ${name}  |
|env | Use to define one or more environment variables used by the application.| n | env:  <br>&nbsp;&nbsp;RAILS_ENV: ${rails-env}|
|name  |Name of application.  | y | See the examples in [Not-So-Simple Sample Manifests](#not-simple).  |
|buildpack  |Use to specify the URL of an external or custom buildpack  | n |  |
|command  |Command to use to start the application  |n  |command: bundle exec rake server:start_command  |
|domain  |Domain for the application. |  |  |
|host  | Host for the application. |  |  |
|instances  |Number of instances of application to run.|y, defaults to 1<br> if not specified.  |instances: 2  |
|mem  |Maximum memory application can use.  |y, defaults to 256M<br> if not specified. |mem: 64M |
|disk  |Maximum disk space application can use.  |  |disk:1G  |
|path  |Path, relative to current working directory, to the application to push.  | y  | path: . |
|stack  |  |n  |  |
|depends-on  |Path, relative to current working directory, of another application upon which the application depends.    |n  |  |
|*Service_Name* |Name of a service instance to be created and bound to the application |y | See "base-manifest.xml" for example. |
|type |Service type. |y |See "base-manifest.xml" for example.|
|provider|Service provider |y |See "base-manifest.xml" for example. |
|plan |Plan under which the service is obtained. |y |See "base-manifest.xml" for example. |

