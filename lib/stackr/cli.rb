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
        @templates_path || 'templates'
      end

      def json_template_path(name)
        File.join(templates_path, "#{name}.json")
      end

      # Only load the template the first time
      def load_template(name)
        if @template.nil?
          template_file = File.join(templates_path, "#{name}.rb")
          @template = Stackr::Template.load(template_file)
        end
        @template
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

      say "Creating stackr project: #{name}\n"
      directory 'templates/project', name
    end

    ## create-template
    desc 'create-template TEMPLATE', 'create a new template generator'
    def create_template(name)
      @template_name = name
      say "Creating template generator #{name}\n"
      template 'templates/generator.rb.tt', File.join(templates_path, "#{name}.rb")
    end

    ## generate-template
    desc 'generate-template TEMPLATE', 'write the template json file'
    def generate_template(template_name)
      template = load_template(template_name)
      if !template
        say "There is no template named \'#{template_name}\'."
        return
      end

      json_file = json_template_path(template_name)

      say "Writing #{template_name} to #{json_file}\n"
      File.open(json_file, 'w') do |f|
        f.write(template.body)
      end
    end

    ## validate-template
    desc 'validate-template TEMPLATE', 'Verify template and parameters'
    def validate_template(template_name)
      template = load_template(template_name)
      if !template
        say "There is no template named \'#{template_name}\'."
        return
      end

      launcher = Stackr::CloudFormation.new
      begin
        launcher.validate_template(template)
      rescue Aws::S3::Errors::ServiceError => e
        say e.message
        return false
      else
        say "Template #{template_name} validates."
        return true
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
      return if !validate_template(template_name)

      template = load_template(template_name)
      if !template
        say "There is no template named \'#{template_name}\'."
        return
      end

      name = options[:name] || template.name
      launcher = Stackr::CloudFormation.new
      say "Creating CloudFormation stack #{name} from template #{template.name}\n"
      begin
        launcher.create_stack(template, options)
      rescue Stackr::StackAlreadyExistsError => e
        say e.message
      end
    end

    ## update-stack
    desc 'update-stack TEMPLATE', 'update the stack created from TEMPLATE'
    option :name,
      aliases: '-n',
      desc: 'Stack name, defaults to template name'

    # TODO: log parameters and their values
    def update_stack(template_name)
      return if !validate_template(template_name)

      template = load_template(template_name)
      if !template
        say "There is no template named \'#{template_name}\'."
        return
      end

      name = options[:name] || template.name
      say "Updating CloudFormation stack #{name} from template #{template.name}\n"
      launcher = Stackr::CloudFormation.new
      begin
        launcher.update_stack(template, options)
      rescue Stackr::StackMissingError => e
        say e.message
      rescue Stackr::StackUpdateNotRequiredError => e
        say e.message
      rescue Stackr::InsufficientCapabilitiesError => e
        say e.message
      end
    end

    ## delete-stack
    desc 'delete-stack STACK', 'delete the stack named STACK'
    def delete_stack(stack_name)
      say "Deleting CloudFormation stack #{stack_name}\n"
      launcher = Stackr::CloudFormation.new
      begin
        launcher.delete_stack(stack_name)
      rescue Stackr::StackMissingError => e
        say e.message
      end
    end

    ## list-stacks
    desc 'list-stacks', 'list all stacks'
    def list_stacks
      launcher = Stackr::CloudFormation.new
      rows = []
      launcher.list_stacks.each do |stack|
        rows << [
          stack.name,
          stack.stack_status,
          stack.creation_time ? stack.creation_time.iso8601 : '',
          stack.last_updated_time ? stack.last_updated_time.iso8601 : ''
        ]
      end
      print_table rows
    end

  end
end
