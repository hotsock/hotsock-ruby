# frozen_string_literal: true

require "hotsock/version"
require "hotsock/config"
require "hotsock/issuer"
require "hotsock/publisher"

module Hotsock
  class << self
    def configure(&block)
      yield default_config
    end

    def publish_message(channel:, event:, **options)
      default_publisher.publish_message(channel:, event:, **options)
    end

    def issue_token(payload = {})
      default_issuer.issue_token(payload)
    end

    private

    def default_config
      @default_config ||= Hotsock::Config.new
    end

    def default_publisher
      @default_publisher ||= Hotsock::Publisher.new(default_config)
    end

    def default_issuer
      @default_issuer ||= Hotsock::Issuer.new(default_config)
    end
  end
end
