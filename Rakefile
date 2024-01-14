$LOAD_PATH.unshift "./lib"

require 'brc-ruby'

namespace :brc do
  task :clear_sidekiq do
    puts BrcRuby::Utils.clear_sidekiq!
  end

  task :single_thread do
    BrcRuby::SingleThread.run
  end
end
