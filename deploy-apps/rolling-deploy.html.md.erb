---
title: Configuring app deployments
owner: CAPI
---

This page describes how to use the Cloud Foundry Command Line Interface (cf CLI) or API (CAPI) to push apps to <%= vars.app_runtime_first %> using rolling deployment or canary deployment strategies, which update apps safely and avoid downtime.

For information about the older method for avoiding app downtime while pushing app updates,
see [Using blue-green deployment to reduce downtime and risk](./blue-green.html).

For more information about CAPI, see the
[Cloud Foundry API (CAPI) documentation](https://v3-apidocs.cloudfoundry.org/).


## <a id="prerequisites"></a> Prerequisites

The procedures in this topic require one of the following:

* **cf CLI v7 or later**

* **CAPI V3:** If you use CAPI V3 API, you must install the cf CLI.

Or for canary deployments:

* **cf CLI v8.8.0 or later**

* **CAPI V3.173.0 or later**

## <a id="how-deployment-strategies-work"></a> How Deployment Strategies Work

Cloud Foundry provides two different strategies for deployments:

* A **Rolling** deployment brings up one or more web processes for the new app version, with the number set by `max-in-flight`, which defaults to 1. After those instances report as healthy and routable, it brings down the same number of instances of the old version. The deployment repeats this process to replace all web process instances, and then updates all old non-web processes.
* A **Canary** deployment brings up one or more web processes for the new app version, defaulting to one. It then pauses to let app operators or developers evaluate the health of a new version instances. App operators can then choose to either `cancel` or `continue` the deployment. When the deployment is continued, the canary deployment proceeds in the same way as a rolling deployment.
  * To gradually increase instance counts and check app health in multiple steps, the latest cf CLI v8 supports an `--instance-steps` option that sets a series of increasing instance counts.

Each rolling or canary deployment increments the `revision` count for the new app deployment, as listed by the `cf revisions` command described in [App Revisions Overview](../revisions.html).

The following sections describe the rolling and canary deployment strategies and their limitations.

### <a id="rolling"></a> Rolling Deployments

This section describes pushing an app with the rolling deployment strategy.

1. The `cf push APP-NAME --strategy rolling` command:
    1. Stages the updated app package.
    2. Creates a droplet with the updated app package.
    3. Creates a deployment with the new droplet and any new configuration.
        * This starts up to `max_in_flight` processes that shares the route with the old process.
        * If you run `cf app` on your app at this point, you see multiple `web` processes.
        <br>
        For more information about the deployment object, see the [Deployments](http://v3-apidocs.cloudfoundry.org/index.html#deployments) section of the CAPI V3 documentation.

2. After the command creates the deployment, the `cc_deployment_updater` BOSH job runs in the
background, updating deployments as follows:
    1. Adds up to `max_in_flight` instances of the new web process and removes instances from the old web process. This step repeats until the new web process reaches the required number of instances.
        <p class="note important">
        This happens only if all instances of the new web process are running.</p>
    2. Removes the old web process. The new web process now fully replaces the old web process.
    3. Restarts all non-web processes of the app.
    4. Sets the deployment to `DEPLOYED`.

### <a id="canary"></a> Canary Deployments

This section describes pushing an app with the default canary deployment strategy, without specifying specific step weights as described in [Canary Deployments with Step Weights](#canary-step).

1. The `cf push APP-NAME --strategy canary` command:
    1. Stages the updated app package.
    2. Creates a droplet with the updated app package.
    3. Creates a deployment with the new droplet and any new configuration.
    <br>
    For more information about the deployment object, see the [Deployments](http://v3-apidocs.cloudfoundry.org/index.html#deployments) section of the CAPI V3 documentation.

2. After the command creates the deployment, the `cc_deployment_updater` BOSH job runs in the
background, updating deployments as follows:
    1. Adds one instance of the new web process (the `canary` instance).
        * This process shares routes with the old process.
        * If you run `cf app` on your app at this point, you see multiple `web` processes.
    2. Sets the deployment to `PAUSED`.

1. After validating that the canary instance is running as expected, execute the command `cf continue-deployment APP-NAME`:
    * Changes the deployment reason to `DEPLOYING` and resumes following the same process as a rolling deployment.

2. After the command changes the status of the deployment, the `cc_deployment_updater` BOSH job runs in the
background, updating deployments as follows:
    1. Adds MaxInFlight number of instances (**by default it is 1**) of the new web process and removes MaxInFlight number of instance from the old web process. This step repeats until the new web process reaches the required number of instances.
        <p class="note important">
        This happens only if all instances of the new web process are running.</p>
    2. Removes the old web process. The new web process now fully replaces the old web process.
    3. Restarts all non-web processes of the app.
    4. Sets the deployment to `DEPLOYED`.

### <a id="canary-step"></a> Canary Deployments with Step Weights

By default, as described in [Canary Deployments](#canary), when you push an app with the canary deployment strategy, the process pauses after it deploys one canary instance, and you manually continue as described in [Continue a canary deployment](#continue) to update the remaining instances to the full-scale deployment.

To run a canary deployment more gradually, you can pass a series of step weights to the `--instance-steps` option of `cf push`.

  - The series specifies increasing numbers of canary instances to deploy. 
    - The deployment will pause after each step, allowing you to manually [continue](#continue) the deployment and proceed to the next step, or [cancel](#cancel) the deployment.
    - Each value represents a **percentage** or **weight** of the web process's instances of the web process to be rolled out as canary instances.
  - Separate step weights with commas and without spaces, for example `5,10,20`.
  - For each canary instance created after the first, a pre-deployment instance is torn down.
  - Canary deployments use one extra instance than is normally allocated throughout the deployment process, until the target number of instances has been reached.
  - Continuing after the last canary step proceeds to the full-scale deployment.
  - As with the default canary deployment process, a rolling deployment strategy updates instances to the new instance count at each step.

For example, to update gradually in four steps, running 5, 10, and 20 percent of an app's instances as canary instances before replacing all running instances of an app:

  ```
  cf push APP-NAME --strategy canary --instance-steps 5,10,20
  ```

#### <a id="canary-step-detail"></a> Detailed Example

Steps are configured as a percentage of instances rather than as an explicit instance value. This allows the deployment definition to be independent of the number of instances used by a process.

**Cloud Controller matches a step weight to the nearest non-zero instance number, rounding down.**

For example, take an application with 10 instances and the following step configuration:

```
cf push APP-NAME --strategy canary --instance-steps 1,20,45,80,100
```

This results in the following deployment plan:

<table class="table">
  <thead><tr>
    <th>Step</th>
    <th>Step Weight</th>
    <th>Original Instances</th>
    <th>Canary Instances</th>
    <th>Actual Weighting</th>
  </tr></thead>
  <tr>
    <td>Pre-deploy</td>
    <td>n/a</td>
    <td>10</td>
    <td>0</td>
    <td>0</td>
  </tr>
  <tr>
    <td>1</td>
    <td>1%</td>
    <td>10</td>
    <td>1</td>
    <td>9%</td>
  </tr>
  <tr>
    <td>2</td>
    <td>20%</td>
    <td>9</td>
    <td>2</td>
    <td>18%</td>
  </tr>
   <tr>
    <td>3</td>
    <td>45%</td>
    <td>6</td>
    <td>5</td>
    <td>45%</td>
  </tr>
  <tr>
    <td>4</td>
    <td>80%</td>
    <td>3</td>
    <td>8</td>
    <td>72%</td>
  </tr>
  <tr>
    <td>5</td>
    <td>100%</td>
    <td>0</td>
    <td>10</td>
    <td>100%</td>
  </tr>
  <tr>
    <td>Post-deploy</td>
    <td>n/a</td>
    <td>0</td>
    <td>10</td>
    <td>100%</td>
  </tr>
</table>

A **Step Weight** of `100` allows app operators to use the `cancel-deployment` command even after all instances have been replaced.

### <a id="canary-testing"></a> Testing Canary Deployments 

To test an in-progress canary deployment, you can route HTTP requests to the canary process, or to an individual canary instance using the [`X-Cf-Process-Instance` header](https://docs.cloudfoundry.org/concepts/http-routing.html#-http-headers-for-process-instance-routing). 

Alternatively, you can use [session affinity](https://docs.cloudfoundry.org/concepts/http-routing.html#sessions) force a particular client to persistently make requests to a canary instance.  

### <a id="limitations"></a> Limitations

The following table describes the limitations when using these deployments.

<table class="table">
  <thead><tr>
    <th>Limitation</th>
    <th>Description</th>
  </tr></thead>
  <tr>
    <td>Multiple app versions</td>
    <td>During a deployment, <%= vars.app_runtime_abbr %> serves both the old and new version of your app at the
    same route. This can lead to user issues if you push API changes that are not backwards-compatible.</td>
  </tr>
  <tr>
    <td>Database migrations</td>
    <td>Deployments do not handle database migrations. Migrating an app database when the existing
    app is not compatible with the migration can result in downtime.</td>
  </tr>
  <tr>
    <td>Non-web processes</td>
    <td>Deployments only run web processes through the update sequence described
    earlier. The commands restart worker and other non-web processes in bulk after updating all web
    processes.<br><br>
		The CAPI V3 API introduces the concept of processes as runnable units of an app. Each app has a
    web process by default. You can specify additional processes with a Procfile, and in some cases
    buildpacks create additional processes. For more information about processes, see
    <a href="http://v3-apidocs.cloudfoundry.org/index.html#processes">Processes</a> in the CAPI V3
    documentation.</td>
  </tr>
  <tr>
    <td>Quotas</td>
    <td>Pushing updates to your app using a deployment strategy creates up to <code>max_in_flight</code> new instances (defaults to 1).
    Additionally, canary deployments use an extra instance when pausing with the canary instance deployed.
    If you lack sufficient quota, the deployment fails. Administrators might need to increase quotas to accommodate deployments.</td>
  </tr>
  <tr>
    <td>Simultaneous apps when interrupting a push</td>
    <td>If you push an app before your previous push command for the same app has completed, your
    first push gets interrupted. Until the last deployment completes, there might be many versions
    of the app running at the same time. Eventually, the app runs the code from your most recent
    push.</td>
  </tr>
  <tr>
    <td>V3 APIs</td>
    <td>During a rolling deploy for an app, requests to the V3 APIs for scaling or updating a process fail with an error message
    like <code>Cannot scale this process while a deployment is in flight</code>. For more information, see <a href="https://v3-apidocs.cloudfoundry.org/version/3.109.0/index.html#scale-a-process">Scale a process</a>
    or <a href="https://v3-apidocs.cloudfoundry.org/version/3.109.0/index.html#update-a-process">Update a process</a> in the CAPI V3 documentation.</td>
  </tr>
  <tr>
    <td>New or stopped applications</td>
    <td>
      When pushing an application for the first time, or if the app is stopped, no deployment strategy is used and all application instances are started immediately.
    </td>
  </tr>
  <tr>
    <td>Evaluating the canary instance option 1</td>
    <td>
      Because the current processes share the same route, the best way to validate that traffic is reaching the canary instance is by looking at the logs.
      If app revision logging is enabled, the logs for all instances will be tagged with <code>process_id</code> and <code>revision_version</code> values. e.g. <code>APP/REV/4/PROC/WEB/1</code>
      <br>
      <br>
      Retrieve the logs by running the cf CLI command <code>cf logs APP_NAME</code>.
    </td>
  </tr>
  <tr>
    <td>Evaluating the canary instance option 2</td>
    <td>
      This method only works with routing-release 0.332.0 or higher.
      <br>
      <br>
      Get the canary process guid via <code>cf curl /v3/deployments?status_values=ACTIVE&app_guid=$(cf app APP_NAME --guid)</code>.
      Add the <code>X-CF-PROCESS-INSTANCE:<CANARY_PROCESS_GUID></code> header to traffic
      to the app. Optionally, to send traffic to one specific canary instance,
      add an index:
      <code>X-CF-PROCESS-INSTANCE:<CANARY_PROCESS_GUID>:<CANARY_INDEX></code>.
    </td>
  </tr>
</table>


## <a id="commands"></a> Commands

This section describes the commands for working with rolling app deployments.

### <a id="deploy"></a> Deploy an app

To deploy an app without incurring downtime:

#### For cf CLI v7+

Run:

```
cf push APP-NAME --strategy rolling
```

Where `APP-NAME` is the name that you want to give your app.

<p class="note caution">
Review the limitations of this feature before running the command. For more information, see
<a href="#limitations">Limitations</a>.</p>

<p class="note">
cf CLI v7 exits when one instance of each process is healthy.
It also includes a <code>--no-wait</code> flag for users who don't want to wait
for the operation to complete.
When <code>cf push</code> is used with the <code>--no-wait</code> flag, the process exits as soon as one instance is healthy.
</p>

If the deployment stops and doesn't restart, cancel it and run it again as described in an earlier step.
To cancel, see [Cancel a deployment](#cancel).


#### For cf CLI v8.8.0+ and CAPI V3.173.0 or later

Run:

```
cf push APP-NAME --strategy STRATEGY --max-in-flight MAX_IN_FLIGHT
```

Where:
<ul>
  <li><code>APP-NAME</code> is the name that you want to give your app.</li>
  <li><code>MAX_IN_FLIGHT</code> specifies the maximum number of new instances to start up simultaneously until the deployment is complete. This parameter is optional and defaults to 1.</li>
  <li><code>STRATEGY</code> is the strategy you want to use for the deployment. Valid strategies are <code>rolling</code> and <code>canary</code>.</li>
</ul>

#### For CAPI V3

1. Log in to the cf CLI.

    ```
    cf login
    ```

2. Create an empty app by running the following `curl` command  with `POST /v3/apps`. <br>Record the
app GUID from the output.

    ```
    cf curl /v3/apps \
      -X POST \
      -H "Content-type: application/json" \
      -d '{
        "name": "APP-NAME",
        "relationships": {
          "space": {
            "data": {
              "guid": "SPACE-GUID"
            }
          }
        }
      }'
    ```

    Where:

    <ul>
      <li><code>APP-NAME</code> is the name that you want to give your app.</li>
      <li><code>SPACE-GUID</code> is the space identifier that you want to associate with your app.</li>
    </ul>

1. Create a package with the following `curl` command with `POST /v3/packages`. Record the package
GUID from the output.

    ```
    cf curl /v3/packages \
      -X POST \
      -H "Content-type: application/json" \
      -d '{
        "type": "bits",
        "relationships": {
          "app": {
            "data": {
              "guid": "APP-GUID"
            }
          }
        }
      }'
    ```

    Where `APP-GUID` is the app GUID that you recorded in an earlier step. This app GUID is a
    unique identifier for your app.

1. Upload the package bits by running the following `curl` command with
`POST /v3/packages/PACKAGE-GUID/upload`.

    ```
    cf curl /v3/packages/PACKAGE-GUID/upload \
    -X POST \
    -F bits=@"PACKAGED-APP" \
    ```

    Where:

    <ul>
      <li><code>PACKAGE-GUID</code> is the package GUID that you recorded in an earlier step.</li>
      <li><code>PACKAGED-APP</code> is your app packaged in a file such as <code>.zip</code>.</li>
    </ul>

1. Create the build by running the following `curl` command with `POST /v3/builds`. Record the
droplet GUID from the output.

    ```
    cf curl /v3/builds \
      -X POST \
      -H "Content-type: application/json" \
      -d '{
        "package": {
          "guid": PACKAGE-GUID"
        }
      }'
    ```

    Where `PACKAGE-GUID` is the package GUID that you recorded in an earlier step.

1. Deploy your app by running the following `curl` command with `POST /v3/deployments`. To verify
the status of the deployment or take action on the deployment, record the deployment GUID from the
output.

    ```
    cf curl /v3/deployments \
    -X POST \
    -H "Content-type: application/json" \
    -d '{
      "droplet": {
        "guid": "DROPLET-GUID"
      },
      "strategy": STRATEGY,
      "options": {
        "max_in_flight": MAX_IN_FLIGHT
      },
      "relationships": {
        "app": {
          "data": {
            "guid": "APP-GUID"
          }
        }
      }
    }'
    ```

    Where:

    <ul>
      <li><code>DROPLET-GUID</code> and <code>APP-GUID</code> are the GUIDs that you recorded in earlier steps.</li>
      <li><code>MAX_IN_FLIGHT</code> is an integer that specifies the maximum number of new instances to start up simultaneously until the deployment is complete. Optional and defaults to 1.</li>
      <li><code>STRATEGY</code> is the strategy you would like to use for the deployment. Valid strategies are <code>rolling</code> and <code>canary</code>.</li>
    </ul>

For more information about this command, see [How Deployment Strategies Work](#how-deployment-strategies-work).

### <a id="cancel"></a> Cancel a deployment

To stop the deployment of an app that you pushed:

* **For cf CLI v7+, run:**

    ```
    cf cancel-deployment APP-NAME
    ```

    Where `APP-NAME` is the name of the app.

* **For CAPI V3, run:**

    ```
    cf curl /v3/deployments/DEPLOYMENT-GUID/actions/cancel" -X POST
    ```

    Where `DEPLOYMENT-GUID` is the GUID of the deployment that you recorded after following the
    CAPI procedure in [Deploy an app](#deploy).

This reverts the app to its state from before the deployment started by:

* Scaling up the original web process
* Removing any deployment artifacts
* Resetting the `current_droplet` on the app

<p class="note important">
The cancel command is designed to revert the app to its
original state as quickly as possible and does not guarantee zero downtime.
<br>It is important to note that changes
to environment variables and service bindings are not reverted.</p>

### <a id="continue"></a> Continue a canary deployment

To finish a canary deployment after the deployment has paused and the canary instance has been validated:

* **For cf CLI v8+, run:**

    ```
    cf continue-deployment APP-NAME
    ```
    Where `APP-NAME` is the name of the app.

* **For CAPI V3, run:**

    ```
    cf curl /v3/deployments/DEPLOYMENT-GUID/actions/continue" -X POST
    ```
    Where `DEPLOYMENT-GUID` is the GUID of the deployment that you recorded after following the
    CAPI procedure in [Deploy an app](#deploy).

This continues the deployment of the app, following the same process as a rolling deployment.

### <a id="restart"></a> Restart an app

Restart your app to apply configuration updates that require a restart, such as environment variables or service bindings.

To restart your app without downtime, run the appropriate command as shown here.

* **For cf CLI v7+, run:**

    ```
    cf restart APP-NAME --strategy STRATEGY
    ```

    Where:
    <ul>
      <li><code>APP-NAME</code> is the name of the app.</li>
      <li><code>STRATEGY</code> is the strategy you would like to use for the deployment. Valid strategies are <code>rolling</code> and <code>canary</code>.</li>
    </ul>

* **For cf CLI v8.8.0+ and CAPI V3.173.0 or later, run:**

    ```
    cf restart APP-NAME --strategy STRATEGY --max-in-flight MAX_IN_FLIGHT
    ```

    Where:
    <ul>
      <li><code>APP-NAME</code> is the name of the app.</li>
      <li><code>MAX_IN_FLIGHT</code> specifies the maximum number of new instances to restart simultaneous until the deployment is complete. Optional and defaults to 1.</li>
      <li><code>STRATEGY</code> is the strategy you would like to use for the deployment. Valid strategies are <code>rolling</code> and <code>canary</code>.</li>
    </ul>

* **For CAPI V3, run:**

    ```
    cf curl /v3/deployments \
    -X POST \
    -H "Content-type: application/json" \
    -d '{
      "droplet": {
        "guid": DROPLET-GUID
      },
      "strategy": STRATEGY,
      "options": {
        "max_in_flight": MAX_IN_FLIGHT
      },
      "relationships": {
        "app": {
          "data": {
            "guid": APP-GUID
          }
        }
      }
    }'
    ```

    Where:
      <ul>
        <li><code>DROPLET-GUID</code> and <code>APP-GUID</code> are the GUIDs that you recorded in earlier steps.</li>
        <li><code>MAX_IN_FLIGH</code> is an integer that specifies the maximum number of new instances to start up simultaneous until the deployment is complete. Optional and defaults to 1.</li>
        <li><code>STRATEGY</code> is the strategy you would like to use for the deployment. Valid strategies are <code>rolling</code> and <code>canary</code>.</li>
      </ul>


## <a id="status"></a> View the status of deployments

You can use CAPI to view the status of deployments.

To view the status of a deployment:

1. Log in to the cf CLI:

    ```
    cf login
    ```

1. Find the GUID of your app by running:

    ```
    cf app APP-NAME --guid
    ```

    Where `APP-NAME` is the name of the app.

1. Find the deployment for that app by running:

    ```
    cf curl GET /v3/deployments?app_guids=APP-GUID&status_values=ACTIVE
    ```
    Where `APP-GUID` is the GUID of the app. Deployments are listed in chronological order, with
    the latest deployment displayed as the last in the list.

1. Run:

    ```
    cf curl GET /v3/deployments/DEPLOYMENT-GUID
    ```
    Where `DEPLOYMENT-GUID` is the GUID of the deployment.

The `cf curl GET /v3/deployments/DEPLOYMENT-GUID` command returns the following status properties:

* `status.value`: Indicates if the deployment is `ACTIVE` or `FINALIZED`.

* `status.reason`: Provides detail about the deployment status.

* `status.details`: Provides the timestamp for the most recent successful health check.
  The value of the `status.details` property can be `nil` with no successful health check
  for the deployment. For example, there might be no successful health check if the deployment was
  cancelled.

The following table describes the possible values for the `status.value` and `status.reason`
properties:

<table class="table">
  <thead>
    <th width="20%">status.value</th>
    <th width="20%">status.reason</th>
    <th width="60%">Description</th></thead>
  <tr>
    <td><code>ACTIVE</code></td>
    <td><code>DEPLOYING</code></td>
    <td>The deployment is deploying.</td>
  </tr>
  <tr>
    <td><code>ACTIVE</code></td>
    <td><code>PAUSED</code></td>
    <td>The deployment is paused waiting for the user to continue with the deployment. Used only for canary Deployments.</td>
  </tr>
  <tr>
    <td><code>ACTIVE</code></td>
    <td><code>CANCELLING</code></td>
    <td>The deployment is cancelling.</td>
  </tr>
  <tr>
    <td><code>FINALIZED</code></td>
    <td><code>DEPLOYED</code></td>
    <td>The deployment is complete.</td>
  </tr>
  <tr>
    <td><code>FINALIZED</code></td>
    <td><code>CANCELLED</code></td>
    <td>The deployment was cancelled.</td>
  </tr>
  <tr>
    <td><code>FINALIZED</code></td>
    <td><code>SUPERSEDED</code></td>
    <td>The deployment was stopped and did not finish deploying because another
    deployment was created for the app.
    </td>
  </tr>
</table>
