[![Build Status](https://travis-ci.org/dalehamel/cloudshaper.svg)](https://travis-ci.org/dalehamel/cloudshaper)

# Cloudshaper

This is a simple DSL for wrapping hashicorp's [terraform configuration](https://terraform.io/docs/configuration/index.html).

Terraform is an infrastructure-as-code tool for managing infrastructure by defining stack element in a DSL.

This ruby DSL It supports almost identical syntax, and generates JSON that the terraform go application will understand.

## Differences from terraform's HCL configuration

There are a few ways to access stack element variables and attributes for different purposes:

* get(:var) - This gets the actual value of a variable at generation time. This is needed when passing variables to submodules
* var(:var) - This references the terraform interpolation syntax of a variable.
* value\_of(:var) - This references the value of a variable for a stack element by type and name using interpolation syntax.
* id\_of(:var) - This references the id of a stack element by type and name using interpolation syntax.

Since 'module' is a keyword in ruby, and even though it is technically OK to use it as a function name, we use 'submodule' instead of module, to make editors happy and avoid using the keyword.
* submodules are terraform modules under the hood - you can use normal terraform module syntax if you wish
* If you reference your source as 'module\_MODULENAME', you can reference another ruby module!
 * This module will be resolved at runtime, not compile time
 * Modules nested most deeply are resolved first. The root module is resolved last.

We allow variables to have array values. This is very useful as a flow-control technique to DRY up modules, and leverage the full power of the ruby DSL.
However, since terraform does not allow variables to have array values, we automatically flatten them to a comma-separated string. This variable may or may not be used by terraform, if you reference it explicity using one of the interpolated accessors mentioned above. If it is not used, it doesn't matter and will simply be ignored.

Keep in mind that when specifying a hash as a value within the DSL, you must use brackets around the braces ( call as ({key: value}) instead of {key: value}, this is an unfortunate but necessary syntax).

# Usage

To use this gem, you will need to:

* define some stack modules
* configure secrets for your app
* define those stacks using your modules in yaml
* create a simple rake file

Once you've done this, you can run various rake tasks to manage your stacks.

If you get lost, take a look at the [sample app](https://github.com/dalehamel/terraform_dsl_sample)

## Stack modules

In terraform, everything is defined in terms of 'modules'. Even if you don't use the 'module' (submodule in our case) keyword, you're implicitly working within the 'root' module.

Create a stack module, like one of our [examples](examples), such as our [simple app](examples/simple_app.rb)

Generally, you need to do:

```
require 'cloudshaper'
```

And then subclass Cloudshaper::StackModule

```
class MyAwesomeStackModule < Cloudshaper::StackModule
```

Within that class, define resources using a similar syntax to [terraform's configuration](https://terraform.io/docs/configuration/index.html).

## Submodules

You may even reference other stack modules that you've defined! Just call the module by using "module\_MODULENAME" as the 'source' value.

Using submodules are a fantastic way to DRY up your infrastructure! Since they are just terraform modules under the hood, you can specify variables as input (to configure the module) and specify outputs of the module, so that other modules may interpolate them for their own resources.

## Configuration

### Secrets

Create a file at config/secrets.json that contains secrets needed for you providers.

Specify the secrets as a JSON hash like so:

```
{
  "aws": {
    "AWS_ACCESS_KEY_ID": "ACCESS_KEY",
    "AWS_SECRET_ACCESS_KEY": "SECRET_KEY"
  }
}
```

For other providers, see [example configs](examples/secretconfig)

**Note** do not commit plaintext secrets.json to your repository. We recommend you use [ejson](https://github.com/Shopify/ejson) to store your secrets, and [capistrano-ejson](https://github.com/Shopify/capistrano-ejson) to decrypt them in production.
**Note** Secrets are never written to module files, as a safeguared to prevent them from accidentally being committed. Instead, they are passed as environment vairables.

### YAML

After setting up your rakefile, as below, just run:

```
bundle exec rake terraform:init
```

This will set up your stacks.yml with an initial config template, which you can customize for your chosen stack module

```
common:
  remote:
    s3:
      bucket: quartermaster-terraform
      region: us-east-1
stacks:
  - name: teststack
    uuid: 1433296428_0safh8-Y # must be unique
    description: just a test stack
    root: simpleapp
    variables:
      flavor: t1.micro
      key: SOMESSHKEY
```

You may also specify a 'common' block, that will be merged into all stacks.

Cloudshaper stacks need somewhere to store their state. By default, this will be the local filesystem.

It's highly recommended that you use a [remote backend](https://www.terraform.io/docs/commands/remote-config.html) instead, so that you can share your stacks.

### Tasks

Create a rake file that loads your modules, and calls Cloudshaper::Tasks.loadall.

```
## Loads terraform tasks and modules
require 'cloudshaper'
Cloudshaper::Tasks.loadall

```

This will add some terraform tasks for managing your terraform stacks:

```
rake terraform:apply[name]          # Apply pending changes for a stack
rake terraform:apply_all            # Apply all pending stack changes
rake terraform:destroy[name]        # Destroy a stack
rake terraform:get[name]            # Fetch modules for a stack
rake terraform:get_all              # Fetch modules for all stacks
rake terraform:init                 # Initialize stacks.yml if it does not exist
rake terraform:list                 # List all available stacks
rake terraform:load                 # Loads available stack modules
rake terraform:plan[name]           # Show pending changes for a stack
rake terraform:pull[name]           # Pulls stack state from remote location
rake terraform:pull_all             # Pulls stack states from remote location
rake terraform:push[name]           # Push stack state to remote location
rake terraform:push_all             # Push stack states to remote location
rake terraform:remote_config[name]  # Sets up remote config for a stack
rake terraform:remote_config_all    # Sets up remote config for all stacks that support it
rake terraform:show[name]           # Show details about a stack by name
rake terraform:show_all             # Show all pending stack changes
rake terraform:uuid                 # Generate a UUID for a stack, so stacks do not clobber each other
```

# Credits

Inspired by [terraframe](https://github.com/eropple/terraframe), a very similar but less generic and complete terraform DSL.

[license](LICENSE)
