t0 = Time.now
puts("Program started at #{t0}")

t1 = Time.now
work_queue = Thread::Queue.new
# agrre_queue = Queue.new
require 'concurrent-ruby'
# city_map = Concurrent::Map.new
Stat = Struct.new(:min, :max, :mean, :sum, :count, keyword_init: true)

producer = Thread.new do
  file = File.open('measurements.txt')
  file.lazy.each_slice(1_000) do |lines|
    work_queue << lines
  end
end

end_object = :done
consumers_count = (ENV['t_count'] || 8).to_i

consumers = Array.new(consumers_count) do
  Thread.new do
    city_map = {}
    until (lines = work_queue.pop) == end_object
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
  end
end

producer.join
consumers_count.times { work_queue << end_object }
consumers.each(&:join)

# arr = []
# city_map.each do |name, stat|
#   arr<< [name, "#{name}=#{stat.min}/#{stat.mean}/#{stat.max}"]
# end

# puts arr

# result_string = "{#{arr.sort_by { |x| x[0] }.map{|x| x[1]}.join(", ")}}"
# result_string = "{"
# city_map.sort.each do |name, stat|
#   result_string.concat "#{name}="
#   result_string.concat "#{stat.min}/#{stat.mean}/#{stat.max}, "
# end
# result_string.chomp!(", ")
# result_string.concat "}"

# puts result_string

puts("Program completed at #{t1}")
puts("Total time taken is #{t1 - t0}")
