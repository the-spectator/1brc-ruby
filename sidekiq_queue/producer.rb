require 'sidekiq'
require 'sidekiq-pro'
require_relative './a_job.rb'

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:6379" }
end

Sidekiq.redis { |c| c.flushdb }

t0 = Time.now
puts("Program started at #{t0}")

file = File.open('measurements.txt')
job_count = 0
agrregate = []
file.lazy.each_slice(50_000) do |lines|
  job_count+=1
  agrregate << lines
  if job_count % 500 == 0
    A.perform_bulk(agrregate.zip)
    agrregate = []
    puts("pushed bulk for #{job_count} angre #{agrregate}")
  end
  puts("pushed #{job_count} batch")
end

## queue using brop

puts("😀"*100)
agrregate = {}
processed_count = 0

Sidekiq.redis do |conn|
  while (_key, redis_city_hash = conn.brpop("1brc", timeout: 10))
    processed_count += 1
    puts("Processed #{processed_count}")

    city_hash = JSON.parse(redis_city_hash)

    city_hash.each do |key, stat|
      city_from_aggregate = agrregate[key]
      if city_from_aggregate.nil?
        agrregate[key] = stat
        agrregate[key]["mean"] = (stat["sum"] / stat["count"].to_f).round(1)
        next
      end

      city_from_aggregate["min"] = [city_from_aggregate["min"], stat["min"]].min
      city_from_aggregate["max"] = [city_from_aggregate["max"], stat["max"]].max
      city_from_aggregate["sum"] = city_from_aggregate["sum"] + stat["sum"]
      city_from_aggregate["count"] = city_from_aggregate["count"] + stat["count"]
      city_from_aggregate["mean"] = (city_from_aggregate["sum"] / city_from_aggregate["count"].to_f).round(1)

      agrregate[key] = city_from_aggregate
    end

    break if processed_count == job_count
  end
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
puts({job_count:, processed_count:})
puts("Task completed at #{t1}")
puts("Time taken to complete the batch #{t1 - t0} seconds")
puts("😀"*100)
