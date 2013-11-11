---
title: Tips for Node.js Applications
---

This page will prepare you to deploy Node.js apps via the [getting started guide](getting-started.html).

## <a id='packagejson'></a> Application package file ##

Cloud Foundry expects a `package.json` in your Node.js application. You can specify the version of Node.js you want to use in the `engine` node of your `package.json` file. As of July, 2013, Cloud Foundry uses 0.10.x as the default.

## <a id='start'></a> Application start command ##

Node.js applications require a start command, which is saved with other configurations in `manifest.yml`.

You will be asked if you want to save your configuration the first time you deploy. This will save a `manifest.yml` in your application with the settings you entered during the initial push. Edit the `manifest.yml` file and create a start command as follows:

~~~yaml
---
applications:
- name: my-app
  command: node my-app.js
... the rest of your settings  ...
~~~

Alternately, specify the `cf push --command` flag.

<pre class="termainl">
$ cf push --command "node my-app.js"
</pre>

## <a id='nodemodules'></a> Application bundling ##

You do not need to run `npm install` before deploying your application. Cloud Foundry will run it for you when your application is pushed. If you would prefer to run `npm install` and create a `node_modules` folder inside of your application, this is also supported.

## <a id='discovery'></a> Solving Discovery Problems ##

If Cloud Foundry does not automatically detect that your application is a Node.js application, you can override the auto-detection by specifying the Node.js buildpack.

Either, add the buildpack into your `manifest.yml` and re-run `cf push --reset`

~~~yaml
---
applications:
- name: my-app
  buildpack: https://github.com/cloudfoundry/heroku-buildpack-nodejs.git
... the rest of your settings  ...
~~~

Or, specify the `cf push --buildpack` flag.

<pre class="termainl">
$ cf push --buildpack https://github.com/cloudfoundry/heroku-buildpack-nodejs.git
</pre>

## <a id='services'></a> How do I bind services? ##

Refer to the [instructions for node.js service bindings](../bind-services/node-service-bindings.html).

## <a id='buildpack'></a> About the Node.js Buildpack ##

For information about using and extending the Node.js buildpack in Cloud Foundry, see https://github.com/cloudfoundry/heroku-buildpack-nodejs.

The table below lists:

* **Resource** --- The software installed by the buildpack.
* **Available Versions** --- The versions of each software resource that are available from the buildpack.
* **Installed by Default** --- The version of each software resource that is installed by default.
* **To Install a Different Version** --- How to change the buildpack to install a different version of a software resource.

 **This page was last updated on August 2, 2013.**

|Resource |Available Versions |Installed by Default| To Install a Different Version |
| --------- | --------- | --------- |--------- |
|Node.js |0.10.0 - 0.10.6 <br> 0.10.8  - 0.10.12<br>0.8.0 - 0.8.8<br>0.8.10 - 0.8.14<br>0.8.19<br>0.8.21 -  0.8.25<br>0.6.3<br>0.6.5 - 0.6.8<br>0.6.10 - 0.6.18<br>0.6.20<br>0.4.10<br>0.4.7  |latest version of 0.10.x  |To change the default version installed by the buildpack, see <br>“hacking” on https://github.com/cloudfoundry/heroku-buildpack-nodejs. <br><br>To specify the versions of Node.js and npm an application <br>requires, edit the application’s `package.json`, as described in “node.js and npm <br>versions” on https://github.com/cloudfoundry/heroku-buildpack-nodejs.|
|npm |1.3.2<br>1.2.30<br>1.2.21 - 1.2.28<br>1.2.18<br>1.2.14 - 1.2.15<br>1.2.12<br>1.2.10<br>1.1.65<br>1.1.49<br>1.1.40 - 1.1.41<br>1.1.39<br>1.1.35 - 1.1.36<br>1.1.32<br>1.1.9<br>1.1.4<br>1.1.1<br>1.0.10 |latest version of 1.2.x |as above|

