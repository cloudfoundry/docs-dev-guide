---
title: Install Go CLI
---

This page has instructions for installing gcf, the Cloud Foundry Go-based command line interface. For information about installing cf, the Ruby-based command line interface, see [Install Ruby CLI](install-ruby-cli.html).

Download gcf from https://github.com/cloudfoundry/cli/releases, and then follow the instructions for your operating system.

## <a id="windows"></a>Install gcf on Windows ##

1. Unpack the zip file.
1. Move the `gcf` executable to `C:\Program Files\Cloud Foundry\`
1. Add `C:\Program Files\Cloud Foundry` to your`%PATH%` environment variable.
  1. Right-click **My Computer > Properties**.
  2. Click **Advanced system settings**.
  3. Click **Environment Variables**.
  4. Click ** "Path" in the **System Variables** list.
  5. Click **Edit**
  6. Append "C:\Program Files\Cloud Foundry\" to the variable value; use a semicolon (;) to delimit your entry from the previous path component.
  7. Click **OK**.
  8. Click **OK**
5. Open a terminal window and enter `gcf`.
6. If your installation was successful, the gcf help listing appears.

## <a id="nixlike"></a>Install gcf on Mac OSX and Linux ##

1. Unpack the the tgz file.
1. Move the `gcf` executable to `/usr/local/bin`.
1. Confirm `/usr/local/bin` is in your `PATH` by typing `echo $PATH` at the command line.
1. Type `gcf` at the command line.
1. If your installation was successful, the gcf help listing appears.

## <a id="about"></a>Get Started with the Go CLI ##

See [Getting Started with cf v6](go-cli.html).
