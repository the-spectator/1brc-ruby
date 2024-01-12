# require 'debug'
t0 = Time.now
puts("Program started at #{t0}")

file = File.open('measurements.txt')

Stat = Struct.new(:min, :max, :mean, :sum, :count, keyword_init: true)
city_hash = {}
# debugger
file.lazy.each_slice(1_000) do |lines|
  lines.each do |tupple|
    city, measurement = tupple.split(";")
    measurement = measurement.to_f
    stat = city_hash.fetch(city, Stat.new(min: measurement, max: measurement, mean: 0, sum: 0, count: 0))
    stat.min = [measurement, stat.min].min
    stat.max = [measurement, stat.max].max
    stat.sum += measurement
    stat.count += 1
    stat.mean = (stat.sum / stat.count.to_f).round(1)
    city_hash[city] = stat
  end
end

result_string = "{"
city_hash.sort.each do |name, stat|
  result_string.concat "#{name}="
  result_string.concat "#{stat.min}/#{stat.mean}/#{stat.max}, "
end
result_string.concat "}"

puts result_string
t1 = Time.now
puts("Program completed at #{t1}")
puts("Total time taken is #{t1 - t0}")
