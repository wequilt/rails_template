# Liminal Rails Application Template
This is the template used to generate new Rails services at Liminal. It will ask a series of
questions about the service you're creating and then establish some sensible defaults (install
common gems, create a deployment Helm chart, etc).

## Environment
Before using this template you need to make sure your environment is set up with a ruby version
manager (RVM, rbenv, etc) and a few prerequisites are installed in that environment.

### Ruby Version Manager
There are several choices when it comes to managing multiple Ruby versions on a single machine. You
can use whatever version manager appeals to you but you need to have one installed before
proceeding. Popular version managers include:
* [RVM](https://rvm.io/)
* [rbenv](https://github.com/rbenv/rbenv)
* [chruby](https://github.com/postmodern/chruby)
* [frum](https://github.com/tako8ki/frum)
There are likely others and any of them should work fine. You'll need to select (and install) the
version of Ruby you'd like to use for this new service. In general you'll want to choose the
latest stable Ruby version but whatever version you choose, make sure you have installed and
selected it as the current version with your version manager.

### Gems
You will also need several gems installed to facilitate creating a new Rails app. If supported by
your version manager you may also want to create a `gemset` for this new service. The template will
assume the `gemset` name (if used) will correspond to the name of the service so if you choose to use
a `gemset` go ahead and create/select it for use. Regardless, when ready run:
```sh
gem install bundler rails
```
to install prerequisite gems.

### Clone Me
The last step before using this template is to clone it somewhere on your local machine. The
template makes heavy use of Thor `template` and `copy_file` which don't work when the template is
used over HTTP.

## Service Creation
With your environment configurated you can now proceed to generating the new Rails app. The `rails
new` command takes many options that can help configure an app with the specific capabilities you
require. Some commonly selected options are things like `--api` to create an API-only project,
`--minimal` to create a super minimal app, etc. For a complete list of options use `rails new
--help`. Once you've selected the set of options that makes the most sense for your application, run
`rails new <selected_options> -m <location_of_cloned_repo>/template.rb`
to create the new application.
