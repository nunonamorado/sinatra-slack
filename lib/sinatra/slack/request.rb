module Sinatra
  module Slack
    class Request
      attr_reader :context, :args
  
      def initialize(context, args)
        @context = context
        @args = args
      end
    end
  end
end