# Hotsock Ruby Library

The Hotsock Ruby library provides convenient access to [Hotsock](https://www.hotsock.io) message publishing APIs and JWT signing from applications written in Ruby.

## Installation

You can install the gem with:

```sh
gem install hotsock
```

### Requirements

- Ruby 3.1+.

### Bundler

```ruby
source "https://rubygems.org"

gem "hotsock"
```

## Usage

The library needs to be configured with information specific to your Hotsock installation.

```ruby
require "hotsock"

# Setup the default configuration
Hotsock.configure do |config|
  config.publish_function_arn = "..."
  config.aws_region = "us-east-1"
  # ... see below for all `configure` options
end

# Publish a message
Hotsock.publish_message(
  channel: "user.1",
  event: "user.updated",
  data: user.attributes
  # ... see below for all `publish_message` options
)

# Issue a JWT. `issue_token` takes an options hash of claims that will be
# included in the token payload.
token = Hotsock.issue_token(
  channels: {
    "user.#{current_user.id}": {
      subscribe: true
    }
  },
  exp: Time.now.to_i + 30,
  iat: Time.now.to_i,
  scope: "connect",
  uid: current_user.id.to_s,
  umd: current_user.metadata_hash
)
# => "eyJ0eXAiOiJKV1QiLCJraWQiOiI5NTYxNmI3MCIsI..."
```

### Multiple configurations

For apps that need to use multiple configurations during the lifetime of a process, like when interacting with multiple Hotsock installations, it's also possible to configure any number of publishers or issuers.

```ruby
require "hotsock"

eastConfig = Hotsock::Config.new
eastConfig.aws_region = "us-east-1"
eastConfig.publish_function_arn = "arn:aws:lambda:us-east-1:111111111111:function:Hotsock-Publishing-J718-PublishFunction-t8ix"

westConfig = Hotsock::Config.new
westConfig.aws_region = "us-west-2"
westConfig.publish_function_arn = "arn:aws:lambda:us-west-2:111111111111:function:Hotsock-Publishing-UUA5-PublishFunction-f5h8"

eastPublisher = Hotsock::Publisher.new(eastConfig)
eastPublisher.publish_message(...)

westPublisher = Hotsock::Publisher.new(westConfig)
westPublisher.publish_message(...)
```

It's safe (and recommended) to use a single instance of `Hotsock::Publisher` or `Hotsock::Issuer` across threads. Do not create a publisher for each message or an issuer for each token. Doing so will cause performance issues when obtaining AWS credentials. It will also slow down token issuing because the private key will need to be loaded for each token.

### `configure`

You typically call `configure` once when your application is starting up. If using Rails, place your call to `configure` in an initializer.

```ruby
require "hotsock"

Hotsock.configure do |config|
  # The Amazon Resource Name (Arn) of the Lambda function used to publish
  # Hotsock messages. Grab the value from `PublishFunctionArn` in your
  # installation's CloudFormation stack output. (required)
  config.publish_function_arn = "arn:aws:lambda:us-east-1:111111111111:function:Hotsock-Publishing-J718-PublishFunction-t8ix"

  # The AWS region where your Hotsock installation resides. (required)
  config.aws_region = "us-east-1"

  # If using static IAM user credentials to authorize access to invoke the
  # message publishing Lambda function, specify the user's Access Key ID and
  # Secret Access Key. (optional)
  config.aws_access_key_id = "AKIAIOSFODNN7EXAMPLE"
  config.aws_secret_access_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

  # If the IAM principal (user or role) that you are authorizing as must assume
  # another role to publish messages to the Lambda function, specify the role
  # that must be assumed. (optional)
  config.aws_assume_role_arn = "arn:aws:iam::111111111111:role/MyRoleToAssume"

  # If specifying `aws_assume_role_arn`, you can specify a session name. If
  # unspecified and assuming a role, this will be set to
  # "hotsock-ruby-#{Hotsock::VERSION}"
  # (optional)
  config.aws_assume_role_session_name = "my-application-name"

  # If required by your administrator when assuming a role, specify an
  # External ID. (optional)
  config.aws_assume_role_external_id = "6f4c10321f"

  # If using this library for signing tokens, this is the private key.
  # Committing this key to source control is not recommended. Instead consider
  # using environment variables, Rails encrypted credentials, AWS Parameter
  # Store, etc. and loading this key from there. For ES256 (ECDSA using P-256
  # and SHA-256), this key must be in PEM format. Don't use the key below!
  # Generate your own! (optional)
  config.issuer_private_key = "-----BEGIN EC PRIVATE KEY-----\nMIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg72ab3fXPvtD2iIQQ\n/RWiZh8WA6T9u6JNhEuy1DPSFpuhRANCAASmEDhCts7/LkmooXH1tMhyh9Qn94e3\ny3e/UtmnnAYMPwro8iySvqEUrYaDUqQ3iMjYpf+mvxOFmCy97MsBj/pu\n-----END EC PRIVATE KEY-----"

  # The algorithm to use when signing with the above key. Defaults to ES256.
  # Supports HS256, HS384, HS512, ES256, ES384, ES512, RS256, RS384, RS512.
  config.issuer_key_algorithm = "ES256"

  # Sets the `kid` JWT header to this value for all issued tokens. (optional)
  config.issuer_key_id = "95616b70"

  # Sets the default value of the `aud` JWT payload claim to this value for
  # issued tokens. Override by setting `aud` in the claims hash passed to
  # `issue_token`. Ensure this matches the required audience claim required by
  # your Hotsock installation configuration. (optional)
  config.issuer_aud_claim = "hotsock"

  # Sets the default value of the `iat` JWT payload claim to the timestamp when
  # the token is generated. Override by setting `iat` in the claims hash passed
  # to `issue_token`. (optional, false by default)
  config.issuer_iat_claim = true

  # Sets the default value of the `iss` JWT payload claim to this value for
  # issued tokens. Override by setting `iss` in the claims hash passed to
  # `issue_token`. (optional)
  config.issuer_iss_claim = "my-application-name"

  # Sets the default value of the `jti` JWT payload claim to a unique ID (UUID)
  # when the token is generated. Override by setting `jti` in the claims hash
  # passed to `issue_token`. (optional, false by default)
  config.issuer_jti_claim = true

  # Sets the default value of the `exp` JWT payload claim to this many seconds
  # from the time that the token was issued. Override by setting `exp` in the
  # claims hash passed to `issue_token`. (optional)
  config.issuer_token_ttl = 10
end
```

### `Hotsock.publish_message` or `Hotsock::Publisher#publish_message`

The `publish_message` method directly invokes the AWS Lambda function specified in `config.publish_function_arn`. Supported attributes are [documented here](https://www.hotsock.io/docs/server-api/publish-messages).

`publish_message` returns the raw `Aws::Lambda::Types::InvocationResponse` struct. The reason for this is because the actual response body is rarely needed - parsing the JSON and returning another object for each message would consume unnecessary cycles in the majority of cases.

A case where you may want the response is when `eager_id_generation` is `true`. In this case you can access the payload like the following. This can obviously be shortened in a real application, but is illustrated in multiple steps here to clarify how it works.

```ruby
lambda_response = Hotsock.publish_message(channel: "mychannel", event: "myevent", eager_id_generation: true)
# => #<struct Aws::Lambda::Types::InvocationResponse
#  status_code=200,
#  function_error=nil,
#  log_result=nil,
#  payload=#<StringIO:0x000000010af76290>,
#  executed_version="$LATEST">
hotsock_response = lambda_response.payload.read
# => "{\"id\":\"01HBM6KJCPNZK11H79ZSHGAEE9\",\"channel\":\"mychannel\",\"event\":\"myevent\"}"
message_id = JSON.load(response)["id"]
# => "01HBM6KJCPNZK11H79ZSHGAEE9"
```

### `Hotsock.issue_token` or `Hotsock::Issuer#issue_token`

The `issue_token` method locally signs and returns a JSON Web Token (JWT) using the key specified in `config.issuer_private_key`. It takes a single argument with a `Hash` of payload claims. This can be used to issue a JWT for anything, but provides some configuration options with Hotsock in mind. Hotsock-supported token claims are [documented here](https://www.hotsock.io/docs/connection/claims).

At a minimum, Hotsock requires an `exp` claim to produce a valid token. Here's an example issuing a token that is valid for 30 seconds. You'll likely want additional claims.

```ruby
Hotsock.issue_token(exp: Time.now.to_i + 30, scope: "connect")
# => "eyJ0eXAiOiJKV1QiLCJraWQiOiI5NTYxNmI3MCIsImFsZyI6IkhTMjU2In0.eyJleHAiOjE2OTYxMTcwNTIsInNjb3BlIjoiY29ubmVjdCJ9.CRam2nIGu55tIGRdXmU2rBpg2IVWzrBRmroSVquhg5I"
```

This translates to the following decoded token.

```json
{
  "typ": "JWT",
  "kid": "95616b70",
  "alg": "ES256"
}
{
  "exp": 1696117052,
  "scope": "connect"
}
```

## AWS Permissions

If your application is running on EC2, ECS, Lambda, or another service that provides a built-in role (recommended), there is no need to specify credentials when calling `Hotsock.configure`. They will be loaded and refreshed automatically from the instance, task, or function role.

Regardless of the AWS principal type, this role or user must be granted `lambda:InvokeFunction` permission to publish messages to the Hotsock publisher Lambda function. The policy might look something like this (replace the example function Arn with your `PublishFunctionArn`) and attach the policy to your role or user:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["lambda:InvokeFunction"],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:lambda:us-east-1:111111111111:function:Hotsock-Publishing-J718-PublishFunction-t8ix"
      ]
    }
  ]
}
```

## License

See [LICENSE](LICENSE).
