---
title: Configure Service Connections for Lift
---

## <a id='intro'></a>Introduction ##

This guide shows how to adapt the standard example lift application to use a bound service on Cloud Foundry.

## <a id='auto'></a>Auto-Configuration ##

By default, Cloud Foundry will detect service connections in a Lift application and configure them to use the credentials provided in the Cloud Foundry environment. Auto-configuration will only happen if there is a single service of any of the supported types - relational database (MySQL or Postgres), MongoDB, Redis, or RabbitMQ. If you application has more than one service of those types, or you want more control over the configuration, you can manually configure the service connections as described in following section.

## <a id='manual'></a>Manual Configuration ##

To manually configure the database connection using a bound service in Scala, a few more dependencies need to be added to the project. First, add the `spring-core` and `cloudfoundry-runtime` dependencies, as shown in the following Maven `pom.xml` example. **For Cloud Foundry v2 support, the version of `cloudfoundry-runtime` must be at least `0.8.4`**:

~~~xml
  <dependency>
    <groupId>spring</groupId>
    <artifactId>spring-core</artifactId>
    <version>1.0.2</version>
  </dependency>

  <dependency>
    <groupId>org.cloudfoundry</groupId>
    <artifactId>cloudfoundry-runtime</artifactId>
    <version>0.8.4</version>
  </dependency>
~~~

You will also need to add the Spring milestones repository to the project configuration, as in this Maven example: 

~~~xml
  <repository>
    <id>org.springframework.maven.milestone</id>
    <name>Spring Framework Maven Milestone Repository</name>
    <url>http://maven.springframework.org/milestone</url>
  </repository>
~~~

Now set the Connection Manager in `./src/main/scala/bootstrap/liftweb/Boot.scala`. Import the following namespaces first:

~~~scala
  import org.cloudfoundry.runtime.env._
  import org.cloudfoundry.runtime.service.relational._
  import scala.collection.JavaConversions._
~~~

Then replace the existing code at the start of the boot method with the following. This will use the `cloudfoundry-runtime` library to find the correct service using the set name at the start of the code and then create and set the connection manager for the project.

~~~scala
  val serviceName = "lift-db"
  val service = new CloudEnvironment().getServiceDataByName("name")
  val creds = service.get("credentials").asInstanceOf[java.util.LinkedHashMap[String, Object]]

  val password = Box[String](creds.get("password").toString)
  val username = Box[String](creds.get("username").toString)
  val url = "jdbc:mysql://" + creds.get("host") + ":" + creds.get("port") + "/" + creds.get("name")
  val driver = "com.mysql.jdbc.Driver"

  val vendor = new StandardDBVendor(driver, url, username, password)

  LiftRules.unloadHooks.append(vendor.closeAllConnections_! _)
  DB.defineConnectionManager(DefaultConnectionIdentifier, vendor)
~~~

