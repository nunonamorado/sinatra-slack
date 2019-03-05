# frozen_string_literal: true

require_relative './helpers/command_request'
require_relative './helpers/channel'
require_relative './helpers/slack_response'
require_relative './helpers/action_request'

module Sinatra
  module Slack
    # Instance level helper methods
    module InstanceHelpers
      def command
        @command ||= Helpers::CommandRequest.new(params)
      end

      def action
        @action ||= Helpers::ActionRequest.parse(params)
      end

      def channel
        @channel ||= Helpers::Channel.parse(params)
      end

      def slack_response(callback_id)
        s_resp = Helpers::SlackResponse.new(callback_id)
        yield s_resp if block_given?
        s_resp
      end

      def slack_error_notification
        slack_response '' do |r|
          r.text = 'Ups, something went wrong'
        end
      end

      def handle_request(request_handler:, request_params:, quick_reply: '...')
        EM.defer do
          deferred_message = request_handler.bind(self).call(*request_params)
          channel.send(deferred_message)
        rescue StandardError => ex
          logger.error ex.full_message
          channel.send(slack_error_notification)
        end

        body quick_reply
      end

      # Checks for Slack defined HTTP headers
      # and computes the request signature (HMAC). If provided signature
      # is the same as the computed one, the request is valid.
      #
      # Go to this page for the verification process:
      # https://api.slack.com/docs/verifying-requests-from-slack
      def authorized?
        logger.warn 'Missing Slack signing token' unless settings.slack_secret
        return true unless settings.slack_secret

        valid_headers? &&
          compute_signature(settings.slack_secret) == slack_signature
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
  end
end
