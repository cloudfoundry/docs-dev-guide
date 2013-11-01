---
title: Buildpacks
---

Cloud Foundry stages application using framework and and runtime-specific buildpacks. Heroku developed the buildpack approach, and made it available to the open source community.


* **Cloud Foundry Buildpacks** ---  When you push an application the runs in a runtime and framwork supported by a Cloud Foundry buildpack, the appropriate buildpack is automatically applied to the application.  For information about the software resources each buildpack provides see:

     * [Java Buildpack](/docs/using/deploying-apps/java-buildpack.html)
     * [Ruby Buildpack](ruby-buildpack.html)
     * [Node.js Buildpack](/docs/using/deploying-apps/node-buildpack.html)

<br>

* **External Buildpacks** --- If you have an application that uses a language or framework that Cloud Foundry buildpacks do not support, there may be a third-party or community-developed buildpack that you can use. You can also customize an existing buildpack, or write your own.

    * [Cloud Foundry Commmunity Buildpacks](https://github.com/cloudfoundry-community/cf-docs-contrib/wiki/Buildpacks) --- This page has links to buildpacks contributed by members of the Cloud Foundry Community.

    * [Heroku Third-Party Buildpacks](https://devcenter.heroku.com/articles/third-party-buildpacks) for a list of community-developed buildpacks. --- This page has links to buildpacks developed for Heroku, which may (but have not been verified to) work with Cloud Foundry.
    * [Custom Buildpacks](/docs/using/deploying-apps/custom-buildpacks.html) --- See this page for information about writing a custom buildpack.


      To use a buildpack that is not built-in to Cloud Foundry, you specify the URL of the buildpack when you push an application, using the `--buildpack` qualifier.







