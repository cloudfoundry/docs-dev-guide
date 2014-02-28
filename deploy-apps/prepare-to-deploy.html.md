---
title: Prepare to Deploy an Application
---

## <a id="app-design"></a>Application Design for the Cloud ##

Applications written in supported application frameworks often run unmodified on
Cloud Foundry, if the application design follows a few simple guidelines.
Following these guidelines makes an application cloud-friendly, and facilitates
deployment to Cloud Foundry and other cloud platforms.

The following guidelines are not specific to Cloud Foundry. Instead, they represent best practices for developing modern web applications for cloud platforms. For further reading, you can find similar guidelines from other sources. In particular, [The Twelve-Factor App](www.12factor.net) site presents a detailed methodology from experienced app developers.

### <a id="filesystem"></a>Avoid Writing to the Local File System ###

Applications running on Cloud Foundry should not write files to the local file
system.
There are a few reasons for this.

* **Local file system storage is short-lived.** When an application instance crashes or stops, the resources assigned to that instance are reclaimed by the platform including any local disk changes made since the app started. When the instance is restarted, the application will start with a new disk image. Although your application can write local files while it is running, the files will disappear after the application restarts.

* **Instances of the same application do not share a local file system.** Each application instance runs in it's own isolated container. Thus a file written by one instance is not visible to other instances of the same application. If the files are temporary, this should not be a problem. However, if your application needs the data in the files to persist across application restarts, or the data needs to be shared across all running instances of the application, the local file system should not be used. Rather we recommend using a shared data service like a database or blob store for this purpose.

For example, rather than using the local file system, you can use a Cloud
Foundry service such as the MongoDB document database or a relational database
(MySQL or Postgres).
Another option is to use cloud storage providers such as [Amazon S3](http://aws.amazon.com/s3/), [Google Cloud Storage](https://cloud.google.com/products/cloud-storage), [Dropbox](https://www.dropbox.com/developers), or [Box](http://developers.box.com/).
If your application needs to communicate across different instances of itself
(for example to share state), consider a cache like Redis or a messaging-based
architecture with RabbitMQ.

### <a id="sessions"></a>HTTP Sessions Not Persisted or Replicated ###

Cloud Foundry supports session affinity or sticky sessions for incoming HTTP
requests to applications if a jsessionid cookie is used.
If multiple instances of an application are running on Cloud Foundry, all
requests from a given client will be routed to the same application instance.
This allows application containers and frameworks to store session data specific
to each user session.

Cloud Foundry does not persist or replicate HTTP session data.
If an instance of an application crashes or is stopped, any data stored for HTTP
sessions that were sticky to that instance are lost.
When a user session that was sticky to a crashed or stopped instance makes
another HTTP request, the request is routed to another instance of the
application.

Session data that must be available after an application crashes or stops, or
that needs to be shared by all instances of an application, should be stored in
a Cloud Foundry service.
There are several open source projects that share sessions in a data service.

### <a id="ports"></a>HTTP and HTTPS Port Limitations ###

Applications running on Cloud Foundry receive requests using only the URLs
configured for the application, and only on ports 80 (the standard HTTP port)
and 443 (the standard HTTPS port).

## <a id="exclude"></a>Ignore Unnecessary Files When Pushing ##

By default, when you push an application, all files in the application’s project
directory tree, except version control files with file extensions `.svn` `.git`,
and `.darcs`, are uploaded to your Cloud Foundry instance.
If the application directory contains other files (such as `temp` or `log`
files), or complete subdirectories that are not required to build and run your
application, the best practice is to exclude them using a `.cfignore` file.
(`.cfignore` is similar to git’s `.gitignore`, which allows you to exclude files
and directories from git tracking.)
Especially with a large application, uploading unnecessary files slows down
application deployment.

Specify the files or file types you wish to exclude from upload in a text file,
named `.cfignore`, in the root of your application directory structure.
For example, these lines exclude the "tmp" and "log" directories.

<pre class="terminal">
	tmp/
	log/
</pre>

The file types you will want to exclude vary, based on the application
frameworks you use.
The `.gitignore` templates for common frameworks, available at
https://github.com/github/gitignore, are a useful starting point.

## <a id="Buildpack"></a>Buildpacks and Language-Specific Considerations ##

Cloud Foundry stages application using buildpacks.
Heroku developed the buildpack approach and made it available to the open source
community.
Cloud Foundry currently provides buildpacks for the several runtimes and
frameworks.

### <a id="system-buildpacks"></a>Cloud Foundry Buildpacks ###

Cloud Foundry uses buildpacks to transform user-provided artifacts into runnable applications.  The functionality of buildpacks varies, but many of them examine the user-provided artifact in order to properly download needed dependencies and configure applications to communicate with bound services.  Heroku developed the buildpack approach and Cloud Foundry embraces it.

**Cloud Foundry Buildpacks** --- When an artifact is pushed to Cloud Foundry, the system chooses a buildpack automatically. Buildpacks are designed such that they can examine the artifact and opt to process an artifact. For information about the built-in candidate buildpacks, see:

* [Java Buildpack][j]
* [Node.js Buildpack][n]
* [Ruby Buildpack][r]

### <a id="external-buildpacks"></a>External Buildpacks ###

If you have an application that uses a language or framework that Cloud Foundry
buildpacks do not support, there may be a third-party or community-developed
buildpack that you can use. You can also customize existing buildpacks or write your own. To use a buildpack that is not built-in to Cloud Foundry, you specify the URL of the buildpack when you push an application, using the `-b` qualifier or the `buildpack: ` manifest key.

* [Cloud Foundry Commmunity Buildpacks][c] --- This page has links to buildpacks contributed by members of the Cloud Foundry Community.
* [Heroku Third-Party Buildpacks][h] --- This page has links to buildpacks developed for Heroku, which may (but have not been verified to) work with Cloud Foundry.
* [Custom Buildpacks][u] --- See this page for information about writing a custom buildpack.

[c]: https://github.com/cloudfoundry-community/cf-docs-contrib/wiki/Buildpacks
[h]: https://devcenter.heroku.com/articles/third-party-buildpacks
[j]: ./java-tips.html
[n]: ./node-tips.html
[r]: ./ruby-tips.html
[u]:../../buildpacks/
