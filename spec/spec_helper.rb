$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'stackr'

RSpec.configure do |config|

  def fixtures_path
    File.join(File.dirname(__FILE__), 'fixtures')
  end

  def includes_path
    File.join(fixtures_path, 'includes')
  end

  def load_fixture(fixture)
    path = File.join(fixtures_path, fixture)
    Stackr::Template.load(path)
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end
end
