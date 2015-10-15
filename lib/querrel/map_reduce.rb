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

      results = {}
      results_semaphore = Mutex.new

      pool = StaticPool.new(options[:threads] || 20)
      dbs.each do |db|
        pool.enqueue do
          ActiveRecord::Base.connection_handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new
          con_config = retrieve_connection_config(db, resolver)
          ActiveRecord::Base.establish_connection(con_config)

          begin
            local_results = block_given? ? yield(scope, db) : scope
            local_results.to_a.each(&:readonly!) if local_results.is_a?(ActiveRecord::Relation)

            results_semaphore.synchronize { results[db] = local_results }
          ensure
            ActiveRecord::Base.connection_handler.clear_all_connections!
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