# frozen_string_literal: true

require_relative "streams_channel"

module Hotsock
  module Turbo
    module StreamsHelper
      def hotsock_turbo_stream_from(*streamables, **attributes)
        channel = Hotsock::Turbo::StreamsChannel.new
        channel_name = channel.broadcasting_for(streamables)
        token = create_subscription_token(channel_name)
        set_attributes(attributes, token, channel_name)

        tag.hotsock_turbo_stream_source(**attributes)
      end

      private

      def create_subscription_token(channel_name)
        Hotsock.issue_token scope: "subscribe", channels: {[channel_name] => {subscribe: true}}
      end

      def set_attributes(attributes, token, channel_name)
        attributes[:"data-token"] = token
        attributes[:"data-channel"] = channel_name
        attributes[:"data-user-id"] = uid
      end

      def uid
        "" # if !current_user
        # current_user&.id.to_s
      end
    end
  end
end
