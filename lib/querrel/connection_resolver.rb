module Querrel
  class ConnectionResolver
    attr_accessor :resolver

    def initialize(conns, db_names)
      if db_names
        base_spec = ActiveRecord::Base.connection_config

        specs = conns.map do |c|
          [c, base_spec.dup.update(database: c)]
        end
        specs = Hash[specs]
      else
        case conns
        when Hash
          specs = conns
        when Array
          conns.map!(&:to_s)
          specs = ActiveRecord::Base.configurations.select{ |n, _| conns.include?(n.to_s) }
        end
      end

      @resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new(specs)
    end

    [:configurations, :spec, :resolve].each do |m|
      define_method(m) do |*args, &block|
        @resolver.send(m, *args, &block)
      end
    end
  end
end