---
title: Create a Managed Service Instance
---

This page has information about creating a managed service with cf.

## <a id='cf-create-service'></a>Create a Managed Service with cf v5 ##

1. Use this cf v5 command to create a service instance:
<pre class="terminal">
cf create-service
</pre>
The service types available to applications in your Cloud Foundry instance are listed, and you are prompted to select a service type.
1. After selecting a service type, enter a name for the new service instance at the prompt.
1. Depending on your environment, you may be prompted to select additional service options, for example, a service plan.

## <a id='gcf-create-service'></a>Create a Managed Service with cf v6 ##

The cf v6 command to create a service instance is:

<pre class="terminal">
gcf create-service SERVICE PLAN SERVICE_INSTANCE
</pre>

where:

* `SERVICE` --- is the type of service.
* `PLAN` --- is the service plan.
* `SERVICE_INSTANCE` --- is the name you assign to the service instance.

For example:
<pre class="terminal">
gcf create-service rabbitmq cloudamqp rabbitmq1
</pre>