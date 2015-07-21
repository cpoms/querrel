require 'querrel/connection_resolver'

module Querrel
  class Querreller
    attr_accessor :connection_resolver

    def initialize(dbs, options = {})
      @connection_resolver = ConnectionResolver.new(dbs, options[:db_names])
    end

    def query(scope, options = {}, &blk)
      buckets = map(scope, options, &blk)
      reduce(buckets)
    end

    def map(scope, options = {}, &blk)
      if options.key?(:on)
        resolver = ConnectionResolver.new(dbs, !!options[:db_names])
        dbs = resolver.configurations.keys
      else
        resolver = @connection_resolver
        dbs = @connection_resolver.configurations.keys
      end

      query_model = scope.model
      results = {}

      threads = []
      dbs.each do |db|
        threads << Thread.new do
          con_spec = retrieve_connection_spec(db, resolver)
          dynamic_class_name = "TempModel#{Thread.current.object_id}"
          dynamic_class = Class.new(query_model)
          dynamic_class.send(:define_singleton_method, :name) { dynamic_class_name }

          begin
            dynamic_class.establish_connection(con_spec.config)
            local_scope = dynamic_class.all.merge(scope)
            results[db] = if block_given?
              res = yield(local_scope)
              res.to_a.each(&:readonly!) if res.is_a?(ActiveRecord::Relation)
              res
            else
              local_scope.to_a.each(&:readonly!)
            end
          ensure
            dynamic_class.connection_pool.release_connection
          end
        end
      end
      threads.each(&:join)

      results
    end

    def reduce(buckets)
      buckets.flat_map{ |db, results| results }
    end

    def retrieve_connection_spec(db, resolver)
      resolver.spec(db.to_sym)
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