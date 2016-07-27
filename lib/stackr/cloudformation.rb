require 'aws-sdk'

module Stackr
  class CloudFormation

    # Is this template too big to include in API calls?
    # If so, we better upload it to S3
    def is_too_big?(template_str)
      template_str.bytesize > 51200
    end

    # Is this template too big for CloudFormation
    def is_way_too_big?(template_str)
      template_str.bytesize > 460800
    end

    # Submit template to CloudFormation for validation
    # nil if the template does not validate
    # Otherwise return parameters hash
    def validate_template(template)
      params = {}

      # is it a string or an s3 url?
      if template =~/^http/
        params[template_url: template]
      else
        params[template_body: template]
      end

      cfn = Aws::CloudFormation::Client.new()
      begin
        resp = cfn.validate_template(params)
      rescue Aws::CloudFormation::Errors::ValidationError => e
        return nil
      end

      return resp
    end

    def stack_parameters(parameter_map)
      parameter_map.map { |k,v| {parameter_key: k, parameter_value: ENV[v]} }
    end

    # takes a Stackr::Template
    def create_stack(template, options={})
      options[:disable_rollback] ||= false

      cfn = Aws::CloudFormation::Resource.new
      cfn.create_stack({
        stack_name:       options[:name] || template.name,
        template_body:    template.generate,
        parameters:       stack_parameters(template.parameter_map),
        disable_rollback: options[:disable_rollback],
        capabilities:     template.capabilities
      })
    end
  end
end
