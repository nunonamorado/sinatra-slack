require "sinatra/base"
require_relative "./class_helpers"

module Sinatra
  module Slack
    module Actions
      extend Slack::ClassHelpers

      def actions_endpoint(path, defer: true, message: nil)
        settings.post(path) do
          action_pattern = self.class.get_pattern(action.name)

          halt 400, "Unknown action" unless action_pattern

          request_handler = self.class.get_handler(action.name)
          request_params = action_pattern.params(action.name).values || []
          request_params << action.value

          handle_request(defer, message, request_handler, request_params)
        end
      end

      Actions.send(:alias_method, :action, :register_handler)
    end
  end

  register Slack::Actions
end

