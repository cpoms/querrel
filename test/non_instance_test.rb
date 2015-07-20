require_relative 'setup/test_helper'

class NonInstanceTest < Querrel::Test
  def setup
    super

    @dbs = [:sqlite_db_1, :sqlite_db_2, :sqlite_db_3]
  end

  def test_map_reduce
    res = Querrel.query(Brand.all, on: @dbs)
    num_brands = Brand.count

    assert_equal num_brands * @dbs.length, res.length,
      "Not returning the correct number of results"
  end

  def test_map
    res = Querrel.map(Brand.all, on: @dbs)
    num_brands = Brand.count

    assert (@dbs.map(&:to_s) & res.keys).length == res.keys.length,
      "Map keys not the same as input dbs"
    assert res.values.all?{ |r| r.length == num_brands },
      "Not querying all DBs the same"
  end

  def test_records_are_readonly
    res = Querrel.query(Product.all, on: @dbs)

    assert res.any?, "No records returned"
    assert res.all?{ |p| p.readonly? }, "Records not readonly"
  end
end