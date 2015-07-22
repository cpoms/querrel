module Querrel
  class ConnectedModelFactory
    def self.[](model, con_spec = nil)
      con_spec ||= Thread.current[:querrel_con_spec]
      dynamic_class_name = "#{model.name}#{Thread.current.object_id}"
      Class.new(model).tap do |m|
        m.send(:define_singleton_method, :name) { dynamic_class_name }
        m.establish_connection(con_spec.config)

        Thread.current[:querrel_connected_models] << m
      end
    end
  end
end