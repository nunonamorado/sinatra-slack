require "sinatra/base"
require_relative "./class_helpers"

module Sinatra
  module Slack
    module Commands
      extend Slack::ClassHelpers

      def commands_endpoint(path, defer: true, message: nil)
        settings.post(path) do
          signature = "#{command.command} #{command.text}"
          command_pattern = self.class.get_pattern(signature)

          halt 400, "Unknown Command" unless command_pattern

          request_handler = self.class.get_handler(signature)
          request_params = command_pattern.params(signature).values

          handle_request(defer, message, request_handler, request_params)
        end
      end

      def command(signature, &block)
        register_handler(signature, &block)
      end
    end
  end

  register Slack::Commands
end
