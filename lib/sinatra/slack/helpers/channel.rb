require "httparty"

module Sinatra
  module Slack
    module Helpers
      class Channel
        def initialize(opts = {})
          @id = opts["channel_id"]
          @name = opts["channel_name"]
          @url = opts["response_url"]
        end

        def send(response)
          options = {
            headers: {
              "Content-type": "application/json"
            },
            body: response.to_json
          }
          HTTParty.post(@url, options)
        end

        def to_s
          "Slack Channel: #{@name}"
        end

        def self.parse(params)
          payload = params.clone
          if payload["payload"]
            payload = JSON.parse(payload["payload"])
            payload["channel_id"] = payload.dig("channel", "id")
            payload["channel_name"] = payload.dig("channel", "name")
          end

          self.new(payload)
        end
      end
    end
  end
end
