require 'sidekiq'
require 'sidekiq-pro'


Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:6379" }
end

class A
  include Sidekiq::Job
  def perform(lines)
    puts lines.sum
  end

  def on_success(status, options)
    puts("😀"*100)
    puts({status:, options:})
    puts("😀"*100)
  end
end

batch = Sidekiq::Batch.new
batch.on(:success, A, 'filename' => 'xyz')

batch.jobs do
  # file = File.open('measurements.txt')

  # file.lazy.each_slice(1_000) do |lines|
  #   work_queue << lines
  # end

  (1..10_000).lazy.each_slice(1000) do |lines|
    A.perform_async(lines)
  end
end
