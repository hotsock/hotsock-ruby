# frozen_string_literal: true

require "openssl"

module Hotsock
  class Config
    def aws_region
      @aws_region or raise ArgumentError, "Hotsock configuration requires an aws_region"
    end
    attr_writer :aws_region

    attr_accessor :aws_access_key_id
    attr_accessor :aws_secret_access_key
    attr_accessor :aws_assume_role_arn
    attr_accessor :aws_assume_role_session_name
    attr_accessor :aws_assume_role_external_id
    attr_accessor :publish_function_arn
    attr_accessor :issuer_aud_claim
    attr_accessor :issuer_iat_claim
    attr_accessor :issuer_iss_claim
    attr_accessor :issuer_jti_claim
    attr_accessor :issuer_token_ttl
    attr_accessor :issuer_key_id

    def issuer_private_key
      @issuer_private_key or raise ArgumentError, "Hotsock configuration requires issuer_private_key for JWT issuing"
    end
    attr_writer :issuer_private_key

    def issuer_key_algorithm
      @issuer_key_algorithm || "ES256"
    end
    attr_writer :issuer_key_algorithm

    def issuer_key
      case issuer_key_algorithm
      when "HS256", "HS384", "HS512"
        @issuer_key ||= issuer_private_key
      when "RS256", "RS384", "RS512"
        @issuer_key ||= OpenSSL::PKey::RSA.new(issuer_private_key)
      when "ES256", "ES384", "ES512"
        @issuer_key ||= OpenSSL::PKey::EC.new(issuer_private_key)
      else
        raise ArgumentError, "Issuer key algorithm must be one of HS256, HS384, HS512, RS256, RS384, RS512, ES256, ES384, ES512"
      end
    end
  end
end
