require 'sidekiq'
require 'sidekiq-pro'
require_relative './a_job.rb'

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:6379" }
end

Sidekiq.redis { |c| c.flushdb }

t0 = Time.now
puts("Program started at #{t0}")

batch = Sidekiq::Batch.new
batch.on(:success, A, 't0' => t0.iso8601)

batch.jobs do
  file = File.open('measurements.txt')
  count = 0
  agrregate = []
  file.lazy.each_slice(50_000) do |lines|
    agrregate << lines
    if count % 500 == 0
      A.perform_bulk(agrregate.zip)
      agrregate = []
      puts("pushed bulk for #{count} angre #{agrregate}")
    end
    # A.perform_async(lines)
    puts("pushed #{count+=1} batch")
  end
end
