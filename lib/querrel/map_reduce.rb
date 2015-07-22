module Querrel
  module MapReduce
    def query(scope, options = {}, &blk)
      buckets = map(scope, options, &blk)
      reduce(buckets)
    end

    def map(scope, options = {}, &blk)
      options = @options.merge(options)
      if options.key?(:on)
        resolver = ConnectionResolver.new(options[:on], !!options[:db_names])
        dbs = resolver.configurations.keys
      else
        resolver = @connection_resolver
        dbs = @connection_resolver.configurations.keys
      end

      query_model = scope.model
      results = {}
      results_semaphore = Mutex.new

      pool = StaticPool.new(options[:threads] || 20)
      dbs.each do |db|
        pool.enqueue do
          Thread.current[:querrel_connected_models] = []
          con_spec = retrieve_connection_spec(db, resolver)
          Thread.current[:querrel_con_spec] = con_spec
          dynamic_class = ConnectedModelFactory[query_model, con_spec]

          begin
            local_scope = dynamic_class.all.merge(scope)
            local_results = if block_given?
              res = yield(local_scope, ConnectedModelFactory)
              res.to_a.each(&:readonly!) if res.is_a?(ActiveRecord::Relation)
              res
            else
              local_scope.to_a.map do |r|
                query_model.instantiate(r.attributes, {}).tap(&:readonly!)
              end
            end

            results_semaphore.synchronize { results[db] = local_results }
          ensure
            Thread.current[:querrel_connected_models].each do |m|
              m.connection_pool.release_connection
            end
            Thread.current[:querrel_connected_models] = nil
          end
        end
      end
      pool.do_your_thang!

      results
    end

    def reduce(buckets)
      buckets.flat_map{ |db, results| results }
    end
  end
end