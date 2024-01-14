$LOAD_PATH.unshift "./lib"

require 'brc-ruby'

namespace :brc do
  task :clear_sidekiq do
    puts BrcRuby::Utils.clear_sidekiq!
  end

  task :single_thread do
    BrcRuby::Utils.pretty_print("single thread") do
      BrcRuby::SingleThread.run
    end
  end

  task :async do
    BrcRuby::Utils.pretty_print("async") do
      BrcRuby::AsyncRunner.run
    end
  end
end
