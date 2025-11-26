# frozen_string_literal: true

require_relative "../helper"
require "json"

describe Hotsock::Publisher do
  let(:config) do
    Hotsock::Config.new.tap do |config|
      config.aws_region = "us-east-1"
      config.publish_function_arn = "arn:aws:lambda:us-east-1:111111111111:function:Hotsock-Publishing-J718QESEO304-PublishFunction-t8ixecGdSgel"
    end
  end

  it "publishes a minimal message" do
    expected_payload = JSON.dump({event: "myevent", channel: "mychannel"})

    mock = Minitest::Mock.new
    mock.expect(:invoke, nil, function_name: config.publish_function_arn, payload: expected_payload)

    Aws::Lambda::Client.stub :new, mock do
      publisher = Hotsock::Publisher.new(config)
      publisher.publish_message(event: "myevent", channel: "mychannel")
    end

    mock.verify
  end

  it "publishes a message with known optional parameters" do
    expected_payload = JSON.dump({
      event: "myevent",
      channel: "mychannel",
      data: "mydata",
      deduplicationId: "noduplicates",
      eagerIdGeneration: true,
      emitPubSubEvent: true,
      store: 100
    })

    mock = Minitest::Mock.new
    mock.expect(:invoke, nil, function_name: config.publish_function_arn, payload: expected_payload)

    Aws::Lambda::Client.stub :new, mock do
      publisher = Hotsock::Publisher.new(config)
      publisher.publish_message(
        event: "myevent",
        channel: "mychannel",
        data: "mydata",
        deduplication_id: "noduplicates",
        eager_id_generation: true,
        emit_pub_sub_event: true,
        store: 100
      )
    end

    mock.verify
  end

  it "publishes a message with unknown parameters" do
    expected_payload = JSON.dump({
      event: "myevent",
      channel: "mychannel",
      someNewParam: true,
      anotherNewParam: "stringy"
    })

    mock = Minitest::Mock.new
    mock.expect(:invoke, nil, function_name: config.publish_function_arn, payload: expected_payload)

    Aws::Lambda::Client.stub :new, mock do
      publisher = Hotsock::Publisher.new(config)
      publisher.publish_message(
        event: "myevent",
        channel: "mychannel",
        someNewParam: true,
        anotherNewParam: "stringy"
      )
    end

    mock.verify
  end
end
