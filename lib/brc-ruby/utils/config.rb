# frozen_string_literal: true

module BrcRuby
  module Utils
    class Config
      ROWS_MAP = {
        "1mil"=>1000000,
        "10mil"=>10000000,
        "50mil"=>50000000,
        "100mil"=>100000000,
        "1billion"=>1000000000
      }.freeze

      class << self
        def rows
          @rows ||= ROWS_MAP.fetch(ENV.fetch("rows"))
        end

        def slice_size
          @slice_size ||= ENV.fetch("slice_size", 1_000).to_i
        end

        def filename
          @filename ||= "measurements_#{ENV.fetch("rows")}.txt"
        end

        def debug?
          @debug ||= (ENV['debug'] == 'true')
        end
      end
    end
  end
end
