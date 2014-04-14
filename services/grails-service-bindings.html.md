---
title: Grails - Service Bindings
---
Cloud Foundry provides extensive support for connecting a Grails application to services such as MySQL, Postgres, MongoDB, Redis, and RabbitMQ. In many cases, a Grails application running on Cloud Foundry can automatically detect and configure connections to services. For more advanced cases, you can control service connection parameters yourself.

## <a id="auto"></a>Auto-Configuration ##
Grails provides plugins for accessing SQL (using [Hibernate](http://grails.org/plugin/hibernate)), [MongoDB](http://www.grails.org/plugin/mongodb), and [Redis](http://grails.org/plugin/redis) services. If you install any of these plugins and configure them in your `Config.groovy` or `DataSource.groovy` file, the Cloud Foundry Grails plugin will re-configure the plugins when the app starts to provide the connection information to the plugins.

If you were using all three types of services, your configuration might look like this:

```groovy
environments {
  production {
    dataSource {
      url = 'jdbc:mysql://localhost/db?useUnicode=true&characterEncoding=utf8'
      dialect = org.hibernate.dialect.MySQLInnoDBDialect
      driverClassName = 'com.mysql.jdbc.Driver'
      username = 'user'
      password = "password"
    }
    grails {
      mongo {
        host = 'localhost'
        port = 27107
        databaseName = "foo"
        username = 'user'
        password = 'password'
      }
      redis {
        host = 'localhost'
        port = 6379
        password = 'password'
        timeout = 2000
      }
    }
  }
}
```

The `url`, `host`, `port`, `databaseName`, `username`, and `password` fields in this configuration will be overriden by the Cloud Foundry auto-reconfiguration if it detects that the application is running in a Cloud Foundry environment. If you want to test the application locally against your own services, you can put real values in these fields. If the application will only be run against Cloud Foundry services, you can put placeholder values as shown here, but the fields must exist in the configuration.

## <a id="manual"></a>Manual Configuration ##
If you do not want to use the Cloud Foundry auto-reconfiguration, you can choose to configure the Cloud Foundry service connections manually.

The best way to do the manual configuration is to use the `spring-cloud` library to get the details of the Cloud Foundry environment the application is running in. To use this library, add it to the `dependencies` section in your `BuildConfig.groovy` file.

```groovy
  repositories {
    grailsHome()
    mavenCentral()
    grailsCentral()
    mavenRepo "http://repo.spring.io/milestone"
  }

  dependencies {
    compile "org.springframework.cloud:cloudfoundry-connector:0.9.5"
    compile "org.springframework.cloud:spring-service-connector:0.9.5"
  }
```

Then you can use the `spring-cloud` API in your `DataSources.groovy` file to set the connection parameters. If you were using all three types of database services as in the auto-configuration example, and the services were named "myapp-mysql", "myapp-mongodb", and "myapp-redis", your `DataSources.groovy` file might look like the one below.

```groovy
import org.springframework.cloud.CloudFactory

def cloud

try {
  cloud = new CloudFactory().cloud
} catch(e) {}

environments {
  production {
    dataSource {
      pooled = true
      dbCreate = 'update'
      driverClassName = 'com.mysql.jdbc.Driver'

      if (cloud) {
        def dbInfo = cloud.getServiceInfo('myapp-mysql')
        url = dbInfo.jdbcUrl
        username = dbInfo.userName
        password = dbInfo.password
      } else {
        url = 'jdbc:mysql://localhost:5432/myapp'
        username = 'sa'
        password = ''
      }
    }

    grails {
      mongo {
        if (cloud) {
          def mongoInfo = cloud.getServiceInfo('myapp-mongodb')
          host = mongoInfo.host
          port = mongoInfo.port
          databaseName = mongoInfo.database
          username = mongoInfo.userName
          password = mongoInfo.password
        } else {
          host = 'localhost'
          port = 27107
          databaseName = 'foo'
          username = 'user'
          password = 'password'
        }
      }
      redis {
        if (cloud) {
          def redisInfo = cloud.getServiceInfo('myapp-redis')
          host = redisInfo.host
          port = redisInfo.port
          password = redisInfo.password
        } else {
          host = 'localhost'
          port = 6379
          password = 'password'
        }
      }
    }
  }
}
```
