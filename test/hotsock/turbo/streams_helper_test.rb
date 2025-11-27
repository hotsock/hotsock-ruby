require_relative "../../helper"
require "ostruct"
require "rails"
require "action_controller/railtie"
require "hotsock/engine"

unless defined?(TestApp)
  class TestApp < Rails::Application
    config.eager_load = false
    config.secret_key_base = "test"
  end
  TestApp.initialize!
end

class DummyController < ActionController::Base
  include ActionView::Helpers::TagHelper
  include Hotsock::Turbo::StreamsHelper

  def view_context
    self
  end
end

describe Hotsock::Turbo::StreamsHelper do
  before do
    @controller = DummyController.new
    @original_resolver = Hotsock::Turbo.config.uid_resolver
    Hotsock::Turbo.config.uid_resolver = ->(view) { "test-uid" }
  end

  after do
    Hotsock::Turbo.config.uid_resolver = @original_resolver
  end

  it "it generates attributes" do
    streamables = %w[stream1 stream2]
    expected_stream_name = "stream1,stream2"

    Hotsock.stub :issue_token, "fake-token" do
      result = @controller.hotsock_turbo_stream_from(*streamables, class: "test-class")

      assert_includes result, "data-channel=\"#{expected_stream_name}\""
      assert_includes result, "data-token=\"fake-token\""
      assert_includes result, "data-user-id=\"test-uid\""
      assert_includes result, "class=\"test-class\""
      assert_includes result, "<hotsock-turbo-stream-source"
    end
  end

  it "uses custom uid_resolver" do
    Hotsock::Turbo.config.uid_resolver = ->(view) { "custom-user-123" }

    Hotsock.stub :issue_token, "fake-token" do
      result = @controller.hotsock_turbo_stream_from("stream")
      assert_includes result, "data-user-id=\"custom-user-123\""
    end
  end

  it "returns empty string when uid_resolver is nil" do
    Hotsock::Turbo.config.uid_resolver = nil

    Hotsock.stub :issue_token, "fake-token" do
      result = @controller.hotsock_turbo_stream_from("stream")
      assert_includes result, "data-user-id=\"\""
    end
  end
end
