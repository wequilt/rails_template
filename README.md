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

### AWS CLI
Many of the services that this template configures requires access to AWS via the AWS CLI. See
https://aws.amazon.com/cli/ for more information on the AWS CLI and
https://www.notion.so/quilt/AWS-STS-Auth-Setup-dbceea78d75b4839b67d5739fcde726b for instructions to
set up the CLI on your machine (with support for 2FA).

### Terraform
Configuring production database clusters, Kubernetes service accounts, etc. for this new service
is done through Terraform. As long as you have successfully configured the AWS CLI (see above)
you should be able to simply `brew install terraform` to install the Terraform client. Most
Terraform operations are performed by remotely by Atlantis as part of the pull request process
but the template does a `terraform init` to ensure Terraform is set up correctly, generate a
lockfile, etc. as part of the service creation.

### Clone Me
The last step before using this template is to clone it somewhere on your local machine. The
template makes heavy use of Thor `template` and `copy_file` which don't work when the template is
used over HTTP without some additional work (see
https://github.com/mattbrictson/rails-template/blob/main/template.rb#L107 for inspiration on how to
make this possible).

### Repository Configuration
Assuming this new service will live in GitHub with all of its service siblings it's best to prepare
the repository before running the Rails generator. At the end of app generation you will be given a
chance to create and push an initial commit. Having some things set up before hand will ensure this
process goes smoothly.

*Do not enable branch protections for `main` before running this generator. Otherwise you the
generator won't be able to push to GitHub*

These are the steps you'll want to follow to create and configure a new repository.
1. Create the repo in GitHub. Choose all options to make an empty repository (no default README,
   .gitignore, etc).
2. Grant the new repository access to the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` Actions
   organization secrets in GitHub. All other needed secrets are available to all private
   repositories but mobile app builds and backend builds use different AWS credentials so different
   secrets are needed.

## Service Creation
With your environment configurated you can now proceed to generating the new Rails app. The `rails
new` command takes many options that can help configure an app with the specific capabilities you
require. Some commonly selected options are things like `--api` to create an API-only project,
`--minimal` to create a super minimal app, etc. For a complete list of options use `rails new
--help`. Once you've selected the set of options that makes the most sense for your application, run
`rails new <selected_options> -m <location_of_cloned_repo>/template.rb`
to create the new application.

### Finishing Up
You're almost there, in the home stretch. Once your new app is pushed to GitHub there are just a few
final things you need to do for everything to be completely set up.

##### CodeClimate
For whatever reason, CodeClimate doesn't really allow you to add an empty repository so you will
need to generate and push to GitHub before setting up in CodeClimate. When you're ready, add the
new repository to CodeClimate, set up coverage reporting, and add as a new repository secret to
GitHub, `CC_TEST_REPORTER_ID`, for both Actions and Dependabot.

Once the repo is set up in CodeClimate you'll also want to replace the placeholders near the top of
the new app's README.md with the code for maintainability and coverage badges.

##### CI
With the `CC_TEST_REPORTER_ID` in place you should be able to re-run the `Stage + prod build and
deploy` action in GitHub actions (should have failed previously due to the missing secret). Once
this passes you're almost there.

##### GitHub Permissions
Now that you have a `main` branch you need to protect it. You can copy the settings from an existing
repo but essentially you want to require a PR to merge, require one approval on that PR, dismiss
stale approvals, and require a review from Code Owners. You'll also want to make the `test / test`
and `atlantis/plan` actions to pass and branches to be up to date before merging.
