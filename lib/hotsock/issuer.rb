# frozen_string_literal: true

require "jwt"
require "securerandom"

module Hotsock
  class Issuer
    def initialize(config)
      @config = config
    end

    def issue_token(claims = {})
      headers = {typ: "JWT"}
      if @config.issuer_key_id
        headers[:kid] = @config.issuer_key_id
      end

      payload = {}
      now_i = Time.now.to_i
      if @config.issuer_aud_claim
        payload[:aud] = @config.issuer_aud_claim
      end
      if @config.issuer_iat_claim == true
        payload[:iat] = now_i
      end
      if @config.issuer_iss_claim
        payload[:iss] = @config.issuer_iss_claim
      end
      if @config.issuer_jti_claim == true
        payload[:jti] = SecureRandom.uuid
      end
      if @config.issuer_token_ttl.to_i > 0
        payload[:exp] = now_i + @config.issuer_token_ttl.to_i
      end

      JWT.encode(payload.merge(claims), @config.issuer_key, @config.issuer_key_algorithm, headers)
    end
  end
end
