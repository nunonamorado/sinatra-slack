module Sinatra
  module Slack  
    class Command
      attr_reader :name, :args, :subcommands, :sub_cmd_handlers
      attr_accessor :handler
  
      def initialize(name, args = {})
        @name = name
        @args = args
        @subcommands = {}        
        @sub_cmd_handlers = {}
      end
  
      def with_subcommand(name, options = {}, &block)
        @subcommands[name] = {args: args}
        @sub_cmd_handlers[name] = block if block_given?
      end
    end
  end
end