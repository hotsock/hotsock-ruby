# frozen_string_literal: true

require_relative "../helper"
require "jwt"

describe Hotsock::Issuer do
  context "ES256" do
    it "issues a token" do
      config = Hotsock::Config.new
      config.issuer_private_key = TEST_ES256_PRIVATE_KEY_PEM
      config.issuer_key_id = "95616b70"
      config.issuer_aud_claim = "hotsock"
      config.issuer_iss_claim = "me"

      issuer = Hotsock::Issuer.new(config)
      exp = Time.now.to_i + 5
      token = issuer.issue_token(exp:)
      decoded = JWT.decode token, OpenSSL::PKey::EC.new(TEST_ES256_PUBLIC_KEY_PEM), true, {algorithm: config.issuer_key_algorithm}
      assert_equal [{"aud" => config.issuer_aud_claim, "iss" => "me", "exp" => exp}, {"typ" => "JWT", "kid" => "95616b70", "alg" => "ES256"}], decoded
    end

    it "allows overriding registered claims" do
      config = Hotsock::Config.new
      config.issuer_private_key = TEST_ES256_PRIVATE_KEY_PEM
      config.issuer_aud_claim = "hotsock"
      config.issuer_iss_claim = "me"
      config.issuer_jti_claim = true
      config.issuer_iat_claim = true
      config.issuer_token_ttl = 10

      issuer = Hotsock::Issuer.new(config)
      now = Time.now
      exp = now.to_i + 5
      token = issuer.issue_token(exp:, aud: "hotsock-override", iss: "you", iat: now.to_i - 5, jti: "less-unique")
      decoded = JWT.decode token, OpenSSL::PKey::EC.new(TEST_ES256_PUBLIC_KEY_PEM), true, {algorithm: config.issuer_key_algorithm}
      assert_equal [{"aud" => "hotsock-override", "iat" => now.to_i - 5, "iss" => "you", "jti" => "less-unique", "exp" => exp}, {"typ" => "JWT", "alg" => "ES256"}], decoded
    end

    it "allows generating unique jti claim" do
      config = Hotsock::Config.new
      config.issuer_private_key = TEST_ES256_PRIVATE_KEY_PEM
      config.issuer_jti_claim = true

      issuer = Hotsock::Issuer.new(config)
      exp = Time.now.to_i + 5
      token = issuer.issue_token(exp:)
      decoded = JWT.decode token, OpenSSL::PKey::EC.new(TEST_ES256_PUBLIC_KEY_PEM), true, {algorithm: config.issuer_key_algorithm}
      assert decoded[0]["jti"].length == 36
    end

    it "allows generating iat claim with issued at timestamp" do
      config = Hotsock::Config.new
      config.issuer_private_key = TEST_ES256_PRIVATE_KEY_PEM
      config.issuer_iat_claim = true

      issuer = Hotsock::Issuer.new(config)
      exp = Time.now.to_i + 5
      token = issuer.issue_token(exp:)
      decoded = JWT.decode token, OpenSSL::PKey::EC.new(TEST_ES256_PUBLIC_KEY_PEM), true, {algorithm: config.issuer_key_algorithm}
      assert decoded[0]["iat"] >= Time.now.to_i
    end

    it "allows setting token ttl for default token expiration" do
      config = Hotsock::Config.new
      config.issuer_private_key = TEST_ES256_PRIVATE_KEY_PEM
      config.issuer_token_ttl = 10

      issuer = Hotsock::Issuer.new(config)
      now = Time.now
      token = issuer.issue_token
      decoded = JWT.decode token, OpenSSL::PKey::EC.new(TEST_ES256_PUBLIC_KEY_PEM), true, {algorithm: config.issuer_key_algorithm}
      assert decoded[0]["exp"] >= now.to_i + 10
    end

    it "cannot issue token for invalid private key" do
      config = Hotsock::Config.new
      config.issuer_private_key = "INVALID KEY"
      issuer = Hotsock::Issuer.new(config)
      assert_raises OpenSSL::PKey::ECError do
        issuer.issue_token
      end
    end
  end

  context "RS256" do
    it "issues a token" do
      config = Hotsock::Config.new
      config.issuer_private_key = TEST_RS256_PRIVATE_KEY_PEM
      config.issuer_key_algorithm = "RS256"

      issuer = Hotsock::Issuer.new(config)
      exp = Time.now.to_i + 5
      token = issuer.issue_token(exp:)
      decoded = JWT.decode token, OpenSSL::PKey::RSA.new(TEST_RS256_PUBLIC_KEY_PEM), true, {algorithm: config.issuer_key_algorithm}
      assert_equal [{"exp" => exp}, {"typ" => "JWT", "alg" => "RS256"}], decoded
    end
  end

  context "HS256" do
    it "issues a token" do
      config = Hotsock::Config.new
      config.issuer_private_key = TEST_HS256_SECRET
      config.issuer_key_algorithm = "HS256"

      issuer = Hotsock::Issuer.new(config)
      exp = Time.now.to_i + 5
      token = issuer.issue_token(exp:)
      decoded = JWT.decode token, TEST_HS256_SECRET, true, {algorithm: config.issuer_key_algorithm}
      assert_equal [{"exp" => exp}, {"typ" => "JWT", "alg" => "HS256"}], decoded
    end
  end

  context "unsupported algorithm" do
    it "raises argument error" do
      config = Hotsock::Config.new
      config.issuer_private_key = TEST_HS256_SECRET
      config.issuer_key_algorithm = "ED25519"

      issuer = Hotsock::Issuer.new(config)
      assert_raises ArgumentError do
        issuer.issue_token
      end
    end
  end
end
