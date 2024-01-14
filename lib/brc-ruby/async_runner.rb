# frozen_string_literal: true

require 'async/barrier'

module BrcRuby
  class AsyncRunner
    Stat = Struct.new(:min, :max, :sum, :count, keyword_init: true)

    def self.run
      new.run
    end

    def initialize
      @total_rows = BrcRuby::Utils::Config.rows
      @slice_size = Utils::Config.slice_size
      @filename = Utils::Config.filename
      @file = File.open(@filename, 'r')
      @city_map = Concurrent::Map.new
    end

    def run
      Sync do |task|
        sliced_lazy_reader = file.lazy.each_slice(slice_size)
        iterations = (total_rows / slice_size).ceil.to_i

        iterations.times do |i|
          task.async do
            # NOTE: it maybe thread unsafe. When 1 task is getting nth batch, if there is a concurrent
            # task started at same time, it will process the same nth batch.
            lines = sliced_lazy_reader.next

            lines.each do |tupple|
              city, measurement = tupple.split(";")
              measurement = measurement.to_f
              stat = city_map.fetch(city, Stat.new(min: measurement, max: measurement, sum: 0, count: 0))
              stat.min = [measurement, stat.min].min
              stat.max = [measurement, stat.max].max
              stat.sum += measurement
              stat.count += 1
              city_map[city] = stat
            end
          end
        end
      end

      create_result_string
    end

    private

    attr_reader :total_rows, :slice_size, :file, :filename, :city_map

    def create_result_string
      cities = []
      city_map.each do |key, stat|
        cities << [key, stat]
      end

      result_string = +"{"
      cities.sort_by { |x| x[0] }.each do |name, stat|
        mean = (stat.sum / stat.count.to_f).round(1)
        result_string.concat "#{name}="
        result_string.concat "#{stat.min}/#{mean}/#{stat.max}, "
      end
      result_string.chomp!(", ")
      result_string.concat(+"}")

      result_string
    end
  end
end
