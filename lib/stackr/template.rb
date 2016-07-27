require 'json'
require 'stackr/template_helpers'

include Stackr::TemplateHelpers

module Stackr
  class Template
    attr_accessor :name, :parameter_map, :template_dsl, :capabilities
    attr_accessor :includes_path, :templates_path

    def initialize
      @capabilities = []
      @parameter_map = {}
    end

    # eval the contents in the context of this class
    def self.load(template_file)
      eval File.read(template_file)
    end

    def generate
      JSON.pretty_generate(template_dsl)
    end

  end
end
