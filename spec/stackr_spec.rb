require 'spec_helper'

describe Stackr do
  it 'has a version number' do
    expect(Stackr::VERSION).not_to be nil
  end

  it 'has a cli' do
    expect(Stackr::Cli.new).not_to be nil
  end
end
