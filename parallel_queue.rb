require 'parallel'
require 'concurrent-ruby'

t0 = Time.now
puts("Program started at #{t0}")

work_queue = Thread::Queue.new
city_map = Concurrent::Map.new

# producer = Thread.new do
#   (1..10_000).lazy.each_slice(1000) do |lines|
#     work_queue << lines
#   end
# end

# producer.join

hash_index = (1..100).to_a

Parallel.each(->{ (1..10_000).each_slice(1000) || Parallel::Stop }) do |lines|
  index = hash_index.sample
  exiting_value = city_map.fetch(index, 0)
  city_map[index] = exiting_value+ lines.sum
end

arr = []
city_map.each do |k, v|
  arr << [k, v]
end

puts arr.inspect

puts("Program completed at #{t1}")
puts("Total time taken is #{t1 - t0}")
