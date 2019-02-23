# frozen_string_literal: true

require_relative './slack/instance_helpers'
require_relative './slack/signature_helpers'

# Sinatra
module Sinatra
  # Sinatra Module for creating Slack apps with ease
  module Slack
    def self.registered(app)
      app.helpers Slack::InstanceHelpers
      app.helpers Slack::SignatureHelpers

      Slack.send(:alias_method, :action, :register_handler)
      Slack.send(:alias_method, :command, :register_handler)
    end

    ##############################################################
    #  Go to this page for the verification process:             #
    #  https://api.slack.com/docs/verifying-requests-from-slack  #
    #                                                            #
    #                                                            #
    #  Defines a new before action for verifying all requests    #
    #  This should be called before any other                    #
    ##############################################################
    def verify_slack_request(secret: '')
      before do
        halt 401, 'Invalid Headers' unless valid_headers? ||
                                          compute_signature(secret) == slack_signature
      end
    end

    # Defines a new HTTP POST Handler to receive
    # Slash Command notifications.
    def commands_endpoint(path, defer: true, message: nil)
      settings.post(path) do
        signature = "#{command.command} #{command.text}"
        command_pattern = self.class.get_pattern(signature)

        halt 400 unless command_pattern

        request_handler = self.class.get_handler(signature)
        request_params = command_pattern.params(signature).values

        handle_request(defer, message, request_handler, request_params)
      end
    end

    # Defines a new HTTP POST Handler to receive
    # Actions notifications.
    def actions_endpoint(path, defer: true, message: nil)
      settings.post(path) do
        action_pattern = self.class.get_pattern(action.name)

        halt 400 unless action_pattern

        request_handler = self.class.get_handler(action.name)
        request_params = action_pattern.params(action.name).values || []
        request_params << action.value

        handle_request(defer, message, request_handler, request_params)
      end
    end

    ####################
    # Helper methods
    ####################
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
      @patterns.find { |p| p.match(signature) }
    end

    def parse_signature(signature)
      @patterns ||= []
      raise StandardError, 'Signature already defined' if get_pattern(signature)

      @patterns << Mustermann.new(signature)
      @patterns.last
    end
  end

  register Sinatra::Slack
end
