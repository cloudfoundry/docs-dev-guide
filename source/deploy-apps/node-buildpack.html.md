---
title: About the Node.js Buildpack  
---

For information about using and extending the Node.js buildpack in Cloud Foundry, see https://github.com/cloudfoundry/heroku-buildpack-nodejs.

For information about the software installed by the Node.js buildpack, see the following section.

## <a id='software-versions'></a>Software Installed by the Node.js Buildpack ##

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

