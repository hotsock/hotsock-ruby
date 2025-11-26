# frozen_string_literal: true

require_relative "helper"

describe Hotsock do
  def setup
    Hotsock.reset_config!
  end

  it "has a default config" do
    assert_instance_of Hotsock::Config, Hotsock.send(:default_config)
  end

  it "has a default issuer" do
    assert_instance_of Hotsock::Issuer, Hotsock.send(:default_issuer)
  end

  it "has a default publisher" do
    assert_instance_of Hotsock::Publisher, Hotsock.send(:default_publisher)
  end

  it "configure takes a block to set default config" do
    Hotsock.configure do |config|
      config.aws_region = "us-east-1"
    end
    assert_equal "us-east-1", Hotsock.send(:default_config).aws_region
  end

  it "publish message with default config" do
    Hotsock.configure do |config|
      config.aws_region = "us-east-1"
      config.publish_function_arn = "arn:aws:lambda:us-east-1:111111111111:function:Hotsock-Publishing-J718QESEO304-PublishFunction-t8ixecGdSgel"
    end
    response = Hotsock.publish_message(event: "chat", channel: "group1", data: "hey")
    assert_equal 200, response.status_code
    assert_equal '{"id":null}', response.payload.read
  end

  it "issue token with default config" do
    Hotsock.configure do |config|
      config.issuer_private_key = TEST_ES256_PRIVATE_KEY_PEM
    end
    token = Hotsock.issue_token({foo: "bar"})

    decoded = JWT.decode token, OpenSSL::PKey::EC.new(TEST_ES256_PRIVATE_KEY_PEM), true, {algorithm: "ES256"}
    assert_equal [{"foo" => "bar"}, {"typ" => "JWT", "alg" => "ES256"}], decoded
  end

  it "has a version" do
    assert_operator Hotsock::VERSION, :>=, "1"
  end
end
