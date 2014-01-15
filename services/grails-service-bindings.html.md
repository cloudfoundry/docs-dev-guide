---
title: Configure Service Connections for Grails
---
_This page assumes that you are using cf v5._

# Introduction #
This guide is for developers who wish to bind a service to a Grails application deployed and running on Cloud Foundry.

Cloud Foundry provides extensive support for connecting a Grails application to services such as MySQL, Postgres, MongoDB, Redis, and RabbitMQ. You can configure these connections manually, but in many cases the Cloud Foundry Grails plugin can detect and configure connections to services automatically.

## <a id="cf-library"></a>The cloudfoundry-runtime Library ##

The `cloudfoundry-runtime` Java library provides methods for obtaining pre-configured clients and connection properties from Cloud Foundry services. To use `cloudfoundry-runtime`, add it to the `dependencies` section in your `BuildConfig.groovy` file. Note: The version of this library must be at least `0.8.4` for Cloud Foundry v2 support.

You will also need to add the Spring Framework Milestone repository to the `repositories` section of the `BuildConfig.groovy` file.

~~~
  repositories {
    grailsHome()
    mavenCentral()
    grailsCentral()
    mavenRepo "http://maven.springframework.org/milestone/"
  }

  dependencies {
    compile "org.cloudfoundry:cloudfoundry-runtime:0.8.4"
  }
~~~

Once your `BuildConfig.groovy` file has been modified, you can either manually set the connection parameters to your services, or enable auto-configuration of the connection settings by adding the Cloud Foundry Grails plugin.

## <a id="manual"></a>Manually Set Connection Parameters ##

After adding the `cloudfoundry-runtime` Java library to `BuildConfig.groovy`, you can use the cloudfoundry-runtime API in your `DataSources.groovy` to manually set the connection parameters to your services.

To manually set connection parameters:

* Add the [cloudfoundry-runtime Java library](#cf-library) to BuildConfig.groovy.
* Modify DataSources.groovy:
  * Add `import org.cloudfoundry.runtime.env.CloudEnvironment`.
  * Create a new instance of the general `CloudEnvironment` class.
  * Read the connection parameters for your services from this `CloudEnvironment` object.

Example: If your application needs to use MySQL, MongoDB, and Redis, with the services named "myapp-mysql", "myapp-mongodb", and "myapp-redis", your `DataSources.groovy` file might look like this:

~~~
  import org.cloudfoundry.runtime.env.CloudEnvironment
  import org.cloudfoundry.runtime.env.RdbmsServiceInfo
  import org.cloudfoundry.runtime.env.RedisServiceInfo
  import org.cloudfoundry.runtime.env.MongoServiceInfo

  def cloudEnv = new CloudEnvironment()

  environments {
    production {
      dataSource {
        pooled = true
        dbCreate = 'update'
        driverClassName = 'com.mysql.jdbc.Driver'

        if (cloudEnv.isCloudFoundry()) {
          def dbInfo = cloudEnv.getServiceInfo('myapp-mysql', RdbmsServiceInfo.class)
          url = dbInfo.url
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
          if (cloudEnv.isCloudFoundry()) {
            def mongoInfo = cloudEnv.getServiceInfo('myapp-mongodb', MongoServiceInfo.class)
            host = mongoInfo.host
            port = mongoInfo.port
            databaseName = mongoInfo.database
            username = mongoInfo.userName
            password = mongoInfo.password
          } else {
            host = 'localhost'
            port = 27107
            databaseName = 'local-db-name'
            username = 'user'
            password = 'password'
          }
        }

        redis {
          if (cloudEnv.isCloudFoundry()) {
            def redisInfo = cloudEnv.getServiceInfo('myapp-redis', RedisServiceInfo.class)
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
~~~

## <a id="auto"></a>Enable Auto-Configuration ##

Grails provides plugins for accessing SQL (using [Hibernate](http://grails.org/plugin/hibernate)), [MongoDB](http://www.grails.org/plugin/mongodb), and [Redis](http://grails.org/plugin/redis) services. If you install any of these plugins and configure them in your `Config.groovy` or `DataSource.groovy` file, the Cloud Foundry Grails plugin will re-configure the plugins when your application starts to provide the correct connection information to the plugins.

To enable auto-configuration of service connections, modify your `BuildConfig.groovy` file:

* Add the [cloudfoundry-runtime Java library](#cf-library).
* Add the `cloud-foundry` plugin to the `plugins` section.

~~~
  repositories {
    grailsHome()
    mavenCentral()
    grailsCentral()
    mavenRepo "http://maven.springframework.org/milestone/"
  }

  dependencies {
    compile "org.cloudfoundry:cloudfoundry-runtime:0.8.4"
  }

  plugins {
    compile ':cloud-foundry:1.2.3'
  }
~~~

Once the `BuildConfig.groovy` file has been modified, the following fields in the `DataSources.groovy` or `Config.groovy` file will be automatically modified by the Cloud Foundry Grails plugin if the plugin detects the application is running in a Cloud Foundry environment:

* url
* host
* port
* databaseName
* username
* password

These fields must exist in the `DataSources.groovy` or `Config.groovy` file. You can use placeholder values in the fields if the application will only be run against Cloud Foundry services. To allow testing of the application locally against your own services, you can use actual values.

Example: If your application needs to use MySQL, MongoDB, and Redis, your `DataSources.groovy` file might look like this:

~~~
  environments {
    production {
      dataSource {
        url = 'jdbc:mysql://localhost/db?useUnicode=true&characterEncoding=utf8'
        dialect = org.hibernate.dialect.MySQLInnoDBDialect
        driverClassName = 'com.mysql.jdbc.Driver'
        username = 'user'
        password = 'password'
      }

      grails {
        mongo {
          host = 'localhost'
          port = 27107
          databaseName = 'foo'
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
~~~