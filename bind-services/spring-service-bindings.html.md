---
title: Spring - Service Bindings
---

## <a id='intro'></a>Introduction ##

Cloud Foundry provides extensive support for connecting a Spring application to services such as MySQL, Postgres, MongoDB, Redis, and RabbitMQ. In many cases, Cloud Foundry can automatically configure a Spring application without any code changes. For more advanced cases, you can control service connection parameters yourself. 

## <a id='auto'></a>Auto-Configuration ##

If your Spring application requires services (such as a database or messaging system), you might be able to deploy your application to Cloud Foundry without changing any code. In this case, Cloud Foundry automatically re-configures the relevant bean definitions to bind them to cloud services. 

Cloud Foundry auto-configures applications only if the following items are true for your application:

* Only one service instance of a given service type is bound to the application. In this context, MySQL and Postgres are considered the same service type (relational database), so if both a MySQL and a Postgres service are bound to the application, auto-configuration will not occur.
* Only one bean of a matching type is in the Spring application context. For example, you can have only one bean of type `javax.sql.DataSource`.

With auto-configuration, Cloud Foundry creates the database or connection factory bean itself, using its own values for properties such as host, port, username and so on. For example, if you have a single `javax.sql.DataSource` bean in your application context that Cloud Foundry auto-configures and binds to its own database service, Cloud Foundry doesn’t use the username, password and driver URL you originally specified. Rather, it uses its own internal values. This is transparent to the application, which really only cares about having a relational database to which it can write data but doesn’t really care what the specific properties are that created the database. Also note that if you have customized the configuration of a service (such as the pool size or connection properties), Cloud Foundry auto-configuration ignores the customizations.

For more information on auto-configuration of specific services types, see the [Service-specific Details](#services) section.

### <a id='optout'></a>Opting out of Auto-Configuration ###

Sometimes you may not want Cloud Foundry to auto-configure your Spring application. To opt out of auto-configuration, use the [`<cloud:>` namespace](#namespace) elements in your Spring application context file to explicitly create a bean that represents a service. This makes auto-configuration unnecessary. 

## <a id='manual'></a>Manual Configuration ##

If your Spring application cannot take advantage of Cloud Foundry’s auto-configuration feature, or you want more control over the configuration, the additional steps you must take are very simple. 

To use any of the manual configuration techniques, you need to include the `cloudfoundry-runtime` library in your list of application dependencies. Update your application build file (e.g. Maven `pom.xml` file or Gradle `build.gradle` file) to include a dependency on the `org.cloudfoundry.cloudfoundry-runtime` artifact. For example, if you use Maven to build your application, the following `pom.xml` snippet shows how to add this dependency. **For Cloud Foundry v2 support, the version of this library must be at least `0.8.4`**:

~~~xml
<dependencies>
    <dependency>
        <groupId>org.cloudfoundry</groupId>
        <artifactId>cloudfoundry-runtime</artifactId>
        <version>0.8.4</version>
    </dependency>

    <!-- additional dependency declarations -->
</dependencies>
~~~ 

You will also need to update your application build file to include the Spring Framework Milestone repository. The following `pom.xml` snippet shows how to do this for Maven:

~~~xml
<repositories>
    <repository>
          <id>org.springframework.maven.milestone</id>
           <name>Spring Maven Milestone Repository</name>
           <url>http://maven.springframework.org/milestone</url>
           <snapshots>
                   <enabled>false</enabled>
           </snapshots>
    </repository>

    <!-- additional repository declarations -->
</repositories>
~~~

### <a id='namespace'></a>XML Configuration ###

The `<cloud:>` namespace can be used in Spring XML application context configuration files to manually configure services. This allows multiple services of the same type to be used in a Spring application. The `<cloud:>` namespace elements provide defaults for most common configurations.

The basic steps to update your Spring application to use any of the Cloud Foundry services are as follows:

* Add the `cloudfoundry-runtime` dependency to your application as described above.

* In your Spring application, update all application context files that will include the Cloud Foundry service declarations, such as a data source, by adding the `<cloud:>` namespace declaration and the location of the Cloud Foundry services schema, as shown in the following snippet:

~~~xml
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:context="http://www.springframework.org/schema/context"
    xmlns:cloud="http://schema.cloudfoundry.org/spring"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans-3.2.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context-3.2.xsd
        http://schema.cloudfoundry.org/spring
        http://schema.cloudfoundry.org/spring/cloudfoundry-spring.xsd">

    <!-- bean declarations -->

</beans>
~~~

You can configure Cloud Foundry services in a Spring XML application context file by using the `<cloud:>` namespace along with the name of specific elements. 

Cloud Foundry provides elements for each of the supported services: database (MySQL and Postgres), Redis, MongoDB, and RabbitMQ. See the [Service-specific Details](#services) section for details on the namespace elements for each of these services. The following namespace elements apply to all service types.

#### Cloud Properties ####

The `<cloud:properties>` element exposes basic information about the application and its bound services as properties. Your application can then consume these properties using the Spring property placeholder support.

Note that if you are using Spring Framework 3.1 (or later), these properties are automatically available without having to include `<cloud:properties>` in your application context file.

The `<cloud:properties>` element has just a single attribute (`id`) which specifies the name of the `Properties` bean. Use this ID as a reference to `<context:property-placeholder>` which you can use to hold all the properties exposed by Cloud Foundry. You can then use these properties in other bean defintions.

The following example shows how to use this element in a Spring application context file:

~~~xml
<cloud:properties id="cloudProperties" />
~~~

See the following section for more information on using Spring property placeholders for cloud properties.

### <a id='javaconfig'></a>Java Configuration ###

Java configuration can be used as an alternative to the `<cloud:>` namespace in XML. Methods of the `CloudEnvironment` class contained in the `cloudfoundry-runtime` library can be used to get information on services by name or by type, and to create connection objects of the appropriate type for each service. In order to use Java configuration, you must add the `cloudfoundry-runtime` library to your project as described [above](#manual).

See the [Service-specific Details](#services) section below for details on using `CloudEnvironment` for each type of supported service.

### <a id='properties'></a>Property Placeholders ###

Cloud Foundry exposes a number of application and service properties directly into its deployed applications. The properties exposed by Cloud Foundry include basic information about the application, such as its name and the Cloud provider, and detailed connection information for all services currently bound to the application.

Service properties generally take one of the following forms:

~~~
    cloud.services.{service-name}.connection.{property}
    cloud.services.{service-name}.{property}
~~~

where `{service-name}` refers to the name you gave the service when you bound it to your application at deploy time, and `{property}` is a field in the credentials section of the `VCAP_SERVICES` environment variable.

For example, assume that you created a Postgres service called `my-postgres` and then bound it to your application. Assume also that this service exposes credentials in `VCAP_SERVICES` as discrete fields. Cloud Foundry exposes the following properties about this service:

~~~
    cloud.services.my-postgres.connection.hostname
    cloud.services.my-postgres.connection.name
    cloud.services.my-postgres.connection.password
    cloud.services.my-postgres.connection.port
    cloud.services.my-postgres.connection.username
    cloud.services.my-postgres.plan
    cloud.services.my-postgres.type
~~~

If the service exposed the credentials as a single `uri` field, then the following properties would be set up: 

~~~
    cloud.services.my-postgres.connection.uri
    cloud.services.my-postgres.plan
    cloud.services.my-postgres.type
~~~

For convenience, if you have bound just one service of a given type to your application, Cloud Foundry creates an alias based on the service type instead of the service name. For example, if only one MySQL service is bound to an application, the properties will take the form `cloud.services.mysql.connection.{property}`. Cloud Foundry uses the following aliases in this case:

* `mysql`
* `postgresql`
* `mongodb`
* `redis`
* `rabbitmq`

A Spring application can take advantage of these Cloud Foundry properties using the property placeholder mechanism. For example, assume that you have bound a MySQL service called `spring-mysql` to your application. Your application requires a c3p0 connection pool instead of the connection pool provided by Cloud Foundry, but you want to use the same connection properties defined by Cloud Foundry for the MySQL service - in particular the username, password and JDBC URL. 

The following Spring XML application context snippet shows how you might implement this:

~~~xml
<beans profile="cloud">
  <bean id="c3p0DataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource" destroy-method="close">
    <property name="driverClass" value="com.mysql.jdbc.Driver" />
    <property name="jdbcUrl"
              value="jdbc:mysql://${cloud.services.spring-mysql.connection.host}:${cloud.services.spring-mysql.connection.port}/${cloud.services.spring-mysql.connection.name}" />
    <property name="user" value="${cloud.services.spring-mysql.connection.username}" />
    <property name="password" value="${cloud.services.spring-mysql.connection.password}" />
  </bean>
</beans>
~~~

The following table lists all the application properties that Cloud Foundry exposes to deployed applications. 

| Property               | Description                                                               |
|------------------------|---------------------------------------------------------------------------|
| cloud.application.name | The name provided when the application was pushed to CloudFoundry.        |
| cloud.provider.url     | The URL of the cloud hosting the application, such as `cloudfoundry.com`. |

The service properties that are exposed for each type of service are listed in the [Service-specific Details](#services) section. 

### <a id='profiles'></a>Profiles ###

Spring Framework versions 3.1 and above support bean definition profiles as a way to conditionalize the application configuration so that only specific bean definitions are activated when a certain condition is true. Setting up such profiles makes your application portable to many different environments so that you do not have to manually change the configuration when you deploy it to, for example, your local environment and then to Cloud Foundry. 

See the [Spring Framework documentation](http://static.springsource.org/spring/docs/current/spring-framework-reference/html/new-in-3.1.html#new-in-3.1-bean-definition-profiles) for additional information about using Spring bean definition profiles.

When you deploy a Spring application to Cloud Foundry, Cloud Foundry automatically enables the `cloud` profile.

#### Profiles in Java Configration ####

The `@Profile` annotation can be placed on `@Configuration` classes in a Spring application to set conditions under which configuration classes are invoked. By using the `default` and `cloud` profiles to determine whether the application is running on CloudFoundry or not, your Java configuration can support both local and cloud deployments using Java configuration classes like these: 

~~~java
@Configuration
@Profile("cloud")
public class CloudDataSourceConfig {
    @Bean
    public DataSource dataSource() {
        CloudEnvironment cloudEnvironment = new CloudEnvironment();
        RdbmsServiceInfo serviceInfo = cloudEnvironment.getServiceInfo("my-postgres", RdbmsServiceInfo.class);
        RdbmsServiceCreator serviceCreator = new RdbmsServiceCreator();
        return serviceCreator.createService(serviceInfo);
    }
}
~~~

~~~java
@Configuration
@Profile("default")
public class LocalDataSourceConfig {
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
~~~


#### Profiles in XML Configration ####

In XML configuration files, you group the configuration for a specific environment using the profile attribute of a nested `<beans>` element in the appropriate Spring application context file. You can create your own custom profiles, but the ones that are most relevant in the context of Cloud Foundry are the `default` and `cloud` profiles.

You should group all usages of the `<cloud:>` namespace within the `cloud` profile block to allow the application to run outside of Cloud Foundry environments. You then use the `default` profile (or a custom profile) to group the non-Cloud Foundry configuration that will be used if you deploy your application to a non-Cloud Foundry environment.

~~~xml
<?xml version="1.0" encoding="UTF-8"?>
<beans  xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:cloud="http://schema.cloudfoundry.org/spring"
        xmlns:jdbc="http://www.springframework.org/schema/jdbc"
        xmlns:util="http://www.springframework.org/schema/util"
        xmlns:mongo="http://www.springframework.org/schema/data/mongo"
        xsi:schemaLocation="http://www.springframework.org/schema/data/mongo
          http://www.springframework.org/schema/data/mongo/spring-mongo-1.0.xsd
          http://www.springframework.org/schema/jdbc
          http://www.springframework.org/schema/jdbc/spring-jdbc-3.2.xsd
          http://schema.cloudfoundry.org/spring
          http://schema.cloudfoundry.org/spring/cloudfoundry-spring.xsd
          http://www.springframework.org/schema/beans
          http://www.springframework.org/schema/beans/spring-beans-3.2.xsd
          http://www.springframework.org/schema/util
          http://www.springframework.org/schema/util/spring-util-3.2.xsd">

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
~~~

Note that the `<beans profile="value">` element is nested inside the standard root `<beans>` element. The MongoDB connection factory in the cloud profile uses the `<cloud:>` namespace, the connection factory configuration in the default profile uses the `<mongo:>` namespace. You can now deploy this application to the two different environments without making any manual changes to its configuration when you switch from one to the other.

## <a id='services'></a>Service-specific Details ##

The following sections describe Spring auto-configuration and manual configuration for the services supported by Cloud Foundry. 

### <a id='rdbms'></a>MySQL and Postgres ###

#### Auto-Configuration ####

Auto-configuration occurs if Cloud Foundry detects a `javax.sql.DataSource` bean in the Spring application context. The following snippet of a Spring application context file shows an example of defining this type of bean which Cloud Foundry will detect and potentially auto-configure:

~~~xml
<bean class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close" id="dataSource">
    <property name="driverClassName" value="org.h2.Driver" />
    <property name="url" value="jdbc:h2:mem:" />
    <property name="username" value="sa" />
    <property name="password" value="" />
</bean>
~~~ 

The relational database that Cloud Foundry actually uses depends on the service instance you explicitly bind to your application when you deploy it: MySQL or Postgres. Cloud Foundry creates either a commons DBCP or Tomcat datasource depending on which datasource implementation it finds on the classpath.

Cloud Foundry will internally generate values for the following properties: `driverClassName`, `url`, `username`, `password`, `validationQuery`.

#### Manual Configuration in Java ####

To configure a database service in Java configuration, simply create a `@Configuration` class with a `@Bean` method to return a `javax.sql.DataSource` bean. The bean can be created by helper classes in the `cloudfoundry-runtime` library, as shown here: 

~~~java
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
~~~

#### Manual Configuration in XML ####

The `<cloud:data-source>` element provides an easy way for you to configure a JDBC data source in your Spring application. Later, when you actually deploy the application, you bind a particular MySQL or Postgres service instance to it.

##### Basic Manual Configuration #####

The following snippet of a Spring XML application context file shows a simple way to configure a JDBC data source that will be injected into a `org.springframework.jdbc.core.JdbcTemplate` bean:

~~~xml
<cloud:data-source id="dataSource" />

<bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
  <property name="dataSource" ref="dataSource" />
</bean>
~~~

In the preceding example, note that no specific information about the datasource is supplied, such as the JDBC driver classname, the specific URL to access the database, or the database user. Instead, Cloud Foundry will provide these values at runtime, using appropriate information from the specific type of database service instance you bind to your application.

The following table lists the attributes of the `<cloud:data-source>` element:

| Attribute | Description | Type |
|-----------|-------------|------|
| id | The ID of this data source. The JdbcTemplate bean uses this ID when it references the data source. Default value is the name of the bound service instance. | String |
| service-name | The name of the data source service. You specify this attribute only if you are binding multiple database services to your application and you want to specify which particular service instance binds to a particular Spring bean. The default value is the name of the bound service instance. | String |

With this configuration, Cloud Foundry uses the most common configuration options when it creates the data source at runtime. The next section describes how to override the defaults for these options. 

##### Advanced Manual Configuration #####

You can specify configuration options for a JDBC data source using two child elements of `<cloud:data-source>`: `<cloud:connection>` and `<cloud:pool>`.

The `<cloud:connection>` child element takes a single String attribute (`properties`) that you use to specify connection properties you want to send to the JDBC driver when establishing new database connections. The format of the string must be semi-colon separated name/value pairs (for example, "`property1=value;property2=value`").

The `<cloud:pool>` child element takes the following two attributes:

| Attribute | Description | Type | Default |
|-----------|-------------|------|---------|
| pool-size | Specifies the size of the connection pool. Set the value to either the maximum number of connections in the pool, or a range of the minimum and maximum number of connections separated by a dash. | int | Default minimum is `0`. Default maximum is `8`. These are the same defaults as the Apache Commons Pool. |
| max-wait-time | In the event that there are no available connections, this attribute specifies the maximum number of milliseconds that the connection pool waits for a connection to be returned before throwing an exception. Specify `-1` to indicate that the connection pool should wait forever. | int | Default value is `-1` (forever). |

The following example shows how to use these advanced data source configuration options:

~~~xml
<cloud:data-source id="mydatasource">
  <cloud:connection properties="charset=utf-8" />
  <cloud:pool pool-size="5-10" max-wait-time="2000" />
</cloud:data-source>
~~~

In the preceding example, the JDBC driver is passed the property that specifies that it should use the UTF-8 character set. The minimum and maximum number of connections in the pool at any given time is 5 and 10, respectively. The maximum amount of time that the connection pool waits for a returned connection if there are none available is 2000 milliseconds (2 seconds), after which the JDBC connection pool throws an exception.

### <a id='mongodb'></a>MongoDB ###

#### Auto-Configuration ####

You must use [Spring Data MongoDB](http://www.springsource.org/spring-data/mongodb) 1.0 M4 or later for auto-configuration to work.

Auto-configuration occurs if Cloud Foundry detects a `org.springframework.data.document.mongodb.MongoDbFactory` bean in the Spring application context. The following snippet of a Spring XML application context file shows an example of defining this type of bean which Cloud Foundry will detect and potentially auto-configure:

~~~xml
<mongo:db-factory
    id="mongoDbFactory"
    dbname="pwdtest"
    host="127.0.0.1"
    port="1234"
    username="test_user"
    password="test_pass"  />
~~~ 

Cloud Foundry will create a `SimpleMongoDbFactory` with its own values for the following properties: `host`, `port`, `username`, `password`, `dbname`.

#### Manual Configuration in Java ####

To configure a MongoDB service in Java configuration, simply create a `@Configuration` class with a `@Bean` method to return a `org.springframework.data.mongodb.MongoDbFactory` bean (from Spring Data MongoDB). The bean can be created by helper classes in the `cloudfoundry-runtime` library, as shown here: 

~~~java
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
~~~

#### Manual Configuration in XML ####

The `<cloud:mongo-db-factory>` namespace provides a simple way for you to manually configure a MongoDB connection factory for your Spring application.

##### Basic Manual Configuration #####

The following snippet of a Spring XML appication context file shows a `MongoDbFactory` configuration that will be injected into a `org.springframework.data.mongodb.core.MongoTemplate` bean:

~~~xml
<cloud:mongo-db-factory id="mongoDbFactory" />

<bean id="mongoTemplate" class="org.springframework.data.mongodb.core.MongoTemplate">
    <constructor-arg ref="mongoDbFactory"/>
</bean>
~~~

The following table lists the attributes of the `<cloud:mongo-db-factory>` element.

<table>
<tbody>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Type</th>
  </tr>
  <tr>
    <td>id</td>
    <td>The ID of this MongoDB connection factory.  The MongoTemplate bean uses this ID when it references the connection factory. <br>Default value is the name of the bound service instance.</td>
    <td>String</td>
  </tr>
  <tr>
  <td>service-name</td>
    <td>The name of the MongoDB service. <br>You specify this attribute only if you are binding multiple MongoDB services to your application and you want to specify which particular service instance binds to a particular Spring bean.  The default value is the name of the bound service instance.</td>
    <td>String</td>
  </tr>
  <tr>
    <td>write-concern</td>
    <td>Controls the behavior of writes to the data store.  The values of this attribute correspond to the values of the `com.mongodb.WriteConcern` class.
       <p>If you do not specify this attribute, then no `WriteConcern` is set for the database connections and all writes default to NORMAL.  </p>
       <p>The possible values for this attribute are as follows:</p>
       <ul>
         <li><b>NONE</b>: No exceptions are raised, even for network issues.</li>
         <li><b>NORMAL</b>: Exceptions are raised for network issues, but not server errors.</li>
         <li><b>SAFE</b>: MongoDB service waits on a server before performing a write operation.  Exceptions are raised for both network and server errors.</li>
         <li><b>FSYNC_SAVE</b>: MongoDB service waits for the server to flush the data to disk before performing a write operation.  Exceptions are raised for both network and server errors.</li>
       </ul>
     </td>
     <td>String</td>
   </tr>
</tbody>
</table>

This configuration creates a simple MongoDB connection factory using default values for the options. The following section describes how to override the defaults for these options. 

##### Advanced Manual Configuration #####

The connection factory created by the `<cloud:mong-db-factory>` namespace can be customized by specifying the optional `<cloud:mongo-options>` child element. The following example shows how to use the advanced MongoDB options:

~~~xml
<cloud:mongo-db-factory id="mongoDbFactory" write-concern="FSYNC_SAFE">
  <cloud:mongo-options connections-per-host="12" max-wait-time="2000" />
</cloud:mongo-db-factory>
~~~

In the preceding example, the maximum number of connections is set to 12 and the maximum amount of time that a thread waits for a connection is 1 second. The WriteConcern is also specified to be the safest possible (FSYNC_SAFE).

The `<cloud:mongo-options>` child element takes the following attributes:

| Attribute | Description | Type | Default |
|-----------|-------------|------|---------|
| connections-per-host | Specifies the maximum number of connections allowed per host for the MongoDB instance. Those connections will be kept in a pool when idle. Once the pool is exhausted, any operation requiring a connection will block while waiting for an available connection. | int | 10 | 
| max-wait-time | Specifies the maximum wait time (in milliseconds) that a thread waits for a connection to become available. | int | 120,000 (2 minutes) |

### <a id='redis'></a>Redis ###

#### Auto-Configuration ####

You must be using [Spring Data Redis](http://www.springsource.org/spring-data/redis) 1.0 M4 or later for auto-configuration to work.

Auto-configuration occurs if Cloud Foundry detects a `org.springframework.data.redis.connection.RedisConnectionFactory` bean in the Spring application context. The following snippet of a Spring XML application context file shows an example of defining this type of bean which Cloud Foundry will detect and potentially auto-configure:

~~~xml
<bean id="redis"
      class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory"
      p:hostName="localhost" p:port="6379"  />
~~~

Cloud Foundry will create a `JedisConnectionFactory` with its own values for the following properties: `host`, `port`, `password`. This means that you must package the Jedis JAR in your application. Cloud Foundry does not currently support the JRedis and RJC implementations.

#### Manual Configuration in Java ####

To configure a Redis service in Java configuration, simply create a `@Configuration` class with a `@Bean` method to return a `org.springframework.data.redis.connection.RedisConnectionFactory` bean (from Spring Data Redis). The bean can be created by helper classes in the `cloudfoundry-runtime` library, as shown here: 

~~~java
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
~~~

#### Manual Configuration in XML ####

The `<cloud:redis-connection-factory>` provides a simple way for you to configure a Redis connection factory for a Spring application.

##### Basic Manual Configuration #####

The following snippet of a Spring XML application context file shows a `RedisConnectionFactory` configuration that will be injected into a `org.springframework.data.redis.core.StringRedisTemplate` bean:

~~~xml
<cloud:redis-connection-factory id="redisConnectionFactory" />

<bean id="redisTemplate" class="org.springframework.data.redis.core.StringRedisTemplate">
  <property name="connection-factory" ref="redisConnectionFactory"/>
</bean>
~~~

The following table lists the attributes of the `<cloud:redis-connection-factory>` element:

<table>
<tbody>
<tr>
  <th>Attribute</th>
  <th>Description</th>
  <th>Type</th>
</tr>
<tr>
  <td>id</td>
  <td>The ID of this Redis connection factory.  The RedisTemplate bean uses this ID when it references the connection factory. <br>Default value is the name of the bound service instance.</td>
  <td>String</td>
</tr>
<tr>
  <td>service-name</td>
  <td>The name of the Redis service. <br>You specify this attribute only if you are binding multiple Redis services to your application and you want to specify which particular service instance binds to a particular Spring bean.  The default value is the name of the bound service instance.</td>
  <td>String</td>
</tr>
</tbody> 
</table>

With this configuration, Cloud Foundry uses the most common configuration options when it creates the factory at runtime. The following section describes how to override the defaults for these options.

##### Advanced Manual Configuration #####

The connection factory created by the `<cloud:redis-connection-factory>` namespace can be customized by specifying the optional `<cloud:pool>` child element. 

The following example shows how to use these advanced Redis configuration options:

~~~xml
<cloud:redis-connection-factory id="myRedisConnectionFactory">
  <cloud:pool pool-size="5-10" max-wait-time="2000" />
</cloud:redis-connection-factory>
~~~

In this example, the minimum and maximum number of connections in the pool at any given time is 5 and 10, respectively. The maximum amount of time that the connection pool waits for a returned connection if there are none available is 2000 milliseconds (2 seconds), after which the Redis connection pool throws an exception.

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
  <td>pool-size</td>
  <td>Specifies the size of the connection pool.  Set the value to either the maximum number of connections in the pool, or a range of the minimum and maximum number of connections separated by a dash.</td>
  <td>int</td>
  <td>Default minimum is 0.  Default maximum is 8. These are the same defaults as the Apache Commons Pool.</td>
</tr>
<tr>
  <td>max-wait-time</td>
  <td>In the event that there are no available connections, this attribute specifies the maximum number of milliseconds that the connection pool waits for a connection to be returned before throwing an exception. Specify `-1` to indicate that the connection pool should wait forever. </td>
  <td>int</td>
  <td>Default value is `-1` (forever).</td>
 </tr>
</tbody> 
</table>

### <a id='rabbitmq'></a>RabbitMQ ###

#### Auto-Configuration ####

You must be using [Spring AMQP](http://www.springsource.org/spring-amqp) 1.0 or later for auto-configuration to work. Spring AMQP provides publishing, multi-threaded consumer generation, and message conversion. It also facilitates management of AMQP resources while promoting dependency injection and declarative configuration.

Auto-configuration occurs if Cloud Foundry detects a `org.springframework.amqp.rabbit.connection.ConnectionFactory` bean in the Spring application context. The following snippet of a Spring application context file shows an example of defining this type of bean which Cloud Foundry will detect and potentially auto-configure:

~~~xml
<rabbit:connection-factory
    id="rabbitConnectionFactory"
    host="localhost"
    password="testpwd"
    port="1238"
    username="testuser"
    virtual-host="virthost" />
~~~

Cloud Foundry will create a `org.springframework.amqp.rabbit.connection.CachingConnectionFactory` with its own values for the following properties: `host`, `virtual-host`, `port`, `username`, `password`.

#### Manual Configuration in Java ####

To configure a RabbitMQ service in Java configuration, simply create a `@Configuration` class with a `@Bean` method to return a `org.springframework.amqp.rabbit.connection.ConnectionFactory` bean (from the Spring AMQP library). The bean can be created by helper classes in the `cloudfoundry-runtime` library, as shown here: 

~~~java
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
~~~

#### Manual Configuration in XML ####

The `<cloud:rabbit-connection-factory>` provides a simple way for you to configure a RabbitMQ connection factory for a Spring application.

##### Basic Manual Configuration #####

The following snippet of a Spring XML application context file shows a RabbitConnectionFactory configuration that will be injected into a `rabbitTemplate` bean. The example also uses the `<rabbit:>` namespace to perform RabbitMQ-specific configurations, as explained after the example:

~~~xml
<!-- Obtain a connection to the RabbitMQ via cloudfoundry-runtime: -->
<cloud:rabbit-connection-factory id="rabbitConnectionFactory" />

<!-- Set up the AmqpTemplate/RabbitTemplate: -->
<rabbit:template id="rabbitTemplate"
    connection-factory="rabbitConnectionFactory" />

<!-- Request that queues, exchanges and bindings be automatically declared on the broker: -->
<rabbit:admin connection-factory="rabbitConnectionFactory"/>

<!-- Declare the "messages" queue: -->
<rabbit:queue name="messages" durable="true"/>
~~~

The following table lists the attributes of the `<cloud:rabbit-connection-factory>` element:

<table>
<tbody>
<tr>
  <th>Attribute</th>
  <th>Description</th>
  <th>Type</th>
</tr>
<tr>
  <td>id</td>
  <td>The ID of this RabbitMQ connection factory. The RabbitTemplate bean uses this ID when it references the connection factory. <br>Default value is the name of the bound service instance.</td>
  <td>String</td>
</tr>
<tr>
  <td>service-name</td>
  <td>The name of the RabbitMQ service. <br>You specify this attribute only if you are binding multiple RabbitMQ services to your application and you want to specify which particular service instance binds to a particular Spring bean. The default value is the name of the bound service instance.</td>
  <td>String</td>
</tr>
</tbody>
</table>

This configuration creates a simple RabbitMQ connection factory using default values for the options. The following section describes how to override the defaults for these options. 

##### Advanced Manual Configuration #####

The connection factory created by the `<cloud:rabbit-connection-factory>` namespace can be customized by specifying the optional `<cloud:rabbit-options>` child element. 

The following example shows how to use these advanced RabbitMQ configuration options:

~~~xml
<cloud:rabbit-connection-factory id="rabbitConnectionFactory" >
  <cloud:rabbit-options channel-cache-size="10" />
</cloud:rabbit-connection-factory>
~~~

The `<cloud:rabbit-options>` child element defines one attribute called `channel-cache-size` which you can set to specify the size of the channel cache size. The default value is `1`.  In the preceding example, the channel cache size of the RabbitMQ connection factory is set to 10.

