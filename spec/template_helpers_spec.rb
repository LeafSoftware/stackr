require 'spec_helper'
require 'json'

describe Stackr::TemplateHelpers do

  describe 'find_in_env' do
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
      expect(find_in_env('foo')).to eq expected
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
