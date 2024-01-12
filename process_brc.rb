require 'parallel'
require 'concurrent-ruby'

t0 = Time.now
puts("Program started at #{t0}")

# file = File.open('measurements.txt')

Stat = Struct.new(:min, :max, :sum, :mean, :count, keyword_init: true)
work_queue = Thread::Queue.new
city_map = Concurrent::Map.new

file = File.open('measurements.txt')
producer = Thread.new do
  file.lazy.each_slice(1_000) do |lines|
    work_queue << lines
  end
end
producer.join
file.close

end_object = :done
consumers_count = (ENV['t_count'] || 4).to_i

Parallel.each(->{ work_queue.pop || Parallel::Stop }) do |lines|
  lines.each do |tupple|
    city, measurement = tupple.split(";")
    measurement = measurement.to_f
    stat = city_map.fetch(city, Stat.new(min: measurement, max: measurement, mean: 0, sum: 0, count: 0))
    # puts({city:, stat: , measurement: })
    stat.min = [measurement, stat.min].min
    stat.max = [measurement, stat.max].max
    stat.sum += measurement
    stat.count += 1
    stat.mean = (stat.sum / stat.count.to_f).round(1)
    city_map[city] = stat
  end
end


arr = []
city_map.each do |name, stat|
  arr<< [name, "#{name}=#{stat.min}/#{stat.mean}/#{stat.max}"]
end
result_string = "{#{arr.sort_by { |x| x[0] }.map{|x| x[1]}.join(", ")}}"

puts result_string

puts("Program completed at #{t1}")
puts("Total time taken is #{t1 - t0}")
