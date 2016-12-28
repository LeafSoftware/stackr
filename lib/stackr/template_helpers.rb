require 'cloudformation-ruby-dsl/cfntemplate'

module Stackr
  module TemplateHelpers
    # Put all helper methods that you want to add to the DSL here.
    # TODO: Make something that loads project helpers too.

    # DEPRECATED: This is the old version of find_in_env()
    # It fails when there are more than 64 attributes in the map.
    # Use new find_in_env() instead
    def find_in_env_map(name)
      find_in_map('EnvironmentMap', ref('Environment'), name)
    end

    def load_environment_map(includes_path='includes')
      if @environment_map.nil?
        map_path = File.join(includes_path, 'environment_map.rb')
        mappings = eval(File.read(map_path))
        @environment_map = mappings['Mappings']['EnvironmentMap']
      end
      @environment_map
    end

    def find_in_env(name)
      if ENV['ENVIRONMENT'].nil?
        raise Stackr::EnvironmentMissingError, 'Please set ENVIRONMENT environment variable.'
      end
      map = load_environment_map()
      return map[ ENV['ENVIRONMENT'].to_sym ][name.to_sym]
    end

    def include_file(filepath, locals={})
      interpolate(file(filepath), locals)
    end
  end
end
