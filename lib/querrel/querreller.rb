require 'querrel/connection_resolver'
require 'querrel/static_pool'
require 'querrel/map_reduce'

module Querrel
  class Querreller
    include MapReduce
    attr_accessor :connection_resolver

    def initialize(dbs, options = {})
      @connection_resolver = ConnectionResolver.new(dbs, options.delete(:db_names))
      @options = options
    end

    def run(options = {}, &blk)
      options = @options.merge(options)
      if options.key?(:on)
        resolver = ConnectionResolver.new(options[:on], !!options[:db_names])
        dbs = resolver.configurations.keys
      else
        resolver = @connection_resolver
        dbs = @connection_resolver.configurations.keys
      end

      pool = StaticPool.new(options[:threads] || 20)
      dbs.each do |db|
        pool.enqueue do
          begin
            ActiveRecord::Base.connection_handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new
            con_config = retrieve_connection_config(db, resolver)
            ActiveRecord::Base.establish_connection(con_config)
            yield(db)
          ensure
            ActiveRecord::Base.connection_handler.clear_all_connections!
          end
        end
      end
      pool.do_your_thang!
    end

    def retrieve_connection_spec(db, resolver)
      resolver.spec(db.to_sym)
    end

    def retrieve_connection_config(db, resolver)
      resolver.resolve(db.to_sym)
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