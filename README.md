[![Build Status](https://travis-ci.org/dalehamel/terraform_dsl.svg)](https://travis-ci.org/dalehamel/terraform_dsl)

# Terraform DSL

This is a simple DSL for wrapping hashicorp's [terraform configuration](https://terraform.io/docs/configuration/index.html).

Terraform is an infrastructure-as-code tool for managing infrastructure by defining stack element in a DSL.

This ruby DSL It supports almost identical syntax, and generates JSON that the terraform go application will understand.

# Usage

To use this gem, you will need to:

* define some stack templates
* configure secrets for your app
* define those stacks using your templates in yaml
* create a simple rake file

Once you've done this, you can run various rake tasks to manage your stacks.

If you get lost, take a look at the [sample app](https://github.com/dalehamel/terraform_dsl_sample)

## Stack Templates

Create a stack template, like one of our [examples](examples), such as our [simple app](examples/simple_app.rb)

Generally, you need to do:

```
require 'terraform_dsl'
```

And then subclass Terraform::StackTemplate

```
class MyAwesomeStackTemplate < Terraform::StackTemplate
```

Within that class, define resources using a similar syntax to [terraform's configuration](https://terraform.io/docs/configuration/index.html).

Generally speaking, you can still use the "{ / }" syntax because it's all ruby blocks, but 'do / end' is often preferred as it differentiates from a hash more nicely.

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
**Note** Secrets are never written to template files, as a safeguared to prevent them from accidentally being committed. Instead, they are passed as environment vairables.

### YAML

```
cat stacks.yml
stacks:
  - name: teststack
    description: just a test stack
    template: simpleapp
    variables:
      flavor: t1.micro
      key: SOMESSHKEY
```

### Tasks

Create a rake file that loads your templates, and calls Terraform::Tasks.loadall.

```
# Load your stack templates
require_relative 'simple_app.rb'

## Loads terraform tasks
#require 'terraform_dsl/tasks'
require 'terraform_dsl'
Terraform::Tasks.loadall

```

This will add some terraform tasks for managing your terraform stacks:

```
rake apply[name]    # Apply pending changes for a stack
rake apply_all      # Apply all pending stack changes
rake destroy[name]  # Destroy a stack
rake list           # List all available stacks
rake load           # Loads available stack templates
rake plan[name]     # Show pending changes for a stack
rake show[name]     # Show details about a stack by name
rake show_all       # Show all pending stack changes
```

[license](LICENSE)
