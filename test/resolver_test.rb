require_relative 'setup/test_helper'

class InstanceTest < Querrel::Test
  def test_env_resolver
    conns = [:sqlite_db_0, :sqlite_db_1]
    resolver = Querrel::ConnectionResolver.new(conns, false)

    assert_equal 2, resolver.configurations.length
    assert_equal conns.map(&:to_s), resolver.configurations.keys
  end

  def test_db_name_resolver
    conns = ['test/dbs/test_db_10.sqlite3', 'test/dbs/test_db_11.sqlite3',
             'test/dbs/test_db_12.sqlite3', 'test/dbs/test_db_13.sqlite3']
    resolver = Querrel::ConnectionResolver.new(conns, true)

    assert_equal 4, resolver.configurations.length
    assert_equal conns, resolver.configurations.keys
    assert_equal conns, resolver.configurations.values.map{ |c| c[:database] }
  end

  def test_hash_config_resolver
    conns = {
      one: {
        adapter: "sqlite3",
        database: "test/dbs/test_db_1.sqlite3"
      },
      two: {
        adapter: "sqlite3",
        database: "test/dbs/test_db_2.sqlite3"
      }
    }
    resolver = Querrel::ConnectionResolver.new(conns, false)

    assert_equal conns, resolver.configurations
  end

  def test_default_resolver
  end
end