require_relative 'setup/test_helper'

class TestTest < Querrel::Test
  def test_test_data_loaded_properly
    assert Brand.count > 0,
      "Test data not loaded"
  end
end