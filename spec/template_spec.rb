require 'spec_helper'

describe Stackr::Template do

  let(:cwd) { File.expand_path(File.dirname(__FILE__)) }

  it { should respond_to :includes_path }
  it { should respond_to :capabilities }
  it {should respond_to :body}
  it {should respond_to :url}

  subject { load_fixture('simple.rb') }

  describe '#name' do
    it 'has a name' do
      expect(subject.name).to eq 'Simple'
    end
  end

  describe '#load' do
    it 'loads template from a file' do
      expect(subject).to be_a Stackr::Template
    end

    it 'returns nil if the template does not exist' do
      expect(Stackr::Template.load('missing')).to be_nil
    end
  end

  describe '#generate' do
    it 'generates json template' do
      json = subject.generate
      expect(json).to eq "{\n  \"AWSTemplateFormatVersion\": \"2010-09-09\",\n  \"Description\": \"Simple Template\"\n}"
    end
  end

  describe '#parameter_map' do
    it 'sets parameters' do
      expect(subject.parameter_map['FirstParameter']).to eq 'FIRST_PARAMETER'
    end
  end

end
