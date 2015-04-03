---
title: Installing the cf Command Line Interface
---

To install the cf CLI, download it from https://console.run.pivotal.io/tools and follow the instructions for your operating system.

## <a id="uninstall-gem"></a>Uninstall cf CLI v5 ##

If you previously used the cf CLI v5 Ruby gem, you must uninstall this gem before installing cf CLI v6.

To uninstall, run `gem uninstall cf`.

<p class="note"><strong>Note</strong>: To ensure that your Ruby environment manager registers the change, close and reopen your terminal.</p>

## <a id="windows"></a>Windows Installation##

To install cf on Windows:

1. Unpack the zip file.
1. Double click the `cf` executable.
1. When prompted, click **Install**, then **Close**.

## <a id="nixlike"></a>Mac OSX and Linux Installation##

1. Open the .pkg file.
1. In the installer wizard, click **Continue**.
1. Select an install destination and click **Continue**.
1. When prompted, click **Install**.

## <a id="next-steps"></a>Next Steps ##
To verify your installation, open a terminal window and type `cf`.
If your installation was successful, the cf help listing appears.

For information on how to use the cf CLI version 6, see [Getting Started with cf CLI v6](../installcf/whats-new-v6.html).
