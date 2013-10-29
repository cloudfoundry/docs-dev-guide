---
title: Build Tool Integration
---

It is possible to deploy application using a couple of different JVM build tools - Maven and Gradle.

## <a id='gradle'></a>Gradle ##

Gradle is a build tool that automates the building, testing, publishing, and deployment of software packages, generated static websites, generated documentation, and more.

The `cf-gradle-plugin` adds Cloud Foundry-oriented tasks to a Gradle project. 

### <a id="gradle-install"></a> Install the plugin ###

An example Gradle project with the Cloud Foundry plugin installed looks something like this (build.gradle):

~~~
buildscript {
  repositories {
    mavenCentral()
  }
  dependencies {
    classpath group: 'org.cloudfoundry', name: 'cf-gradle-plugin', version: '1.0.0'
  }
}

apply plugin: 'cloudfoundry'

cloudfoundry {
    target = 'https://api.run.pivotal.io'
    space = 'development'
    username = 'user@example.com'
    password = 's3cr3t'
    file = new File('build/libs/my-app.war')
    uri = 'http://my-app.run.pivotal.io'
    env = [
        "key": "value"
    ]
}
~~~

After adding and configuring the plugin you can build and push the application to Cloud Foundry with the following command: 

<pre class="terminal">
$ gradle clean assemble cf-push
</pre>

For more information on configuration options within Gradle, take a look at the [cf-gradle-plugin project](https://github.com/cloudfoundry/cf-java-client/tree/master/cloudfoundry-gradle-plugin) on Github.

## <a id='maven'></a>Maven ##

Using the `cf-maven-plugin` Maven plugin, you can deploy an application directly from Maven. This is useful as it means being able to store the Cloud Foundry application manifest in `pom.xml`.

### <a id='maven-install'></a>Install the Plugin ###

Add the following to the `plugins` node of your `pom.xml`:

~~~xml
<plugin>
  <groupId>org.cloudfoundry</groupId>
  <artifactId>cf-maven-plugin</artifactId>
  <version>1.0.0</version>
  <configuration>
      <server>mycloudfoundry-instance</server>
      <target>http://api.run.pivotal.io</target>
      <url>hello-java-maven.cfapps.io</url>
      <memory>256</memory>
  </configuration>
</plugin>
~~~

Set the server name, the target address of the Cloud Foundry server, the intended URL of the application and memory allocation.

Create a file in ~/.m2/settings.xml or if the file exists, edit and add:

~~~xml

<settings>
    ...
    <servers>
        ...
        <server>
          <id>mycloudfoundry-instance</id>
          <username>user@example.com</username>
          <password>mypassword</password>
        </server>
    </servers>
    ...
</settings>
~~~

Set the `server/id` node to correspond to the server name set in the `pom.xml` file and also set the username and password for the desired account.

Then you can use Maven to package and deploy:

<pre class="terminal">
$ mvn clean package cf:push
</pre>

