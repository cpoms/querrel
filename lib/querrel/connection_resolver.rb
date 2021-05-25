module Querrel
  class ConnectionResolver

    def initialize(conns, db_names)
      if db_names
        base_spec = ActiveRecord::Base.connection_db_config.configuration_hash

        specs = conns.map do |c|
          [ c.to_s, base_spec.dup.update(database: c) ]
        end
        @specs = Hash[specs]
      else
        case conns
        when Hash
          @specs = conns
        when Array
          specs = conns.map do |c|
            [ c.to_s, ActiveRecord::Base.configurations.find_db_config(c).configuration_hash ]
          end
          @specs = Hash[specs]
        end
      end
    end

    def resolve(db)
      @specs[db.to_s]
    end

    def configurations
      @specs
    end
  end
end
