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

      def handle_request(defer, message, request_handler, request_params)
        if defer
          EM.defer do
            deferred_message = request_handler.bind(self).call(*request_params)
            channel.send(deferred_message)
          end

          return message
        end

        request_handler.bind(self).call(*request_params)
      end
    end
  end
end
