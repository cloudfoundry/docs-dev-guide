---
title: Install cf Version 6 Beta (gcf)
---

Version 6 of the cf cli is currently in beta. During the beta period, the executable name is `gcf` so that you can have both cf version 5.x and cf version 6 on your system. Once cf version 6 goes into production, the name will change from gcf to cf.

To install gcf, download it from https://github.com/cloudfoundry/cli/releases then follow the instructions for your operating system.


## <a id="windows"></a>Install gcf on Windows ##

To install gcf on Windows:

1. Unpack the zip file.
1. Move the `gcf` executable to `C:\Program Files\Cloud Foundry\`
1. Add `C:\Program Files\Cloud Foundry` to your`%PATH%` environment variable:
  * Right-click **My Computer > Properties**.
  * Click **Advanced system settings**.
  * Click **Environment Variables**.
  * Click **Path** in the **System Variables** list.
  * Click **Edit**
  * Append "C:\Program Files\Cloud Foundry\" to the variable value; use a semicolon (;) to delimit your entry from the previous path component.
  * Click **OK**.
  * Click **OK**

## <a id="nixlike"></a>Install gcf on Mac OSX and Linux ##

1. Unpack the the tgz file.
1. Move the `gcf` executable to `/usr/local/bin`.
1. Confirm `/usr/local/bin` is in your `PATH` by typing `echo $PATH` at the command line.


## <a id="nixlike"></a>Next Steps ##
To verify your installation, open a terminal window and type `gcf`.
If your installation was successful, the gcf help listing appears.

For information on how to use cf version 6, see [Getting Started with cf v6](../installcf/whats-new-v6.html).
