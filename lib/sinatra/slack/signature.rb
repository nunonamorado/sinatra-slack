require "sinatra/base"

module Sinatra
  module Slack
    module Signature

      class HMACSHA256
        def self.hmac_signed(to_sign, hmac_key)
          sha256 = OpenSSL::Digest.new('sha256')
          OpenSSL::HMAC.hexdigest(sha256, hmac_key, to_sign)
        end
      end

      ##############################################################
      #  Go to this page for the verification process:             #
      #  https://api.slack.com/docs/verifying-requests-from-slack  #
      ##############################################################
      def verify_slack_request(secret: "")
        before do
          # these are not the HTTP Headers names sent from
          # Slack because Rack renames them
          slack_request_signature = env["HTTP_X_SLACK_SIGNATURE"]
          slack_request_timestamp = env["HTTP_X_SLACK_REQUEST_TIMESTAMP"]

          halt 401, "Unauthorized!" unless slack_request_signature || slack_request_signature

          # The request timestamp is more than five minutes from local time.
          # It could be a replay attack, so let's ignore it.
          halt 401, "Unauthorized!" if (Time.now.to_i - slack_request_timestamp.to_i).abs > 60 * 5

          # in case someone already read it
          request.body.rewind

          # From Slack API docs, the "v0" is always fixed for now
          sig_basestring = "v0:#{slack_request_timestamp}:#{request.body.read}"
          signed = 'v0=' + HMACSHA256.hmac_signed(sig_basestring, secret)

          halt 401, "Unauthorized!" unless signed == slack_request_signature
        end
      end
    end
  end

  register Slack::Signature
end
