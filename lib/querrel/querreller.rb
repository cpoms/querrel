require 'querrel/connected_model_factory'
require 'querrel/connection_resolver'
require 'querrel/map_reduce'

module Querrel
  class Querreller
    include MapReduce
    attr_accessor :connection_resolver

    def initialize(dbs, options = {})
      @connection_resolver = ConnectionResolver.new(dbs, options[:db_names])
    end

    def run(options = {}, &blk)
      if options.key?(:on)
        resolver = ConnectionResolver.new(options[:on], !!options[:db_names])
        dbs = resolver.configurations.keys
      else
        resolver = @connection_resolver
        dbs = @connection_resolver.configurations.keys
      end

      threads = []
      dbs.each do |db|
        threads << Thread.new do
          con_spec = retrieve_connection_spec(db, resolver)
          Thread.current[:querrel_con_spec] = con_spec
          yield(ConnectedModelFactory)
        end
      end
      threads.each(&:join)
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