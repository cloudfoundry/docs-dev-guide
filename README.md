cf-docs
====

This is the documentation for the Cloud Foundry project - including information about running and managing applications on Cloud Foundry, and setting up your own Cloud Foundry instance with VCAP and BOSH. 

This repository also feeds [cloudfoundry.github.com](http://cloudfoundry.github.com) using [Github Pages](http://pages.github.com/) and [Middleman](http://middlemanapp.com/).

If you have minor changes, you can contribute by forking this repository, modifying the files in `/source/docs`, and creating a GitHub pull request.

If you want to contribute on a larger scale, see the [Pivotal Project for CF Docs](https://www.pivotaltracker.com/projects/713283#).

## Contributing docs

You can either contribute directly within Github or by cloning the repository to your local machine using git.

## Viewing docs locally

These docs are rendered using [middleman](https://github.com/middleman/middleman). To pull down the raw documentation project and view the docs on your local machine using middleman:

```
git clone https://github.com/cloudfoundry/cf-docs.git cloudfoundry-docs
cd cloudfoundry-docs
bundle
bundle exec middleman server
```

Then view [http://0.0.0.0:4567](http://0.0.0.0:4567) in your browser.

## More help

### Twitter

* Follow the [@cloudfoundry](https://twitter.com/cloudfoundry) Twitter account for retweets of blogs and news from the world of Cloud Foundry
* Search the [#cloudfoundry](https://twitter.com/search/realtime?q=%23cloudfoundry) hashtag to follow discussions about Cloud Foundry

### Discussion Groups

* [Using Cloud Foundry](http://stackoverflow.com/questions/tagged/cloudfoundry) (development-related questions)
* [Running / Setting up Cloud Foundry](https://groups.google.com/a/cloudfoundry.org/forum/?fromgroups#!forum/vcap-dev)
* [Using BOSH](https://groups.google.com/a/cloudfoundry.org/forum/?fromgroups#!forum/bosh-users)
* [Running / Setting up BOSH](https://groups.google.com/a/cloudfoundry.org/forum/?fromgroups#!forum/bosh-dev)

There is also a #cloudfoundry IRC channel on the Freenode network, but that may be less-frequently monitored by members of the core team.

### Bugs

When you are getting started with Cloud Foundry, and are still learning your way around the repositories, you can file bugs in each repo's Github Issue section.

### Support

Support issues that are particular to the Pivotal-hosted Cloud Foundry public PaaS available at http://run.pivotal.io can be filed at the address below.

* [support.cloudfoundry.com](http://support.cloudfoundry.com)

