module Querrel
  module MapReduce
    def query(scope, options = {}, &blk)
      buckets = map(scope, options, &blk)
      reduce(buckets)
    end

    def map(scope, options = {}, &blk)
      if options.key?(:on)
        resolver = ConnectionResolver.new(options[:on], !!options[:db_names])
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
          Thread.current[:querrel_con_spec] = con_spec
          dynamic_class = ConnectedModelFactory[query_model, con_spec]

          begin
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
  end
end