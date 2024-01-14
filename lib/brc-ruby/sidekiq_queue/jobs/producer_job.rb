require_relative './stats_cruncher_job'
require 'async'
require 'async/semaphore'


class ProducerJob
  include Sidekiq::Job

  def perform(batch_size, slice_size, aggregator_key_set)

    Sync do |task|
      semaphore = Async::Semaphore.new(3)

      key_set = aggregator_key_set.cycle
      file = File.open('measurements.txt')

      file.lazy.each_slice(slice_size).each_slice(batch_size) do |lines_array|
        aggre_key = key_set.next
        y = lines_array.product([aggre_key])
        semaphore.async do
          StatsCruncherJob.perform_bulk(y, batch_size: 500)
        end

        debug_print { "pushed bulk for #{batch_size} with slice_size(#{slice_size}) and key #{aggre_key}" }
      end
    end
  end

  def debug_print(&block)
    return if ENV['debug'] != 'true'
    puts(block.call)
  end
end
