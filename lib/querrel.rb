require 'querrel/version'
require 'querrel/querreller'

module Querrel
  class << self
    def new(dbs)
      Querreller.new(dbs)
    end

    def query(scope, opts, &blk)
      Querreller.new(opts.delete(:on), opts).query(scope, &blk)
    end

    def map(scope, opts, &blk)
      Querreller.new(opts.delete(:on), opts).map(scope, &blk)
    end

    def run(opts, &blk)
      Querreller.new(opts.delete(:on), opts).run(&blk)
    end
  end
end
