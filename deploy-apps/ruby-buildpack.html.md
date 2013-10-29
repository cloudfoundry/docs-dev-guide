---
title: About the Ruby Buildpack  
---
For information about using and extending the Ruby buildpack in Cloud Foundry, see https://github.com/cloudfoundry/heroku-buildpack-ruby.

For information about the software installed by the Ruby buildpack, see the following section.

## <a id='software-versions'></a>Software Installed by the Ruby Buildpack ##


The table below lists:

* **Resource** --- The software installed by the Cloud Foundry Ruby buildpack, when appropriate.
* **Available Versions** --- The versions of each software resource that are available from the buildpack.
* **Installed by Default** --- The version of each software resource that is installed by default. 
* **To Install a Different Version** --- How to change the buildpack to install a different version of a software resource.

**This page was last updated on August 14, 2013.**


|Resource |Available Versions |Installed by Default| To Install a Different Version |
| --------- | --------- | --------- |--------- |
|Ruby |1.8.7  patchlevel 374, Rubygems 1.8.24 <br><br>1.9.2  patchlevel 320, Rubygems 1.3.7.1 <br><br>1.9.3  patchlevel 448, Rubygems 1.8.24 <br><br>2.0.0  patchlevel 247, Rubygems 2.0.3   | The latest security patch release of 1.9.3|Specify desired version in application gem file. |
|Bundler |1.2.1 <br><br>1.3.0.pre.5<br><br>1.3.2 |1.3.2 |Not supported. |



