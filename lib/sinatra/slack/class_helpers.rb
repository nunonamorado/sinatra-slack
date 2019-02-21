require "mustermann"

module Sinatra
  module Slack
    module ClassHelpers
      def self.extended(base_class)
        base_class.module_eval do
          def register_handler(signature, &block)
            pattern = parse_signature(signature)
            method_name = get_handler_name(pattern)
            define_method(method_name, &block)
          end

          def get_handler_name(pattern)
            "#{pattern.safe_string}_handler"
          end

          def get_handler(signature)
            pattern = get_pattern(signature)
            return unless pattern

            method_name = get_handler_name(pattern)
            instance_method method_name
          end

          def get_pattern(signature)
            @patterns.find {|p| p.match(signature)}
          end

          def parse_signature(signature)
            @patterns ||= []
            raise StandardError.new("Signature already defined") if get_pattern(signature)

            @patterns << Mustermann.new(signature)
            @patterns.last
          end
        end
      end
    end
  end
end
