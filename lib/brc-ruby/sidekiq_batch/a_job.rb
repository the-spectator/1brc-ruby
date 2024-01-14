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

  def on_success(status, options)
    puts("😀"*100)
    agrregate = {}
    Sidekiq.redis do |conn|
      while redis_city_hash = conn.rpop("1brc")
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

        # puts
        # puts agrregate
        # puts redis_city_hash
        # puts
      end

    end

    # arr = []
    # agrregate.each do |name, stat|
    #   arr<< [name, "#{name}=#{stat["min"]}/#{stat["mean"]}/#{stat["max"]}"]
    # end
    # result_string = "{#{arr.sort_by { |x| x[0] }.map{|x| x[1]}.join(", ")}}"
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
    puts("Task completed at #{t1}")
    puts("Time taken to complete the batch #{t1 - Time.parse(options["t0"])} second")
    puts("😀"*100)
  end
end
