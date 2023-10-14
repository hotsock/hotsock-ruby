# frozen_string_literal: true

$LOAD_PATH.unshift(::File.join(::File.dirname(__FILE__), "lib"))

require "hotsock/version"

Gem::Specification.new do |spec|
  spec.name = "hotsock"
  spec.version = Hotsock::VERSION
  spec.authors = ["James Miller"]
  spec.email = ["support@hotsock.io"]
  spec.homepage = "https://www.hotsock.io"
  spec.summary = "Ruby bindings for the Hotsock message publishing APIs and JWT signing"
  spec.description = "Hotsock is a real-time WebSockets service for your web and mobile applications, fully-managed and self-hosted in your AWS account."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  ignored = Regexp.union(
    /\A\.git/,
    /\Atest/
  )
  spec.files = `git ls-files`.split("\n").reject { |f| ignored.match(f) }

  spec.add_dependency "jwt", "~> 2.7"
  spec.add_dependency "aws-sdk-lambda", "~> 1.105"
end
