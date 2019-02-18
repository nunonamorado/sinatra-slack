require "sinatra/base"
require "mustermann"

module Sinatra
  module Slack
    module Commands
      def commands_endpoint(path, defer: true, message: nil)
        settings.post(path) do
          logger.info "Received: #{command}"

          signature = "#{command.command} #{command.text}"
          command_pattern = self.class.match_signature(signature)

          halt 400, "Unknown Command" unless command_pattern

          command_handler = self.class.get_handler(command_pattern)
          command_params = command_pattern.params(signature).values

          if defer
            EM.defer do
              message = command_handler.bind(self).call(*command_params)
              channel.send(message)
            end

            return (message.nil? ? "Working..." : message)
          end

          command_handler.bind(self).call(*command_params)
        end
      end

      def command(command_signature, &block)
        pattern = parse_command_signature(command_signature)
        method_name = get_handler_name(pattern)
        define_method(method_name, &block)
      end

      def get_handler_name(pattern)
        "#{pattern.safe_string}_handler"
      end

      def get_handler(pattern)
        method_name = get_handler_name(pattern)
        instance_method method_name
      end

      def match_signature(signature)
        @commands.find {|p| p.match(signature)}
      end

      private

      def parse_command_signature(signature)
        @commands ||= []
        @commands << Mustermann.new(signature)
        @commands.last
      end
    end
  end

  register Slack::Commands
end
