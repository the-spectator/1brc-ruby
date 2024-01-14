module BrcRuby
  module Utils
    module_function

    def clear_sidekiq!
      Sidekiq.redis { |c| c.flushdb }
    end

    def pretty_print(&work)
      t0 = Time.now
      puts("😀"*100)
      puts("Program started at #{t0}")

      result_string = work.call
      t1 = Time.now

      puts
      puts(result_string)
      puts
      puts("Task completed at #{t1}")
      puts("Time taken to complete the batch #{t1 - t0} seconds")
      puts("😀"*100)
    end

    def debug_print(&block)
      return unless debug?

      puts(block.call)
    end

    def debug?
      BrcRuby::Utils::Config.debug?
    end
  end
end
