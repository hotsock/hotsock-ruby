require_relative "../../helper"
require "ostruct"
require "action_controller"

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
  end

  it "it generates attributes" do
    streamables = %w[stream1 stream2]
    expected_stream_name = "stream1,stream2"

    Hotsock.stub :issue_token, "fake-token" do
      result = @controller.hotsock_turbo_stream_from(*streamables, class: "test-class")

      assert_includes result, "data-channel=\"#{expected_stream_name}\""
      assert_includes result, "data-token=\"fake-token\""
      assert_includes result, "class=\"test-class\""
      assert_includes result, "<hotsock-turbo-stream-source"
    end
  end
end
