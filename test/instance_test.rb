require_relative 'setup/test_helper'

class InstanceTest < Querrel::Test
  def setup
    super

    @dbs = [:sqlite_db_1, :sqlite_db_2, :sqlite_db_3]
    @q = Querrel.new(@dbs)
  end

  def test_map_reduce
    res = @q.query(Brand.all)
    num_brands = Brand.count

    assert_equal num_brands * @dbs.length, res.length,
      "Not returning the correct number of results"
  end

  def test_map
    res = @q.map(Brand.all)
    num_brands = Brand.count

    assert (@dbs.map(&:to_s) & res.keys).length == res.keys.length,
      "Map keys not the same as input dbs"
    assert res.values.all?{ |r| r.length == num_brands },
      "Not querying all DBs the same"
  end

  def test_records_are_readonly
    res = @q.query(Product.all)

    assert res.any?, "No records returned"
    assert res.all?{ |p| p.readonly? }, "Records not readonly"
  end

  def test_block
    names = Product.pluck(:name)
    res = @q.query(Product.all) do |scope|
      scope.pluck(:name)
    end

    assert_equal names * @dbs.length, res
  end

  def test_runner
    s = Mutex.new
    configs_actual = []

    @q.run do
      s.synchronize do
        configs_actual << Product.connection_db_config.configuration_hash
      end
    end

    configs = Querrel::ConnectionResolver.new(@dbs, false).configurations.values

    configs = configs.map{ |c| Hash[c.map{ |k, v| [k.to_s, v] }] }.sort_by{ |c| c["database"] }
    configs_actual = configs_actual.map{ |c| Hash[c.map{ |k, v| [k.to_s, v] }] }.sort_by{ |c| c["database"] }

    assert_equal configs, configs_actual
  end
end
