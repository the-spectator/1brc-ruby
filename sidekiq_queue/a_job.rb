require 'sidekiq'
require 'sidekiq-pro'

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:6379" }
end

class A
  include Sidekiq::Job

  def perform(lines)
    city_hash = {}
    lines.each do |tupple|
      city, measurement = tupple.split(";")
      measurement = measurement.to_f
      stat = city_hash.fetch(city, { "min" => measurement, "max" => measurement, "sum" => 0, "count" => 0 })
      stat["min"] = [measurement, stat["min"]].min
      stat["max"] = [measurement, stat["max"]].max
      stat["sum"] += measurement
      stat["count"] += 1
      # stat["mean"] = (stat["sum"] / stat["count"].to_f).round(1)
      city_hash[city] = stat
    end

    Sidekiq.redis do |conn|
      conn.lpush("1brc", city_hash.to_json)
    end
  end
end
