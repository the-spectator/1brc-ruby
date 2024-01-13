require 'sidekiq'
require 'sidekiq-pro'
require_relative './jobs/aggregator_job'
require_relative './jobs/producer_job'
require_relative './jobs/stats_cruncher_job'

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:6379" }
end

Sidekiq.redis { |c| c.flushdb }

t0 = Time.now
puts("Program started at #{t0}")

total_measurement_rows = ENV.fetch("rows", 1_000_000_000).to_i
slice_size = 20_000
sidekiq_push_batch_size = 500

total_stats_jobs = total_measurement_rows / slice_size

# Enqueue aggregator job
AggregatorJob.perform_async(total_stats_jobs)

# Enqueue producer (batch_size, slice_size)
ProducerJob.perform_async(sidekiq_push_batch_size, slice_size)

## print the final result

puts("😀"*100)

agrregate = nil
Sidekiq.redis do |conn|
  _key, agrregate_result_string = conn.brpop("1brc-result", timeout: 36000)
  agrregate = JSON.parse(agrregate_result_string)
end

result_string = "{"
agrregate.sort.each do |name, stat|
  result_string.concat "#{name}="
  result_string.concat "#{stat["min"]}/#{stat["mean"]}/#{stat["max"]}, "
end
result_string.chomp!(", ")
result_string.concat "}"

puts
puts(result_string)
puts
t1 = Time.now
puts({total_stats_jobs:})
puts("Task completed at #{t1}")
puts("Time taken to complete the batch #{t1 - t0} seconds")
puts("😀"*100)


# start instruction
