# frozen_string_literal: true

require "hotsock/turbo/config"
require "hotsock/turbo/streams_channel"
require "hotsock/turbo/streams_helper"

module Hotsock
  module Turbo
    class << self
      def configure
        yield config
      end

      def config
        @config ||= Config.new
      end
    end
  end
end
