require "sinatra/base"
require "mustermann"

require_relative "./helpers/action_request"
require_relative "./helpers/slack_response"

module Sinatra
  module Slack
    module Actions

      def actions_endpoint(path, defer: true, message: nil)
        settings.post(path) do
          logger.info "Received: #{params}"

          action_handler = self.class.match_action(action.name)

          halt 400, "Unknown Action" unless action_handler

          action_value = action.value

          if defer
            EM.defer do
              message = action_handler.bind(self).call(action_value)
              channel.send(message)
            end

            return (message.nil? ? "Working..." : message)
          end

          action_handler.bind(self).call(action_value)
        end
      end

      def action(action_name, &block)
        method_name = get_handler_name(action_name)
        define_method(method_name, &block)
      end

      def get_handler_name(action_name)
        "#{action_name}_action_handler"
      end

      def match_action(action_name)
        method_name = get_handler_name(action_name)
        instance_method method_name if self.instance_methods.any? { |m| m.to_s == method_name }
      end
    end
  end

  register Slack::Actions
end

