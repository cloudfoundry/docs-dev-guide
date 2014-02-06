---
title: Install cf Version 6
---

To install cf, download it from https://github.com/cloudfoundry/cli/releases and follow the instructions for your operating system.

## <a id="uninstall-gem"></a>Uninstall cf v5 ##

If you previously used the cf v5 Ruby gem, you must uninstall this gem before installing cf v6.

To uninstall, run `gem uninstall cf`.

## <a id="windows"></a>Install cf on Windows ##

To install cf on Windows:

1. Unpack the zip file.
1. Move the `cf` executable to `C:\Program Files\Cloud Foundry\`
1. Add `C:\Program Files\Cloud Foundry` to your `%PATH%` environment variable:
  * Right-click **My Computer > Properties**.
  * Click **Advanced system settings**.
  * Click **Environment Variables**.
  * Click **Path** in the **System Variables** list.
  * Click **Edit**
  * Append "C:\Program Files\Cloud Foundry\" to the variable value; use a semicolon (;) to delimit your entry from the previous path component.
  * Click **OK**.
  * Click **OK**.

## <a id="nixlike"></a>Install cf on Mac OSX and Linux ##

1. Unpack the the .pkg file.
1. Move the `cf` executable to `/usr/local/bin`.
1. Confirm `/usr/local/bin` is in your `PATH` by typing `echo $PATH` at the command line.


## <a id="nixlike"></a>Next Steps ##
To verify your installation, open a terminal window and type `cf`.
If your installation was successful, the cf help listing appears.

For information on how to use cf version 6, see [Getting Started with cf v6](../installcf/whats-new-v6.html).
