require_relative './stats_cruncher_job'

class ProducerJob
  include Sidekiq::Job

  def perform(batch_size, slice_size, aggregator_key_set)
    key_set = aggregator_key_set.cycle
    file = File.open('measurements.txt')
    job_count = 0
    agrregate = []
    file.lazy.each_slice(slice_size) do |lines|
      job_count+=1
      agrregate << lines
      if job_count % batch_size == 0
        StatsCruncherJob.perform_bulk(agrregate.product([key_set.next]), batch_size: 500)
        agrregate = []
        debug_print { "pushed bulk for #{job_count} angre #{agrregate}" }
      end
      debug_print { "pushed #{job_count} batch" }
    end
  end

  def debug_print(&block)
    return if ENV['debug'] != true
    puts(block.call)
  end
end
