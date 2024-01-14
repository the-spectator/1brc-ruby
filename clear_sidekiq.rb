require 'sidekiq'

puts Sidekiq.redis { |c| c.flushdb }
