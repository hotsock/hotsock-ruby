# frozen_string_literal: true

require "json"
require "aws-sdk-lambda"
require "aws-sdk-sts"

module Hotsock
  class Publisher
    def initialize(config)
      @config = config
    end

    def publish_message(channel:, event:, **options)
      payload = {event:, channel:}
      payload[:data] = options.delete(:data) if options[:data]
      payload[:deduplicationId] = options.delete(:deduplication_id) if options[:deduplication_id]
      payload[:eagerIdGeneration] = options.delete(:eager_id_generation) if options[:eager_id_generation]
      payload[:emitPubSubEvent] = options.delete(:emit_pub_sub_event) if options[:emit_pub_sub_event]
      options.each do |k, v|
        payload[k] = v
      end

      lambda_client.invoke(
        function_name: @config.publish_function_arn,
        payload: JSON.dump(payload)
      )
    end

    private

    def lambda_client
      return @lambda_client if @lambda_client

      options = {region: @config.aws_region}

      if @config.aws_assume_role_arn
        options[:credentials] = assume_role_credentials
      elsif @config.aws_access_key_id || @config.aws_secret_access_key
        options[:credentials] = static_credentials
      end

      @lambda_client ||= Aws::Lambda::Client.new(options)
    end

    def static_credentials
      Aws::Credentials.new(
        @config.aws_access_key_id,
        @config.aws_secret_access_key
      )
    end

    def assume_role_credentials
      Aws::AssumeRoleCredentials.new(
        client: sts_base_client,
        role_arn: @config.aws_assume_role_arn,
        role_session_name: @config.aws_assume_role_session_name || "hotsock-ruby-#{Hotsock::VERSION}",
        external_id: @config.aws_assume_role_external_id
      )
    end

    def sts_base_client
      options = {region: @config.aws_region}

      if @config.aws_access_key_id || @config.aws_secret_access_key
        options[:credentials] = static_credentials
      end

      Aws::STS::Client.new(options)
    end
  end
end
