# frozen_string_literal: true

require_relative './slack/instance_helpers'
require_relative './slack/signature_helpers'

# Sinatra
module Sinatra
  # Sinatra Module for creating Slack apps with ease
  module Slack
    def self.registered(app)
      app.helpers Slack::InstanceHelpers
    end

    #  Defines a new before action for verifying all requests
    def verify_slack_request(secret)
      before do
        halt 401, 'Invalid Headers' unless authorized?(secret)
      end
    end

    # Defines a new HTTP POST Handler to receive
    # Slash Command notifications.
    def commands_endpoint(path, defer: true, message: nil)
      settings.post(path) do
        signature = "#{command.command} #{command.text}"
        command_pattern = self.class.get_pattern(signature)

        halt 400 unless command_pattern

        request_handler = self.class.get_handler(signature)
        request_params = command_pattern.params(signature).values

        handle_request(defer, message, request_handler, request_params)
      end
    end

    # Defines a new HTTP POST Handler to receive
    # Actions notifications.
    def actions_endpoint(path, defer: true, message: nil)
      settings.post(path) do
        action_pattern = self.class.get_pattern(action.name)

        halt 400 unless action_pattern

        request_handler = self.class.get_handler(action.name)
        request_params = action_pattern.params(action.name).values || []
        request_params << action.value

        handle_request(defer, message, request_handler, request_params)
      end
    end

    # Checks for Slack defined HTTP headers
    # and computes the request signature (HMAC). If provided signature
    # is the same as the computed one, the request is valid.
    #
    # Go to this page for the verification process:
    # https://api.slack.com/docs/verifying-requests-from-slack
    def authorized?(secret)
      valid_headers? && compute_signature(secret) == slack_signature
    end

    def register_handler(signature, &block)
      pattern = parse_signature(signature)
      method_name = get_handler_name(pattern)
      define_method(method_name, &block)
    end
    alias action register_handler
    alias command register_handler

    def get_handler(signature)
      pattern = get_pattern(signature)
      return unless pattern

      method_name = get_handler_name(pattern)
      instance_method method_name
    end

    def get_pattern(signature)
      @patterns.find { |p| p.match(signature) }
    end

    private

    def get_handler_name(pattern)
      "#{pattern.safe_string}_handler"
    end

    def parse_signature(signature)
      @patterns ||= []
      raise StandardError, 'Signature already defined' if get_pattern(signature)

      @patterns << Mustermann.new(signature)
      @patterns.last
    end

    # Helper methods for Slack request validation
    def slack_signature
      @slack_signature ||= env['HTTP_X_SLACK_SIGNATURE']
    end

    def slack_timestamp
      @slack_timestamp ||= env['HTTP_X_SLACK_REQUEST_TIMESTAMP']
    end

    def valid_headers?
      return false unless slack_signature || slack_timestamp

      # The request timestamp is more than five minutes from local time.
      # It could be a replay attack, so let's ignore it.
      (Time.now.to_i - slack_timestamp.to_i).abs <= 60 * 5
    end

    def compute_signature(secret)
      # in case someone already read it
      request.body.rewind

      # From Slack API docs, the "v0" is always fixed for now
      sig_basestring = "v0:#{slack_timestamp}:#{request.body.read}"
      "v0=#{hmac_signed(sig_basestring, secret)}"
    end

    def hmac_signed(to_sign, hmac_key)
      sha256 = OpenSSL::Digest.new('sha256')
      OpenSSL::HMAC.hexdigest(sha256, hmac_key, to_sign)
    end
  end

  register Sinatra::Slack
end
