require "sinatra/base"
require "mustermann"

module Sinatra
  module Slack
    module Commands
      module Helpers
        def defer(&block)                
          Thread.new(&block)        
        end             
      end

      def self.registered(app)
        app.helpers Commands::Helpers
      end

      def commands_endpoint(path)
        settings.post(path) do                
          logger.info "Received: #{params}"        

          signature = "#{params["command"]} #{params["text"]}"        
          command_pattern = self.class.match_signature(signature)

          halt 400, "Unknown Command" unless command_pattern

          command_handler = self.class.get_handler(command_pattern)
          command_params = self.class.fetch_command_params(command_pattern, signature)        
          command_handler.bind(self).call(*command_params)
        end
      end
      
      def command(command_signature, &block)
        pattern = parse_signature(command_signature)  
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

      def fetch_command_params(pattern, signature)
        pattern.params(signature).values
      end

      def match_signature(signature)
        @commands.find {|p| p.match(signature)}
      end
      
      private

      def parse_signature(signature)
        @commands ||= []
        @commands << Mustermann.new(signature)
        @commands.last
      end    
    end
  end

  register Slack::Commands
end