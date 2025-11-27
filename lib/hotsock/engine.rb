module Hotsock
  class Engine < Rails::Engine
    isolate_namespace Hotsock

    initializer "hotsock.turbo" do
      require "hotsock/turbo"

      ActiveSupport.on_load(:action_view) do
        include Hotsock::Turbo::StreamsHelper
      end
    end
  end
end
