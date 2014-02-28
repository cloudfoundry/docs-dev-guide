---
title: Configure Service Connections for Spring
---

## <a id='intro'></a>Introduction ##

Cloud Foundry provides extensive support for connecting a Spring application to services such as MySQL, PostgreSQL, MongoDB, Redis, and RabbitMQ. In many cases, Cloud Foundry can automatically configure a Spring application without any code changes. For more advanced cases, you can control service connection parameters yourself.

## <a id='auto'></a>Auto-Reconfiguration ##

If your Spring application requires services (such as a relational database or messaging system), you might be able to deploy your application to Cloud Foundry without changing any code. In this case, Cloud Foundry automatically re-configures the relevant bean definitions to bind them to cloud services.

Cloud Foundry auto-reconfigures applications only if the following items are true for your application:

* Only one service instance of a given service type is bound to the application. In this context, MySQL and PostgreSQL are considered the same service type (relational database), so if both a MySQL and a PostgreSQL service are bound to the application, auto-reconfiguration will not occur.
* Only one bean of a matching type is in the Spring application context. For example, you can have only one bean of type `javax.sql.DataSource`.

With auto-reconfiguration, Cloud Foundry creates the database or connection factory bean itself, using its own values for properties such as host, port, username and so on. For example, if you have a single `javax.sql.DataSource` bean in your application context that Cloud Foundry auto-reconfigures and binds to its own database service, Cloud Foundry doesn’t use the username, password and driver URL you originally specified. Rather, it uses its own internal values. This is transparent to the application, which really only cares about having a relational database to which it can write data but doesn’t really care what the specific properties are that created the database. Also note that if you have customized the configuration of a service (such as the pool size or connection properties), Cloud Foundry auto-reconfiguration ignores the customizations.

For more information on auto-reconfiguration of specific services types, see the [Service-specific Details](#services) section.

## <a id='manual'></a>Manual Configuration ##

Sometimes you may not be able to take advantage of Cloud Foundry's
auto-reconfiguration of your Spring application.  This may be because you have
multiple services of a given type or because you'd like to have more control over the
configuration.  In either case, you need to include the `spring-cloud` library in your
list of application dependencies.  Update your application Maven `pom.xml` or Gradle
`build.gradle`file to include a dependency on the
`org.springframework.cloud:spring-service-connector` and
`org.springframework.cloud:cloudfoundry-connector` artifacts. For example, if you use
Maven to build your application, the following `pom.xml` snippet shows how to add this
dependency.

```xml
<dependencies>
	<dependency>
	    <groupId>org.springframework.cloud</groupId>
	    <artifactId>cloudfoundry-connector</artifactId>
	    <version>0.9.5</version>
	</dependency>
	<dependency>
	    <groupId>org.springframework.cloud</groupId>
	    <artifactId>spring-service-connector</artifactId>
	    <version>0.9.5</version>
	 </dependency>
</dependencies>
```

You will also need to update your application build file to include the Spring Framework Milestone repository. The following `pom.xml` snippet shows how to do this for Maven:

```xml
<repositories>
    <repository>
	   <id>org.springframework.maven.milestone</id>
	   <name>Spring Maven Milestone Repository</name>
	   <url>http://repo.spring.io/milestone</url>
	 </repository>
	 ...
</repositories>
```

### <a id='javaconfig'></a>Java Configuration ###
Typical use of Java config involves extending the `AbstractCloudConfig` class and
adding methods with the `@Bean` annotation to create beans for services. Apps
migrating from
[auto-reconfguration](http://spring.io/blog/2011/11/04/using-cloud-foundry-services-with-spring-part-2-auto-reconfiguration/) might first try [the service-scanning approach](#scanning-for-services) until they need more explicit control. Java config
also offers a way to expose application and service properties, should you choose to
take a lower level access in creating service connectors yourself (or for debugging
purposes, etc.).

#### Creating Service Beans ####
In the following example, the configuration creates a `DataSource` bean connecting to
the only relational database service bound to the app (it will fail if there is no
such unique service). It also creates a `MongoDbFactory` bean, again, connecting to
the only mongodb service bound to the app. Please check Javadoc for
`AbstractCloudConfig` for ways to connect to other services.

```java
class CloudConfig extends AbstractCloudConfig {
	  @Bean
	    public DataSource inventoryDataSource() {
	      return connectionFactory().dataSource();
	   }
	   ... more beans to obtain service connectors
}
```

The bean names will match the method names unless you specify an explicit value to the
annotation such as `@Bean("inventory-service")` (this just follows how Spring's Java
configuration works).

If you have more than one service of a type bound to the app or want to have an
explicit control over the services to which a bean is bound, you can pass the service
names to methods such as `dataSource()` and `mongoDbFactory()` as follows:

```java
class CloudConfig extends AbstractCloudConfig {

	@Bean
    public DataSource inventoryDataSource() {
       return connectionFactory().dataSource("inventory-db-service");
    }

  @Bean
   public MongoDbFactory documentMongoDbFactory() {
        return connectionFactory().mongoDbFactory("document-service");
    }

   ... more beans to obtain service connectors

}
```

Method such as `dataSource()` come in a additional overloaded variant that offer
specifying configuration options such as the pooling parameters. Please see Javadoc
for more details.

#### Connecting to Generic Services ####
Java config supports access to generic services (that don't have a directly mapped
method--typical for a newly introduced service or connecting to a private service in
private PaaS) through the `service()` method. It follows the same pattern as the
`dataSource()` etc, except it allows supplying the connector type as an additional
parameters.

#### Scanning for Services ####
You can scan for each bound service using the `@ServiceScan` annotation as follows
(conceptually similar to the @ComponentScan annotation in Spring):

```java
@Configuration
@ServiceScan
class CloudConfig {

}
```
Here, one bean of the appropriate type (`DataSource` for a relational database
service, for example) will be created. Each created bean will have the `id` matching
the corresponding service name. You can then inject such beans using auto-wiring:

```java
@Autowired DataSource inventoryDb;
```

If the app is bound to more than one services of a type, you can use the `@Qualifier`
 annotation supplying it the name of the service as in the following code:

```java
@Autowired @Qualifier("inventory-db") DataSource inventoryDb;
@Autowired @Qualifier("shipping-db") DataSource shippingDb;
```

#### Accessing Service Properties ####
You can expose raw properties for all services and the app through a bean as follows:

```java
class CloudPropertiesConfig extends AbstractCloudConfig {

   @Bean
   public Properties cloudProperties() {
       return properties();
   }

}
```

### <a id='cloud'></a>The `<cloud>` Namespace ###

#### Setting Up ####
The `<cloud>` namespace offers a simple way for Spring application to connect to cloud
services. To use this namespace, add a declaration for the cloud namespace:

```xml
 <?xml version="1.0" encoding="UTF-8"?>
 <beans  xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:cloud="http://www.springframework.org/schema/cloud"
        xsi:schemaLocation="
          http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
          http://www.springframework.org/schema/cloud http://www.springframework.org/schema/cloud/spring-cloud.xsd">


    <!-- <cloud> namespace usage here -->
```

#### Creating Service Beans ####
Each namespace element that creates a bean corresponding to a service follows the following pattern (example is for a relational service):

```xml
<cloud:data-source id="inventory-db" service-name="inventory-db-service">
    <cloud:connection properties="sessionVariables=sql_mode='ANSI';characterEncoding=UTF-8"/>
    <cloud:pool pool-size="20" max-wait-time="200"/>
</cloud:data-source>
```
This creates a `javax.sql.DataSource` bean with the `inventory-db` id, binding it to
`inventory-db-service`. The created `DataSource` bean is configured with connection
and pool properties as specified in the nested elements. When the `id` attribute is
not specified, the service name is used as the `id`. When the `service-name` is not
specified, the bean is bound to the only service in the corresponding category
(relational database, in this case). If no unique service is found, a runtime
exception is thrown. Other namespace elements that create service connector include:

```xml
 <cloud:mongo-db-factory/>
 <cloud:redis-connection-factory/>
 <cloud:rabbit-connection-factory/>
```

#### Connecting to Generic Services ####
We also supports a generic `<cloud:service>` namespace to allow connecting to a
service that doesn't have directly mapped element (typical for a newly introduced
service or connecting to a private service in private PaaS). You must specify either
the `connector-type` attribute (so that it can find a unique service matching that
type) or the `service-name` attribute.

```xml
 <cloud:service id="email" service-name="email-service" connector-type="com.something.EmailConnectory"/>
```

#### <a id='scanning-for-services'></a> Scanning for Services ####
Besides these element that create one bean per element, we also support the
`<cloud:service-scan>` element in the same spirit as the `<context:component-scan>`
element. It scans for all the services bound to the app and creates a bean
corresponding to each service. Each created bean has id that matches the service name
to allow the use of the `@Qualifier` annotation along with `@Autowired` when more than
one bean of the same type is introduced.

#### Accessing Service Properties ####
Lastly, we support `<cloud:properties>` that exposes properties for the app and
services.

## <a id='cloud-profiles'></a>Cloud Profile ##
Spring Framework versions 3.1 and above support bean definition profiles as a way to conditionalize the application configuration so that only specific bean definitions are activated when a certain condition is true. Setting up such profiles makes your application portable to many different environments so that you do not have to manually change the configuration when you deploy it to, for example, your local environment and then to Cloud Foundry.

See the Spring Framework documentation for additional information about using Spring bean definition profiles.

When you deploy a Spring application to Cloud Foundry, Cloud Foundry automatically enables the `cloud` profile.

### <a id='cloud-profiles-java'></a>Profiles in Java Configration ###

The `@Profile` annotation can be placed on `@Configuration` classes in a Spring
application to set conditions under which configuration classes are invoked. By using
the `default` and `cloud` profiles to determine whether the application is running on
CloudFoundry or not, your Java configuration can support both local and cloud
deployments using Java configuration classes like these:

```java
public class Configuration {
	@Configuration
    @Profile("cloud")
    static class CloudConfiguration {

        @Bean
        public DataSource dataSource() {
            CloudEnvironment cloudEnvironment = new CloudEnvironment();
            RdbmsServiceInfo serviceInfo = cloudEnvironment.getServiceInfo("my-postgres", RdbmsServiceInfo.class);
            RdbmsServiceCreator serviceCreator = new RdbmsServiceCreator();
            return serviceCreator.createService(serviceInfo);
        }
    }

  @Configuration
    @Profile("default")
    static class LocalConfiguration {

	 @Bean
	       public DataSource dataSource() {
	           BasicDataSource dataSource = new BasicDataSource();
	           dataSource.setUrl("jdbc:postgresql://localhost/db");
	           dataSource.setDriverClassName("org.postgresql.Driver");
	           dataSource.setUsername("postgres");
	           dataSource.setPassword("postgres");
	           return dataSource;
	     }

	 }

}
```
### <a id='cloud-profiles-xml'></a>Profiles in XML Configration ###
In XML configuration files, you group the configuration for a specific environment using the profile attribute of a nested `<beans>` element in the appropriate Spring application context file. You can create your own custom profiles, but the ones that are most relevant in the context of Cloud Foundry are the `default` and `cloud` profiles.

You should group all usages of the `<cloud:>` namespace within the `cloud` profile block to allow the application to run outside of Cloud Foundry environments. You then use the `default` profile (or a custom profile) to group the non-Cloud Foundry configuration that will be used if you deploy your application to a non-Cloud Foundry environment.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans  xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:cloud="http://schema.cloudfoundry.org/spring"
        xmlns:jdbc="http://www.springframework.org/schema/jdbc"
        xmlns:util="http://www.springframework.org/schema/util"
        xmlns:mongo="http://www.springframework.org/schema/data/mongo"
      	xsi:schemaLocation="
		          http://www.springframework.org/schema/data/mongo http://www.springframework.org/schema/data/mongo/spring-mongo-1.0.xsd
		          http://www.springframework.org/schema/jdbc http://www.springframework.org/schema/jdbc/spring-jdbc-3.2.xsd
		          http://schema.cloudfoundry.org/spring http://schema.cloudfoundry.org/spring/cloudfoundry-spring.xsd
		          http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-3.2.xsd
		          http://www.springframework.org/schema/util http://www.springframework.org/schema/util/spring-util-3.2.xsd">

  <bean id="mongoTemplate" class="org.springframework.data.mongodb.core.MongoTemplate">
     <constructor-arg ref="mongoDbFactory" />
  </bean>

  <beans profile="default">
    <mongo:db-factory id="mongoDbFactory" dbname="pwdtest" host="127.0.0.1" port="27017" username="test_user" password="efgh" />
  </beans>

  <beans profile="cloud">
    <cloud:mongo-db-factory id="mongoDbFactory" />
  </beans>

</beans>
```

Note that the `<beans profile="value">` element is nested inside the standard root `<beans>` element. The MongoDB connection factory in the cloud profile uses the `<cloud:>` namespace, the connection factory configuration in the default profile uses the `<mongo:>` namespace. You can now deploy this application to the two different environments without making any manual changes to its configuration when you switch from one to the other.

## <a id='properties'></a>Property Placeholders ##
Cloud Foundry exposes a number of application and service properties directly into its
deployed applications. The properties exposed by Cloud Foundry include basic
information about the application, such as its name and the Cloud provider, and
detailed connection information for all services currently bound to the application.

Service properties generally take one of the following forms:

```bash
 cloud.services.{service-name}.connection.{property}
 cloud.services.{service-name}.{property}
```

where `{service-name}` refers to the name you gave the service when you bound it to your application at deploy time, and `{property}` is a field in the credentials section of the `VCAP_SERVICES` environment variable.

For example, assume that you created a Postgres service called `my-postgres` and then bound it to your application. Assume also that this service exposes credentials in `VCAP_SERVICES` as discrete fields. Cloud Foundry exposes the following properties about this service:

```bash
cloud.services.my-postgres.connection.hostname
cloud.services.my-postgres.connection.name
cloud.services.my-postgres.connection.password
cloud.services.my-postgres.connection.port
cloud.services.my-postgres.connection.username
cloud.services.my-postgres.plan
cloud.services.my-postgres.type
```

If the service exposed the credentials as a single `uri` field, then the following properties would be set up:

```bash
cloud.services.my-postgres.connection.uri
cloud.services.my-postgres.plan
cloud.services.my-postgres.type
```

For convenience, if you have bound just one service of a given type to your
application, Cloud Foundry creates an alias based on the service type instead of the
service name. For example, if only one MySQL service is bound to an application, the
properties will take the form `cloud.services.mysql.connection.{property}`. Cloud
Foundry uses the following aliases in this case:

* `mysql`
* `postgresql`
* `mongodb`
* `redis`
* `rabbitmq`

A Spring application can take advantage of these Cloud Foundry properties using the
property placeholder mechanism. For example, assume that you have bound a MySQL
service called `spring-mysql` to your application. Your application requires a `c3p0`
connection pool instead of the connection pool provided by Cloud Foundry, but you want
to use the same connection properties defined by Cloud Foundry for the MySQL service -
in particular the username, password and JDBC URL.

The following Spring XML application context snippet shows how you might implement this:

```xml
<beans profile="cloud">
  <bean id="c3p0DataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource" destroy-method="close">
    <property name="driverClass" value="com.mysql.jdbc.Driver" />
    <property name="jdbcUrl"
              value="jdbc:mysql://${cloud.services.spring-mysql.connection.host}:${cloud.services.spring-mysql.connection.port}/${cloud.services.spring-mysql.connection.name}" />
    <property name="user" value="${cloud.services.spring-mysql.connection.username}" />
    <property name="password" value="${cloud.services.spring-mysql.connection.password}" />
  </bean>
</beans>
```

The following table lists all the application properties that Cloud Foundry exposes to deployed applications.

| Property                 | Description
| ------------------------ |------------
| `cloud.application.name` | The name provided when the application was pushed to CloudFoundry.
| `cloud.provider.url`     | The URL of the cloud hosting the application, such as `cloudfoundry.com`.

The service properties that are exposed for each type of service are listed in the [Service-specific Details](#services) section.

## <a id='services'></a>Service-Specific Details ##
The following sections describe Spring auto-reconfiguration and manual configuration for the services supported by Cloud Foundry.

### <a id='rdbms'></a>MySQL and Postgres ###

#### Auto-Reconfiguration ####
Auto-reconfiguration occurs if Cloud Foundry detects a `javax.sql.DataSource` bean in
the Spring application context. The following snippet of a Spring application context
file shows an example of defining this type of bean which Cloud Foundry will detect
and potentially auto-reconfigure:

```xml
<bean class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close" id="dataSource">
    <property name="driverClassName" value="org.h2.Driver" />
    <property name="url" value="jdbc:h2:mem:" />
    <property name="username" value="sa" />
    <property name="password" value="" />
</bean>
```

The relational database that Cloud Foundry actually uses depends on the service instance you explicitly bind to your application when you deploy it: MySQL or Postgres. Cloud Foundry creates either a commons DBCP or Tomcat datasource depending on which datasource implementation it finds on the classpath.

Cloud Foundry will internally generate values for the following properties: `driverClassName`, `url`, `username`, `password`, `validationQuery`.

#### Manual Configuration in Java ####

To configure a database service in Java configuration, simply create a `@Configuration` class with a `@Bean` method to return a `javax.sql.DataSource` bean. The bean can be created by helper classes in the `cloudfoundry-runtime` library, as shown here:

```java
@Configuration
public class DataSourceConfig {
    @Bean
    public DataSource dataSource() {
        CloudEnvironment cloudEnvironment = new CloudEnvironment();
        RdbmsServiceInfo serviceInfo = cloudEnvironment.getServiceInfo("my-postgres", RdbmsServiceInfo.class);
        RdbmsServiceCreator serviceCreator = new RdbmsServiceCreator();
        return serviceCreator.createService(serviceInfo);
    }
}
```

#### Manual Configuration in XML ####

The `<cloud:data-source>` element provides an easy way for you to configure a JDBC data source in your Spring application. Later, when you actually deploy the application, you bind a particular MySQL or Postgres service instance to it.

##### Basic Manual Configuration #####

The following snippet of a Spring XML application context file shows a simple way to configure a JDBC data source that will be injected into a `org.springframework.jdbc.core.JdbcTemplate` bean:

```xml
<cloud:data-source id="dataSource" />

<bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
  <property name="dataSource" ref="dataSource" />
</bean>
```

In the preceding example, note that no specific information about the datasource is supplied, such as the JDBC driver classname, the specific URL to access the database, or the database user. Instead, Cloud Foundry will provide these values at runtime, using appropriate information from the specific type of database service instance you bind to your application.

The following table lists the attributes of the `<cloud:data-source>` element:

| Attribute | Description | Type |
|-----------|-------------|------|
| `id` | The ID of this data source. The JdbcTemplate bean uses this ID when it references the data source. Default value is the name of the bound service instance. | `String` |
| `service-name` | The name of the data source service. You specify this attribute only if you are binding multiple database services to your application and you want to specify which particular service instance binds to a particular Spring bean. The default value is the name of the bound service instance. | `String` |

With this configuration, Cloud Foundry uses the most common configuration options when it creates the data source at runtime. The next section describes how to override the defaults for these options.

##### Advanced Manual Configuration #####

You can specify configuration options for a JDBC data source using two child elements of `<cloud:data-source>`: `<cloud:connection>` and `<cloud:pool>`.

The `<cloud:connection>` child element takes a single String attribute (`properties`) that you use to specify connection properties you want to send to the JDBC driver when establishing new database connections. The format of the string must be semi-colon separated name/value pairs (for example, "`property1=value;property2=value`").

The `<cloud:pool>` child element takes the following two attributes:

| Attribute | Description | Type | Default |
|-----------|-------------|------|---------|
| `pool-size` | Specifies the size of the connection pool. Set the value to either the maximum number of connections in the pool, or a range of the minimum and maximum number of connections separated by a dash. | `int` | Default minimum is `0`. Default maximum is `8`. These are the same defaults as the Apache Commons Pool. |
| `max-wait-time` | In the event that there are no available connections, this attribute specifies the maximum number of milliseconds that the connection pool waits for a connection to be returned before throwing an exception. Specify `-1` to indicate that the connection pool should wait forever. | `int` | Default value is `-1` (forever). |

The following example shows how to use these advanced data source configuration options:

```xml
<cloud:data-source id="mydatasource">
  <cloud:connection properties="charset=utf-8" />
  <cloud:pool pool-size="5-10" max-wait-time="2000" />
</cloud:data-source>
```

In the preceding example, the JDBC driver is passed the property that specifies that it should use the UTF-8 character set. The minimum and maximum number of connections in the pool at any given time is 5 and 10, respectively. The maximum amount of time that the connection pool waits for a returned connection if there are none available is 2000 milliseconds (2 seconds), after which the JDBC connection pool throws an exception.

### <a id='mongodb'></a>MongoDB ###

#### Auto-Reconfiguration ####
You must use Spring Data MongoDB 1.0 M4 or later for auto-reconfiguration to work.

Auto-reconfiguration occurs if Cloud Foundry detects a `org.springframework.data.document.mongodb.MongoDbFactory` bean in the Spring application context. The following snippet of a Spring XML application context file shows an example of defining this type of bean which Cloud Foundry will detect and potentially auto-reconfigure:

```xml
<mongo:db-factory
    id="mongoDbFactory"
    dbname="pwdtest"
    host="127.0.0.1"
    port="1234"
    username="test_user"
    password="test_pass" />
```

Cloud Foundry will create a `SimpleMongoDbFactory` with its own values for the following properties: `host`, `port`, `username`, `password`, `dbname`.

#### Manual Configuration in Java ####

To configure a MongoDB service in Java configuration, simply create a `@Configuration` class with a `@Bean` method to return a `org.springframework.data.mongodb.MongoDbFactory` bean (from Spring Data MongoDB). The bean can be created by helper classes in the `cloudfoundry-runtime` library, as shown here:

```java
@Configuration
public class MongoConfig {

    @Bean
    public MongoDbFactory mongoDbFactory() {
        CloudEnvironment cloudEnvironment = new CloudEnvironment();
        MongoServiceInfo serviceInfo = cloudEnvironment.getServiceInfo("my-mongodb", MongoServiceInfo.class);
        MongoServiceCreator serviceCreator = new MongoServiceCreator();
        return serviceCreator.createService(serviceInfo.get);
    }

    @Bean
    public MongoTemplate mongoTemplate() {
        return new MongoTemplate(mongoDbFactory());
    }

}
````

#### Manual Configuration in XML ####
The `<cloud:mongo-db-factory>` namespace provides a simple way for you to manually configure a MongoDB connection factory for your Spring application.

##### Basic Manual Configuration #####
The following snippet of a Spring XML application context file shows a `MongoDbFactory` configuration that will be injected into a `org.springframework.data.mongodb.core.MongoTemplate` bean:

```xml
<cloud:mongo-db-factory id="mongoDbFactory" />

<bean id="mongoTemplate" class="org.springframework.data.mongodb.core.MongoTemplate">
    <constructor-arg ref="mongoDbFactory"/>
</bean>
```

The following table lists the attributes of the `<cloud:mongo-db-factory>` element.

<table>
<tbody>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Type</th>
  </tr>
  <tr>
    <td><code>id</code></td>
    <td>The ID of this MongoDB connection factory. The MongoTemplate bean uses this ID when it references the connection factory. <br>Default value is the name of the bound service instance.</td>
    <td><code>String</code></td>
  </tr>
  <tr>
  <td><code>service-name</code></td>
    <td>The name of the MongoDB service. <br>You specify this attribute only if you are binding multiple MongoDB services to your application and you want to specify which particular service instance binds to a particular Spring bean. The default value is the name of the bound service instance.</td>
    <td><code>String</code></td>
  </tr>
  <tr>
    <td><code>write-concern</code></td>
    <td>Controls the behavior of writes to the data store. The values of this attribute correspond to the values of the `com.mongodb.WriteConcern` class.
       <p>If you do not specify this attribute, then no `WriteConcern` is set for the database connections and all writes default to NORMAL.</p>
       <p>The possible values for this attribute are as follows:</p>
       <ul>
         <li><code>NONE</code>: No exceptions are raised, even for network issues.</li>
         <li><code>NORMAL</code>: Exceptions are raised for network issues, but not server errors.</li>
         <li><code>SAFE</code>: MongoDB service waits on a server before performing a write operation. Exceptions are raised for both network and server errors.</li>
         <li><code>FSYNC_SAVE</code>: MongoDB service waits for the server to flush the data to disk before performing a write operation. Exceptions are raised for both network and server errors.</li>
       </ul>
     </td>
     <td><code>String</code></td>
   </tr>
</tbody>
</table>

This configuration creates a simple MongoDB connection factory using default values for the options. The following section describes how to override the defaults for these options.

##### Advanced Manual Configuration #####
The connection factory created by the `<cloud:mong-db-factory>` namespace can be customized by specifying the optional `<cloud:mongo-options>` child element. The following example shows how to use the advanced MongoDB options:

```xml
<cloud:mongo-db-factory id="mongoDbFactory" write-concern="FSYNC_SAFE">
  <cloud:mongo-options connections-per-host="12" max-wait-time="2000" />
</cloud:mongo-db-factory>
```

In the preceding example, the maximum number of connections is set to `12` and the
maximum amount of time that a thread waits for a connection is `1` second. The
`WriteConcern` is also specified to be the safest possible (`FSYNC_SAFE`).

The `<cloud:mongo-options>` child element takes the following attributes:

| Attribute | Description | Type | Default |
|-----------|-------------|------|---------|
| `connections-per-host` | Specifies the maximum number of connections allowed per host for the MongoDB instance. Those connections will be kept in a pool when idle. Once the pool is exhausted, any operation requiring a connection will block while waiting for an available connection. | `int` | `10` |
| `max-wait-time` | Specifies the maximum wait time (in milliseconds) that a thread waits for a connection to become available. | `int` | `120,000` (2 minutes) |

### <a id='redis'></a>Redis ###

#### Auto-Configuration ####
You must be using Spring Data Redis 1.0 M4 or later for auto-configuration to work.

Auto-configuration occurs if Cloud Foundry detects a `org.springframework.data.redis.connection.RedisConnectionFactory` bean in the Spring application context. The following snippet of a Spring XML application context file shows an example of defining this type of bean which Cloud Foundry will detect and potentially auto-configure:

```xml
<bean id="redis"
      class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory"
      p:hostName="localhost" p:port="6379" />
```

Cloud Foundry will create a `JedisConnectionFactory` with its own values for the following properties: `host`, `port`, `password`. This means that you must package the Jedis JAR in your application. Cloud Foundry does not currently support the JRedis and RJC implementations.

#### Manual Configuration in Java ####
To configure a Redis service in Java configuration, simply create a `@Configuration` class with a `@Bean` method to return a `org.springframework.data.redis.connection.RedisConnectionFactory` bean (from Spring Data Redis). The bean can be created by helper classes in the `spring-cloud` library, as shown here:

```java
@Configuration
public class RedisConfig {

    @Bean
    public RedisConnectionFactory redisConnectionFactory() {
        CloudEnvironment cloudEnvironment = new CloudEnvironment();
        RedisServiceInfo serviceInfo = cloudEnvironment.getServiceInfo("my-redis", RedisServiceInfo.class);
        RedisServiceCreator serviceCreator = new RedisServiceCreator();
        return serviceCreator.createService(serviceInfo);
    }

    @Bean
    public RedisTemplate redisTemplate() {
        return new StringRedisTemplate(redisConnectionFactory());
    }

}
```

#### Manual Configuration in XML ####
The `<cloud:redis-connection-factory>` provides a simple way for you to configure a Redis connection factory for a Spring application.

##### Basic Manual Configuration #####
The following snippet of a Spring XML application context file shows a `RedisConnectionFactory` configuration that will be injected into a `org.springframework.data.redis.core.StringRedisTemplate` bean:

```xml
<cloud:redis-connection-factory id="redisConnectionFactory" />

<bean id="redisTemplate" class="org.springframework.data.redis.core.StringRedisTemplate">
  <property name="connection-factory" ref="redisConnectionFactory"/>
</bean>
````

The following table lists the attributes of the `<cloud:redis-connection-factory>` element:

<table>
<tbody>
<tr>
  <th>Attribute</th>
  <th>Description</th>
  <th>Type</th>
</tr>
<tr>
  <td><code>id</code></td>
  <td>The ID of this Redis connection factory. The RedisTemplate bean uses this ID when it references the connection factory. <br>Default value is the name of the bound service instance.</td>
  <td><code>String</code></td>
</tr>
<tr>
  <td><code>service-name</code></td>
  <td>The name of the Redis service. <br>You specify this attribute only if you are binding multiple Redis services to your application and you want to specify which particular service instance binds to a particular Spring bean. The default value is the name of the bound service instance.</td>
  <td><code>String</code></td>
</tr>
</tbody>
</table>

With this configuration, Cloud Foundry uses the most common configuration options when it creates the factory at runtime. The following section describes how to override the defaults for these options.

##### Advanced Manual Configuration #####
The connection factory created by the `<cloud:redis-connection-factory>` namespace can be customized by specifying the optional `<cloud:pool>` child element.

The following example shows how to use these advanced Redis configuration options:

```xml
<cloud:redis-connection-factory id="myRedisConnectionFactory">
  <cloud:pool pool-size="5-10" max-wait-time="2000" />
</cloud:redis-connection-factory>
```

In this example, the minimum and maximum number of connections in the pool at any
given time is 5 and 10, respectively. The maximum amount of time that the connection
pool waits for a returned connection if there are none available is `2000`
milliseconds (2 seconds), after which the Redis connection pool throws an exception.

The `<cloud:pool>` child element takes the following attributes:

<table>
<tbody>
<tr>
  <th>Attribute</th>
  <th>Description</th>
  <th>Type</th>
  <th>Default</th>
</tr>
<tr>
  <td><code>pool-size</code></td>
  <td>Specifies the size of the connection pool. Set the value to either the maximum number of connections in the pool, or a range of the minimum and maximum number of connections separated by a dash.</td>
  <td><code>int</code></td>
  <td>Default minimum is 0. Default maximum is 8. These are the same defaults as the Apache Commons Pool.</td>
</tr>
<tr>
  <td><code>max-wait-time</code></td>
  <td>In the event that there are no available connections, this attribute specifies the maximum number of milliseconds that the connection pool waits for a connection to be returned before throwing an exception. Specify <code>-1</code> to indicate that the connection pool should wait forever. </td>
  <td><code>int</code></td>
  <td>Default value is <code>-1</code> (forever).</td>
 </tr>
</tbody>
</table>

### <a id='rabbitmq'></a>RabbitMQ ###

#### Auto-Configuration ####
You must be using Spring AMQP 1.0 or later for auto-configuration to work. Spring AMQP provides publishing, multi-threaded consumer generation, and message conversion. It also facilitates management of AMQP resources while promoting dependency injection and declarative configuration.

Auto-configuration occurs if Cloud Foundry detects a `org.springframework.amqp.rabbit.connection.ConnectionFactory` bean in the Spring application context. The following snippet of a Spring application context file shows an example of defining this type of bean which Cloud Foundry will detect and potentially auto-configure:

```xml
<rabbit:connection-factory
    id="rabbitConnectionFactory"
    host="localhost"
    password="testpwd"
    port="1238"
    username="testuser"
    virtual-host="virthost" />
```

Cloud Foundry will create a `org.springframework.amqp.rabbit.connection.CachingConnectionFactory` with its own values for the following properties: `host`, `virtual-host`, `port`, `username`, `password`.

#### Manual Configuration in Java ####
To configure a RabbitMQ service in Java configuration, simply create a
`@Configuration` class with a `@Bean` method to return a
`org.springframework.amqp.rabbit.connection.ConnectionFactory` bean (from the Spring
AMQP library). The bean can be created by helper classes in the `spring-cloud`
library, as shown here:

```java
@Configuration
public class RabbitConfig {
    @Bean
    public ConnectionFactory rabbitConnectionFactory() {
        CloudEnvironment cloudEnvironment = new CloudEnvironment();
        RabbitServiceInfo serviceInfo = cloudEnvironment.getServiceInfo("my-rabbit", RabbitServiceInfo.class);
        RabbitServiceCreator serviceCreator = new RabbitServiceCreator();
        return serviceCreator.createService(serviceInfo);
    }

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
        return new RabbitTemplate(connectionFactory);
    }

}
```

#### Manual Configuration in XML ####
The `<cloud:rabbit-connection-factory>` provides a simple way for you to configure a RabbitMQ connection factory for a Spring application.

##### Basic Manual Configuration #####
The following snippet of a Spring XML application context file shows a RabbitConnectionFactory configuration that will be injected into a `rabbitTemplate` bean. The example also uses the `<rabbit:>` namespace to perform RabbitMQ-specific configurations, as explained after the example:

```xml
<cloud:rabbit-connection-factory id="rabbitConnectionFactory" />

<rabbit:template id="rabbitTemplate"
    connection-factory="rabbitConnectionFactory" />

<rabbit:admin connection-factory="rabbitConnectionFactory"/>

<rabbit:queue name="messages" durable="true"/>
```

The following table lists the attributes of the `<cloud:rabbit-connection-factory>` element:

<table>
<tbody>
<tr>
  <th>Attribute</th>
  <th>Description</th>
  <th>Type</th>
</tr>
<tr>
  <td><code>id</code></td>
  <td>The ID of this RabbitMQ connection factory. The RabbitTemplate bean uses this ID when it references the connection factory. <br>Default value is the name of the bound service instance.</td>
  <td><code>String</code></td>
</tr>
<tr>
  <td><code>service-name</code></td>
  <td>The name of the RabbitMQ service. <br>You specify this attribute only if you are binding multiple RabbitMQ services to your application and you want to specify which particular service instance binds to a particular Spring bean. The default value is the name of the bound service instance.</td>
  <td><code>String</code></td>
</tr>
</tbody>
</table>

This configuration creates a simple RabbitMQ connection factory using default values for the options. The following section describes how to override the defaults for these options.

##### Advanced Manual Configuration #####
The connection factory created by the `<cloud:rabbit-connection-factory>` namespace can be customized by specifying the optional `<cloud:rabbit-options>` child element.

The following example shows how to use these advanced RabbitMQ configuration options:

```xml
<cloud:rabbit-connection-factory id="rabbitConnectionFactory" >
  <cloud:rabbit-options channel-cache-size="10" />
</cloud:rabbit-connection-factory>
```

The `<cloud:rabbit-options>` child element defines one attribute called `channel-cache-size` which you can set to specify the size of the channel cache size. The default value is `1`. In the preceding example, the channel cache size of the RabbitMQ connection factory is set to 10.

