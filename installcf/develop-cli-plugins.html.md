---
title: Developing cf CLI Plugins
---

Users can create and install Cloud Foundry command line interface (cf CLI) 
plugins to provide custom commands.
These plugins can be submitted and shared to the [CF Community repo](http://plugins.cloudfoundry.org/ui/).

### Requirements ###

Using plugins requires cf CLI v.6.7 or higher. 
Refer to the [Installing the cf Command Line Interface](./install-go-cli.html) topic for information about downloading, installing, and uninstalling the cf CLI.

### Installing the Architecture ###

1. Implement the [predefined plugin interface](https://github.com/cloudfoundry/cli/blob/master/plugin/plugin.go).
1. Clone the [template repo](https://github.com/cloudfoundry/cli). You will need the [basic GO plugin](https://github.com/cloudfoundry/cli/blob/master/plugin_examples/basic_plugin.go).

### Initializing the Plugin ###

To initialize a plugin, call `plugin.Start(new(MyPluginStruct))` from within 
the `main()` method of your plugin. 
The `plugin.Start(...)` function requires a new reference to the struct that 
implements the defined interface.

### Invoking CLI Commands ###

Invoke CLI commands with `cliConnection.CliCommand([]args)` from within a plugin's `Run(...)` method. 
`The Run(...)` method receives the `cliConnection` as its first argument.
The `cliConnection.CliCommand([]args)` returns the output printed by the command and an error. 

The output is returned as a slice of strings. 
The error will be present if the call to the CLI command fails.

For more information, see the [calling CLI commands example](https://github.com/cloudfoundry/cli/blob/master/plugin_examples/call_cli_cmd/main/call_cli_cmd.go).
	
### Installing a Plugin ###

To install a plugin, run `cf install-plugin PATH_TO_PLUGIN_BINARY`.

For additional information on developing plugins, see the [plugin development guide](https://github.com/cloudfoundry/cli/tree/master/plugin_examples).
