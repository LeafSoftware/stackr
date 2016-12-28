require 'spec_helper'
require 'json'

describe Stackr::TemplateHelpers do

  describe 'find_in_env_map' do
    it 'returns a Fn::FindInMap fragment' do
      expected = {
        'Fn::FindInMap': [
          'EnvironmentMap',
          {
            Ref: 'Environment'
          },
          'foo'
        ]
      }
      expect(find_in_env_map('foo')).to eq expected
    end
  end

  describe 'find_in_env' do
    before(:each) do
      load_environment_map(includes_path)
    end

    it 'handles a map with > 64 attribures' do
      ENV['ENVIRONMENT'] = 'dev'
      expect(find_in_env('dev65')).to eq 'dev65'
    end
    it 'returns the string' do
      ENV['ENVIRONMENT'] = 'dev'
      expect(find_in_env('dev65')).to eq 'dev65'
    end
    
    it 'raises an exception if ENVIRONMENT not set' do
      ENV.delete 'ENVIRONMENT'
      expect { find_in_env('dev1') }.to raise_error(Stackr::EnvironmentMissingError)
    end
  end

  describe 'include_file' do
    it 'renders file into Fn::Join fragment' do
      filepath = File.join(includes_path, 'hello_world')
      expect(include_file(filepath)).to eq({'Fn::Join': ['', ["hello world\n"]]})
    end

    it 'interpolates variables' do
      filepath = File.join(includes_path, 'hello_x_world')
      expect(include_file(filepath, {x: 'foo'})).to eq({'Fn::Join': ['', ["hello ", "foo", " world\n"]]})
    end
  end

end
