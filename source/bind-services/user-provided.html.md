---
title: User Provided Service Instances
---

User-provided service instances are service instances which have been provisioned outside of Cloud Foundry. For example, a DBA may provide a developer with credentials to an Oracle database managed outside of, and unknown to Cloud Foundry. Rather than hard coding credentials for these instances into your applications, you can create a mock service instance in Cloud Foundry to represent an external resource using the familiar `create-service` command, and provide whatever credentials your application requires. Once created, user-provided service instances behave just like other service instances.

When creating a user-provided instance, Cloud Foundry will ask you to provide a name for the service instance and the parameters for your credentials. Credential parameters are a comma-delimated list. You'll then be prompted to enter a value for each parameter. 

<pre class="terminal">
$ cf create-service user-provided
Name?> mydb

What credential parameters should applications use to connect to this service instance?
(e.g. hostname, port, password)> hostname, port, username, password, name     

hostname> db.example.com

port> 1234

username> dbuser

password> dbpasswd

name> mydb

Creating service mydb... OK
</pre>

<pre class="terminal">
$ cf services
Getting services in test... OK

name               service         provider     version   plan        bound apps     
cleardb-28472      cleardb         cleardb      n/a       spark       none           
blazemeter-78fb4   blazemeter      blazemeter   n/a       free-tier   none           
mydb               user-provided   n/a          n/a       n/a         none
</pre> 

After [binding](managing-services#bind) a user-provided service instance and restarting your app, you'll find that the [VCAP_SERVICES](../deploying-apps/environment-variable.html) will be updated with your credentials.

~~~
{
  user-provided: [
    {
      name: "mydb",
      label: "user-provided",
      tags: [ ],
      credentials: {
        hostname: "db.example.com",
        port: "1234",
        username: "dbuser",
        password: "dbpasswd",
        name: "mydb"
      }
    }
  ]
}
~~~

User-provided instances can be created and bound during your app push and saved in a manifest. If you do save a manifest with a user-provided instance, an instance will be created and bound to your app next time you push the app to a space; if a user-provided instance already exists in the space with the same name it will be bound to your app.

<pre class="terminal">
$ cf push spring-music --path build/libs/spring-music.war

...skipping ahead...

Create services for application?> y

1: blazemeter n/a, via blazemeter
2: cleardb n/a, via cleardb
3: cloudamqp n/a, via cloudamqp
4: elephantsql n/a, via elephantsql
5: mongolab n/a, via mongolab
6: newrelic n/a, via newrelic
7: rediscloud n/a, via garantiadata
8: sendgrid n/a, via sendgrid
9: treasuredata n/a, via treasuredata
10: user-provided , via 
What kind?> 10

Name?> user-provided-b702e

What credential parameters should applications use to connect to this service instance?
(e.g. hostname, port, password)> uri

uri> postgres://dbuser:dbpass@db.example.com:1234/dbname

Creating service user-provided-b702e... OK
Binding user-provided-b702e to spring-music... OK
Create another service?> n

Bind other services to application?> n

Save configuration?> y

Saving to manifest.yml... OK

...skipping ahead...

Push successful! App 'spring-music' available at http://spring-music.cfapps.io
</pre>

<pre class="terminal">
$ cat manifest.yml
---
applications:
- name: spring-music
  memory: 512M
  instances: 1
  host: spring-music
  domain: cfapps.io
  path: build/libs/spring-music.war
  services:
    user-provided-b702e:
      label: user-provided
      credentials:
        uri: postgres://dbuser:dbpass@db.example.com:1234/dbname

</pre>

