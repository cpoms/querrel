require "minitest/autorun"

class Querrel::Test < Minitest::Test
  def teardown
    DatabaseRewinder.clean
  end
end