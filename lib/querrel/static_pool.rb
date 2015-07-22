require 'thread'

module Querrel
  class StaticPool
    def initialize(size)
      @size = size
      @jobs = Queue.new
    end

    def enqueue(&job)
      @jobs.push(job)
    end

    def do_your_thang!
      threads = Array.new(@size) do
        Thread.new do
          while job = @jobs.pop(true) rescue nil
            job.call
          end
        end
      end

      threads.each(&:join)
    end
  end
end