---
title: Create a Managed Service Instance
---

This page has information about creating a managed service with cf.

## <a id='cf-create-service'></a>Create a Managed Service with cf v5 ##

1. Use this command to create a service instance.
<pre class="terminal">
cf create-service
</pre>
2. Select a service type from the list presented.
<pre class="terminal">
: blazemeter n/a, via blazemeter
2: cleardb n/a, via cleardb
3: cloudamqp n/a, via cloudamqp
4: elephantsql n/a, via elephantsql
5: loadimpact n/a, via loadimpact
6: mongolab n/a, via mongolab
7: newrelic n/a, via newrelic
8: rediscloud n/a, via garantiadata
9: searchify n/a, via searchify
10: searchly n/a, via searchly
11: sendgrid n/a, via sendgrid
12: treasuredata n/a, via treasuredata
13: urbanairship n/a, via urbanairship
14: user-provided , via
What kind?>2
</pre>
3. Enter a name for the service instance.
<pre class="terminal">
Name?> cleardb-5dc45
</pre>
4. Select a service plan.
<pre class="terminal">
	1: amp: For apps with moderate data requirements
	2: boost: Best for light production or staging your applications
	3: shock: Designed for apps where you need real MySQL reliability, power and throughput
	4: spark: Great for getting started and developing your apps
	Which plan?> 2
</pre>

The service instance is created.


## <a id='gcf-create-service'></a>Create a Managed Service with cf v6 ##

The cf v6 command to create a service instance is:

<pre class="terminal">
cf create-service SERVICE PLAN SERVICE_INSTANCE`
</pre>

where:

* `SERVICE` --- is the type of service.
* `PLAN` --- is the service plan.
* `SERVICE_INSTANCE` --- is the name you assign to the service instance.

For example:
<pre class="terminal">
gcf create-service cleardb spark cleardb1
</pre>