require 'thor'

module Stackr
  class Cli < Thor

    no_commands do
      def project_path=(name)
        @project_path = name
      end

      def project_path
        @project_path || File.basename(Dir.getwd)
      end

      def templates_path=(path)
        @templates_path = path
      end

      def templates_path()
        @templates_path || File.join(File.basename(Dir.getwd), 'templates')
      end

      def json_template_path(name)
        File.join(templates_path, "#{name}.json")
      end

      def load_template(name)
        template_file = File.join(templates_path, "#{name}.rb")
        Stackr::Template.load(template_file)
      end
    end

    ## version
    desc 'version', 'show version'
    def version
      say Stackr::VERSION
    end

    ## project
    include Thor::Actions
    def self.source_root
      File.join(File.dirname(__FILE__),'..','..')
    end

    desc 'create-project PROJECT_NAME', 'create stackr project'
    def create_project(name)
      @project_name = name

      say "\nCreating stackr project: #{name}\n", :yellow
      directory 'templates/project', name
    end

    ## create-template
    desc 'create-template TEMPLATE', 'create a new template generator'
    def create_template(name)
      @template_name = name
      say "\nCreating template generator #{name}\n", :yellow
      template 'templates/generator.rb.tt', "#{project_path}/templates/#{name}.rb"
    end

    desc 'generate-template TEMPLATE', 'write the CloudFormation template json file'
    def generate_template(name)
      t = load_template(name)
      json_file = json_template_path(name)

      say "\nWriting #{name} to #{json_file}"
      File.open(json_file, 'w') do |f|
        f.write(t.generate)
      end
    end

    ## create-stack
    desc 'create-stack TEMPLATE', 'create a stack from TEMPLATE'
    option :name,
      aliases: '-n',
      desc: 'Stack name, defaults to template name'

    option :disable_rollback,
      type: :boolean,
      default: false,
      desc: 'disable rollback of failed stacks'

    # TODO: log parameters and their values
    def create_stack(template_name)
      say "\nCreating CloudFormation stack #{options[:name]}"
      template = load_template(template_name)
      launcher = Stackr::CloudFormation.new
      launcher.create_stack(template, options)
    end

  end
end
