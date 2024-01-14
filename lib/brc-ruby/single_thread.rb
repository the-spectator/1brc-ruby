# frozen_string_literal: true

module BrcRuby
  class SingleThread
    Stat = Struct.new(:min, :max, :mean, :sum, :count, keyword_init: true)

    def self.run
      BrcRuby::Utils.pretty_print do
        new.run
      end
    end

    def initialize
      @total_rows = Utils::Config.rows
      @slice_size = Utils::Config.slice_size
      @filename = Utils::Config.filename
      @file = File.open(@filename, 'r')
      @city_hash = {}
    end

    def run
      print_info

      file.lazy.each_slice(slice_size) do |lines|
        lines.each do |tupple|
          city, measurement = tupple.split(";")
          measurement = measurement.to_f
          stat = city_hash.fetch(city, Stat.new(min: measurement, max: measurement, mean: 0, sum: 0, count: 0))
          stat.min = [measurement, stat.min].min
          stat.max = [measurement, stat.max].max
          stat.sum += measurement
          stat.count += 1
          city_hash[city] = stat
        end
      end

      create_result_string
    end

    private

    attr_reader :total_rows, :slice_size, :file, :filename, :city_hash

    def print_info
      puts("Process #{total_rows} rows from file #{filename} with size size of #{slice_size}")
    end

    def create_result_string
      result_string = +"{"
      city_hash.sort.each do |name, stat|
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
