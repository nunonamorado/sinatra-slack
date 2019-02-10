module Sinatra
  module Slack
    class Request
      attr_reader :args
  
      def initialize(args)
        @context = context
        @args = args
      end

      
    end
  end
end