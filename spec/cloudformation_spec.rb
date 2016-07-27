require 'spec_helper'

describe Stackr::CloudFormation do
  it { should respond_to :is_too_big? }
  it { should respond_to :is_way_too_big? }
  # it { should respond_to :create_stack }
  # it { should respond_to :update_stack }
  # it { should respond_to :delete_stack }
  # it { should respond_to :validate_template }

  describe '#stack_parameters' do
    it 'fills parameters from environment variables' do
      ENV['FIRST_PARAMETER'] = 'foo'
      params = subject.stack_parameters({'FirstParameter' => 'FIRST_PARAMETER'})
      expect(params).to eq([{parameter_key: 'FirstParameter', parameter_value: 'foo'}])
    end
  end
end
