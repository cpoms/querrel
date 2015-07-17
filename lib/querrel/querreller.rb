require 'querrel/connection_resolver'

module Querrel
  class Querreller
    attr_accessor :connection_resolver

    def initialize(dbs, db_names = false)
      @connection_resolver = ConnectionResolver.new(dbs, db_names)
    end

    def query(scope, options = {})
      buckets = map(scope, options)
      reduce(buckets)
    end

    def map(scope, options = {})
      if options.key?(:on)
        resolver = init_resolver(dbs, !!options[:db_names])
        dbs = resolver.configurations.keys
      else
        resolver = @connection_resolver
        dbs = @connection_resolver.configurations.keys
      end

      sql = scope.to_sql
      query_model = scope.model
      results = {}

      threads = []
      dbs.each do |db|
        threads << Thread.new do
          while_connected_to(db, resolver) do |conn|
            result_set = conn.select_all(sql, "MapReduce Load")
            column_types = result_set.column_types

            results[db] = result_set.map { |record| query_model.instantiate(record, column_types) }
          end
        end
      end
      threads.each(&:join)

      results
    end

    def reduce(buckets)
      buckets.map do |db, results|
        results.map do |result|
          result.tap { |r| r.readonly! }
        end
      end.flatten
    end

    def while_connected_to(db, resolver, &b)
      conf = resolver.spec(db.to_sym)
      pool = ActiveRecord::ConnectionAdapters::ConnectionPool.new(conf)
      pool.with_connection(&b)
    ensure
      pool.disconnect!
    end
  end
end