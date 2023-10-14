# frozen_string_literal: true

require_relative "helper"

class HotsockTest < TLDR
  run_these_together!

  def setup
    Hotsock.reset_config!
  end

  def test_has_a_default_config
    assert_instance_of Hotsock::Config, Hotsock.send(:default_config)
  end

  def test_has_a_default_issuer
    assert_instance_of Hotsock::Issuer, Hotsock.send(:default_issuer)
  end

  def test_has_a_default_publisher
    assert_instance_of Hotsock::Publisher, Hotsock.send(:default_publisher)
  end

  def test_configure_takes_a_block_to_set_default_config
    Hotsock.configure do |config|
      config.aws_region = "us-east-1"
    end
    assert_equal "us-east-1", Hotsock.send(:default_config).aws_region
  end

  def test_publish_message_with_default_config
    Hotsock.configure do |config|
      config.aws_region = "us-east-1"
      config.publish_function_arn = "arn:aws:lambda:us-east-1:111111111111:function:Hotsock-Publishing-J718QESEO304-PublishFunction-t8ixecGdSgel"
    end
    response = Hotsock.publish_message(event: "chat", channel: "group1", data: "hey")
    assert_equal 200, response.status_code
    assert_equal '{"id":null}', response.payload.read
  end

  def test_issue_token_with_default_config
    Hotsock.configure do |config|
      config.issuer_private_key = TEST_ES256_PRIVATE_KEY_PEM
    end
    token = Hotsock.issue_token({foo: "bar"})

    decoded = JWT.decode token, OpenSSL::PKey::EC.new(TEST_ES256_PRIVATE_KEY_PEM), true, {algorithm: "ES256"}
    assert_equal [{"foo" => "bar"}, {"typ" => "JWT", "alg" => "ES256"}], decoded
  end

  def test_it_has_a_version
    assert_operator Hotsock::VERSION, :>=, "1"
  end
end
