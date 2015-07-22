require 'thread'
require_relative 'setup/test_helper'

class StaticPoolTest < Querrel::Test
  def test_never_more_than_max_threads
    p = Querrel::StaticPool.new(10)

    thread_counts = []
    thread_semaphore = Mutex.new

    50.times do
      p.enqueue do
        thread_semaphore.synchronize do
          thread_counts << Thread.list.select{ |t| t.status == "run" }.count
        end
      end
    end
    p.do_your_thang!

    assert thread_counts.all?{ |c| c <= 10 }
  end
end