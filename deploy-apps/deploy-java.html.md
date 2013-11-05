---
title: Deploy Java, Groovy, or Scala Apps
---

This page will prepare you to deploy applications written in Java, Groovy, or Scala, using the Spring, Grails, Lift, or Play frameworks, via the [getting started guide](getting-started.html).

## <a id='war'></a> Build a war file ##

If you are deploying a web application built with Spring, Grails, Lift, or Play, then you should compile the application and assemble a war file for deploying to Cloud Foundry. The path to the war file should then be provided to `cf` using the `--path` option. Below are some examples of doing this with the various frameworks and build tools:

Spring with Maven

<pre class="terminal">
$ mvn package
$ cf push --path target/my-app-1.0.0.war
</pre>

Spring with Gradle

<pre class="terminal">
$ gradle assemble
$ cf push --path build/libs/my-app-1.0.war
</pre>

Grails

<pre class="terminal">
$ grails prod war
$ cf push --path target/my-app-1.0.0.war
</pre>

Play

<pre class="terminal">
$ play dist
$ cf push --path dist/my-app-1.0.war
</pre>

Lift

<pre class="terminal">
$ mvn package
$ cf push --path target/my-app-1.0.0.war
</pre>

## <a id='services'></a> Binding to Services ##

Information about binding apps to services can be found on the following pages:

* [Spring](../bind-services/spring-service-bindings.html)
* [Grails](../bind-services/grails-service-bindings.html)
* [Lift](../bind-services/lift-service-bindings.html)

