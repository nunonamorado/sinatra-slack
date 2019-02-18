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

          action_pattern = self.class.match_action(action.name)

          halt 400, "Unknown Action" unless action_pattern

          action_handler = self.class.get_handler(action_pattern)
          action_params = action_pattern.params(action.name).values

          action_params << action.value

          if defer
            EM.defer do
              message = action_handler.bind(self).call(*action_params)
              channel.send(message)
            end

            return (message.nil? ? "Working..." : message)
          end

          action_handler.bind(self).call(*action_params)
        end
      end

      def action(action_signature, &block)
        pattern = parse_action_signature(action_signature)
        method_name = get_handler_name(pattern)
        define_method(method_name, &block)
      end

      def get_handler_name(pattern)
        "#{pattern.safe_string}_action_handler"
      end

      def get_handler(pattern)
        method_name = get_handler_name(pattern)
        instance_method method_name
      end

      def match_action(signature)
        @actions.find {|p| p.match(signature)}
      end

      private

      def parse_action_signature(signature)
        @actions ||= []
        @actions << Mustermann.new(signature)
        @actions.last
      end
    end
  end

  register Slack::Actions
end

