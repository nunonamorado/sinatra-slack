require "sinatra/base"
require "bcrypt"

module Sinatra
  module Security

    class HMAC_SHA256
      def self.hmac_signed(password, hmac_key)
        Base64.encode64(sha256_hash(password, hmac_key))
      end      

      def self.sha256_hash(password, hmac_key)
        sha256 = OpenSSL::Digest.new('sha256')
        OpenSSL::HMAC.digest(sha256, hmac_key, password)
      end      
    end

    module SlackSignature
      def verify_slack_request(secret)
        @secret = secret

        before do
          slack_request_signature = request["X-Slack-Signature"]
          slack_request_timestamp = request["X-Slack-Request-Timestamp"]

          halt 401, "Unauthorized!" unless slack_request_signature || slack_request_signature

          # The request timestamp is more than five minutes from local time.
          # It could be a replay attack, so let's ignore it.
          halt 401, "Unauthorized!" if (Time.now.to_i - slack_request_timestamp.to_i).abs > 60 * 5

          ##################################################
          #  Go to this page for the verification process: 
          #  https://api.slack.com/docs/verifying-requests-from-slack
          ###################################################         

          # in case someone already read it
          request.body.rewind

          # From Slack API docs, the "v0" is always fixed for now 
          sig_basestring = "v0:#{slack_request_timestamp}:#{request.body}"
          signed = 'v0=' + HMAC_SHA256.hmac_signed(sig_basestring, @secret)

          computed_signature = BCrypt::Password.new(signed)
          slack_signature = BCrypt::Password.new(slack_request_signature)

          halt 401, "Unauthorized!" unless computed_signature == slack_signature
        end
      end
    end    
  end

  register Security::SlackSignature
end