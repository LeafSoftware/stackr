require 'spec_helper'
require 'fileutils'

describe Stackr::Cli do
  def destination_path
    File.join(File.dirname(__FILE__), 'sandbox')
  end

  def project_path
    File.join(destination_path, 'foo')
  end

  def templates_path
    File.join(project_path, 'templates')
  end

  def clean_sandbox
    ::FileUtils.rm_rf(destination_path)
  end

  describe '#create_project' do
    def check_directory(dir)
      dir_path = File.join(project_path, dir)
      expect(Dir.exist?(dir_path)).to be true
    end

    def check_file(file)
      path = File.join(project_path, file)
      expect(File.exist?(path)).to be_truthy
    end

    before do
      clean_sandbox
      subject.destination_root = destination_path
      capture(:stdout) {subject.create_project 'foo'}
    end

    files = %w[
      .env.example
      .gitignore
      .ruby-gemset
      Gemfile
      includes/environment_map.rb
    ]

    files.each do |file|
      it "creates #{file} file" do
        check_file file
      end
    end

    %w[templates includes].each do |dir|
      it "creates #{dir} directory" do
        check_directory dir
      end
    end

    it 'sets gemset to the project name' do
      path = File.join(project_path, '.ruby-gemset')
      expect(File.read(path)).to eq "foo\n"
    end
  end

  describe '#version' do
    it { should respond_to :version }

    it 'says the version' do
      content = capture(:stdout) {subject.version}
      expect(content).to eq "#{Stackr::VERSION}\n"
    end
  end

  describe '#create-template' do
    before do
      clean_sandbox
      subject.destination_root = destination_path
      subject.templates_path   = templates_path
      capture(:stdout) { subject.create_project 'foo' }
      capture(:stdout) { subject.create_template 'foo' }
    end

    let(:generator_path) {
      File.join(templates_path, 'foo.rb')
    }

    it 'creates a new template generator' do
      expect(File.exist?(generator_path)).to be_truthy
    end

    it 'creates a generator that sets the template name' do
      contents = File.read(generator_path)
      expect(contents).to match(/t.name = 'foo'/)
    end

    it 'creates a generator that adds the environment map' do
      contents = File.read(generator_path)
      expect(contents).to match(/mapping 'EnvironmentMap', File.join\(t.includes_path, 'environment_map.rb'\)/)
    end
  end

  describe '#generate_template' do
    before do
      clean_sandbox
      subject.destination_root = destination_path
      subject.templates_path = templates_path
      capture(:stdout) { subject.create_project 'foo' }
      FileUtils.cp File.join(fixtures_path, 'simple.rb'), templates_path
    end

    it 'bails if the template does not exist' do
      content = capture(:stdout) { subject.generate_template 'missing'}
      expect(content).to eq "There is no template named 'missing'.\n"
    end

    it 'creates the json file' do
      capture(:stdout) { subject.generate_template 'simple' }
      json_file = File.join(templates_path, 'simple.json')
      expected_file = File.join(fixtures_path, 'simple.json')

      expect(File.read(json_file)).to eq File.read(expected_file)
    end
  end

  describe '#create_stack' do
    before do
      clean_sandbox
      subject.destination_root = destination_path
      subject.templates_path = templates_path
      capture(:stdout) { subject.create_project 'foo' }
      FileUtils.cp File.join(fixtures_path, 'simple.rb'), templates_path
    end

    it {should respond_to :create_stack}

    it 'bails if the template does not exist' do
      content = capture(:stdout) { subject.generate_template 'missing'}
      expect(content).to eq "There is no template named 'missing'.\n"
    end
  end

  describe '#update_stack' do
    before do
      clean_sandbox
      subject.destination_root = destination_path
      subject.templates_path = templates_path
      capture(:stdout) { subject.create_project 'foo' }
      FileUtils.cp File.join(fixtures_path, 'simple.rb'), templates_path
    end

    it {should respond_to :update_stack}

    it 'bails if the template does not exist' do
      content = capture(:stdout) { subject.generate_template 'missing'}
      expect(content).to eq "There is no template named 'missing'.\n"
    end
  end

  describe '#delete_stack' do
    before do
      clean_sandbox
      subject.destination_root = destination_path
      subject.templates_path = templates_path
      capture(:stdout) { subject.create_project 'foo' }
      FileUtils.cp File.join(fixtures_path, 'simple.rb'), templates_path
    end

    it {should respond_to :delete_stack}

    it 'bails if the template does not exist' do
      content = capture(:stdout) { subject.generate_template 'missing'}
      expect(content).to eq "There is no template named 'missing'.\n"
    end
  end

  describe '#list_stacks' do
    before do
      clean_sandbox
      subject.destination_root = destination_path
      subject.templates_path = templates_path
      capture(:stdout) { subject.create_project 'foo' }
      FileUtils.cp File.join(fixtures_path, 'simple.rb'), templates_path
    end

    it {should respond_to :list_stacks}

    it 'bails if the template does not exist' do
      content = capture(:stdout) { subject.generate_template 'missing'}
      expect(content).to eq "There is no template named 'missing'.\n"
    end
  end

  describe '#validate_template' do
    before do
      clean_sandbox
      subject.destination_root = destination_path
      subject.templates_path = templates_path
      capture(:stdout) { subject.create_project 'foo' }
      FileUtils.cp File.join(fixtures_path, 'simple.rb'), templates_path
    end

    it {should respond_to :validate_template}

    it 'bails if the template does not exist' do
      content = capture(:stdout) { subject.validate_template 'missing'}
      expect(content).to eq "There is no template named 'missing'.\n"
    end
  end

end
