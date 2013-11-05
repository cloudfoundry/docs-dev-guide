---
title: Installing Ruby
---
cf, the Cloud Foundry command line interface, requires Ruby and the RubyGems package management framework; both are available for a variety of operating systems.

This page has information about installing Ruby in different environments, and package managers --- especially useful if you run multiple versions of Ruby --- for those environments.

Before installing Ruby, see [Installing cf](cf.html#installing) for information about what version of Ruby the cf requires.

For more information about Ruby and Rubygems see:

* http://www.ruby-lang.org/en/downloads/
* http://rubygems.org/


## <a id="linux"></a>Installing Ruby on Linux ##

Options for installing and managing a Ruby environment on Unix-like operating systems include `rvm` and `rbenv`; both include RubyGems.

* [rvm installation instructions](https://rvm.io/rvm/install/)
* [rbenv installation instructions](https://github.com/sstephenson/rbenv/#installation)

Ruby can also be installed using the package manager available for each Linux distribution --- `apt` on Ubuntu and Debian, `yum` on RedHat/Fedora and Centos, or `yast` on SuSE Linux. When installing via a package manager, install the "ruby" and "rubygems" packages.

[chruby](https://github.com/postmodern/chruby) is a lightweight alternative to the environment managers listed above --- it simply eases the process of switching among multiple Ruby environments.

## <a id="osx"></a>Installing Ruby on Mac OS X ##

If you are going to run cf on OS X, you must obtain a cf-supported version of Ruby.  Since v10.5, OS X includes Ruby, but not a current version.

`rvm` and `rbenv`, the environment managers described in [Ruby on Linux](#linux) above, also run on OS X. You can use the [Homebrew](http://mxcl.github.com/homebrew/) OS X package manager to install either `rvm` or `rbenv`, or if desired, to directly install Ruby and RubyGems.

## <a id="windows"></a>Installing Ruby on Windows ##

[RubyInstaller](http://rubyinstaller.org/) can be used to install Ruby on Windows.

There is also a Ruby environment manager available for Windows, named `pik`. For more information, see [pik installation instructions](https://github.com/vertiginous/pik#install).

