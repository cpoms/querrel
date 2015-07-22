require 'thread'
require_relative 'setup/test_helper'

class StaticPoolTest < Querrel::Test
  def test_never_more_than_max_threads
    max_threads = 10
    p = Querrel::StaticPool.new(max_threads)

    thread_counts = []
    thread_semaphore = Mutex.new

    50.times do
      p.enqueue do
        thread_semaphore.synchronize do
          thread_counts << Thread.list.count{ |t| t.status == "run" }
        end
      end
    end
    p.do_your_thang!

    assert thread_counts.all?{ |c| c <= max_threads }
  end
end