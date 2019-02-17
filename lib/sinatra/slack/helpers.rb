require "sinatra/base"
require_relative "./helpers/command_request"
require_relative "./helpers/channel"
require_relative "./helpers/slack_response"
require_relative "./helpers/action_request"

module Sinatra
  module Slack
    module Helpers
      def command
        @command ||= Sinatra::Slack::Helpers::CommandRequest.new(params)
      end

      def action
        @action ||= Sinatra::Slack::Helpers::ActionRequest.parse(params)
      end

      def channel
        @channel ||= Sinatra::Slack::Helpers::Channel.parse(params)
      end

      def slack_response(callback_id = "", &block)
        s_resp = Sinatra::Slack::Helpers::SlackResponse.new(callback_id)
        yield s_resp if block_given?
        s_resp
      end
    end
  end
end
