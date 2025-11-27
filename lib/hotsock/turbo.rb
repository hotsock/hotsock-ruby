require "hotsock/turbo/config"
require "hotsock/turbo/streams_channel"
require "hotsock/turbo/streams_helper"

module Hotsock
  module Turbo
    class << self
      def configure(&block)
        yield config
      end

      def config
        @config ||= Config.new
      end
    end
  end
end
