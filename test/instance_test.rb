require_relative 'setup/test_helper'

class InstanceTest < Querrel::Test
  def test_map_reduce
    dbs = [:sqlite_db_1, :sqlite_db_2]
    num_brands = Brand.count
    q = Querrel.new(dbs)
    res = q.query(Brand.all)

    assert_equal num_brands * dbs.length, res.length,
      "Not returning the correct number of results"
  end
end