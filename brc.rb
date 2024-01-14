require_relative 'utils/config'

t0 = Time.now
puts("Program started at #{t0}")

total_measurement_rows = Config.rows
slice_size = Config.slice_size
filename = Config.filename

puts("Process #{total_measurement_rows} rows from file #{filename} with size size of #{slice_size}")
puts

file = File.open(filename)
Stat = Struct.new(:min, :max, :mean, :sum, :count, keyword_init: true)
city_hash = {}
file.lazy.each_slice(slice_size) do |lines|
  lines.each do |tupple|
    city, measurement = tupple.split(";")
    measurement = measurement.to_f
    stat = city_hash.fetch(city, Stat.new(min: measurement, max: measurement, mean: 0, sum: 0, count: 0))
    stat.min = [measurement, stat.min].min
    stat.max = [measurement, stat.max].max
    stat.sum += measurement
    stat.count += 1
    # stat.mean = (stat.sum / stat.count.to_f).round(1)
    city_hash[city] = stat
  end
end

result_string = "{"
city_hash.sort.each do |name, stat|
  mean = (stat.sum / stat.count.to_f).round(1)
  result_string.concat "#{name}="
  result_string.concat "#{stat.min}/#{mean}/#{stat.max}, "
end
result_string.chomp!(", ")
result_string.concat "}"

puts("😀"*100)
puts
puts result_string
puts

t1 = Time.now
puts("Program completed at #{t1}")
puts("Total time taken is #{t1 - t0}")
puts("😀"*100)
