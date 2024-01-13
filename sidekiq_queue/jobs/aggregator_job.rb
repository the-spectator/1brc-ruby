class AggregatorJob
  include Sidekiq::Job

  def perform(total_stats_jobs)
    agrregate = {}
    processed_count = 0

    Sidekiq.redis do |conn|
      while (_key, redis_city_hash = conn.brpop("1brc", timeout: 10))
        processed_count += 1
        debug_print { "Processed #{processed_count}" }

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

        break if processed_count == total_stats_jobs
      end
    end
    debug_print { "Total processed jobs #{processed_count} & stats jobs #{total_stats_jobs}" }

    Sidekiq.redis do |conn|
      conn.lpush("1brc-result", agrregate.to_json)
    end
  end

  def debug_print(&block)
    return if ENV['debug'] != true
    puts(block.call)
  end
end
