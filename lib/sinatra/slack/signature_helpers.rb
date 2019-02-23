# frozen_string_literal: true

module Sinatra
  module Slack
    # Helper methods for Slack request validation
    module SignatureHelpers
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
