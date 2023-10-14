# frozen_string_literal: true

require_relative "../helper"
require "json"

class HotsockPublisherTest < TLDR
  def setup
    @config = Hotsock::Config.new.tap do |config|
      config.aws_region = "us-east-1"
      config.publish_function_arn = "arn:aws:lambda:us-east-1:111111111111:function:Hotsock-Publishing-J718QESEO304-PublishFunction-t8ixecGdSgel"
    end
  end

  def teardown
    Mocktail.reset
  end

  def test_publishes_a_minimal_message
    lambda_client = Mocktail.of_next(Aws::Lambda::Client)
    expected_payload = JSON.dump({event: "myevent", channel: "mychannel"})

    publisher = Hotsock::Publisher.new(@config)
    publisher.publish_message(event: "myevent", channel: "mychannel")

    verify {
      lambda_client.invoke(function_name: @config.publish_function_arn, payload: expected_payload)
    }
  end

  def test_publishes_a_message_with_known_optional_parameters
    lambda_client = Mocktail.of_next(Aws::Lambda::Client)
    expected_payload = JSON.dump({
      event: "myevent",
      channel: "mychannel",
      data: "mydata",
      deduplicationId: "noduplicates",
      eagerIdGeneration: true,
      emitPubSubEvent: true,
      store: 100
    })

    publisher = Hotsock::Publisher.new(@config)
    publisher.publish_message(
      event: "myevent",
      channel: "mychannel",
      data: "mydata",
      deduplication_id: "noduplicates",
      eager_id_generation: true,
      emit_pub_sub_event: true,
      store: 100
    )

    verify {
      lambda_client.invoke(function_name: @config.publish_function_arn, payload: expected_payload)
    }
  end

  def test_publishes_a_message_with_unknown_parameters
    lambda_client = Mocktail.of_next(Aws::Lambda::Client)
    expected_payload = JSON.dump({
      event: "myevent",
      channel: "mychannel",
      someNewParam: true,
      anotherNewParam: "stringy"
    })

    publisher = Hotsock::Publisher.new(@config)
    publisher.publish_message(
      event: "myevent",
      channel: "mychannel",
      someNewParam: true,
      anotherNewParam: "stringy"
    )

    verify {
      lambda_client.invoke(function_name: @config.publish_function_arn, payload: expected_payload)
    }
  end
end
