# frozen_string_literal: true

require_relative "../helper"

class HotsockConfigTest < TLDR
  def test_accepts_configuration_options
    config = Hotsock::Config.new
    config.aws_region = "us-east-1"
    config.aws_access_key_id = "AKIAIOSFODNN7EXAMPLE"
    config.aws_secret_access_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    config.aws_assume_role_arn = "arn:aws:iam::111111111111:role/MyRoleToAssume"
    config.aws_assume_role_session_name = "my-application-name"
    config.aws_assume_role_external_id = "6f4c10321f"
    config.publish_function_arn = "arn:aws:lambda:us-east-1:111111111111:function:Hotsock-Publishing-J718QESEO304-PublishFunction-t8ixecGdSgel"
    config.issuer_private_key = TEST_ES256_PRIVATE_KEY_PEM
    config.issuer_key_id = "95616b70"
    config.issuer_aud_claim = "hotsock"
    config.issuer_iat_claim = true
    config.issuer_iss_claim = "me"
    config.issuer_jti_claim = true

    assert_equal "us-east-1", config.aws_region
    assert_equal "AKIAIOSFODNN7EXAMPLE", config.aws_access_key_id
    assert_equal "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY", config.aws_secret_access_key
  end

  def test_requires_aws_region_if_reader_is_called
    assert_raises(ArgumentError) { Hotsock::Config.new.aws_region }
  end

  def test_requires_signing_private_key_if_reader_is_called
    assert_raises(ArgumentError) { Hotsock::Config.new.issuer_private_key }
  end

  def test_returns_valid_signing_key
    config = Hotsock::Config.new
    config.issuer_private_key = TEST_ES256_PRIVATE_KEY_PEM
    assert_instance_of OpenSSL::PKey::EC, config.issuer_key
  end
end
