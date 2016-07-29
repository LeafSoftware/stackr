# Stackr

[![Build Status](https://travis-ci.org/LeafSoftware/stackr.svg?branch=master)](https://travis-ci.org/LeafSoftware/stackr)

Create CloudFormation templates using ruby DSL and launch them with a CLI.

## TODO

* Add options to create-template to add boilerplate stuff like vpc, instance, etc
* Add tests for cli for all the exception handling

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stackr'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stackr

## Configuration

You must configure your AWS credentials to use stackr. Refer to the ruby [aws-sdk](http://docs.aws.amazon.com/sdkforruby/api/).

## Usage

```
Commands:
  stackr create-project PROJECT_NAME  # create stackr project
  stackr create-stack TEMPLATE        # create a stack from TEMPLATE
  stackr create-template TEMPLATE     # create a new template generator
  stackr delete-stack STACK           # delete the stack named STACK
  stackr generate-template TEMPLATE   # write the template json file
  stackr help [COMMAND]               # Describe available commands
  stackr list-stacks                  # list all stacks
  stackr update-stack TEMPLATE        # update the stack created from TEMPLATE
  stackr validate-template TEMPLATE   # Verify template and parameters
  stackr version                      # show version
```

1. Create a project with ```stackr create-project myproject```
2. Change directory into your project ```cd myproject```
3. ```cp .env.example .env``` and edit ```.env```
5. ```source .env```
2. Create a template with ```stackr create-template mytemplate```
3. Edit the new template in ```templates/mytemplate.rb``` adding parameters, resources, outputs, etc. See [cloudformation-ruby-dsl](https://github.com/bazaarvoice/cloudformation-ruby-dsl) for tips
4. Run ```stackr generate-template mytemplate``` and review the json document created at ```templates/mytemplate.json```
5. Create a CloudFormation stack from your template using ```stackr create-stack mytemplate```
6. List all of your stacks with ```stackr list-stacks```
7. Tear your stack down with ```stackr delete-stack mytemplate```

## Parameter Mapping

Many times you want to include secrets as stack parameters. These secrets do not belong in your source code. So we hand them in as environment variables.

You can set up a mapping between stack parameters and environment variables using the template parameter_map method.

This example tells stackr to fill in the "Environment" stack parameter with the contents of $ENVIRONMENT when creating or updating the stack.

```ruby
t.parameter_map = {
  'Environment' => 'ENVIRONMENT'
}
```

You can use a ```.env``` file for your environment variables. It's included in the project .gitignore file.

## Environment Map

You may want to use the same template to launch stacks in different environments (e.g. 'dev', 'prd', 'test'). You can edit ```includes/environment_map.rb``` to configure your different environments. This is useful when you are creating resources in different VPCs or Regions for different environments.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/LeafSoftware/stackr.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
