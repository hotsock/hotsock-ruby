module Hotsock
  class Engine < Rails::Engine
    isolate_namespace Hotsock
    config.hotsock = ActiveSupport::OrderedOptions.new

    initializer "hotsock.turbo" do
      require "hotsock/turbo/streams_channel"
      require "hotsock/turbo/streams_helper"

      ActiveSupport.on_load(:action_view) do
        include Hotsock::Turbo::StreamsHelper
      end
    end
  end
end
