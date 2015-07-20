require 'querrel/version'
require 'querrel/querreller'

module Querrel
  class << self
    def new(dbs)
      Querreller.new(dbs)
    end

    def query(scope, opts)
      Querreller.new(opts.delete(:on), opts).query(scope)
    end

    def map(scope, opts)
      Querreller.new(opts.delete(:on), opts).map(scope)
    end
  end
end
