require 'aws-sdk'
require 'stackr'

module Stackr
  class CloudFormation

    # Is this template too big to include in API calls?
    # If so, we better upload it to S3
    def is_too_big?(template_str)
      template_str.bytesize > 51200
      true
    end

    # Is this template too big for CloudFormation
    def is_way_too_big?(template_str)
      template_str.bytesize > 460800
    end

    # Requires TEMPLATE_BUCKET environment variable to be set.
    # If TEMPLATE_PREFIX environment variable is set, templates will be uploaded
    # using that prefix.
    def upload_to_s3(template_str, name)
      s3 = Aws::S3::Resource.new
      if ENV['TEMPLATE_BUCKET'].nil?
        raise Stackr::TemplateBucketMissingError, 'Please set TEMPLATE_BUCKET environment variable before uploading templates to S3.'
      end
      bucket = s3.bucket(ENV['TEMPLATE_BUCKET'])
      key = "#{name}.json"
      if ENV['TEMPLATE_PREFIX']
        key = "#{ENV['TEMPLATE_PREFIX']}/#{key}"
      end
      s3_object = bucket.object(key)
      s3_object.put(body: template_str)
      return s3_object.public_url
    end

    # Return proper argument for CloudFormation api calls.
    # If template is too big, upload it to s3 first and return
    # {template_url: s3_url}
    # otherwise return
    # {template_body: template_contents}
    # But if we've already uploaded the template to s3 this run,
    # (because we validated it and then ran a create-stack),
    # don't upload it a second time, just return the s3 url.
    def template_argument(template)

      if is_way_too_big? template.body
        raise Stackr::TemplateTooBigError, "Template #{template.name} is too big for CloudFormation."
      end

      if is_too_big? template.body
        if template.url.nil?
          template.url = upload_to_s3(template.body, template.name)
        end
        return {template_url: template.url}
      end

      return {template_body: template.body}
    end

    def stack_parameters(parameter_map)
      parameter_map.map { |k,v| {parameter_key: k, parameter_value: ENV[v]} }
    end

    # Raise an error if the template does not validate
    # takes a Stackr::Template
    def validate_template(template)
      cfn = Aws::CloudFormation::Client.new

      opts = template_argument(template)
      begin
        resp = cfn.validate_template(opts)
      rescue Aws::CloudFormation::Errors::ValidationError => e
        raise Stackr::TemplateValidationError, e.message
      end

      # validate parameters
      # Make sure each parameter w/o a default has a value
      resp.parameters.each do |param|
        param_name = param[:parameter_key]
        env_var    = template.parameter_map[param_name]

        if param[:default_value].nil? && ENV[env_var].nil?
          raise Stackr::ParameterMissingError, "Required parameter #{param_name} (#{env_var}) not specified."
        end
      end
    end

    # Takes a Stackr::Template
    def create_stack(template, options)
      cfn = Aws::CloudFormation::Resource.new
      stack_name = options[:name] || template.name

      opts = {
        stack_name:       options[:name] || template.name,
        parameters:       stack_parameters(template.parameter_map),
        disable_rollback: options[:disable_rollback],
        capabilities:     template.capabilities
      }

      # are we using template_body or template_url?
      opts.merge!( template_argument(template) )

      # Trap error raised when stack already exists
      begin
        cfn.create_stack(opts)
      rescue Aws::CloudFormation::Errors::AlreadyExistsException => e
        raise Stackr::StackAlreadyExistsError, e.message
      end
    end

    # Takes a Stackr::Template
    def update_stack(template, options)
      cfn = Aws::CloudFormation::Resource.new
      stack_name = options[:name] || template.name
      stack = cfn.stack(stack_name)
      if !stack
        raise Stackr::StackMissingError, "Stack #{stack_name} does not exist."
      end

      opts = {
        parameters:    stack_parameters(template.parameter_map),
        capabilities:  template.capabilities
      }

      # are we using template_body or template_url?
      opts.merge!( template_argument(template) )

      begin
        stack.update(opts)
      rescue Aws::CloudFormation::Errors::ValidationError => e
        case e.message
        when 'No updates are to be performed.'
          raise Stackr::StackUpdateNotRequiredError, "Stack [#{stack_name}] requires no updates."
        when "Stack [#{stack_name}] does not exist"
          raise Stackr::StackMissingError, e.message
        else
          raise e
        end
      rescue Aws::CloudFormation::Errors::InsufficientCapabilitiesException => e
        raise Stackr::InsufficientCapabilitiesError, "#{e.message}\nPlease add them to your template and run update again."
      end
    end

    def delete_stack(stack_name)
      cfn = Aws::CloudFormation::Resource.new
      stack = cfn.stack(stack_name)
      if stack.exists?
        stack.delete
      else
        raise Stackr::StackMissingError, "Stack [#{stack_name}] does not exist."
      end
    end

    def list_stacks
      cfn = Aws::CloudFormation::Resource.new
      cfn.stacks
    end

    # template is a Stackr::Template
    def create_change_set(stack_name, template, change_set_name, options)
      cfn = Aws::CloudFormation::Resource.new
      stack = cfn.stack(stack_name)
      if !stack
        raise Stackr::StackMissingError, "Stack #{stack_name} does not exist."
      end

      opts = {
        stack_name:      stack_name,
        change_set_name: change_set_name,
        parameters:      stack_parameters(template.parameter_map),
        capabilities:    template.capabilities
      }

      # are we using template_body or template_url?
      opts.merge!( template_argument(template) )

      begin
        # stack.update(opts)
        resp = cfn.client.create_change_set(opts)
      rescue Aws::CloudFormation::Errors::ValidationError => e
        case e.message
        when 'No updates are to be performed.'
          raise Stackr::StackUpdateNotRequiredError, "Stack [#{stack_name}] requires no updates."
        when "Stack [#{stack_name}] does not exist"
          raise Stackr::StackMissingError, e.message
        else
          raise e
        end
      rescue Aws::CloudFormation::Errors::InsufficientCapabilitiesException => e
        raise Stackr::InsufficientCapabilitiesError, "#{e.message}\nPlease add them to your template and run update again."
      end
      say "Change set #{change_set_name}, id: #{resp.id}"
    end

    def list_change_sets(stack_name)
      cfn = Aws::CloudFormation::Resource.new
      stack = cfn.stack(stack_name)
      if !stack
        raise Stackr::StackMissingError, "Stack #{stack_name} does not exist."
      end
      resp = cfn.client.list_change_sets({stack_name: stack_name})
      return resp.summaries
    end

    def show_change_set(change_set_name, stack_name)
      if stack_name.nil? && !change_set_name.start_with?('arn')
        raise Stackr::StackNameMissingError, "If change_set_name is not an ARN, you must specify stack_name"
      end

      cfn = Aws::CloudFormation::Client.new
      opts = {
        change_set_name: change_set_name,
        stack_name: stack_name
      }
      begin
        resp = cfn.describe_change_set(opts)
      rescue Aws::CloudFormation::Errors::ChangeSetNotFound => e
        raise Stackr::ChangeSetMissingError, e.message
      end
      return resp.data
    end

    def delete_change_set(change_set_name, stack_name)
      if stack_name.nil? && !change_set_name.start_with?('arn')
        raise Stackr::StackNameMissingError, "If change_set_name is not an ARN, you must specify stack_name"
      end

      cfn = Aws::CloudFormation::Client.new
      opts = {
        change_set_name: change_set_name,
        stack_name: stack_name
      }
      begin
        resp = cfn.delete_change_set(opts)
      rescue Aws::CloudFormation::Errors::ChangeSetNotFound => e
        raise Stackr::ChangeSetMissingError, e.message
      end
    end

    def execute_change_set(change_set_name, stack_name)
      if stack_name.nil? && !change_set_name.start_with?('arn')
        raise Stackr::StackNameMissingError, "If change_set_name is not an ARN, you must specify stack_name"
      end

      cfn = Aws::CloudFormation::Client.new
      opts = {
        change_set_name: change_set_name,
        stack_name: stack_name
      }
      begin
        cfn.execute_change_set(opts)
      rescue Aws::CloudFormation::Errors::ChangeSetNotFound => e
        raise Stackr::ChangeSetMissingError, e.message
      end
    end
  end
end
