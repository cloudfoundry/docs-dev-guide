---
title: Install cf v5
---

This page has instructions for installing cf v5. For information about installing cf v6, see [Install cf v6](install-go-cli.html).

## <a id="prerequisites"></a>Prerequisites ##

cf requires Ruby and RubyGems. Ruby 1.9.3 or later is required. Ruby 1.9.3 is recommended.

## <a id="ruby"></a>Install Ruby ##

This section has instructions for installing Ruby on Linux, Mac OS X, and Windows.


### <a id="linux"></a>Install Ruby on Linux ###

Options for installing and managing a Ruby environment on Unix-like operating systems include `rvm` and `rbenv`; both include RubyGems.

* [rvm installation instructions](https://rvm.io/rvm/install/)
* [rbenv installation instructions](https://github.com/sstephenson/rbenv/#installation)

Ruby can also be installed using the package manager available for each Linux distribution --- `apt` on Ubuntu and Debian, `yum` on RedHat/Fedora and Centos, or `yast` on SuSE Linux. When installing via a package manager, install the "ruby" and "rubygems" packages.

[chruby](https://github.com/postmodern/chruby) is a lightweight alternative to the environment managers listed above --- it simply eases the process of switching among multiple Ruby environments.

### <a id="osx"></a>Install Ruby on Mac OS X ###

If you are going to run cf on OS X, you must obtain a cf-supported version of Ruby.  Since v10.5, OS X includes Ruby, but not a current version.

`rvm` and `rbenv`, the environment managers described in [Ruby on Linux](#linux) above, also run on OS X. You can use the [Homebrew](http://mxcl.github.com/homebrew/) OS X package manager to install either `rvm` or `rbenv`, or if desired, to directly install Ruby and RubyGems.

### <a id="windows"></a>Install Ruby on Windows ###

[RubyInstaller](http://rubyinstaller.org/) can be used to install Ruby on Windows.

There is also a Ruby environment manager available for Windows, named `pik`. For more information, see [pik installation instructions](https://github.com/vertiginous/pik#install).


## <a id='installing'></a>Install cf ##

After installing Ruby and RubyGems, use this command to install the latest released version of cf:

<pre class="terminal">
$ gem install cf
</pre>

To install a pre-release version of cf:

<pre class="terminal">
$ gem install cf --pre
</pre>

## <a id='troubleshooting'></a>Troubleshoot cf Installation ##

* OS X includes Ruby v1.8.7, which cf does not support. On OS X you must upgrade Ruby to 1.9.3 or later to run cf.

* If you are running Ruby 1.9.3 with a pre-1.9.x gemset, cf installation will fail with a message like this:

<pre class="terminal">
$ gem install cf
...
...
ERROR: Error installing cf:
activesupport requires Ruby version >= 1.9.3.
</pre>

## <a id="about"></a>Get Started with the Ruby CLI ##

See [cf Command Line Interface](../manage/cf.html).