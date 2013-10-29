---
title: About the Java Buildpack
---
## <a id='design-doc'></a>Java Buildpack Documentation ##

For information about using, configuring, and extending the Cloud Foundry Java buildpack, see <https://github.com/cloudfoundry/java-buildpack>.

For information about the software installed by the Java buildpack, see the following section.

## <a id='software-versions'></a>Software Installed by the Java Buildpack ##

The table below lists:

* **Name** --- The name of the software installed by the Cloud Foundry Java buildpack, when appropriate.
* **Available Versions** --- The versions of the software that are available from the buildpack.  Note that the available versions may be dependent on the platform that the buildpack is run on.
* **Installed by Default** --- The version of the software that is installed by default. See https://github.com/cloudfoundry/java-buildpack/blob/master/docs/util-repositories.md#version-wildcards for an explanation of the format used to indicate the version in the "Installed by Default" column.

 This page was last updated on 19 September, 2013

| Name | Available Versions | Installed by Default
| ---- | ------------------ | --------------------
| OpenJDK | lucid: [`1.6.0_21 -> 1.8.0_M8`](http://download.pivotal.io.s3.amazonaws.com/openjdk/lucid/x86_64/index.yml)<br>mountainlion: [`1.7.0_04 -> 1.8.0_M8`](http://download.pivotal.io.s3.amazonaws.com/openjdk/mountainlion/x86_64/index.yml)<br>precise: [`1.7.0_01 -> 1.8.0_M8`](http://download.pivotal.io.s3.amazonaws.com/openjdk/precise/x86_64/index.yml) | [`1.7.0_+`](https://github.com/cloudfoundry/java-buildpack/blob/master/config/openjdk.yml)
| Groovy | [`1.5.0 -> 2.1.7`](http://download.pivotal.io.s3.amazonaws.com/groovy/index.yml) | [`2.1.+`](https://github.com/cloudfoundry/java-buildpack/blob/master/config/groovy.yml)
| Spring Boot CLI | [`0.5.0_M2 -> 0.5.0_M4`](http://download.pivotal.io.s3.amazonaws.com/spring-boot-cli/index.yml) | [`0.5.0_+`](https://github.com/cloudfoundry/java-buildpack/blob/master/config/springbootcli.yml)
| Tomcat | [`6.0.0 -> 7.0.42`](http://download.pivotal.io.s3.amazonaws.com/tomcat/index.yml) | [`7.0.+`](https://github.com/cloudfoundry/java-buildpack/blob/master/config/tomcat.yml)
| Auto Reconfiguration | [`0.6.8 -> 0.7.1`](http://download.pivotal.io.s3.amazonaws.com/auto-reconfiguration/index.yml) | [`0.+`](https://github.com/cloudfoundry/java-buildpack/blob/master/config/springautoreconfiguration.yml)
| Play JPA Plugin | [`0.7.1`](http://download.pivotal.io.s3.amazonaws.com/play-jpa-plugin/index.yml) | [`0.+`](https://github.com/cloudfoundry/java-buildpack/blob/master/config/playautoreconfiguration.yml)
| New Relic | [`2.11.0 -> 2.21.4`](http://download.pivotal.io.s3.amazonaws.com/new-relic/index.yml) | [`2.21.+`](https://github.com/cloudfoundry/java-buildpack/blob/master/config/newrelic.yml)
