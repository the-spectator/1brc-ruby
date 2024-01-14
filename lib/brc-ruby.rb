# frozen_string_literal: true

require 'bundler'
Bundler.require

# utils
require "brc-ruby/utils"
require "brc-ruby/utils/config"

# implementations
require "brc-ruby/single_thread"
require "brc-ruby/async_runner"

module BrcRuby
  module_function
end
