require 'cloudformation-ruby-dsl/cfntemplate'

module Stackr
  module TemplateHelpers
    # Put all helper methods that you want to add to the DSL here.
    # TODO: Make something that loads project helpers too.

    def find_in_env(name)
      find_in_map('EnvironmentMap', ref('Environment'), name)
    end

    def include_file(filepath, locals={})
      interpolate(file(filepath), locals)
    end
  end
end
